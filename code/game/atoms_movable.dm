/atom/movable
	layer = OBJ_LAYER
	var/last_move = null
	var/last_move_time = 0
	var/anchored = FALSE
	var/drag_delay = 3 //delay (in deciseconds) added to mob's move_delay when pulling it.
	var/throwing = FALSE
	var/thrower = null
	var/turf/throw_source = null
	var/throw_speed = 2
	var/throw_range = 7
	var/mob/pulledby = null
	var/atom/movable/pulling
	var/moving_diagonally = 0 //to know whether we're in the middle of a diagonal move,
	var/atom/movable/moving_from_pull		//attempt to resume grab after moving instead of before.

	appearance_flags = TILE_BOUND|PIXEL_SCALE

	var/initial_language_holder = /datum/language_holder
	var/datum/language_holder/language_holder
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_yell = "yells"

	var/datum/component/orbiter/orbiting

//===========================================================================
/atom/movable/Destroy()
	if(throw_source)
		throw_source = null

	loc?.on_stored_atom_del(src) //things that container need to do when a movable atom inside it is deleted

	QDEL_NULL(language_holder)

	. = ..()

	for(var/atom/movable/AM in contents)
		qdel(AM)

	moveToNullspace()
	invisibility = INVISIBILITY_ABSTRACT

	pulledby?.stop_pulling()

	if(orbiting)
		orbiting.end_orbit(src)
		orbiting = null



////////////////////////////////////////
// Here's where we rewrite how byond handles movement except slightly different
// To be removed on step_ conversion
// All this work to prevent a second bump
/atom/movable/Move(atom/newloc, direct=0)
	. = FALSE
	if(!newloc || newloc == loc)
		return

	if(!direct)
		direct = get_dir(src, newloc)
	setDir(direct)

	if(!loc.Exit(src, newloc))
		return

	if(!newloc.Enter(src, loc))
		return

	// Past this is the point of no return
	SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc)
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)
	loc = newloc
	. = TRUE
	oldloc.Exited(src, newloc)
	if(oldarea != newarea)
		oldarea.Exited(src, newloc)

	for(var/i in oldloc)
		if(i == src) // Multi tile objects
			continue
		var/atom/movable/thing = i
		thing.Uncrossed(src)

	newloc.Entered(src, oldloc)
	if(oldarea != newarea)
		newarea.Entered(src, oldloc)

	for(var/i in loc)
		if(i == src) // Multi tile objects
			continue
		var/atom/movable/thing = i
		thing.Crossed(src)
//
////////////////////////////////////////

/atom/movable/Move(atom/newloc, direct)
	var/atom/movable/pullee = pulling
	var/turf/T = loc
	if(!moving_from_pull)
		check_pulling()
	if(!loc || !newloc)
		return FALSE
	var/atom/oldloc = loc

	if(loc != newloc)
		if(!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if step() fails because we hit something.
			if(direct & NORTH)
				if(direct & EAST)
					if(step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if(moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
				else if(direct & WEST)
					if(step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if(moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
			else if(direct & SOUTH)
				if(direct & EAST)
					if(step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if(moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
				else if(direct & WEST)
					if(step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if(moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!.)
					setDir(first_step_dir)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(.)
		Moved(oldloc, direct)

	if(. && pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			var/pull_dir = get_dir(src, pulling)
			//puller and pullee more than one tile away or in diagonal position
			if(get_dist(src, pulling) > 1 || (moving_diagonally != SECOND_DIAG_STEP && ((pull_dir - 1) & pull_dir)))
				pulling.moving_from_pull = src
				pulling.Move(T, get_dir(pulling, T)) //the pullee tries to reach our previous position
				pulling.moving_from_pull = null
			check_pulling()

	last_move = direct
	last_move_time = world.time
	setDir(direct)


/atom/movable/Bump(atom/A)
	if(!A)
		CRASH("Bump was called with no argument.")
	if(throwing)
		throw_impact(A)
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
	. = ..()
	if(QDELETED(A))
		return
	A.Bumped(src)


// Make sure you know what you're doing if you call this, this is intended to only be called by byond directly.
// You probably want CanPass()
/atom/movable/Cross(atom/movable/AM)
	. = TRUE
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSS, AM)
	return CanPass(AM, AM.loc, TRUE)


//oldloc = old location on atom, inserted when forceMove is called and ONLY when forceMove is called!
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)


/atom/movable/Uncross(atom/movable/AM, atom/newloc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSS, AM) & COMPONENT_MOVABLE_BLOCK_UNCROSS)
		return FALSE
	if(isturf(newloc) && !CheckExit(AM, newloc))
		return FALSE


/atom/movable/Uncrossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSSED, AM)


/atom/movable/proc/Moved(atom/oldloc, direction, Forced = FALSE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, oldloc, direction, Forced)
	if(isturf(loc))
		if(opacity)
			oldloc.UpdateAffectingLights()
		else if(light)
			light.changed()

	return TRUE


/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")


/atom/movable/proc/moveToNullspace()
	return doMove(null)


/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/atom/oldloc = loc
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		loc = destination

		if(!same_loc)
			if(oldloc)
				oldloc.Exited(src, destination)
				if(old_area && old_area != destarea)
					old_area.Exited(src, destination)
			for(var/atom/movable/AM in oldloc)
				AM.Uncrossed(src)
			//var/turf/oldturf = get_turf(oldloc)
			//var/turf/destturf = get_turf(destination)
			//var/old_z = (oldturf ? oldturf.z : null)
			//var/dest_z = (destturf ? destturf.z : null)
			//if (old_z != dest_z)
			//	onTransitZ(old_z, dest_z)
			destination.Entered(src, oldloc)
			if(destarea && old_area != destarea)
				destarea.Entered(src, oldloc)

			for(var/atom/movable/AM in destination)
				if(AM == src)
					continue
				AM.Crossed(src, oldloc)

		Moved(oldloc, NONE, TRUE)
		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE
		if (loc)
			var/atom/oldloc = loc
			var/area/old_area = get_area(oldloc)
			oldloc.Exited(src, null)
			if(old_area)
				old_area.Exited(src, null)
		loc = null


//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, speed)
	if(isliving(hit_atom))
		var/mob/living/M = hit_atom
		M.hitby(src, speed)

	else if(isobj(hit_atom)) // Thrown object hits another object and moves it
		var/obj/O = hit_atom
		if(!O.anchored && !isxeno(src))
			step(O, dir)
		O.hitby(src, speed)

	else if(isturf(hit_atom))
		throwing = FALSE
		var/turf/T = hit_atom
		if(T.density)
			spawn(2)
				step(src, turn(dir, 180))
			if(isliving(src))
				var/mob/living/M = src
				M.turf_collision(T, speed)

	SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom)


//decided whether a movable atom being thrown can pass through the turf it is in.
/atom/movable/proc/hit_check(speed)
	if(!throwing)
		return
		
	for(var/atom/A in get_turf(src))
		if(A == src) 
			continue
		if(isliving(A))
			var/mob/living/L = A
			if(L.lying) 
				continue
			throw_impact(A, speed)
		if(isobj(A) && A.density && !(A.flags_atom & ON_BORDER) && (!A.throwpass || iscarbon(src)))
			throw_impact(A, speed)


/atom/movable/proc/throw_at(atom/target, range, speed, thrower, spin)
	if(!target || !src)	
		return FALSE
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	if(spin)
		animation_spin(5, 1)

	throwing = TRUE
	src.thrower = thrower
	throw_source = get_turf(src)	//store the origin turf

	var/dist_x = abs(target.x - x)
	var/dist_y = abs(target.y - y)

	var/dx
	if(target.x > x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if(target.y > y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(loc)
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		while(!gc_destroyed && target &&((((x < target.x && dx == EAST) || (x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || isspaceturf(loc)) && throwing && istype(loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				hit_check(speed)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				hit_check(speed)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(loc)
	else
		var/error = dist_y/2 - dist_x
		while(!gc_destroyed && target &&((((y < target.y && dy == NORTH) || (y > target.y && dy == SOUTH)) && dist_travelled < range) || a && a.has_gravity == 0 || isspaceturf(loc)) && throwing && istype(loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				hit_check(speed)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				hit_check(speed)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(loc)

	//done throwing, either because it hit something or it finished moving
	if(isobj(src) && throwing) 
		throw_impact(get_turf(src), speed)
	if(loc)
		throwing = FALSE
		thrower = null
		throw_source = null


//things the user's machine must do just after we set the user's machine.
/atom/movable/proc/on_set_interaction(mob/user)
	return


//things the user's machine must do just before we unset the user's machine.
/atom/movable/proc/on_unset_interaction(mob/user)
	return


//called when a mob tries to breathe while inside us.
/atom/movable/proc/handle_internal_lifeform(mob/lifeform_inside_me)
	. = return_air()


/atom/movable/proc/check_blocked_turf(turf/target)
	if(target.density)
		return TRUE //Blocked; we can't proceed further.

	for(var/obj/machinery/MA in target)
		if(MA.density)
			return TRUE //Blocked; we can't proceed further.

	for(var/obj/structure/S in target)
		if(S.density)
			return TRUE //Blocked; we can't proceed further.

	return FALSE


/atom/movable/proc/update_icon()
	return


/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 0.2 SECONDS)
	animate(src, pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 0.2 SECONDS)


/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(icon = used_item, loc = A, layer = A.layer + 0.1)
		I.plane = GAME_PLANE

		// Scale the icon.
		I.transform *= 0.75
		// The icon should not rotate.
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

		// Set the direction of the icon animation.
		var/direction = get_dir(src, A)
		if(direction & NORTH)
			I.pixel_y = -16
		else if(direction & SOUTH)
			I.pixel_y = 16

		if(direction & EAST)
			I.pixel_x = -16
		else if(direction & WEST)
			I.pixel_x = 16

		if(!direction) // Attacked self?!
			I.pixel_z = 16

	if(!I)
		return

	flick_overlay(I, GLOB.clients, 0.5 SECONDS)

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)


/atom/movable/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Follow"] = "?_src_=holder;[HrefToken()];observefollow=[REF(src)]"
	.["Get"] = "?_src_=vars;[HrefToken()];getatom=[REF(src)]"
	.["Send"] = "?_src_=vars;[HrefToken()];sendatom=[REF(src)]"
	.["Delete All Instances"] = "?_src_=vars;[HrefToken()];delall=[REF(src)]"
	.["Update Icon"] = "?_src_=vars;[HrefToken()];updateicon=[REF(src)]"


/atom/movable/proc/get_language_holder(shadow = TRUE)
	if(language_holder)
		return language_holder
	else
		language_holder = new initial_language_holder(src)
		return language_holder


/atom/movable/proc/grant_language(datum/language/dt, body = FALSE)
	var/datum/language_holder/H = get_language_holder(!body)
	H.grant_language(dt, body)


/atom/movable/proc/grant_all_languages(omnitongue = FALSE)
	var/datum/language_holder/H = get_language_holder()
	H.grant_all_languages(omnitongue)


/atom/movable/proc/get_random_understood_language()
	var/datum/language_holder/H = get_language_holder()
	. = H.get_random_understood_language()


/atom/movable/proc/remove_language(datum/language/dt, body = FALSE)
	var/datum/language_holder/H = get_language_holder(!body)
	H.remove_language(dt, body)


/atom/movable/proc/remove_all_languages()
	var/datum/language_holder/H = get_language_holder()
	H.remove_all_languages()


/atom/movable/proc/has_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()
	. = H.has_language(dt)


/atom/movable/proc/copy_known_languages_from(thing, replace = FALSE)
	var/datum/language_holder/H = get_language_holder()
	. = H.copy_known_languages_from(thing, replace)


// Whether an AM can speak in a language or not, independent of whether
// it KNOWS the language
/atom/movable/proc/could_speak_in_language(datum/language/dt)
	. = TRUE


/atom/movable/proc/can_speak_in_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()

	if(!H.has_language(dt))
		return FALSE
	else if(H.omnitongue)
		return TRUE
	else if(could_speak_in_language(dt) && (!H.only_speaks_language || H.only_speaks_language == dt))
		return TRUE
	else
		return FALSE


/atom/movable/proc/get_default_language()
	// if no language is specified, and we want to say() something, which
	// language do we use?
	var/datum/language_holder/H = get_language_holder()

	if(H.selected_default_language)
		if(can_speak_in_language(H.selected_default_language))
			return H.selected_default_language
		else
			H.selected_default_language = null


	var/datum/language/chosen_langtype
	var/highest_priority

	for(var/lt in H.languages)
		var/datum/language/langtype = lt
		if(!can_speak_in_language(langtype))
			continue

		var/pri = initial(langtype.default_priority)
		if(!highest_priority || (pri > highest_priority))
			chosen_langtype = langtype
			highest_priority = pri

	H.selected_default_language = .
	. = chosen_langtype


/atom/movable/proc/onTransitZ(old_z,new_z)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_z, new_z)
	for(var/item in src) // Notify contents of Z-transition. This can be overridden IF we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)


/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE)
	//if((force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
	//	return
	return throw_at(target, range, speed, thrower, spin)


/atom/movable/proc/start_pulling(atom/movable/AM, supress_message = FALSE)
	if(QDELETED(AM))
		return FALSE

	if(!(AM.can_be_pulled(src)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		var/pulling_old = pulling
		stop_pulling()
		// Are we pulling the same thing twice? Just stop pulling.
		if(pulling_old == AM)
			return FALSE
	if(AM.pulledby)
		log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = AM
	AM.pulledby = src
	if(ismob(AM))
		var/mob/M = AM
		log_combat(src, M, "grabbed", addition = "passive grab")
		if(!supress_message)
			visible_message("<span class='warning'>[src] has grabbed [M] passively!</span>")
	return TRUE


/atom/movable/proc/stop_pulling()
	if(!pulling)
		return FALSE

	pulling.pulledby = null
	pulling = null

	return TRUE


/atom/movable/proc/check_pulling()
	if(pulling)
		var/atom/movable/pullee = pulling
		if(pullee && get_dist(src, pullee) > 1)
			stop_pulling()
			return
		if(!isturf(loc))
			stop_pulling()
			return
		if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			stop_pulling()
			return
		if(pulling.anchored)
			stop_pulling()
			return
	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1)		//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


/atom/movable/proc/can_be_pulled(user)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || throwing)
		return FALSE
	return TRUE