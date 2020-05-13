/obj/effect/acid_hole
	name = "hole"
	desc = "What could have done this? Something agile enough could probably climb through."
	icon = 'icons/effects/new_acid.dmi'
	icon_state = "hole_0"
	anchored = TRUE
	resistance_flags = UNACIDABLE|INDESTRUCTIBLE
	layer = LOWER_ITEM_LAYER
	var/turf/closed/wall/holed_wall

/obj/effect/acid_hole/Initialize()
	. = ..()
	if(iswallturf(loc))
		var/turf/closed/wall/W = loc
		W.acided_hole = src
		holed_wall = W
		holed_wall.opacity = FALSE
		if(W.junctiontype & (NORTH|SOUTH))
			setDir(EAST)
		if(W.junctiontype & (EAST|WEST))
			setDir(SOUTH)


/obj/effect/acid_hole/Destroy()
	if(holed_wall)
		holed_wall.opacity = initial(holed_wall.opacity)
		holed_wall.acided_hole = null
		holed_wall = null
	. = ..()


/obj/effect/acid_hole/fire_act()
	return


/obj/effect/acid_hole/MouseDrop_T(mob/M, mob/user)
	if (!holed_wall)
		return

	if(M == user && isxeno(user))
		use_wall_hole(user)


/obj/effect/acid_hole/specialclick(mob/living/carbon/user)
	if(!isxeno(user))
		return
	if(holed_wall)
		if(user.mob_size == MOB_SIZE_BIG)
			expand_hole(user)
			return
		use_wall_hole(user)

/obj/effect/acid_hole/proc/expand_hole(mob/living/carbon/xenomorph/user)
	if(user.action_busy || user.lying_angle)
		return

	playsound(src, 'sound/effects/metal_creaking.ogg', 25, 1)
	if(do_after(user,60, FALSE, holed_wall, BUSY_ICON_HOSTILE) && !QDELETED(src) && !user.lying_angle)
		holed_wall.take_damage(rand(2000,3500))
		user.emote("roar")

/obj/effect/acid_hole/proc/use_wall_hole(mob/user)

	if(user.mob_size == MOB_SIZE_BIG || user.incapacitated() || user.lying_angle || user.buckled || user.anchored)
		return

	var/mob_dir = get_dir(user, src)
	var/crawl_dir = dir & mob_dir
	if(!crawl_dir)
		crawl_dir = turn(dir,180) & mob_dir
	if(!crawl_dir)
		return

	var/entrance_dir = crawl_dir ^ mob_dir

	var/turf/T = get_step(src, crawl_dir)

	if (!T || T.density)
		to_chat(user, "This hole leads nowhere!")
		return

	if(entrance_dir)
		if(!step(user, entrance_dir))
			to_chat(user, "<span class='warning'>You can't reach the hole's entrance.</span>")
			return

	for(var/obj/O in T)
		if(!O.CanPass(user, user.loc))
			to_chat(user, "<span class='warning'>The hole's exit is blocked by something!</span>")
			return

	if(locate(/obj/machinery/door/poddoor/timed_late/containment) in get_turf(src))
		to_chat(user, "<span class='warning'>You can't reach the hole's entrance under the shutters.</span>")
		return

	if(user.action_busy)
		return

	to_chat(user, "<span class='notice'>You start crawling through the hole.</span>")

	if(do_after(user, 15, FALSE, src, BUSY_ICON_HOSTILE) && !T.density && !user.lying_angle && !user.buckled)
		for(var/obj/O in T)
			if(!O.CanPass(user, user.loc))
				return
		if(user.pulling)
			user.stop_pulling()
			to_chat(user, "<span class='warning'>You release what you're pulling to fit into the tunnel!</span>")
		user.forceMove(T)




//Throwing Shiet
/obj/effect/acid_hole/attackby(obj/item/I, mob/user, params)
	. = ..()

	var/mob_dir = get_dir(user, src)
	var/crawl_dir = dir & mob_dir
	if(!crawl_dir)
		crawl_dir = turn(dir, 180) & mob_dir
	if(!crawl_dir)
		return

	var/turf/T = get_step(src, crawl_dir)

	//Throwing Grenades
	if(istype(I, /obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/G = I

		if(!T || T.density)
			to_chat(user, "<span class='warning'>This hole leads nowhere!</span>")
			return

		to_chat(user, "<span class='notice'>You take the position to throw [G].</span>")

		if(!do_after(user, 10, TRUE, src, BUSY_ICON_HOSTILE) || !T || T.density)
			return

		user.visible_message("<span class='warning'>[user] throws [G] through [src]!</span>", \
							"<span class='warning'>You throw [G] through [src]</span>")
		user.drop_held_item()
		G.forceMove(T)
		G.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		step_away(G, src, rand(2,5))
		if(!G.active)
			G.activate(user)

	//Throwing Flares and flashlights
	else if(istype(I, /obj/item/flashlight))
		var/obj/item/flashlight/F = I

		if(!T || T.density)
			to_chat(user, "<span class='warning'>This hole leads nowhere!</span>")
			return

		to_chat(user, "<span class='notice'>You take the position to throw [F].</span>")

		if(!do_after(user,10, TRUE, src, BUSY_ICON_GENERIC) || !T || T.density)
			return

		user.visible_message("<span class='warning'>[user] throws [F] through [src]!</span>", \
							"<span class='warning'>You throw [F] through [src]</span>")
		user.drop_held_item()
		F.forceMove(T)
		F.setDir(pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		step_away(F, src, rand(1,5))
		if(F.on && loc != user)
			F.set_light(F.brightness_on)
		else
			F.set_light(0)
