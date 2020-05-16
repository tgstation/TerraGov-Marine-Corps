//Key thing that stops lag. Cornerstone of performance in ss13, Just sitting here, in unsorted.dm.

//Increases delay as the server gets more overloaded,
//as sleeps aren't cheap and sleeping only to wake up and sleep again is wasteful
#define DELTA_CALC max(((max(TICK_USAGE, world.cpu) / 100) * max(Master.sleep_delta-1,1)), 1)

//returns the number of ticks slept
/proc/stoplag(initial_delay)
	if(!Master || !(Master.current_runlevel & RUNLEVELS_DEFAULT))
		sleep(world.tick_lag)
		return 1
	if(!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay)
	do
		. += CEILING(i * DELTA_CALC, 1)
		sleep(i * world.tick_lag * DELTA_CALC)
		i *= 2
	while(TICK_USAGE > min(TICK_LIMIT_TO_RUN, Master.current_ticklimit))

#undef DELTA_CALC

#define UNTIL(X) while(!(X)) stoplag()
#define SIGN(x) (x < 0 ? -1  : 1)

//datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)


//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)


/datum/proc/stack_trace(msg)
	CRASH(msg)


GLOBAL_REAL_VAR(list/stack_trace_storage)
/proc/gib_stack_trace()
	stack_trace_storage = list()
	stack_trace()
	stack_trace_storage.Cut(1, min(3, length(stack_trace_storage)))
	. = stack_trace_storage
	stack_trace_storage = null


//returns a GUID like identifier (using a mostly made up record format)
//guids are not on their own suitable for access or security tokens, as most of their bits are predictable.
//	(But may make a nice salt to one)
/proc/GUID()
	var/const/GUID_VERSION = "b"
	var/const/GUID_VARIANT = "d"
	var/node_id = copytext_char(md5("[rand()*rand(1,9999999)][world.name][world.hub][world.hub_password][world.internet_address][world.address][world.contents.len][world.status][world.port][rand()*rand(1,9999999)]"), 1, 13)

	var/time_high = "[num2hex(text2num(time2text(world.realtime,"YYYY")), 2)][num2hex(world.realtime, 6)]"

	var/time_mid = num2hex(world.timeofday, 4)

	var/time_low = num2hex(world.time, 3)

	var/time_clock = num2hex(TICK_DELTA_TO_MS(world.tick_usage), 3)

	return "{[time_high]-[time_mid]-[GUID_VERSION][time_low]-[GUID_VARIANT][time_clock]-[node_id]}"


/proc/pass()
	return


// \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
// If it ever becomes necesary to get a more performant REF(), this lies here in wait
// #define REF(thing) (thing && istype(thing, /datum) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : "\ref[thing]")
/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return "\ref[input]"


//Returns the middle-most value
/proc/dd_range(low, high, num)
	return max(low, min(high, num))


//Returns whether or not A is the middle most value
/proc/InRange(A, lower, upper)
	if(A < lower)
		return FALSE
	if(A > upper)
		return FALSE
	return TRUE


/proc/Get_Angle(atom/start, atom/end)//For beams.
	if(!start || !end)
		CRASH("Get_Angle called for inexisting atoms: [isnull(start) ? "null" : start] to [isnull(end) ? "null" : end].")
	if(!start.z)
		start = get_turf(start)
		if(!start)
			CRASH("Get_Angle called for inexisting atoms (start): [isnull(start.loc) ? "null loc" : start.loc] [start] to [isnull(end.loc) ? "null loc" : end.loc] [end].") //Atoms are not on turfs.
	if(!end.z)
		end = get_turf(end)
		if(!end)
			CRASH("Get_Angle called for inexisting atoms (end): [isnull(start.loc) ? "null loc" : start.loc] [start] to [isnull(end.loc) ? "null loc" : end.loc] [end].") //Atoms are not on turfs.
	var/dy = (32 * end.y + end.pixel_y) - (32 * start.y + start.pixel_y)
	var/dx = (32 * end.x + end.pixel_x) - (32 * start.x + start.pixel_x)
	if(!dy)
		return (dx >= 0) ? 90 : 270
	. = arctan(dx / dy)
	if(dy < 0)
		. += 180
	else if(dx < 0)
		. += 360


/proc/Get_Pixel_Angle(dx, dy)//for getting the angle when animating something's pixel_x and pixel_y
	var/da = (90 - ATAN2(dx, dy))
	return (da >= 0 ? da : da + 360)


/proc/get_angle_with_scatter(atom/start, atom/end, scatter, x_offset = 16, y_offset = 16)
	var/end_apx
	var/end_apy
	if(isliving(end)) //Center mass.
		end_apx = ABS_COOR(end.x)
		end_apy = ABS_COOR(end.y)
	else //Exact pixel.
		end_apx = ABS_COOR_OFFSET(end.x, x_offset)
		end_apy = ABS_COOR_OFFSET(end.y, y_offset)
	scatter = ( (rand(0, min(scatter, 45))) * (prob(50) ? 1 : -1) ) //Up to 45 degrees deviation to either side.
	. = round((90 - ATAN2(end_apx - ABS_COOR(start.x), end_apy - ABS_COOR(start.y))), 1) + scatter
	if(. < 0)
		. += 360
	else if(. >= 360)
		. -= 360

/proc/angle_to_dir(angle)
	switch(angle)
		if(338 to 360, 0 to 22)
			return NORTH
		if(23 to 67)
			return NORTHEAST
		if(68 to 112)
			return EAST
		if(113 to 157)
			return SOUTHEAST
		if(158 to 202)
			return SOUTH
		if(203 to 247)
			return SOUTHWEST
		if(248 to 292)
			return WEST
		if(293 to 337)
			return NORTHWEST



/proc/LinkBlocked(turf/A, turf/B)
	if(isnull(A) || isnull(B))
		return TRUE
	var/adir = get_dir(A, B)
	var/rdir = get_dir(B, A)
	if(adir & (adir - 1))//is diagonal direction
		var/turf/iStep = get_step(A, adir & (NORTH|SOUTH))
		if(!iStep.density && !LinkBlocked(A, iStep) && !LinkBlocked(iStep, B))
			return FALSE

		var/turf/pStep = get_step(A,adir & (EAST|WEST))
		if(!pStep.density && !LinkBlocked(A, pStep) && !LinkBlocked(pStep, B))
			return FALSE
		return TRUE

	if(DirBlocked(A, adir))
		return TRUE
	if(DirBlocked(B, rdir))
		return TRUE
	return FALSE


/proc/DirBlocked(turf/loc, direction)
	for(var/obj/structure/window/D in loc)
		if(!D.density)
			continue
		if(D.is_full_window())
			return TRUE
		if(D.dir == direction)
			return TRUE

	for(var/obj/machinery/door/D in loc)
		if(!D.density)
			continue
		if(istype(D, /obj/machinery/door/window))
			if(D.dir == direction)
				return TRUE
		else
			return TRUE	// it's a real, air blocking door
	for(var/obj/structure/mineral_door/D in loc)
		if(D.density)
			return TRUE
	return FALSE


/proc/TurfBlockedNonWindow(turf/loc)
	for(var/obj/O in loc)
		if(O.density && !istype(O, /obj/structure/window))
			return TRUE
	return FALSE


//Returns whether or not a player is a guest using their ckey as an input
/proc/IsGuestKey(key)
	if (findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/i, ch, len = length(key)

	for (i = 7, i <= len, ++i) //we know the first 6 chars are Guest-
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57) //0-9
			return FALSE
	return TRUE


// Ensure the frequency is within bounds of what it should be sending/receiving at
/proc/sanitize_frequency(frequency, free = FALSE)
	. = round(frequency)
	if(free)
		. = CLAMP(frequency, MIN_FREE_FREQ, MAX_FREE_FREQ)
	else
		. = CLAMP(frequency, MIN_FREQ, MAX_FREQ)
	if(!(. % 2)) // Ensure the last digit is an odd number
		. += 1


// Format frequency by moving the decimal.
/proc/format_frequency(frequency)
	frequency = text2num(frequency)
	return "[round(frequency / 10)].[frequency % 10]"


//Opposite of format, returns as a number
/proc/unformat_frequency(frequency)
	frequency = text2num(frequency)
	return frequency * 10


//Orders mobs by type then by name
/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(GLOB.mob_list)
	for(var/mob/living/silicon/ai/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/human/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/brain/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/xenomorph/M in sortmob)
		moblist.Add(M)
	for(var/mob/dead/observer/M in sortmob)
		moblist.Add(M)
	for(var/mob/new_player/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/carbon/monkey/M in sortmob)
		moblist.Add(M)
	for(var/mob/living/simple_animal/M in sortmob)
		moblist.Add(M)
	return moblist


//ultra range (no limitations on distance, faster than range for distances > 8); including areas drastically decreases performance
/proc/urange(dist = 0, atom/center = usr, orange = FALSE, areas = FALSE)
	if(!dist)
		if(!orange)
			return list(center)
		else
			return list()

	var/list/turfs = RANGE_TURFS(dist, center)
	if(orange)
		turfs -= get_turf(center)
	. = list()
	for(var/V in turfs)
		var/turf/T = V
		. += T
		. += T.contents
		if(areas)
			. |= T.loc

//similar function to range(), but with no limitations on the distance; will search spiralling outwards from the center
/proc/spiral_range(dist=0, center=usr, orange=0)
	var/list/L = list()
	var/turf/t_center = get_turf(center)
	if(!t_center)
		return list()

	if(!orange)
		L += t_center
		L += t_center.contents

	if(!dist)
		return L


	var/turf/T
	var/y
	var/x
	var/c_dist = 1


	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
				L += T.contents
		c_dist++

	return L

//similar function to RANGE_TURFS(), but will search spiralling outwards from the center (like the above, but only turfs)
/proc/spiral_range_turfs(dist=0, center=usr, orange=0, list/outlist = list(), tick_checked)
	outlist.Cut()
	if(!dist)
		outlist += center
		return outlist

	var/turf/t_center = get_turf(center)
	if(!t_center)
		return outlist

	var/list/L = outlist
	var/turf/T
	var/y
	var/x
	var/c_dist = 1

	if(!orange)
		L += t_center

	while( c_dist <= dist )
		y = t_center.y + c_dist
		x = t_center.x - c_dist + 1
		for(x in x to t_center.x+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y + c_dist - 1
		x = t_center.x + c_dist
		for(y in t_center.y-c_dist to y)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist
		x = t_center.x + c_dist - 1
		for(x in t_center.x-c_dist to x)
			T = locate(x,y,t_center.z)
			if(T)
				L += T

		y = t_center.y - c_dist + 1
		x = t_center.x - c_dist
		for(y in y to t_center.y+c_dist)
			T = locate(x,y,t_center.z)
			if(T)
				L += T
		c_dist++
		if(tick_checked)
			CHECK_TICK

	return L

// returns the turf located at the map edge in the specified direction relative to A
// used for mass driver
/proc/get_edge_target_turf(atom/A, direction)
	var/turf/target = locate(A.x, A.y, A.z)
	if(!A || !target)
		return FALSE
		//since NORTHEAST == NORTH & EAST, etc, doing it this way allows for diagonal mass drivers in the future
		//and isn't really any more complicated

		// Note diagonal directions won't usually be accurate
	if(direction & NORTH)
		target = locate(target.x, world.maxy, target.z)
	if(direction & SOUTH)
		target = locate(target.x, 1, target.z)
	if(direction & EAST)
		target = locate(world.maxx, target.y, target.z)
	if(direction & WEST)
		target = locate(1, target.y, target.z)

	return target


// returns turf relative to A in given direction at set range
// result is bounded to map size
// note range is non-pythagorean
// used for disposal system
/proc/get_ranged_target_turf(atom/A, direction, range)
	var/x = A.x
	var/y = A.y
	if(direction & NORTH)
		y = min(world.maxy, y + range)
	else if(direction & SOUTH)
		y = max(1, y - range)
	if(direction & EAST)
		x = min(world.maxx, x + range)
	else if(direction & WEST)
		x = max(1, x - range)

	return locate(x, y, A.z)


// returns turf relative to A offset in dx and dy tiles
// bound to map limits
/proc/get_offset_target_turf(atom/A, dx, dy)
	var/x = min(world.maxx, max(1, A.x + dx))
	var/y = min(world.maxy, max(1, A.y + dy))
	return locate(x, y, A.z)


//Makes sure MIDDLE is between LOW and HIGH. If not, it adjusts it. Returns the adjusted value.
/proc/between(low, middle, high)
	return max(min(middle, high), low)

#if DM_VERSION < 513
/proc/arctan(x)
	return arcsin(x / sqrt(1 + x * x))
#endif

//returns random gauss number
/proc/GaussRand(sigma)
	var/x,y,rsq
	do
		x = 2 * rand() - 1
		y = 2 * rand() - 1
		rsq = x * x + y * y
	while(rsq > 1 || !rsq)
	return sigma * y * sqrt(-2 * log(rsq) / rsq)


//returns random gauss number, rounded to 'roundto'
/proc/GaussRandRound(sigma, roundto)
	return round(GaussRand(sigma), roundto)


/proc/anim(turf/location, atom/target, a_icon, a_icon_state, flick_anim, sleeptime = 0, direction)
//This proc throws up either an icon or an animation for a specified amount of time.
//The variables should be apparent enough.
	var/atom/movable/animation = new(location)
	animation.anchored = FALSE
	animation.density = FALSE
	if(direction)
		animation.setDir(direction)
	animation.icon = a_icon
	animation.layer = target.layer + 0.1
	if(a_icon_state)
		animation.icon_state = a_icon_state
	else
		animation.icon_state = "blank"
		flick(flick_anim, animation)
	sleep(max(sleeptime, 15))
	qdel(animation)


/atom/proc/GetAllContents(T)
	var/list/processing_list = list(src)
	var/list/assembled = list()
	if(T)
		while(length(processing_list))
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			//Byond does not allow things to be in multiple contents, or double parent-child hierarchies, so only += is needed
			//This is also why we don't need to check against assembled as we go along
			processing_list += A.contents
			if(istype(A, T))
				assembled += A
	else
		while(length(processing_list))
			var/atom/A = processing_list[1]
			processing_list.Cut(1, 2)
			processing_list += A.contents
			assembled += A
	return assembled


//Step-towards method of determining whether one atom can see another. Similar to viewers()
/proc/can_see(atom/source, atom/target, length = 5) // I couldnt be arsed to do actual raycasting :I This is horribly inaccurate.
	var/turf/current = get_turf(source)
	var/turf/target_turf = get_turf(target)
	if(current == target_turf)
		return TRUE
	if(get_dist(current, target_turf) > length)
		return FALSE
	current = get_step_towards(source, target_turf)
	while((current != target_turf))
		if(current.opacity)
			return FALSE
		for(var/thing in current)
			var/atom/A = thing
			if(A.opacity)
				return FALSE
		current = get_step_towards(current, target_turf)
	return TRUE


/proc/is_blocked_turf(turf/T)
	if(T.density)
		return TRUE
	for(var/atom/A in T)
		if(A.density)
			return TRUE

//Takes: Anything that could possibly have variables and a varname to check.
//Returns: TRUE if found, FALSE if not.
/proc/hasvar(datum/A, varname)
	if(A.vars.Find(lowertext(varname)))
		return TRUE
	return FALSE


//Takes: Area type as text string or as typepath OR an instance of the area.
//Returns: A list of all turfs in areas of that type of that type in the world.
/proc/get_area_turfs(areatype)
	if(!areatype)
		return

	if(istext(areatype))
		areatype = text2path(areatype)

	if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type

	var/list/turfs = list()
	for(var/i in GLOB.sorted_areas)
		var/area/A = i
		if(!istype(A, areatype))
			continue
		for(var/turf/T in A)
			turfs += T

	return turfs


/datum/coords //Simple datum for storing coordinates.
	var/x_pos = null
	var/y_pos = null
	var/z_pos = null


/area/proc/move_contents_to(area/A, turftoleave, direction)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return FALSE

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x = T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y = T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x = T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y = T.y

	var/list/refined_src = list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new /datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new /datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = list()
	var/list/toupdate = list()

	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					var/turf/X = B.ChangeTurf(T.type)
					X.setDir(old_dir1)
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					/* Quick visual fix for some weird shuttle corner artefacts when on transit space tiles */
					if(direction && findtext(X.icon_state, "swall_s"))

						// Spawn a new shuttle corner object
						var/obj/corner = new()
						corner.loc = X
						corner.density = TRUE
						corner.anchored = TRUE
						corner.icon = X.icon
						corner.icon_state = replacetext(X.icon_state, "_s", "_f")
						corner.tag = "delete me"
						corner.name = "wall"

						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(corner, direction)
						if(!nextturf || !isspaceturf(nextturf))
							nextturf = get_step(corner, turn(direction, 180))


						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state


					for(var/obj/O in T)
						// Reset the shuttle corners
						if(O.tag == "delete me")
							X.icon = 'icons/turf/shuttle.dmi'
							X.icon_state = replacetext(O.icon_state, "_f", "_s") // revert the turf to the old icon_state
							X.name = "wall"
							qdel(O) // prevents multiple shuttle corners from stacking
							continue
						if(!isobj(O))
							continue
						O.loc = X
					for(var/mob/M in T)
						if(!ismob(M))
							continue // If we need to check for more mobs, I'll add a variable
						M.loc = X

//					var/area/AR = X.loc

//					if(AR.dynamic_lighting)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.set_opacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						fromupdate += T.ChangeTurf(turftoleave)
					else
						T.ChangeTurf(/turf/open/space)

					refined_src -= T
					refined_trg -= B
					continue moving

	var/list/doors = list()

	if(length(toupdate))
		for(var/turf/T1 in toupdate)
			for(var/obj/machinery/door/D2 in T1)
				doors += D2
			/*if(T1.parent)
				air_master.groups_to_rebuild += T1.parent
			else
				air_master.tiles_to_update += T1*/

	if(length(fromupdate))
		for(var/turf/T2 in fromupdate)
			for(var/obj/machinery/door/D2 in T2)
				doors += D2
			/*if(T2.parent)
				air_master.groups_to_rebuild += T2.parent
			else
				air_master.tiles_to_update += T2*/


/proc/DuplicateObject(atom/original, atom/newloc)
	RETURN_TYPE(original.type)
	if(!original || !newloc)
		return

	var/atom/O = new original.type(newloc)
	if(!O)
		return

	O.contents.Cut()

	for(var/V in original.vars - GLOB.duplicate_forbidden_vars)
		if(istype(original.vars[V], /datum)) // this would reference the original's object, that will break when it is used or deleted.
			continue
		else if(islist(original.vars[V]))
			var/list/L = original.vars[V]
			O.vars[V] = L.Copy()
		else
			O.vars[V] = original.vars[V]

	for(var/atom/A in original.contents)
		O.contents += new A.type

	if(isobj(O))
		var/obj/N = O

		N.update_icon()
		if(ismachinery(O))
			var/obj/machinery/M = O
			M.power_change()

	return O


/area/proc/copy_contents_to(area/A , platingRequired = FALSE)
	//Takes: Area. Optional: If it should copy to areas that don't have plating
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src)
		return FALSE

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for(var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x)
			src_min_x = T.x
		if(T.y < src_min_y || !src_min_y)
			src_min_y = T.y

	var/trg_min_x = 0
	var/trg_min_y = 0
	for(var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x)
			trg_min_x = T.x
		if(T.y < trg_min_y || !trg_min_y)
			trg_min_y = T.y

	var/list/refined_src = list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new /datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new /datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/toupdate = list()

	var/copiedobjs = list()


	moving:
		for(var/turf/T in refined_src)
			var/datum/coords/C_src = refined_src[T]
			for(var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon

					if(platingRequired)
						if(isspaceturf(B))
							continue moving

					var/turf/X = new T.type(B)
					X.setDir(old_dir1)
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi


					var/list/objs = new/list()
					var/list/newobjs = new/list()
					var/list/mobs = new/list()
					var/list/newmobs = new/list()

					for(var/obj/O in T)

						if(!isobj(O))
							continue

						objs += O


					for(var/obj/O in objs)
						newobjs += DuplicateObject(O, T)


					for(var/obj/O in newobjs)
						O.loc = X

					for(var/mob/M in T)

						if(!ismob(M))
							continue // If we need to check for more mobs, I'll add a variable
						mobs += M

					for(var/mob/M in mobs)
						newmobs += DuplicateObject(M, T)

					for(var/mob/M in newmobs)
						M.loc = X

					copiedobjs += newobjs
					copiedobjs += newmobs



					for(var/V in T.vars)
						if(!(V in list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key", "x", "y", "z", "contents", "luminosity")))
							X.vars[V] = T.vars[V]

//					var/area/AR = X.loc

//					if(AR.dynamic_lighting)
//						X.opacity = !X.opacity
//						X.sd_set_opacity(!X.opacity)			//TODO: rewrite this code so it's not messed by lighting ~Carn

					toupdate += X

					refined_src -= T
					refined_trg -= B
					continue moving


	return copiedobjs


/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)


//Returns the 2 dirs perpendicular to the arg
/proc/get_perpen_dir(dir)
	if(dir & (dir-1))
		return 0 //diagonals
	if(dir in list(EAST, WEST))
		return list(SOUTH, NORTH)
	else
		return list(EAST, WEST)


//chances are 1:value. anyprob(1) will always return true
/proc/anyprob(value)
	return (rand(1, value) == value)


/proc/parse_zone(zone)
	if(zone == "r_hand")
		return "right hand"
	else if (zone == "l_hand")
		return "left hand"
	else if (zone == "l_arm")
		return "left arm"
	else if (zone == "r_arm")
		return "right arm"
	else if (zone == "l_leg")
		return "left leg"
	else if (zone == "r_leg")
		return "right leg"
	else if (zone == "l_foot")
		return "left foot"
	else if (zone == "r_foot")
		return "right foot"
	else if (zone == "l_hand")
		return "left hand"
	else if (zone == "r_hand")
		return "right hand"
	else if (zone == "l_foot")
		return "left foot"
	else if (zone == "r_foot")
		return "right foot"
	else
		return zone


//Quick type checks for some tools
GLOBAL_LIST_INIT(common_tools, typecacheof(list(
/obj/item/stack/cable_coil,
/obj/item/tool/wrench,
/obj/item/tool/weldingtool,
/obj/item/tool/screwdriver,
/obj/item/tool/wirecutters,
/obj/item/multitool,
/obj/item/tool/crowbar)))


/proc/istool(O)
	if(O && is_type_in_typecache(O, GLOB.common_tools))
		return TRUE
	return FALSE


/proc/is_hot(obj/item/I)
	return I.heat


//Whether or not the given item counts as sharp in terms of dealing damage
/proc/is_sharp(obj/item/I)
	if(!istype(I))
		return FALSE
	if(I.sharp)
		return TRUE
	if(I.edge)
		return TRUE
	return FALSE


//Whether or not the given item counts as cutting with an edge in terms of removing limbs
/proc/has_edge(obj/item/I)
	if(!istype(I))
		return FALSE
	if(!I.edge)
		return FALSE
	return TRUE


/proc/params2turf(scr_loc, turf/origin, client/C)
	if(!scr_loc || !origin)
		return
	var/tX = splittext(scr_loc, ",")
	var/tY = splittext(tX[2], ":")
	var/tZ = origin.z
	tY = tY[1]
	tX = splittext(tX[1], ":")
	tX = tX[1]
	var/list/actual_view = getviewsize(C ? C.view : WORLD_VIEW)
	tX = CLAMP(origin.x + text2num(tX) - round(actual_view[1] * 0.5) + (round(C?.pixel_x / 32)) - 1, 1, world.maxx)
	tY = CLAMP(origin.y + text2num(tY) - round(actual_view[2] * 0.5) + (round(C?.pixel_y / 32)) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)


//Returns TRUE if the given item is capable of popping things like balloons, inflatable barriers, or cutting police tape.
/proc/can_puncture(obj/item/I)
	if(!istype(I))
		return FALSE
	return (I.sharp || I.heat >= 400 	|| \
		isscrewdriver(I)	 || \
		istype(I, /obj/item/tool/pen) 		 || \
		istype(I, /obj/item/tool/shovel) \
	)


//Actually better performant than reverse_direction()
#define REVERSE_DIR(dir) ( ((dir & 85) << 1) | ((dir & 170) >> 1) )


/proc/reverse_direction(direction)
	switch(direction)
		if(NORTH)
			return SOUTH
		if(NORTHEAST)
			return SOUTHWEST
		if(EAST)
			return WEST
		if(SOUTHEAST)
			return NORTHWEST
		if(SOUTH)
			return NORTH
		if(SOUTHWEST)
			return NORTHEAST
		if(WEST)
			return EAST
		if(NORTHWEST)
			return SOUTHEAST


/proc/reverse_nearby_direction(direction)
	switch(direction)
		if(NORTH)
			. = list(SOUTH, SOUTHEAST, SOUTHWEST)
		if(NORTHEAST)
			. = list(SOUTHWEST, SOUTH, WEST)
		if(EAST)
			. = list(WEST, SOUTHWEST, NORTHWEST)
		if(SOUTHEAST)
			. = list(NORTHWEST, NORTH, WEST)
		if(SOUTH)
			. = list(NORTH, NORTHEAST, NORTHWEST)
		if(SOUTHWEST)
			. = list(NORTHEAST, NORTH, EAST)
		if(WEST)
			. = list(EAST, NORTHEAST, SOUTHEAST)
		if(NORTHWEST)
			. = list(SOUTHEAST, SOUTH, EAST)


/*
Checks if that loc and dir has a item on the wall
*/
GLOBAL_LIST_INIT(wallitems, typecacheof(list(
	/obj/machinery/power/apc, /obj/machinery/alarm, /obj/item/radio/intercom,
	/obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/wallmounted/peppertank,
	/obj/machinery/status_display, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/door_control,
	/obj/machinery/computer/security/telescreen,
	/obj/item/storage/secure/safe, /obj/machinery/door_timer, /obj/machinery/flasher, /obj/machinery/keycard_auth,
	/obj/structure/mirror, /obj/structure/closet/fireaxecabinet, /obj/machinery/computer/security/telescreen/entertainment
	)))


/proc/gotwallitem(loc, dir)
	for(var/obj/O in loc)
		if(is_type_in_typecache(O, GLOB.wallitems))
			//Direction works sometimes
			if(O.dir == dir)
				return TRUE

			//Some stuff doesn't use dir properly, so we need to check pixel instead
			switch(dir)
				if(SOUTH)
					if(O.pixel_y > 10)
						return TRUE
				if(NORTH)
					if(O.pixel_y < -10)
						return TRUE
				if(WEST)
					if(O.pixel_x > 10)
						return TRUE
				if(EAST)
					if(O.pixel_x < -10)
						return TRUE


	//Some stuff is placed directly on the wallturf (signs)
	for(var/obj/O in get_step(loc, dir))
		if(is_type_in_typecache(O, GLOB.wallitems))
			if(O.pixel_x != 0 || O.pixel_y != 0)
				continue

			return TRUE

	return FALSE


/proc/format_text(text)
	return replacetext(replacetext(text,"\proper ",""),"\improper ","")


//Reasonably Optimized Bresenham's Line Drawing
/proc/getline(atom/start, atom/end)
	var/x = start.x
	var/y = start.y
	var/z = start.z

	//horizontal and vertical lines special case
	if(y == end.y)
		return x <= end.x ? block(locate(x,y,z), locate(end.x,y,z)) : reverseRange(block(locate(end.x,y,z), locate(x,y,z)))
	if(x == end.x)
		return y <= end.y ? block(locate(x,y,z), locate(x,end.y,z)) : reverseRange(block(locate(x,end.y,z), locate(x,y,z)))

	//let's compute these only once
	var/abs_dx = abs(end.x - x)
	var/abs_dy = abs(end.y - y)
	var/sign_dx = SIGN(end.x - x)
	var/sign_dy = SIGN(end.y - y)

	var/list/turfs = list(locate(x,y,z))

	//diagonal special case
	if(abs_dx == abs_dy)
		for(var/j = 1 to abs_dx)
			x += sign_dx
			y += sign_dy
			turfs += locate(x,y,z)
		return turfs

	/*x_error and y_error represents how far we are from the ideal line.
	Initialized so that we will check these errors against 0, instead of 0.5 * abs_(dx/dy)*/

	//We multiply every check by the line slope denominator so that we only handles integers
	if(abs_dx > abs_dy)
		var/y_error = -(abs_dx >> 1)
		var/steps = abs_dx
		while(steps--)
			y_error += abs_dy
			if(y_error > 0)
				y_error -= abs_dx
				y += sign_dy
			x += sign_dx
			turfs += locate(x,y,z)
	else
		var/x_error = -(abs_dy >> 1)
		var/steps = abs_dy
		while(steps--)
			x_error += abs_dx
			if(x_error > 0)
				x_error -= abs_dy
				x += sign_dx
			y += sign_dy
			turfs += locate(x,y,z)

	. = turfs


// Makes a call in the context of a different usr
// Use sparingly
/world/proc/PushUsr(mob/M, datum/callback/CB, ...)
	var/temp = usr
	usr = M
	if (length(args) > 2)
		. = CB.Invoke(arglist(args.Copy(3)))
	else
		. = CB.Invoke()
	usr = temp


/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if(value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if(isnull(value))
			return
	value = trim(value)
	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(!length(matches))
		return

	var/chosen
	if(length(matches) == 1)
		chosen = matches[1]
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in matches
		if(!chosen)
			return
	chosen = matches[chosen]
	return chosen


/proc/IsValidSrc(datum/D)
	if(istype(D))
		return !QDELETED(D)
	return FALSE


//Repopulates sortedAreas list
/proc/repopulate_sorted_areas()
	GLOB.sorted_areas = list()

	for(var/area/A in world)
		GLOB.sorted_areas.Add(A)

	sortTim(GLOB.sorted_areas, /proc/cmp_name_asc)


// Format a power value in W, kW, MW, or GW.
/proc/DisplayPower(powerused)
	if(powerused < 1000) //Less than a kW
		return "[powerused] W"
	else if(powerused < 1000000) //Less than a MW
		return "[round((powerused * 0.001),0.01)] kW"
	else if(powerused < 1000000000) //Less than a GW
		return "[round((powerused * 0.000001),0.001)] MW"
	return "[round((powerused * 0.000000001),0.0001)] GW"


// Bucket a value within boundary
/proc/get_bucket(bucket_size, max, current, min = 0, list/boundary_terms)
	if(length(boundary_terms) == 2)
		if(current >= max)
			return boundary_terms[1]
		if(current < min)
			return boundary_terms[2]

	return CEILING((bucket_size / max) * current, 1)


/atom/proc/GetAllContentsIgnoring(list/ignore_typecache)
	if(!length(ignore_typecache))
		return GetAllContents()
	var/list/processing = list(src)
	var/list/assembled = list()
	while(processing.len)
		var/atom/A = processing[1]
		processing.Cut(1,2)
		if(!ignore_typecache[A.type])
			processing += A.contents
			assembled += A
	return assembled

/atom/proc/Shake(pixelshiftx = 15, pixelshifty = 15, duration = 25 SECONDS) //Does a "shaking" effect on a sprite, code is from tgstation
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	var/shiftx = rand(-pixelshiftx,pixelshiftx)
	var/shifty = rand(-pixelshifty,pixelshifty)
	animate(src, pixel_x = pixel_x + shiftx, pixel_y = pixel_y + shifty, time = 0.2, loop = duration)
	pixel_x = initialpixelx
	pixel_y = initialpixely

/atom/proc/contains(atom/A)
	if(!A)
		return FALSE
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return TRUE

/*

Gets the turf this atom's *ICON* appears to inhabit
It takes into account:
* Pixel_x/y
* Matrix x/y

NOTE: if your atom has non-standard bounds then this proc
will handle it, but:
* if the bounds are even, then there are an even amount of "middle" turfs, the one to the EAST, NORTH, or BOTH is picked
(this may seem bad, but you're atleast as close to the center of the atom as possible, better than byond's default loc being all the way off)
* if the bounds are odd, the true middle turf of the atom is returned

*/

/proc/get_turf_pixel(atom/AM)
	if(!istype(AM))
		return

	//Find AM's matrix so we can use it's X/Y pixel shifts
	var/matrix/M = matrix(AM.transform)

	var/pixel_x_offset = AM.pixel_x + M.get_x_shift()
	var/pixel_y_offset = AM.pixel_y + M.get_y_shift()

	//Irregular objects
	var/icon/AMicon = icon(AM.icon, AM.icon_state)
	var/AMiconheight = AMicon.Height()
	var/AMiconwidth = AMicon.Width()
	if(AMiconheight != world.icon_size || AMiconwidth != world.icon_size)
		pixel_x_offset += ((AMiconwidth/world.icon_size)-1)*(world.icon_size*0.5)
		pixel_y_offset += ((AMiconheight/world.icon_size)-1)*(world.icon_size*0.5)

	//DY and DX
	var/rough_x = round(round(pixel_x_offset,world.icon_size)/world.icon_size)
	var/rough_y = round(round(pixel_y_offset,world.icon_size)/world.icon_size)

	//Find coordinates
	var/turf/T = get_turf(AM) //use AM's turfs, as it's coords are the same as AM's AND AM's coords are lost if it is inside another atom
	if(!T)
		return null
	var/final_x = T.x + rough_x
	var/final_y = T.y + rough_y

	if(final_x || final_y)
		return locate(final_x, final_y, T.z)

/proc/animate_speech_bubble(image/I, list/show_to, duration)
	var/matrix/M = matrix()
	M.Scale(0,0)
	I.transform = M
	I.alpha = 0
	for(var/client/C in show_to)
		C.images += I
	animate(I, transform = 0, alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
	addtimer(CALLBACK(GLOBAL_PROC, /.proc/fade_out, I), duration - 0.5 SECONDS)

/proc/fade_out(image/I, list/show_to)
	animate(I, alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)
	addtimer(CALLBACK(GLOBAL_PROC, /.proc/remove_images_from_clients, I, show_to), 0.5 SECONDS)

//takes an input_key, as text, and the list of keys already used, outputting a replacement key in the format of "[input_key] ([number_of_duplicates])" if it finds a duplicate
//use this for lists of things that might have the same name, like mobs or objects, that you plan on giving to a player as input
/proc/avoid_assoc_duplicate_keys(input_key, list/used_key_list)
	if(!input_key || !istype(used_key_list))
		return
	if(used_key_list[input_key])
		used_key_list[input_key]++
		input_key = "[input_key] ([used_key_list[input_key]])"
	else
		used_key_list[input_key] = 1
	return input_key

//Returns a list of all items of interest with their name
/proc/getpois(mobs_only=FALSE,skip_mindless=FALSE)
	var/list/mobs = sortmobs()
	var/list/namecounts = list()
	var/list/pois = list()
	for(var/mob/M in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			continue
		if(M.client && M.client.holder && M.client.holder.fakekey) //stealthmins
			continue
		var/name = avoid_assoc_duplicate_keys(M.name, namecounts)

		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD)
			if(isobserver(M))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	return pois

//Returns the left and right dir of the input dir, used for AI stutter step while attacking
/proc/LeftAndRightOfDir(direction, diagonal_check = FALSE)
	if(diagonal_check)
		if(ISDIAGONALDIR(direction))
			return list(turn(direction, 45), turn(direction, -45))
	return list(turn(direction, 90), turn(direction, -90))

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))
