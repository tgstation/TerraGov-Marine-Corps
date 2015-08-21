
/obj/structure/m_barricade
	name = "metal barricade"
	desc = "A solid barricade made of reinforced metal. Use a welding tool and/or plasteel to repair it if damaged."
	icon = 'icons/Marine/structures.dmi'
	icon_state = "barricade"
	density = 1
	anchored = 1.0
	layer = 3.5
	throwpass = 1	//You can throw objects over this, despite its density.
	climbable = 1
	flags = ON_BORDER
	var/health = 500 //Pretty tough. Changes sprites at 300 and 150.
	unacidable = 1


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
	if(istype(mover,/obj/item/projectile/bullet))
		return (check_cover(mover,target))
	if(locate(/obj/structure/table) in get_turf(mover)) //Tables let you climb on barricades.
		return 1
	if (get_dir(loc, target) == dir)
		return 0
	else
		return 1

	return 0

//checks if projectile 'P' from turf 'from' can hit whatever is behind the table. Returns 1 if it can, 0 if bullet stops.
/obj/structure/m_barricade/proc/check_cover(obj/item/projectile/P, turf/from)
	var/turf/cover = get_step(loc, get_dir(from, loc))
	if (get_dist(P.starting, loc) <= 1)
		return 1
	if (get_turf(P.original) == cover)
		var/chance = 25
		if (ismob(P.original))
			var/mob/M = P.original
			if (M.lying)
				chance += 20
			if(get_dir(loc, from) == dir)
				chance += 70
			else
				return 1
		if(prob(chance))
			health -= P.damage/2
			visible_message("<span class='warning'>[P] hits \the [src]!</span>")
			update_health()
			return 0

	return 1

/obj/structure/m_barricade/CheckExit(atom/movable/O as mob|obj, target as turf)
	if (get_dir(loc, target) == dir && !istype(O,/obj/item/projectile/bullet) && !istype(O,/obj/item/missile) && !istype(O,/obj/item/weapon/grenade))
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
	P.amount = 5
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
