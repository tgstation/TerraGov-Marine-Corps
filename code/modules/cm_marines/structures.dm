
/obj/structure/m_barricade
	name = "metal barricade"
	desc = "A solid barricade made of reinforced metal. Use a welding tool to repair it if damaged."
	icon = 'icons/Marine/structures.dmi'
	icon_state = "barricade2"
	density = 1
	anchored = 1.0
	layer = 2.9
	throwpass = 1 //You can throw objects over this, despite its density.
	climbable = 1
	unacidable = 0 //Who the fuck though unacidable barricades with 500 health was a good idea?
	flags_atom = ON_BORDER

	var/health = 500 //Pretty tough. Changes sprites at 300 and 150
	var/maxhealth = 500 //Basic code functions
	var/state = 2 //2 is fully secured, 1 is after screw, 0 is after wrench. Crowbar disassembles
	var/tool_cooldown = 0 //Delay to apply tools to prevent spamming
	var/busy = 0 //Standard busy check

/obj/structure/m_barricade/New()
	..()
	spawn()
		update_icon()

/obj/structure/m_barricade/examine(mob/user as mob)
	..()
	switch(health/maxhealth * 100)
		if(60.1 to INFINITY)
			user << "<span class='info'>It appears to be in good shape.</span>"
		if(30.1 to 60)
			user << "<span class='warning'>It's quite beat up, but it's holding together.</span>"
		if(0 to 30)
			user << "<span class='warning'>It's crumbling apart, just a few more blows will tear it apart.</span>"
	switch(state)
		if(2)
			user << "<span class='info'>The protection panel is still tighly screwed in place.</span>"
		if(1)
			user << "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>"
		if(0)
			user << "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>"

/obj/structure/m_barricade/update_icon()
	if(dir == SOUTH)
		layer = 5
	icon_state = initial(icon_state)
	switch(health/maxhealth * 100)
		if(30.1 to 60) //Lowest division is 0.2 %, 1/500th
			icon_state += "_dmg1"
		if(0 to 30)
			icon_state += "_dmg2"

/obj/structure/m_barricade/proc/update_health()

	health = Clamp(health, 0, maxhealth)

	if(!health)
		destroy()
		return

	update_icon()

/obj/structure/m_barricade/CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover)) //Tables let you climb on barricades.
		return 1
	if(get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/structure/m_barricade/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(O)) //Tables let you climb on barricades.
		return 1
	if(get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/structure/m_barricade/attackby(obj/item/W as obj, mob/user as mob)

	if(iswelder(W))
		if(busy || tool_cooldown > world.time)
			return
		tool_cooldown = world.time + 10
		var/obj/item/weapon/weldingtool/WT = W
		if(health <= maxhealth * 0.3)
			user << "<span class='warning'>[src] has sustained too much structural damage to be repaired.</span>"
			return

		if(health == maxhealth)
			user << "<span class='warning'>[src] doesn't need repairs.</span>"
			return

		if(WT.remove_fuel(0, user))
			user.visible_message("<span class='notice'>[user] begins repairing damage to [src].</span>",
			"<span class='notice'>You begin repairing the damage to [src].</span>")
			playsound(src.loc, 'sound/items/Welder2.ogg', 75, 1)
			busy = 1
			if(do_after(user, 50))
				busy = 0
				user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
				"<span class='notice'>You repair [src].</span>")
				health += 150
				update_health()
				playsound(src.loc, 'sound/items/Welder2.ogg', 75, 1)
			else busy = 0
		return

	switch(state)
		if(2) //Fully constructed step. Use screwdriver to remove the protection panels to reveal the bolts
			if(isscrewdriver(W))
				if(busy || tool_cooldown > world.time)
					return
				tool_cooldown = world.time + 10
				user.visible_message("<span class='notice'>[user] removes [src]'s protection panel.</span>",
				"<span class='notice'>You remove [src]'s protection panels, exposing the anchor bolts.</span>")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				state = 1
				return
		if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
			if(isscrewdriver(W))
				if(busy || tool_cooldown > world.time)
					return
				tool_cooldown = world.time + 10
				user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
				"<span class='notice'>You set [src]'s protection panel back.</span>")
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
				state = 2
				return
			if(iswrench(W))
				if(busy || tool_cooldown > world.time)
					return
				tool_cooldown = world.time + 10
				user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
				"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				state = 0
				return
		if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
			if(iswrench(W))
				if(busy || tool_cooldown > world.time)
					return
				tool_cooldown = world.time + 10
				user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
				"<span class='notice'>You secure [src]'s anchor bolts.</span>")
				playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
				state = 1
				return
			if(iscrowbar(W))
				if(busy || tool_cooldown > world.time)
					return
				tool_cooldown = world.time + 10
				user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
				"<span class='notice'>You start unseating [src]'s panels.</span>")
				playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
				busy = 1
				if(do_after(user, 50))
					busy = 0
					user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
					"<span class='notice'>You take [src]'s panels apart.</span>")
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					destroy() //Note : Handles deconstruction too !
				else busy = 0
				return

	//Otherwise, just hit it.
	if(force > 20)
		..()
		health -= W.force / 2
		update_health()

/obj/structure/m_barricade/destroy()
	var/sheet_amount = round(5 * (health/maxhealth)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0
	if(sheet_amount) //Sheet code is a dumb puppy
		var/obj/item/stack/sheet/plasteel/P = new(loc)
		P.amount = sheet_amount
	density = 0
	cdel(src)

/obj/structure/m_barricade/ex_act(severity)
	switch(severity)
		if(1)
			health -= rand(400, 600)
		if(2)
			health -= rand(150, 350)
		if(3)
			health -= rand(50, 100)

	update_health()

/obj/structure/sign/ROsign
	name = "\improper USCM Requisitions Office Directives"
	desc = "OFFICIAL RULES OF THE USCM REQUISITIONS OFFICE\n 1.You are not entitled to service or equipment. Attachments are a privilege, not a right.\n 2. Only two attachments per marine. Squad leaders and specialists may be issued three attachments. \n 3.Webbing is to be only distributed to engineers, medics and, at a lower priority, specialists and squad leaders.\n 4. You must be fully dressed to obtain service. Cyrosleep underwear is non-permissible.\n 5.The Requsitions Officer has the final say and the right to decline service. Only the command staff may override his decisions.\n 6.Please treat your Requsitions Officer with respect. They work hard."
	icon_state = "roplaque"

/obj/structure/sign/prop1
	name = "\improper USCM Poster"
	desc = "The symbol of the United States Colonial Marines corps."
	icon_state = "prop1"

/obj/structure/sign/prop2
	name = "\improper USCM Poster"
	desc = "A deeply faded poster of a group of glamorous Colonial Marines in uniform. Probably taken pre-Alpha."
	icon_state = "prop2"

/obj/structure/sign/prop3
	name = "\improper USCM Poster"
	desc = "An old recruitment poster for the USCM. Looking at it floods you with a mixture of pride and sincere regret."
	icon_state = "prop3"
