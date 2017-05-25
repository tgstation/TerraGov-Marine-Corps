//barricades
//metal, wooden, snadbags, snow.


/obj/structure/barricade
	climbable = TRUE
	anchored = TRUE
	density = 1
	throwpass = TRUE //You can throw objects over this, despite its density.
	layer = OBJ_LAYER - 0.1
	var/stack_type //the type of stack the barricade dropped when disassembled if any.
	var/stack_amount = 5 //the amount of stack dropped when disassembled
	var/always_drop_stack = FALSE //whether the amount of stack dropped is independent of the health.
	var/health = 100 //Pretty tough. Changes sprites at 300 and 150
	var/maxhealth = 100 //Basic code functions
	var/crusher_resistant = FALSE //whether a crusher can ram through it.
	var/barricade_resistance = 5 //how much force an item needs to even damage it at all.
	var/barricade_hitsound

	New()
		..()
		update_icon()

	examine(mob/user)
		..()
		switch(health/maxhealth * 100)
			if(60.1 to INFINITY)
				user << "<span class='info'>It appears to be in good shape.</span>"
			if(30.1 to 60)
				user << "<span class='warning'>It's quite beat up, but it's holding together.</span>"
			if(0 to 30)
				user << "<span class='warning'>It's crumbling apart, just a few more blows will tear it apart.</span>"

	Crossed(atom/movable/AM)
		..()
		if(!crusher_resistant && istype(AM, /mob/living/carbon/Xenomorph/Crusher))
			var/mob/living/carbon/Xenomorph/Crusher/C = AM
			if(!C.stat)
				visible_message("<span class='danger'>[C] steamrolls through [src]!</span>")
				destroy()

	CheckExit(atom/movable/O, turf/target)
		if(istype(O) && O.checkpass(PASSTABLE))
			return 1
		var/obj/structure/table/T = locate() in get_turf(O)
		if(T && !T.flipped) //Non-flipped tables let you climb on barricades.
			return 1
		if((flags_atom & ON_BORDER) && get_dir(loc, target) == dir)
			return 0
		else
			return 1

	CanPass(atom/movable/mover, turf/target, height = 0, air_group = 0)
		if(istype(mover) && mover.checkpass(PASSTABLE))
			return 1
		var/obj/structure/table/T = locate() in get_turf(mover)
		if(T && !T.flipped) //Non-flipped tables let you climb on barricades.
			return 1
		if(!(flags_atom & ON_BORDER) || get_dir(loc, target) == dir)
			return 0
		else
			return 1

	update_icon()
		if(flags_atom & ON_BORDER)
			if(dir == SOUTH) layer = MOB_LAYER + 1
			else layer = initial(layer)
			icon_state = initial(icon_state)
			switch(health/maxhealth * 100)
				if(30.1 to 60) //Lowest division is 0.2 %, 1/500th
					icon_state += "_dmg1"
				if(0 to 30)
					icon_state += "_dmg2"

	attackby(obj/item/W, mob/user)
		if(W.force > barricade_resistance)
			..()
			if(barricade_hitsound)
				playsound(src, barricade_hitsound, 25, 1)
			hit_barricade(W)

	destroy()
		if(stack_type)
			var/stack_amount
			if(always_drop_stack) stack_amount = stack_amount
			else stack_amount = round(stack_amount * (health/maxhealth)) //Get an amount of sheets back equivalent to remaining health. Obviously, fully destroyed means 0

			if(stack_amount) new stack_type (loc, stack_amount)
		cdel(src)

	ex_act(severity)
		switch(severity)
			if(1.0)
				visible_message("<span class='danger'>[src] is blown apart!</span>")
				cdel(src)
				return
			if(2.0)
				health -= rand(30,60)
			if(3.0)
				health -= rand(10,30)
		update_health()

/obj/structure/barricade/proc/hit_barricade(obj/item/I)
	health -= I.force * 0.5
	update_health()

/obj/structure/barricade/proc/update_health(nomessage)
	health = Clamp(health, 0, maxhealth)
	if(!health)
		if(!nomessage)
			visible_message("<span class='danger'>[src] falls apart!</span>")
		destroy()
		return
	update_icon()


//metal barricade

/obj/structure/barricade/metal
	name = "metal barricade"
	desc = "A solid barricade made of reinforced metal. Use a welding tool to repair it if damaged."
	icon = 'icons/Marine/structures.dmi'
	icon_state = "barricade2"
	flags_atom = ON_BORDER
	health = 500
	maxhealth = 500
	crusher_resistant = TRUE
	barricade_resistance = 20
	stack_type = /obj/item/stack/sheet/plasteel
	barricade_hitsound = "sound/effects/metalhit.ogg"
	var/state = 2 //2 is fully secured, 1 is after screw, 0 is after wrench. Crowbar disassembles
	var/tool_cooldown = 0 //Delay to apply tools to prevent spamming
	var/busy = 0 //Standard busy check

	examine(mob/user)
		..()
		switch(state)
			if(2)
				user << "<span class='info'>The protection panel is still tighly screwed in place.</span>"
			if(1)
				user << "<span class='info'>The protection panel has been removed, you can see the anchor bolts.</span>"
			if(0)
				user << "<span class='info'>The protection panel has been removed and the anchor bolts loosened. It's ready to be taken apart.</span>"



	attackby(obj/item/W, mob/user)

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
				playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
				busy = 1
				if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
					busy = 0
					user.visible_message("<span class='notice'>[user] repairs some damage on [src].</span>",
					"<span class='notice'>You repair [src].</span>")
					health += 150
					update_health()
					playsound(src.loc, 'sound/items/Welder2.ogg', 25, 1)
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
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
					state = 1
					return
			if(1) //Protection panel removed step. Screwdriver to put the panel back, wrench to unsecure the anchor bolts
				if(isscrewdriver(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] set [src]'s protection panel back.</span>",
					"<span class='notice'>You set [src]'s protection panel back.</span>")
					playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, 1)
					state = 2
					return
				if(iswrench(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] loosens [src]'s anchor bolts.</span>",
					"<span class='notice'>You loosen [src]'s anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					state = 0
					return
			if(0) //Anchor bolts loosened step. Apply crowbar to unseat the panel and take apart the whole thing. Apply wrench to rescure anchor bolts
				if(iswrench(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] secures [src]'s anchor bolts.</span>",
					"<span class='notice'>You secure [src]'s anchor bolts.</span>")
					playsound(src.loc, 'sound/items/Ratchet.ogg', 25, 1)
					state = 1
					return
				if(iscrowbar(W))
					if(busy || tool_cooldown > world.time)
						return
					tool_cooldown = world.time + 10
					user.visible_message("<span class='notice'>[user] starts unseating [src]'s panels.</span>",
					"<span class='notice'>You start unseating [src]'s panels.</span>")
					playsound(src.loc, 'sound/items/Crowbar.ogg', 25, 1)
					busy = 1
					if(do_after(user, 50, TRUE, 5, BUSY_ICON_CLOCK))
						busy = 0
						user.visible_message("<span class='notice'>[user] takes [src]'s panels apart.</span>",
						"<span class='notice'>You take [src]'s panels apart.</span>")
						playsound(loc, 'sound/items/Deconstruct.ogg', 25, 1)
						destroy() //Note : Handles deconstruction too !
					else busy = 0
					return

		. = ..()

	ex_act(severity)
		switch(severity)
			if(1)
				health -= rand(400, 600)
			if(2)
				health -= rand(150, 350)
			if(3)
				health -= rand(50, 100)

		update_health()

	bullet_act(obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/10)
		if (health < 0)
			visible_message("<span class='warning'>[src] breaks down!</span>")
			destroy()
		return 1



// SANDBAGS BARRICADE

/obj/structure/barricade/sandbags
	name = "sandbag barricade"
	desc = "Trusted since 1914"
	icon = 'icons/Marine/structures.dmi'
	icon_state = "sandbag"
	flags_atom = ON_BORDER
	barricade_resistance = 15
	health = 250
	maxhealth = 250
	stack_type = /obj/item/stack/sandbags

	attackby(obj/item/W, mob/user)
		if(istype(W, /obj/item/weapon/etool) && user.a_intent != "harm")
			var/obj/item/weapon/etool/ET = W
			if(!ET.folded)
				user.visible_message("<span class='notice'>[user] starts disassembling [src].</span>",
					"<span class='notice'>You start disassembling [src].</span>")
				if(do_after(user, 30, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("<span class='notice'>[user] disassembles [src].</span>",
						"<span class='notice'>You disassemble [src].</span>")
					destroy()
			return 1
		else
			. = ..()


	bullet_act(obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/10)
		if (health < 0)
			visible_message("<span class='warning'>[src] breaks down!</span>")
			destroy()
		return 1



//Snow barricade----------
/obj/structure/barricade/snow
	name = "snow barricade"
	desc = "It could be worse..."
	icon = 'icons/turf/snowbarricade.dmi'
	icon_state = "barricade_3"
	health = 50 //Actual health depends on snow layer
	maxhealth = 50

	//Item Attack
	attackby(obj/item/W as obj, mob/user as mob)
		//Removing the barricades
		if(istype(W, /obj/item/snow_shovel))
			var/obj/item/snow_shovel/S = W
			if(S.mode == 2)
				if(S.working)
					user  << "\red You are already shoveling!"
					return
				user.visible_message("[user.name] starts clearing out \the [src].","You start removing \the [src].")
				S.working = 1
				if(!do_after(user,100, TRUE, 5, BUSY_ICON_CLOCK))
					user.visible_message("\red \The [user] decides not to clear out \the [src] anymore.")
					S.working = 0
					return
				user.visible_message("\blue \The [user] clears out \the [src].")
				S.working = 0
				cdel(src)
			return

		. = ..()


	hit_barricade(obj/item/I)
		switch(I.damtype)
			if("fire")
				health -= I.force * 0.6
			if("brute")
				health -= I.force * 0.3

		update_health()






//WOODEN BARRICADE

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	health = 250
	maxhealth = 250
	layer = OBJ_LAYER
	climbable = FALSE
	throwpass = FALSE
	stack_type = /obj/item/stack/sheet/wood
	stack_amount = 3
	always_drop_stack = TRUE
	barricade_hitsound = "sound/effects/woodhit.ogg"

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/stack/sheet/wood))
			var/obj/item/stack/sheet/wood/D = W
			if (health < maxhealth)
				if (D.get_amount() < 1)
					user << "<span class='warning'>You need one plank of wood to repair [src].</span>"
					return
				visible_message("<span class='notice'>[user] begins to repair [src].</span>")
				if(do_after(user,20, TRUE, 5, BUSY_ICON_CLOCK) && health < maxhealth)
					if (D.use(1))
						health = maxhealth
						visible_message("<span class='notice'>[user] repairs [src].</span>")
			return
		. = ..()

	hit_barricade(obj/item/I)
		switch(I.damtype)
			if("fire")
				health -= I.force * 1
			if("brute")
				health -= I.force * 0.75
		update_health()

	bullet_act(var/obj/item/projectile/P)
		bullet_ping(P)
		health -= round(P.damage/2) //Not that durable.
		update_health()
		return 1
