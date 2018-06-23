/atom/movable
	layer = OBJ_LAYER
	var/last_move_dir = null
	var/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/drag_delay = 3 //delay (in deciseconds) added to mob's move_delay when pulling it.
	var/l_move_time = 1
	var/throwing = 0
	var/thrower = null
	var/turf/throw_source = null
	var/throw_speed = 2
	var/throw_range = 7
	var/moved_recently = 0
	var/mob/pulledby = null
	var/moving_diagonally = 0 //to know whether we're in the middle of a diagonal move,
								// and if yes, are we doing the first or second move.

	var/acid_damage = 0 //Counter for stomach acid damage. At ~60 ticks, dissolved

//===========================================================================
/atom/movable/Dispose()
	for(var/atom/movable/I in contents) cdel(I)
	if(pulledby) pulledby.stop_pulling()
	if(throw_source) throw_source = null

	if(loc)
		loc.on_stored_atom_del(src) //things that container need to do when a movable atom inside it is deleted

	. = ..()
	loc = null //so we move into null space. Must be after ..() b/c atom's Dispose handles deleting our lighting stuff


/atom/movable/Recycle()
	return
//===========================================================================

/atom/movable/proc/initialize()
	return

/atom/movable/Move(NewLoc, direct)
	/*
	if (direct & (direct - 1)) //Diagonal move, split it into cardinal moves
		moving_diagonally = FIRST_DIAG_STEP
		if (direct & 1)
			if (direct & 4)
				if (step(src, NORTH))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, EAST)
				else if (step(src, EAST))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, NORTH)
			else if (direct & 8)
				if (step(src, NORTH))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, WEST)
				else if (step(src, WEST))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, NORTH)
		else if (direct & 2)
			if (direct & 4)
				if (step(src, SOUTH))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, EAST)
				else if (step(src, EAST))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, SOUTH)
			else if (direct & 8)
				if (step(src, SOUTH))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, WEST)
				else if (step(src, WEST))
					moving_diagonally = SECOND_DIAG_STEP
					. = step(src, SOUTH)
		moving_diagonally = 0
		return
	*/
	var/atom/oldloc = loc
	var/old_dir = dir

	. = ..()
	if(flags_atom & DIRLOCK) dir = old_dir
	move_speed = world.time - l_move_time
	l_move_time = world.time
	if ((oldloc != loc && oldloc && oldloc.z == z))
		last_move_dir = get_dir(oldloc, loc)
	if(.)
		Moved(oldloc,direct)



/atom/movable/Bump(atom/A, yes) //yes arg is to distinguish our calls of this proc from the calls native from byond.
	if(throwing)
		throw_impact(A)

	spawn( 0 )
		if ((A && yes))
			A.last_bumped = world.time
			A.Bumped(src)
		return
	..()
	return

/atom/movable/proc/Moved(atom/OldLoc,Dir)
	if(isturf(loc))
		if(opacity)
			OldLoc.UpdateAffectingLights()
		else
			if(light)
				light.changed()
	return

/atom/movable/proc/forceMove(atom/destination)
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/oldLoc
		if(loc)
			oldLoc = loc
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		var/area/old_area
		if(oldLoc)
			old_area = get_area(oldLoc)
		var/area/new_area = get_area(destination)
		if(new_area && old_area != new_area)
			new_area.Entered(src)
		for(var/atom/movable/AM in destination)
			if(AM == src)
				continue
			AM.Crossed(src)
		if(oldLoc)
			Moved(oldLoc,dir)
		return 1
	return 0


//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, var/speed)
	if(istype(hit_atom,/mob/living))
		var/mob/living/M = hit_atom
		M.hitby(src,speed)

	else if(isobj(hit_atom)) // Thrown object hits another object and moves it
		var/obj/O = hit_atom
		if(!O.anchored && !isXeno(src))
			step(O, src.dir)
		O.hitby(src,speed)

	else if(isturf(hit_atom))
		src.throwing = 0
		var/turf/T = hit_atom
		if(T.density)
			spawn(2)
				step(src, turn(src.dir, 180))
			if(istype(src,/mob/living))
				var/mob/living/M = src
				M.turf_collision(T, speed)

//decided whether a movable atom being thrown can pass through the turf it is in.
/atom/movable/proc/hit_check(var/speed)
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A,speed)
			if(isobj(A))
				if(A.density && !(A.flags_atom & ON_BORDER) && (!A.throwpass || istype(src,/mob/living/carbon)))
					src.throw_impact(A,speed)

/atom/movable/proc/throw_at(atom/target, range, speed, thrower, spin)
	if(!target || !src)	return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	if(spin)
		animation_spin(5, 1)

	src.throwing = 1
	src.thrower = thrower
	src.throw_source = get_turf(src)	//store the origin turf

	if(usr)
		if(HULK in usr.mutations)
			src.throwing = 2 // really strong throw!

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(src.loc)
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		while(src && !disposed && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/open/space)) && src.throwing && istype(src.loc, /turf))
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
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && !disposed && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/open/space)) && src.throwing && istype(src.loc, /turf))
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

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	if(isobj(src) && throwing) throw_impact(get_turf(src),speed)
	if(loc)
		src.throwing = 0
		src.thrower = null
		src.throw_source = null


//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	..()
	for(var/x in src.verbs)
		src.verbs -= x
	return

/atom/movable/overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return






//when a mob interact with something that gives them a special view,
//check_eye() is called to verify that they're still eligible.
//if they are not check_eye() usually reset the mob's view.
/atom/proc/check_eye(mob/user)
	return


/mob/proc/set_interaction(atom/movable/AM)
	if(interactee)
		if(interactee == AM) //already set
			return
		else
			unset_interaction()
	interactee = AM
	if(istype(interactee)) //some stupid code is setting datums as interactee...
		interactee.on_set_interaction(src)


/mob/proc/unset_interaction()
	if(interactee)
		if(istype(interactee))
			interactee.on_unset_interaction(src)
		interactee = null


//things the user's machine must do just after we set the user's machine.
/atom/movable/proc/on_set_interaction(mob/user)
	return


/obj/on_set_interaction(mob/user)
	..()
	in_use = 1


//things the user's machine must do just before we unset the user's machine.
/atom/movable/proc/on_unset_interaction(mob/user)
	return


// Spin for a set amount of time at a set speed using directional states
/atom/movable/proc/spin(var/duration, var/turn_delay = 1, var/clockwise = 0, var/cardinal_only = 1)
	set waitfor = 0

	if (turn_delay < 1)
		return

	var/spin_degree = 90

	if (!cardinal_only)
		spin_degree = 45

	if (clockwise)
		spin_degree *= -1

	while (duration > turn_delay)
		sleep(turn_delay)
		dir = turn(dir, spin_degree)
		duration -= turn_delay

/atom/movable/proc/spin_circle(var/num_circles = 1, var/turn_delay = 1, var/clockwise = 0, var/cardinal_only = 1)
	set waitfor = 0

	if (num_circles < 1 || turn_delay < 1)
		return

	var/spin_degree = 90
	num_circles *= 4

	if (!cardinal_only)
		spin_degree = 45
		num_circles *= 2

	if (clockwise)
		spin_degree *= -1

	for (var/x = 0, x < num_circles, x++)
		sleep(turn_delay)
		dir = turn(dir, spin_degree)


//called when a mob tries to breathe while inside us.
/atom/movable/proc/handle_internal_lifeform(mob/lifeform_inside_me)
	. = return_air()

