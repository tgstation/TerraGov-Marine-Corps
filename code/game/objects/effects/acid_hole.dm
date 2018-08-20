/obj/effect/acid_hole
	name = "hole"
	desc = "What could have done this?"
	icon = 'icons/effects/new_acid.dmi'
	icon_state = "hole_0"
	anchored = 1
	unacidable = TRUE
	layer = LOWER_ITEM_LAYER
	var/turf/closed/wall/holed_wall

/obj/effect/acid_hole/New(loc)
	..()
	if(istype(loc, /turf/closed/wall))
		var/turf/closed/wall/W = loc
		W.acided_hole = src
		holed_wall = W
		holed_wall.opacity = 0
		if(W.junctiontype & (NORTH|SOUTH))
			dir = EAST
		if(W.junctiontype & (EAST|WEST))
			dir = SOUTH


/obj/effect/acid_hole/Dispose()
	if(holed_wall)
		holed_wall.opacity = initial(holed_wall.opacity)
		holed_wall.acided_hole = null
		holed_wall = null
	. = ..()

/obj/effect/acid_hole/ex_act(severity)
	return

/obj/effect/acid_hole/fire_act()
	return


/obj/effect/acid_hole/MouseDrop_T(mob/M, mob/user)
	if (!holed_wall)
		return

	if(M == user && isXeno(user))
		use_wall_hole(user)


/obj/effect/acid_hole/attack_alien(mob/living/carbon/Xenomorph/user)
	if(holed_wall)
		if(user.mob_size == MOB_SIZE_BIG)
			expand_hole(user)

/obj/effect/acid_hole/proc/expand_hole(mob/living/carbon/Xenomorph/user)
	if(user.action_busy || user.lying)
		return

	playsound(src, 'sound/effects/metal_creaking.ogg', 25, 1)
	if(do_after(user,60, FALSE, 5, BUSY_ICON_GENERIC) && !disposed && holed_wall && !user.lying)
		holed_wall.take_damage(rand(2000,3500))
		user.emote("roar")

/obj/effect/acid_hole/proc/use_wall_hole(mob/user)

	if(user.mob_size == MOB_SIZE_BIG || user.is_mob_incapacitated() || user.lying || user.buckled || user.anchored)
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

	if(user.action_busy)
		return

	to_chat(user, "<span class='notice'>You start crawling through the hole.</span>")

	if(do_after(user, 15, FALSE, 5, BUSY_ICON_GENERIC))
		if(!user.is_mob_incapacitated() && !user.lying && !user.buckled)
			if (T.density)
				return
			for(var/obj/O in T)
				if(!O.CanPass(user, user.loc))
					return
			if(user.pulling)
				user.stop_pulling()
				to_chat(user, "<span class='warning'>You release what you're pulling to fit into the tunnel!</span>")
			user.forceMove(T)




//Throwing Shiet
/obj/effect/acid_hole/attackby(obj/item/W, mob/user)

	var/mob_dir = get_dir(user, src)
	var/crawl_dir = dir & mob_dir
	if(!crawl_dir)
		crawl_dir = turn(dir,180) & mob_dir
	if(!crawl_dir)
		return
	var/turf/Target = get_step(src, crawl_dir)

	//Throwing Grenades
	if(istype(W,/obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/G = W

		if(!Target ||Target.density)
			to_chat(user, "<span class='warning'>This hole leads nowhere!</span>")
			return

		to_chat(user, "<span class='notice'>You take the position to throw [G].</span>")
		if(do_after(user,10, TRUE, 5, BUSY_ICON_HOSTILE))
			if(Target.density)
				return
			user.visible_message("<span class='warning'>[user] throws [G] through [src]!</span>", \
								 "<span class='warning'>You throw [G] through [src]</span>")
			user.drop_held_item()
			G.forceMove(Target)
			G.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step_away(G,src,rand(2,5))
			if(!G.active)
				G.activate(user)
		return

	//Throwing Flares and flashlights
	else if(istype(W,/obj/item/device/flashlight))
		var/obj/item/device/flashlight/F = W

		if(!Target ||Target.density)
			to_chat(user, "<span class='warning'>This hole leads nowhere!</span>")
			return

		to_chat(user, "<span class='notice'>You take the position to throw [F].</span>")
		if(do_after(user,10, TRUE, 5, BUSY_ICON_HOSTILE))
			if(Target.density)
				return
			user.visible_message("<span class='warning'>[user] throws [F] through [src]!</span>", \
								 "<span class='warning'>You throw [F] through [src]</span>")
			user.drop_held_item()
			F.forceMove(Target)
			F.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step_away(F,src,rand(1,5))
			F.SetLuminosity(0)
			if(F.on && loc != user)
				F.SetLuminosity(F.brightness_on)
		return
