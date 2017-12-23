/obj/effects/acid_hole
	name = "hole"
	desc = "What could have done this?"
	icon = 'icons/effects/new_acid.dmi'
	icon_state = "hole_1"
	unacidable = 1
	invisibility = 101

	var/size = 1
	var/mob/userLooking
	var/busy = FALSE
	var/obj/machinery/camera/cam

/obj/effects/acid_hole/New()
	update_hole_icon()
	cam = new /obj/machinery/camera(src)
	cam.network = list("LADDER")
	cam.c_tag = name
	cam.layer = 0

/obj/effects/acid_hole/proc/update_hole_icon()
	var/turf/simulated/wall/W =  loc
	var/jt = W.junctiontype

	if(jt == 12 || jt == 4 || jt == 8)
		icon_state = "hole_0"
		W.overlays += image("icon"='icons/effects/new_acid.dmi',"icon_state"="hole_0","layer"=MOB_LAYER-0.1)
	else if (jt == 1 || jt == 2 || jt == 3)
		icon_state = "hole_1"
		W.overlays += image("icon"='icons/effects/new_acid.dmi',"icon_state"="hole_1","layer"=MOB_LAYER-0.1)

/turf/simulated/wall/proc/GetHole()
	var/obj/effects/acid_hole/toReturn
	for (var/obj/effects/acid_hole/x in contents)
		toReturn = x
	return toReturn


/turf/simulated/wall/MouseDrop_T(mob/I, mob/user)
	var/obj/effects/acid_hole/Hole = GetHole()
	if (!Hole)
		return

	var/Target
	var/Entry

	if (!istype(I, /mob) || !isXeno(user))
		return

	if (Hole.size == 1)
		if (I.mob_size == MOB_SIZE_BIG)
			return

	var/_dir = get_dir(I, src)
	if(Hole.icon_state == "hole_0")
		if (_dir == NORTH || _dir == NORTHEAST || _dir == NORTHWEST)
			Entry = get_step(src, SOUTH)
			Target = get_step(src, NORTH)
		else if (_dir == SOUTH || _dir == SOUTHWEST || _dir == SOUTHEAST)
			Entry = get_step(src, NORTH)
			Target = get_step(src, SOUTH)
	else if (Hole.icon_state == "hole_1")
		if (_dir == EAST || _dir == SOUTHEAST || _dir == NORTHEAST )
			Entry = get_step(src, WEST)
			Target = get_step(src, EAST)
		else if (_dir == WEST || _dir == SOUTHWEST || _dir == NORTHWEST)
			Entry = get_step(src, EAST)
			Target = get_step(src, WEST)

	step(I, get_dir(I, Entry))
	Hole.busy = TRUE

	if (Hole.userLooking)
		Hole.userLooking << "Something is coming through the tunnel!"
		Hole.userLooking.reset_view(null)
		Hole.userLooking = null

	if(do_after(user, 20, FALSE, 5, BUSY_ICON_CLOCK))
		if(!user.is_mob_incapacitated() && get_dist(user, src) <= 1 && !user.blinded && !user.lying && !user.buckled)
			I.loc = Target
			if(I.pulling && get_dist(src, user.pulling) <= 2)
				if(ismob(I.pulling))
					var/mob/pulled_mob = I.pulling
					if (pulled_mob && pulled_mob.mob_size == MOB_SIZE_BIG)
						user << "The thing you were pulling was too big for the tunnel!"
						Hole.busy = FALSE
						return
				user.pulling.loc = Target
				if(isobj(I.pulling))
					var/obj/O = I.pulling
					if(O.buckled_mob)
						O.buckled_mob.loc = Target
		Hole.busy = FALSE

/turf/simulated/wall/MouseDrop(over_object, src_location, over_location)
	if((over_object == usr && (in_range(src, usr))))
		var/Target
		var/obj/effects/acid_hole/Hole = GetHole()
		if (isXeno(usr))
			return
		if (!Hole)
			return

		var/_dir = get_dir(usr, src)

		if(Hole.icon_state == "hole_0")
			if (_dir == NORTH || _dir == NORTHEAST || _dir == NORTHWEST)
				Target = get_step(src, NORTH)
			else if (_dir == SOUTH || _dir == SOUTHWEST || _dir == SOUTHEAST)
				Target = get_step(src, SOUTH)
		else if (Hole.icon_state == "hole_1")
			if (_dir == EAST || _dir == SOUTHEAST || _dir == NORTHEAST )
				Target = get_step(src, EAST)
			else if (_dir == WEST || _dir == SOUTHWEST || _dir == NORTHWEST)
				Target = get_step(src, WEST)

		if(do_after(usr, 10, FALSE, 5, BUSY_ICON_CLOCK))
			usr.visible_message("<span class='notice'>[usr] looks through [src]!</span>", \
			"<span class='notice'>You look through [src]!</span>")
			usr.set_interaction(src)
			Hole.cam.loc = Target
			usr.reset_view(Hole.cam)
			Hole.userLooking = usr

//Throwing Shiet
/obj/effects/acid_hole/attackby(obj/item/W, mob/user)
	var/Target
	//Throwing Grenades
	var/_dir = get_dir(user, src)
	if(icon_state == "hole_0")
		if (_dir == NORTH || _dir == NORTHEAST || _dir == NORTHWEST)
			Target = get_step(src, NORTH)
		else if (_dir == SOUTH || _dir == SOUTHWEST || _dir == SOUTHEAST)
			Target = get_step(src, SOUTH)
	else if (icon_state == "hole_1")
		if (_dir == EAST || _dir == SOUTHEAST || _dir == NORTHEAST )
			Target = get_step(src, EAST)
		else if (_dir == WEST || _dir == SOUTHWEST || _dir == NORTHWEST)
			Target = get_step(src, WEST)

	if(istype(W,/obj/item/explosive/grenade))
		var/obj/item/explosive/grenade/G = W

		user << "You take the position to throw the [G]."
		if(do_after(user,10, TRUE, 5, BUSY_ICON_CLOCK))
			user.visible_message("<span class='warning'>[user] throws [G] through [src]!</span>", \
								 "<span class='warning'>You throw [G] through [src]</span>")
			user.drop_held_item()
			G.loc = get_turf(Target)
			G.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step_away(G,src,rand(1,5))
			if(!G.active)
				G.activate(user)

	//Throwing Flares and flashlights
	else if(istype(W,/obj/item/device/flashlight))
		var/obj/item/device/flashlight/F = W

		user << "You take the position to throw the [F]."
		if(do_after(user,10, TRUE, 5, BUSY_ICON_CLOCK))
			user.visible_message("<span class='warning'>[user] throws [F] through [src]!</span>", \
								 "<span class='warning'>You throw [F] through [src]</span>")
			user.drop_held_item()
			F.loc = get_turf(Target)
			F.dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step_away(F,src,rand(1,5))
			F.SetLuminosity(0)
			if(F.on && loc != user)
				F.SetLuminosity(F.brightness_on)
	else
		return attack_hand(user)