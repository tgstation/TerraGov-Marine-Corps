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

/**
 * NAMEOF: Compile time checked variable name to string conversion
 * evaluates to a string equal to "X", but compile errors if X isn't a var on datum.
 * datum may be null, but it does need to be a typed var.
 **/
#define NAMEOF(datum, X) (#X || ##datum.##X)

/**
 * NAMEOF that actually works in static definitions because src::type requires src to be defined
 */

#define NAMEOF_STATIC(datum, X) (nameof(type::##X))

//gives us the stack trace from CRASH() without ending the current proc.
/proc/stack_trace(msg)
	CRASH(msg)


/datum/proc/stack_trace(msg)
	CRASH(msg)

//returns a GUID like identifier (using a mostly made up record format)
//guids are not on their own suitable for access or security tokens, as most of their bits are predictable.
//	(But may make a nice salt to one)
/proc/GUID()
	var/const/GUID_VERSION = "b"
	var/const/GUID_VARIANT = "d"
	var/node_id = copytext_char(md5("[rand()*rand(1,9999999)][world.name][world.hub][world.hub_password][world.internet_address][world.address][length(world.contents)][world.status][world.port][rand()*rand(1,9999999)]"), 1, 13)

	var/time_high = "[num2hex(text2num(time2text(world.realtime,"YYYY")), 2)][num2hex(world.realtime, 6)]"

	var/time_mid = num2hex(world.timeofday, 4)

	var/time_low = num2hex(world.time, 3)

	var/time_clock = num2hex(TICK_DELTA_TO_MS(world.tick_usage), 3)

	return "{[time_high]-[time_mid]-[GUID_VERSION][time_low]-[GUID_VARIANT][time_clock]-[node_id]}"


/proc/pass()
	return


// \ref behaviour got changed in 512 so this is necesary to replicate old behaviour.
// If it ever becomes necesary to get a more performant REF(), this lies here in wait
// #define REF(thing) (thing && istype(thing, /datum) && (thing:datum_flags & DF_USE_TAG) && thing:tag ? "[thing:tag]" : text_ref(thing))
/proc/REF(input)
	if(istype(input, /datum))
		var/datum/thing = input
		if(thing.datum_flags & DF_USE_TAG)
			if(!thing.tag)
				stack_trace("A ref was requested of an object with DF_USE_TAG set but no tag: [thing]")
				thing.datum_flags &= ~DF_USE_TAG
			else
				return "\[[url_encode(thing.tag)]\]"
	return text_ref(input)


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

///returns degrees between two angles
/proc/get_between_angles(degree_one, degree_two)
	var/angle = abs(degree_one - degree_two) % 360
	return angle > 180 ? 360 - angle : angle

/**
 *	Returns true if the path from A to B is blocked. Checks both paths where the direction is diagonal
 *	Variables:
 *	bypass_window - check for PASS_GLASS - laser like behavior
 *	projectile - check for PASS_PROJECTILE - bullet like behavior
 *	bypass_xeno - whether to bypass dense xeno structures like flamers
 *	air_pass - whether to bypass non airtight atoms
 */
/proc/LinkBlocked(turf/A, turf/B, bypass_window = FALSE, projectile = FALSE, bypass_xeno = FALSE, air_pass = FALSE)
	if(isnull(A) || isnull(B))
		return TRUE
	var/adir = get_dir(A, B)
	var/rdir = get_dir(B, A)
	if(B.density && (!istype(B, /turf/closed/wall/resin) || !bypass_xeno))
		return TRUE
	if(adir & (adir - 1))//is diagonal direction
		var/turf/iStep = get_step(A, adir & (NORTH|SOUTH))
		if((!iStep.density || (istype(iStep, /turf/closed/wall/resin) && bypass_xeno)) && !LinkBlocked(A, iStep, bypass_window, projectile, bypass_xeno, air_pass) && !LinkBlocked(iStep, B, bypass_window, projectile, bypass_xeno, air_pass))
			return FALSE

		var/turf/pStep = get_step(A,adir & (EAST|WEST))
		if((!pStep.density || (istype(pStep, /turf/closed/wall/resin) && bypass_xeno)) && !LinkBlocked(A, pStep, bypass_window, projectile, bypass_xeno, air_pass) && !LinkBlocked(pStep, B, bypass_window, projectile, bypass_xeno, air_pass))
			return FALSE
		return TRUE

	if(DirBlocked(A, adir, bypass_window, projectile, bypass_xeno, air_pass))
		return TRUE
	if(DirBlocked(B, rdir, bypass_window, projectile, bypass_xeno, air_pass))
		return TRUE
	return FALSE

///Checks if moving in a direction is blocked
/proc/DirBlocked(turf/loc, direction, bypass_window = FALSE, projectile = FALSE, bypass_xeno = FALSE, air_pass = FALSE)
	for(var/obj/object in loc)
		if(!object.density)
			continue
		if((object.allow_pass_flags & PASS_PROJECTILE) && projectile)
			continue
		if((istype(object, /obj/structure/mineral_door/resin) || istype(object, /obj/structure/xeno)) && bypass_xeno) //xeno objects are bypassed by flamers
			continue
		if((object.allow_pass_flags & PASS_GLASS) && bypass_window)
			continue
		if((object.allow_pass_flags & PASS_AIR) && air_pass)
			continue
		if(object.flags_atom & ON_BORDER && object.dir != direction)
			continue
		return TRUE
	return FALSE

///Returns true if any object on a turf is both dense and not a window
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
		. = clamp(frequency, MIN_FREE_FREQ, MAX_FREE_FREQ)
	else
		. = clamp(frequency, MIN_FREQ, MAX_FREQ)
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


///Returns the src and all recursive contents as a list.
/atom/proc/GetAllContents()
	. = list(src)
	var/i = 0
	while(i < length(.))
		var/atom/A = .[++i]
		. += A.contents

///identical to getallcontents but returns a list of atoms of the type passed in the argument.
/atom/proc/get_all_contents_type(type)
	var/list/processing_list = list(src)
	. = list()
	while(length(processing_list))
		var/atom/A = processing_list[1]
		processing_list.Cut(1, 2)
		processing_list += A.contents
		if(istype(A, type))
			. += A


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


/proc/DuplicateObject(atom/original, atom/newloc)
	RETURN_TYPE(original.type)
	if(!original || !newloc)
		return

	var/atom/O = new original.type(newloc)
	if(!O)
		return

	O.contents.Cut()

	for(var/V in original.vars - GLOB.duplicate_forbidden_vars)
		if(istype(original.vars[V], /datum) || ismob(original.vars[V]))
			continue // this would reference the original's object, that will break when it is used or deleted.
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

	if(ismob(O)) //Overlays are carried over despite disallowing them, if a fix is found remove this.
		var/mob/M = O
		M.cut_overlays()
		M.regenerate_icons()

	return O


/proc/get_cardinal_dir(atom/A, atom/B)
	var/dx = abs(B.x - A.x)
	var/dy = abs(B.y - A.y)
	return get_dir(A, B) & (rand() * (dx+dy) < dy ? 3 : 12)

/// If given a diagonal dir, return a corresponding cardinal dir. East/west preferred
/proc/closest_cardinal_dir(dir)
	if(!(dir & (dir-1)))
		return dir
	if(dir & EAST)
		return EAST
	return WEST

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
	switch(zone)
		if("r_hand")
			return "right hand"
		if ("l_hand")
			return "left hand"
		if ("l_arm")
			return "left arm"
		if ("r_arm")
			return "right arm"
		if ("l_leg")
			return "left leg"
		if ("r_leg")
			return "right leg"
		if ("l_foot")
			return "left foot"
		if ("r_foot")
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
/obj/item/tool/multitool,
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
	tX = clamp(origin.x + text2num(tX) - round(actual_view[1] * 0.5) + (round(C?.pixel_x / 32)) - 1, 1, world.maxx)
	tY = clamp(origin.y + text2num(tY) - round(actual_view[2] * 0.5) + (round(C?.pixel_y / 32)) - 1, 1, world.maxy)
	return locate(tX, tY, tZ)

///Converts a screen loc param to a x,y coordinate pixel on the screen
/proc/params2screenpixel(scr_loc)
	var/list/x_and_y = splittext(scr_loc, ",")
	var/list/x_dirty = splittext(x_and_y[1], ":")
	var/list/y_dirty = splittext(x_and_y[2], ":")
	var/x = (text2num(x_dirty[1])-1)*32 + text2num(x_dirty[2])
	var/y = (text2num(y_dirty[1])-1)*32 + text2num(y_dirty[2])
	return list(x, y)

//Returns TRUE if the given item is capable of popping things like balloons, inflatable barriers, or cutting police tape.
/proc/can_puncture(obj/item/I)
	if(!istype(I))
		return FALSE
	return (I.sharp || I.heat >= 400 	|| \
		isscrewdriver(I)	 || \
		istype(I, /obj/item/tool/pen) 		 || \
		istype(I, /obj/item/tool/shovel) \
	)

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
	/obj/machinery/power/apc, /obj/machinery/air_alarm, /obj/item/radio/intercom,
	/obj/structure/extinguisher_cabinet, /obj/structure/reagent_dispensers/wallmounted/peppertank,
	/obj/machinery/status_display, /obj/machinery/light_switch, /obj/structure/sign,
	/obj/machinery/newscaster, /obj/machinery/firealarm, /obj/structure/noticeboard, /obj/machinery/door_control,
	/obj/machinery/computer/security/telescreen,
	/obj/item/storage/secure/safe, /obj/machinery/flasher, /obj/machinery/keycard_auth,
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

///Returns a string based on the weight class define used as argument
/proc/weight_class_to_text(w_class)
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			. = "tiny"
		if(WEIGHT_CLASS_SMALL)
			. = "small"
		if(WEIGHT_CLASS_NORMAL)
			. = "normal-sized"
		if(WEIGHT_CLASS_BULKY)
			. = "bulky"
		if(WEIGHT_CLASS_HUGE)
			. = "huge"
		if(WEIGHT_CLASS_GIGANTIC)
			. = "gigantic"
		else
			. = ""

/// Converts a semver string into a list of numbers
/proc/semver_to_list(semver_string)
	var/static/regex/semver_regex = regex(@"(\d+)\.(\d+)\.(\d+)", "")
	if(!semver_regex.Find(semver_string))
		return null

	return list(
		text2num(semver_regex.group[1]),
		text2num(semver_regex.group[2]),
		text2num(semver_regex.group[3]),
	)

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

/**
 * Returns the top-most atom sitting on the turf.
 * For example, using this on a disk, which is in a bag, on a mob,
 * will return the mob because it's on the turf.
 *
 * Arguments
 * * something_in_turf - a movable within the turf, somewhere.
 * * stop_type - optional - stops looking if stop_type is found in the turf, returning that type (if found).
 **/
/proc/get_atom_on_turf(atom/movable/something_in_turf, stop_type)
	if(!istype(something_in_turf))
		CRASH("get_atom_on_turf was not passed an /atom/movable! Got [isnull(something_in_turf) ? "null":"type: [something_in_turf.type]"]")

	var/atom/turf_to_check = something_in_turf
	while(turf_to_check?.loc && !isturf(turf_to_check.loc))
		turf_to_check = turf_to_check.loc
		if(stop_type && istype(turf_to_check, stop_type))
			break
	return turf_to_check

//Repopulates sortedAreas list
/proc/repopulate_sorted_areas()
	GLOB.sorted_areas = list()

	for(var/area/A in world)
		GLOB.sorted_areas.Add(A)

	sortTim(GLOB.sorted_areas, GLOBAL_PROC_REF(cmp_name_asc))


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
	. = list()
	while(length(processing))
		var/atom/A = processing[1]
		processing.Cut(1,2)
		if(ignore_typecache[A.type])
			continue
		processing += A.contents
		. += A

/// Perform a shake on an atom, resets its position afterwards
/atom/proc/Shake(pixelshiftx = 2, pixelshifty = 2, duration = 2.5 SECONDS, shake_interval = 0.02 SECONDS)
	var/initialpixelx = pixel_x
	var/initialpixely = pixel_y
	animate(src, pixel_x = initialpixelx + rand(-pixelshiftx,pixelshiftx), pixel_y = initialpixelx + rand(-pixelshifty,pixelshifty), time = shake_interval, flags = ANIMATION_PARALLEL)
	for (var/i in 3 to ((duration / shake_interval))) // Start at 3 because we already applied one, and need another to reset
		animate(pixel_x = initialpixelx + rand(-pixelshiftx,pixelshiftx), pixel_y = initialpixely + rand(-pixelshifty,pixelshifty), time = shake_interval)
	animate(pixel_x = initialpixelx, pixel_y = initialpixely, time = shake_interval)

/atom/proc/contains(atom/A)
	if(!A)
		return FALSE
	for(var/atom/location = A.loc, location, location = location.loc)
		if(location == src)
			return TRUE

GLOBAL_DATUM_INIT(dview_mob, /mob/dview, new)

/// Version of view() which ignores darkness, because BYOND doesn't have it (I actually suggested it but it was tagged redundant, BUT HEARERS IS A T- /rant).
/proc/dview(range = world.view, center, invis_flags = 0)
	if(!center)
		return

	GLOB.dview_mob.loc = center

	GLOB.dview_mob.see_invisible = invis_flags

	. = view(range, GLOB.dview_mob)
	GLOB.dview_mob.loc = null

/mob/dview
	name = "INTERNAL DVIEW MOB"
	invisibility = 101
	density = FALSE
	see_in_dark = 1e6
	move_resist = INFINITY
	var/ready_to_die = FALSE

/mob/dview/Initialize(mapload) //Properly prevents this mob from gaining huds or joining any global lists
	SHOULD_CALL_PARENT(FALSE)
	if(flags_atom & INITIALIZED)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_atom |= INITIALIZED
	return INITIALIZE_HINT_NORMAL

/mob/dview/Destroy(force = FALSE)
	if(!ready_to_die)
		stack_trace("ALRIGHT WHICH FUCKER TRIED TO DELETE *MY* DVIEW?")

		if (!force)
			return QDEL_HINT_LETMELIVE

		log_world("EVACUATE THE SHITCODE IS TRYING TO STEAL MUH JOBS")
		GLOB.dview_mob = new
	return ..()


#define FOR_DVIEW(type, range, center, invis_flags) \
	GLOB.dview_mob.loc = center;           \
	GLOB.dview_mob.see_invisible = invis_flags; \
	for(type in view(range, GLOB.dview_mob))

#define FOR_DVIEW_END GLOB.dview_mob.loc = null

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
	addtimer(CALLBACK(GLOBAL_PROC, TYPE_PROC_REF(/, fade_out), I), duration - 0.5 SECONDS)

/proc/fade_out(image/I, list/show_to)
	animate(I, alpha = 0, time = 0.5 SECONDS, easing = EASE_IN)
	addtimer(CALLBACK(GLOBAL_PROC, TYPE_PROC_REF(/, remove_images_from_clients), I, show_to), 0.5 SECONDS)

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

///Returns a list of all items of interest with their name
/proc/getpois(mobs_only = FALSE, skip_mindless = FALSE, specify_dead_role = TRUE)
	var/list/mobs = sortmobs()
	var/list/namecounts = list()
	var/list/pois = list()
	for(var/mob/M AS in mobs)
		if(skip_mindless && (!M.mind && !M.ckey))
			continue
		if(M.client?.holder)
			if(M.client.holder.fakekey || M.client.holder.invisimined) //stealthmins
				continue
		var/name = avoid_assoc_duplicate_keys(M.name, namecounts)

		if(M.real_name && M.real_name != M.name)
			name += " \[[M.real_name]\]"
		if(M.stat == DEAD && specify_dead_role)
			if(isobserver(M))
				name += " \[ghost\]"
			else
				name += " \[dead\]"
		pois[name] = M

	return pois

///Returns the left and right dir of the input dir, used for AI stutter step while attacking
/proc/LeftAndRightOfDir(direction, diagonal_check = FALSE)
	if(diagonal_check)
		if(ISDIAGONALDIR(direction))
			return list(turn(direction, 45), turn(direction, -45))
	return list(turn(direction, 90), turn(direction, -90))

/proc/CallAsync(datum/source, proctype, list/arguments)
	set waitfor = FALSE
	return call(source, proctype)(arglist(arguments))

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))


///Takes: Area type as text string or as typepath OR an instance of the area. Returns: A list of all areas of that type in the world.
/proc/get_areas(areatype, subtypes=TRUE)
	if(istext(areatype))
		areatype = text2path(areatype)
	else if(isarea(areatype))
		var/area/areatemp = areatype
		areatype = areatemp.type
	else if(!ispath(areatype))
		return null

	var/list/areas = list()
	if(subtypes)
		var/list/cache = typecacheof(areatype)
		for(var/V in GLOB.sorted_areas)
			var/area/A = V
			if(cache[A.type])
				areas += V
	else
		for(var/V in GLOB.sorted_areas)
			var/area/A = V
			if(A.type == areatype)
				areas += V
	return areas

/**
 *	Generates a cone shape. Any other checks should be handled with the resulting list. Can work with up to 359 degrees
 *	Variables:
 *	center - where the cone begins, or center of a circle drawn with this
 *	max_row_count - how many rows are checked
 *	starting_row - from how far should the turfs start getting included in the cone
 *	cone_width - big the angle of the cone is
 *	cone_direction - at what angle should the cone be made, relative to the game board's orientation
 *	blocked - whether the cone should take into consideration solid walls
 */
/proc/generate_cone(atom/center, max_row_count = 10, starting_row = 1, cone_width = 60, cone_direction = 0, blocked = TRUE)
	var/right_angle = cone_direction + cone_width/2
	var/left_angle = cone_direction - cone_width/2

	//These are needed because degrees need to be from 0 to 359 for the checks to function
	if(right_angle >= 360)
		right_angle -= 360

	if(left_angle < 0)
		left_angle += 360

	///the 3 directions in the direction on the cone that will be checked
	var/cardinals = GLOB.cardinals - REVERSE_DIR(cone_direction)
	///turfs that are checked whether the cone can continue further from them
	var/list/turfs_to_check = list(get_turf(center))
	var/list/cone_turfs = list()

	for(var/r in 1 to max_row_count)
		for(var/X in turfs_to_check)
			var/turf/trf = X
			for(var/direction in cardinals)
				var/turf/T = get_step(trf, direction)
				if(cone_turfs.Find(T))
					continue
				if(get_dist(center, T) < starting_row)
					continue
				var/turf_angle = Get_Angle(center, T)
				if(right_angle > left_angle && (turf_angle > right_angle || turf_angle < left_angle))
					continue
				if(turf_angle > right_angle && turf_angle < left_angle)
					continue
				if(blocked)
					if(T.density || LinkBlocked(trf, T) || TurfBlockedNonWindow(T))
						continue
				cone_turfs += T
				turfs_to_check += T
			turfs_to_check -= trf
	return	cone_turfs

///Returns a list of all locations (except the area) the movable is within.
/proc/get_nested_locs(atom/movable/atom_on_location, include_turf = FALSE)
	. = list()
	var/atom/location = atom_on_location.loc
	var/turf/turf = get_turf(atom_on_location)
	while(location && location != turf)
		. += location
		location = location.loc
	if(location && include_turf) //At this point, only the turf is left, provided it exists.
		. += location

/**
 *	Generates a cone shape. Any other checks should be handled with the resulting list. Can work with up to 359 degrees
 *	Variables:
 *	center - where the cone begins, or center of a circle drawn with this
 *	max_row_count - how many rows are checked
 *	starting_row - from how far should the turfs start getting included in the cone. -1 required to include center turf due to byond
 *	cone_width - big the angle of the cone is
 *	cone_direction - at what angle should the cone be made, relative to the game board's orientation
 *	blocked - whether the cone should take into consideration solid walls
 *	bypass_window - whether it will go through transparent windows like lasers
 *	projectile - whether PASS_PROJECTILE will be checked to ignore dense objects like projectiles
 *	bypass_xeno - whether to bypass dense xeno structures like flamers
 *	air_pass - whether to bypass non airtight atoms
 */
/proc/generate_true_cone(atom/center, max_row_count = 10, starting_row = 1, cone_width = 60, cone_direction = 0, blocked = TRUE, bypass_window = FALSE, projectile = FALSE, bypass_xeno = FALSE, air_pass = FALSE)
	var/right_angle = cone_direction + cone_width/2
	var/left_angle = cone_direction - cone_width/2

	//These are needed because degrees need to be from 0 to 359 for the checks to function
	if(right_angle >= 360)
		right_angle -= 360

	if(left_angle < 0)
		left_angle += 360
	center = get_turf(center)
	var/list/cardinals = GLOB.alldirs
	var/list/turfs_to_check = list(center)
	var/list/cone_turfs = list(center)

	for(var/row in 1 to max_row_count)
		if(row > 2)
			cardinals = GLOB.cardinals
		for(var/turf/old_turf AS in turfs_to_check) //checks the inital turf, then afterwards checks every turf that is added to cone_turfs
			for(var/direction AS in cardinals)
				var/turf/turf_to_check = get_step(old_turf, direction) //checks all turfs around X
				if(cone_turfs.Find(turf_to_check))
					continue
				var/turf_angle = Get_Angle(center, turf_to_check)
				if(right_angle > left_angle && (turf_angle > right_angle || turf_angle < left_angle))
					continue
				if(turf_angle > right_angle && turf_angle < left_angle)
					continue
				if(blocked && LinkBlocked(old_turf, turf_to_check, bypass_window, projectile, bypass_xeno, air_pass))
					continue
				cone_turfs += turf_to_check
				turfs_to_check += turf_to_check
			turfs_to_check -= old_turf
		for(var/turf/checked_turf AS in cone_turfs)
			if(get_dist(center, checked_turf) < starting_row) //if its before the starting row, ignore it.
				cone_turfs -= checked_turf
	return	cone_turfs

GLOBAL_LIST_INIT(survivor_outfits, typecacheof(/datum/outfit/job/survivor))

/**
 *	Draws a line between two atoms, then checks if the path is blocked.
 *	Variables:
 *	start -start point of the path
 *	end - end point of the path
 *	bypass_window - whether it will go through transparent windows in the same way as lasers
 *	projectile - whether PASS_PROJECTILE will be checked to ignore dense objects in the same way as projectiles
 *	bypass_xeno - whether to bypass dense xeno structures in the same way as flamers
 *	air_pass - whether to bypass non airtight atoms
 */
/proc/check_path(atom/start, atom/end, bypass_window = FALSE, projectile = FALSE, bypass_xeno = FALSE, air_pass = FALSE)
	var/list/path_to_target = getline(start, end)
	var/line_count = 1
	while(line_count < length(path_to_target))
		if(LinkBlocked(path_to_target[line_count], path_to_target[line_count + 1], bypass_window, projectile, bypass_xeno, air_pass))
			return FALSE
		line_count ++
	return TRUE
