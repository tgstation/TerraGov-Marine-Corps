
/obj/structure/m_barricade
	name = "metal barricade"
	desc = "A solid barricade made of reinforced metal. Use a welding tool and/or plasteel to repair it if damaged."
	icon = 'icons/Marine/structures.dmi'
	icon_state = "barricade"
	density = 1
	anchored = 1.0
	layer = 2.9
	throwpass = 1	//You can throw objects over this, despite its density.
	climbable = 1
	flags = ON_BORDER
	var/health = 500 //Pretty tough. Changes sprites at 300 and 150.
	unacidable = 0 //Who the fuck though unacidable barricades with 500 health was a good idea?


/obj/structure/m_barricade/update_icon()
	if(health < 300 && health > 150)
		icon_state = "barricade_dmg1"
	else if(health <= 150)
		icon_state = "barricade_dmg2"
	else
		icon_state = initial(icon_state)

/obj/structure/m_barricade/proc/update_health()
	if(health < 0)
		destroy()
		return

	if(health > 500) health = 500
	update_icon()
	return

/obj/structure/m_barricade/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(mover)) //Tables let you climb on barricades.
		return 1
	if (get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/structure/m_barricade/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O) && O.checkpass(PASSTABLE))
		return 1
	if(locate(/obj/structure/table) in get_turf(O)) //Tables let you climb on barricades.
		return 1
	if (get_dir(loc, target) == dir)
		return 0
	else
		return 1

/obj/structure/m_barricade/attackby(obj/item/W as obj, mob/user as mob)
	if (!W) return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(health < 150)
			user << "It's too damaged for that. Better just to build a new one."
			return

		if(health >= 500)
			user << "It's already in perfect condition."
			return

		if(WT.remove_fuel(0, user))
			user.visible_message("\blue [user] begins repairing damage to the [src].","\blue You begin repairing the damage to the [src].")
			if(do_after(user,50))
				user.visible_message("\blue [user] repairs the damaged [src].","\blue Your repair the [src]'s damage.")
				health += 150
				if(health > 500) health = 500
				update_health()
				playsound(src.loc, 'sound/items/Welder2.ogg', 75, 1)
				return
		return

	//Otherwise, just hit it.
	if(force > 20)
		..()
		health -= W.force / 2
		update_health()
		return

	return

/obj/structure/m_barricade/destroy()
	src.visible_message("\red [src] collapses!")
	var/obj/item/stack/sheet/plasteel/P = new (src.loc)
	P.amount = pick(3,4)
	density = 0
	del(src)
	return

/obj/structure/m_barricade/ex_act(severity)
	switch(severity)
		if(1.0)
			health -= rand(150,500)
		if(2.0)
			health -= rand(150,350)
		if(3.0)
			health -= rand(50,100)

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