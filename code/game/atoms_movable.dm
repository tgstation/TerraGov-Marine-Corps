/atom/movable
	layer = OBJ_LAYER
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE
	var/last_move = null
	var/last_move_time = 0
	var/anchored = FALSE
	///How much the atom tries to push things out its way
	var/move_force = MOVE_FORCE_DEFAULT
	///How much the atom resists being thrown or moved.
	var/move_resist = MOVE_RESIST_DEFAULT
	///Delay added to mob's move_delay when pulling it.
	var/drag_delay = 3
	///Wind-up before the mob can pull an object.
	var/drag_windup = 1.5 SECONDS
	var/throwing = FALSE
	var/thrower = null
	///Speed of the current throw. 0 When not throwing.
	var/thrown_speed = 0
	var/turf/throw_source = null
	var/throw_speed = 2
	var/throw_range = 7
	var/mob/pulledby = null
	var/atom/movable/pulling
	var/atom/movable/moving_from_pull		//attempt to resume grab after moving instead of before.
	var/glide_modifier_flags = NONE

	var/status_flags = CANSTUN|CANKNOCKDOWN|CANKNOCKOUT|CANPUSH|CANUNCONSCIOUS|CANCONFUSE	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)
	var/generic_canpass = TRUE
	///What things this atom can move past, if it has the corrosponding flag
	var/pass_flags = NONE
	///TRUE if we should not push or shuffle on bump/enter
	var/moving_diagonally = FALSE

	var/initial_language_holder = /datum/language_holder
	var/datum/language_holder/language_holder
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_sing = "sings"
	var/verb_yell = "yells"
	var/speech_span

	var/grab_state = GRAB_PASSIVE //if we're pulling a mob, tells us how aggressive our grab is.
	var/atom/movable/buckled // movable atom we are buckled to
	var/list/mob/living/buckled_mobs // mobs buckled to this mob
	var/buckle_flags = NONE
	var/max_buckled_mobs = 1
	var/buckle_lying = -1 //bed-like behaviour, forces mob.lying_angle = buckle_lying if != -1

	var/datum/component/orbiter/orbiting

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = EMISSIVE_BLOCK_NONE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block

	/// The voice that this movable makes when speaking
	var/voice
	/// The pitch adjustment that this movable uses when speaking.
	var/pitch = 0
	/// The filter to apply to the voice when processing the TTS audio message.
	var/voice_filter = ""
	/// Set to anything other than "" to activate the silicon voice effect for TTS messages.
	var/tts_silicon_voice_effect = ""

	///Lazylist to keep track on the sources of illumination.
	var/list/affected_movable_lights
	///Highest-intensity light affecting us, which determines our visibility.
	var/affecting_dynamic_lumi = 0
	/**
	 * an associative lazylist of relevant nested contents by "channel", the list is of the form: list(channel = list(important nested contents of that type))
	 * each channel has a specific purpose and is meant to replace potentially expensive nested contents iteration.
	 * do NOT add channels to this for little reason as it can add considerable memory usage.
	 */
	var/list/important_recursive_contents
	///contains every client mob corresponding to every client eye in this container. lazily updated by SSparallax and is sparse:
	///only the last container of a client eye has this list assuming no movement since SSparallax's last fire
	var/list/client_mobs_in_contents

//===========================================================================
/atom/movable/Initialize(mapload, ...)
	. = ..()
	// This one is incredible.
	// `if (x) else { /* code */ }` is surprisingly fast, and it's faster than a switch, which is seemingly not a jump table.
	// From what I can tell, a switch case checks every single branch individually, although sane, is slow in a hot proc like this.
	// So, we make the most common `blocks_emissive` value, EMISSIVE_BLOCK_GENERIC, 0, getting to the fast else branch quickly.
	// If it fails, then we can check over every value it can be (here, EMISSIVE_BLOCK_UNIQUE is the only one that matters).
	// This saves several hundred milliseconds of init time.
	if(blocks_emissive)
		if(blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(src, render_target)
			add_overlay(list(em_block))
	else
		var/mutable_appearance/gen_emissive_blocker = mutable_appearance(icon, icon_state, plane = EMISSIVE_PLANE, alpha = src.alpha)
		gen_emissive_blocker.color = GLOB.em_block_color
		gen_emissive_blocker.dir = dir
		gen_emissive_blocker.appearance_flags |= appearance_flags
		add_overlay(list(gen_emissive_blocker))

	if(opacity)
		AddElement(/datum/element/light_blocking)
	if(light_system == MOVABLE_LIGHT)
		AddComponent(/datum/component/overlay_lighting)


/atom/movable/Destroy()
	QDEL_NULL(proximity_monitor)
	QDEL_NULL(language_holder)
	QDEL_NULL(em_block)

	var/old_loc = loc

	loc?.handle_atom_del(src)

	if(opacity)
		RemoveElement(/datum/element/light_blocking)

	if(LAZYLEN(buckled_mobs))
		unbuckle_all_mobs(force = TRUE)

	if(throw_source)
		throw_source = null

	if(thrower)
		thrower = null

	LAZYCLEARLIST(client_mobs_in_contents)

	. = ..()

	for(var/movable_content in contents)
		qdel(movable_content)

	moveToNullspace()

	if(important_recursive_contents && (important_recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] || important_recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
		SSspatial_grid.force_remove_from_cell(src)


	//This absolutely must be after moveToNullspace()
	//We rely on Entered and Exited to manage this list, and the copy of this list that is on any /atom/movable "Containers"
	//If we clear this before the nullspace move, a ref to this object will be hung in any of its movable containers
	LAZYCLEARLIST(important_recursive_contents)

	if(smoothing_flags && isturf(old_loc))
		QUEUE_SMOOTH_NEIGHBORS(old_loc)

	invisibility = INVISIBILITY_ABSTRACT

	pulledby?.stop_pulling()

	if(orbiting)
		orbiting.end_orbit(src)
		orbiting = null

	vis_locs = null //clears this atom out of all viscontents

	// Checking length(vis_contents) before cutting has significant speed benefits
	if (length(vis_contents))
		vis_contents.Cut()

	QDEL_NULL(light)
	QDEL_NULL(static_light)

///Updates this movables emissive overlay
/atom/movable/proc/update_emissive_block()
	// This one is incredible.
	// `if (x) else { /* code */ }` is surprisingly fast, and it's faster than a switch, which is seemingly not a jump table.
	// From what I can tell, a switch case checks every single branch individually, although sane, is slow in a hot proc like this.
	// So, we make the most common `blocks_emissive` value, EMISSIVE_BLOCK_GENERIC, 0, getting to the fast else branch quickly.
	// If it fails, then we can check over every value it can be (here, EMISSIVE_BLOCK_UNIQUE is the only one that matters).
	// This saves several hundred milliseconds of init time.
	if(blocks_emissive)
		if(blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
			if(!em_block)
				render_target = ref(src)
				em_block = new(src, render_target)
			return em_block
	else
		var/mutable_appearance/gen_emissive_blocker = emissive_blocker(icon, icon_state, alpha = src.alpha, appearance_flags = src.appearance_flags)
		gen_emissive_blocker.dir = dir

/atom/movable/update_overlays()
	. = ..()
	. += update_emissive_block()

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	var/atom/old_loc = loc
	loc = new_loc
	Moved(old_loc)

/**
 * The move proc is responsible for (in order):
 * - Checking if you can move out of the current loc (The exit proc, which calls on_exit through the connect_loc)
 * - Checking if you can move into the new loc (The enter proc, which calls on_enter through the connect_loc and is also overwritten by some atoms)
 *   This is where most bumps take place
 * - If you can do both, then it changes the loc var calls Exited on the old loc, and Entered on the new loc
 * - After that, it does some area checks, calls Moved and handle pulling/buckled mobs.area
 *
 * A diagonal move is slightly different as Moved, entered and exited is called only once
 * In order of calling:
 * - Check if you can exit the current loc
 * - Check if it's a diagonal move
 * - If yes, check if you could exit the turf in that direction, and then if you can enter it (This calls on_exit and on_enter)
 * - Check if you can enter the final new loc
 * - Do the rest of the Move proc normally (Moved, entered, exited, check area change etc)
 *
 * Warning : Doesn't support well multi-tile diagonal moves
 */
/atom/movable/Move(atom/newloc, direction, glide_size_override)
	var/atom/movable/pullee = pulling
	if(!moving_from_pull)
		check_pulling()
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc, direction) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return FALSE
	if(!loc || !newloc || loc == newloc)
		return FALSE

	if(!direction)
		direction = get_dir(src, newloc)

	var/can_pass_diagonally = NONE
	if (direction & (direction - 1)) //Check if the first part of the diagonal move is possible
		moving_diagonally = TRUE
		if(!(flags_atom & DIRLOCK))
			setDir(direction) //We first set the direction to prevent going through dir sensible object
		if((direction & NORTH) && loc.Exit(src, NORTH) && get_step(loc, NORTH).Enter(src))
			can_pass_diagonally = NORTH
		else if((direction & SOUTH) && loc.Exit(src, SOUTH) && get_step(loc, SOUTH).Enter(src))
			can_pass_diagonally = SOUTH
		else if((direction & EAST) && loc.Exit(src, EAST) && get_step(loc, EAST).Enter(src))
			can_pass_diagonally = EAST
		else if((direction & WEST) && loc.Exit(src, WEST) && get_step(loc, WEST).Enter(src))
			can_pass_diagonally = WEST
		else
			moving_diagonally = FALSE
			return
		moving_diagonally = FALSE
		if(!get_step(loc, can_pass_diagonally)?.Exit(src, direction & ~can_pass_diagonally))
			return Move(get_step(loc, can_pass_diagonally), can_pass_diagonally)
		if(!(flags_atom & DIRLOCK)) //We want to set the direction to be the one of the "second" diagonal move, aka not can_pass_diagonally
			setDir(direction &~ can_pass_diagonally)

	else
		if(!loc.Exit(src, direction))
			return
		if(!(flags_atom & DIRLOCK))
			setDir(direction)

	var/enter_return_value = newloc.Enter(src)
	if(!(enter_return_value & TURF_CAN_ENTER))
		if(can_pass_diagonally && !(enter_return_value & TURF_ENTER_ALREADY_MOVED))
			return Move(get_step(loc, can_pass_diagonally), can_pass_diagonally)
		return

	var/atom/oldloc = loc
	loc = newloc
	oldloc.Exited(src, direction)

	if(!loc || loc == oldloc)
		last_move = 0
		return

	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)

	if(oldarea != newarea)
		oldarea.Exited(src, direction)

	newloc.Entered(src, oldloc)

	if(oldarea != newarea)
		newarea.Entered(src, oldarea)

	if(glide_size_override)
		set_glide_size(glide_size_override)

	Moved(oldloc, direction)

	if(pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			var/pull_dir = get_dir(src, pulling)
			//puller and pullee more than one tile away or in diagonal position
			if(get_dist(src, pulling) > 1 || (pull_dir - 1) & pull_dir)
				pulling.moving_from_pull = src
				pulling.Move(oldloc, get_dir(pulling, oldloc), glide_size_override) //the pullee tries to reach our previous position
				pulling.moving_from_pull = null
			check_pulling()

	last_move = direction
	last_move_time = world.time

	if(LAZYLEN(buckled_mobs) && !handle_buckled_mob_movement(loc, direction)) //movement failed due to buckled mob(s)
		return FALSE
	return TRUE


/atom/movable/Bump(atom/A)
	SHOULD_CALL_PARENT(TRUE)
	if(!A)
		CRASH("Bump was called with no argument.")
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A) & COMPONENT_BUMP_RESOLVED)
		return COMPONENT_BUMP_RESOLVED
	. = ..()
	if(throwing)
		. = !throw_impact(A, thrown_speed)
	if(QDELETED(A))
		return
	A.Bumped(src)


// Make sure you know what you're doing if you call this, this is intended to only be called by byond directly.
// You probably want CanPass()
/atom/movable/Cross(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSS, AM)
	return CanPass(AM, AM.loc)


///default byond proc that is deprecated for us in lieu of signals. do not call
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("atom/movable/Crossed() was called!")

/**
 * `Uncross()` is a default BYOND proc that is called when something is *going*
 * to exit this atom's turf. It is prefered over `Uncrossed` when you want to
 * deny that movement, such as in the case of border objects, objects that allow
 * you to walk through them in any direction except the one they block
 * (think side windows).
 *
 * While being seemingly harmless, most everything doesn't actually want to
 * use this, meaning that we are wasting proc calls for every single atom
 * on a turf, every single time something exits it, when basically nothing
 * cares.
 *
 * This overhead caused real problems on Sybil round #159709, where lag
 * attributed to Uncross was so bad that the entire master controller
 * collapsed and people made Among Us lobbies in OOC.
 *
 * If you want to replicate the old `Uncross()` behavior, the most apt
 * replacement is [`/datum/element/connect_loc`] while hooking onto
 * [`COMSIG_ATOM_EXIT`].
 */
/atom/movable/Uncross()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("Uncross() should not be being called, please read the doc-comment for it for why.")

/**
 * default byond proc that is normally called on everything inside the previous turf
 * a movable was in after moving to its current turf
 * this is wasteful since the vast majority of objects do not use Uncrossed
 * use connect_loc to register to COMSIG_ATOM_EXITED instead
 */
/atom/movable/Uncrossed(atom/movable/AM)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("/atom/movable/Uncrossed() was called")


/atom/movable/proc/Moved(atom/old_loc, movement_dir, forced = FALSE, list/old_locs)
	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, movement_dir, forced, old_locs)
	if(client_mobs_in_contents)
		update_parallax_contents()

	if(pulledby)
		SEND_SIGNAL(src, COMSIG_MOVABLE_PULL_MOVED, old_loc, movement_dir, forced, old_locs)
	//Cycle through the light sources on this atom and tell them to update.
	for(var/datum/dynamic_light_source/light AS in hybrid_light_sources)
		light.source_atom.update_light()
		if(!isturf(loc))
			light.find_containing_atom()
	for(var/datum/static_light_source/L AS in static_light_sources) // Cycle through the light sources on this atom and tell them to update.
		L.source_atom.static_update_light()

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)

	if(HAS_SPATIAL_GRID_CONTENTS(src))
		if(old_turf && new_turf && (old_turf.z != new_turf.z \
			|| ROUND_UP(old_turf.x / SPATIAL_GRID_CELLSIZE) != ROUND_UP(new_turf.x / SPATIAL_GRID_CELLSIZE) \
			|| ROUND_UP(old_turf.y / SPATIAL_GRID_CELLSIZE) != ROUND_UP(new_turf.y / SPATIAL_GRID_CELLSIZE)))

			SSspatial_grid.exit_cell(src, old_turf)
			SSspatial_grid.enter_cell(src, new_turf)

		else if(old_turf && !new_turf)
			SSspatial_grid.exit_cell(src, old_turf)

		else if(new_turf && !old_turf)
			SSspatial_grid.enter_cell(src, new_turf)

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
	var/atom/oldloc = loc
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)
		var/movement_dir = get_dir(src, destination)

		loc = destination

		if(!same_loc)
			if(oldloc)
				oldloc.Exited(src, movement_dir)
				if(old_area && old_area != destarea)
					old_area.Exited(src, movement_dir)
			var/turf/oldturf = get_turf(oldloc)
			var/turf/destturf = get_turf(destination)
			var/old_z = (oldturf ? oldturf.z : null)
			var/dest_z = (destturf ? destturf.z : null)
			if(old_z != dest_z)
				onTransitZ(old_z, dest_z)
			destination.Entered(src, oldloc)
			if(destarea && old_area != destarea)
				destarea.Entered(src, oldloc)

		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE
		loc = null
		if(oldloc)
			var/area/old_area = get_area(oldloc)
			oldloc.Exited(src, NONE)
			if(old_area)
				old_area.Exited(src, NONE)

	Moved(oldloc, NONE, TRUE)

/atom/movable/Exited(atom/movable/gone, direction)
	. = ..()
	if(LAZYLEN(gone.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in gone.important_recursive_contents)
			for(var/atom/movable/location AS in nested_locs)
				LAZYREMOVEASSOC(location.important_recursive_contents, channel, gone.important_recursive_contents[channel])

/atom/movable/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(LAZYLEN(arrived.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in arrived.important_recursive_contents)
			for(var/atom/movable/location AS in nested_locs)
				LAZYORASSOCLIST(location.important_recursive_contents, channel, arrived.important_recursive_contents[channel])

///called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, speed, bounce = TRUE)
	var/hit_successful
	var/old_throw_source = throw_source
	hit_successful = hit_atom.hitby(src, speed)
	if(hit_successful)
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom)
		if(bounce && hit_atom.density && !isliving(hit_atom))
			INVOKE_NEXT_TICK(src, PROC_REF(throw_bounce), hit_atom, old_throw_source)
	return hit_successful //if the throw missed, it continues

///Bounces the AM off hit_atom
/atom/movable/proc/throw_bounce(atom/hit_atom, turf/old_throw_source)
	if(QDELETED(src))
		return
	if(!isturf(loc))
		return
	var/dir_to_proj = get_dir(hit_atom, old_throw_source)
	if(ISDIAGONALDIR(dir_to_proj))
		var/list/cardinals = list(turn(dir_to_proj, 45), turn(dir_to_proj, -45))
		for(var/direction in cardinals)
			var/turf/turf_to_check = get_step(hit_atom, direction)
			if(turf_to_check.density)
				cardinals -= direction
		dir_to_proj = pick(cardinals)

	var/perpendicular_angle = Get_Angle(hit_atom, get_step(hit_atom, dir_to_proj))
	var/new_angle = (perpendicular_angle + (perpendicular_angle - Get_Angle(old_throw_source, src) - 180) + rand(-10, 10))

	if(new_angle < -360)
		new_angle += 720 //north is 0 instead of 360
	else if(new_angle < 0)
		new_angle += 360
	else if(new_angle > 360)
		new_angle -= 360

	step(src, angle_to_dir(new_angle))

/atom/movable/proc/throw_at(atom/target, range, speed = 5, thrower, spin, flying = FALSE, targetted_throw = TRUE)
	set waitfor = FALSE
	if(!target || !src)
		return FALSE

	var/gravity = get_gravity()
	if(gravity < 1)
		range = round(range * (2 - gravity))
	else if(gravity > 1)
		range = ROUND_UP(range * (2 - gravity))

	if(!targetted_throw)
		target = get_turf_in_angle(Get_Angle(src, target), target, range - get_dist(src, target))

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_THROW) & COMPONENT_MOVABLE_BLOCK_PRE_THROW)
		return FALSE

	var/turf/origin = get_turf(src)

	if(spin)
		animation_spin(5, 1)

	set_throwing(TRUE)
	src.thrower = thrower
	thrown_speed = speed

	var/original_layer = layer
	if(flying)
		set_flying(TRUE, FLY_LAYER)

	var/originally_dir_locked = flags_atom & DIRLOCK
	if(!originally_dir_locked)
		setDir(get_dir(src, target))
		flags_atom |= DIRLOCK

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

	var/dist_since_sleep = 0

	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		while(!gc_destroyed && target &&((((x < target.x && dx == EAST) || (x > target.x && dx == WEST)) && get_dist_euclide(origin, src) < range) || isspaceturf(loc)) && throwing && istype(loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				error += dist_x
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				error -= dist_y
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
	else
		var/error = dist_y/2 - dist_x
		while(!gc_destroyed && target &&((((y < target.y && dy == NORTH) || (y > target.y && dy == SOUTH)) && get_dist_euclide(origin, src) < range) || isspaceturf(loc)) && throwing && istype(loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				error += dist_y
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				Move(step)
				error -= dist_x
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)

	//done throwing, either because it hit something or it finished moving
	if(!originally_dir_locked)
		flags_atom &= ~DIRLOCK
	if(isobj(src) && throwing)
		throw_impact(get_turf(src), speed)
	if(loc)
		stop_throw(flying, original_layer)
		SEND_SIGNAL(loc, COMSIG_TURF_THROW_ENDED_HERE, src)
	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW)

/// Annul all throw var to ensure a clean exit out of throw state
/atom/movable/proc/stop_throw(flying = FALSE, original_layer)
	set_throwing(FALSE)
	if(flying)
		set_flying(FALSE, original_layer)
	thrower = null
	thrown_speed = 0
	throw_source = null

/atom/movable/proc/handle_buckled_mob_movement(NewLoc, direct)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(buckled_mob.Move(NewLoc, direct))
			continue
		forceMove(buckled_mob.loc)
		last_move = buckled_mob.last_move
		return FALSE
	return TRUE

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


/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	var/direction = get_dir(src, A)
	switch(direction)
		if(NORTH)
			pixel_y_diff = 8
		if(SOUTH)
			pixel_y_diff = -8
		if(EAST)
			pixel_x_diff = 8
		if(WEST)
			pixel_x_diff = -8
		if(NORTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = 8
		if(NORTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = 8
		if(SOUTHEAST)
			pixel_x_diff = 8
			pixel_y_diff = -8
		if(SOUTHWEST)
			pixel_x_diff = -8
			pixel_y_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 0.2 SECONDS, flags = ANIMATION_PARALLEL)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 0.2 SECONDS)


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
		I.appearance_flags = APPEARANCE_UI

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

	flick_overlay_view(I, A, 0.5 SECONDS)

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
	.["Edit Particles"] = "?_src_=vars;[HrefToken()];modify_particles=[REF(src)]"


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


/atom/movable/proc/can_speak_in_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()

	if(H.has_language(dt) == LANGUAGE_KNOWN)
		return TRUE
	if(H.omnitongue)
		return TRUE
	if(H.only_speaks_language == dt)
		return TRUE

	return FALSE


/atom/movable/proc/can_understand_in_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()

	if(H.has_language(dt) == LANGUAGE_SHADOWED)
		return TRUE
	if(H.omnitongue)
		return TRUE
	if(H.only_speaks_language == dt)
		return TRUE

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


/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, force = MOVE_FORCE_STRONG)
	if((force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
		return
	return throw_at(target, range, speed, thrower, spin)


/atom/movable/proc/start_pulling(atom/movable/AM, force = move_force, suppress_message = FALSE)
	if(QDELETED(AM))
		return FALSE

	if(!(AM.can_be_pulled(src, force)))
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
	AM.glide_modifier_flags |= GLIDE_MOD_PULLED
	if(ismob(AM))
		var/mob/M = AM
		if(M.buckled)
			if(!M.buckled.anchored)
				return start_pulling(M.buckled)
			M.buckled.set_glide_size(glide_size)
		else
			M.set_glide_size(glide_size)
		log_combat(src, M, "grabbed", addition = "passive grab")
		if(!suppress_message)
			visible_message(span_warning("[src] has grabbed [M] passively!"))
	else
		pulling.set_glide_size(glide_size)
	return TRUE


/atom/movable/proc/stop_pulling()
	if(!pulling)
		return FALSE

	setGrabState(GRAB_PASSIVE)

	pulling.pulledby = null
	pulling.glide_modifier_flags &= ~GLIDE_MOD_PULLED
	if(ismob(pulling))
		var/mob/pulled_mob = pulling
		if(pulled_mob.buckled)
			pulled_mob.buckled.reset_glide_size()
		else
			pulled_mob.reset_glide_size()
	else
		pulling.reset_glide_size()
	pulling = null

	return TRUE


/atom/movable/proc/Move_Pulled(turf/target)
	if(!pulling)
		return FALSE
	if(pulling.anchored || !pulling.Adjacent(src))
		stop_pulling()
		return FALSE
	var/move_dir = get_dir(pulling.loc, target)
	var/turf/destination_turf = get_step(pulling.loc, move_dir)
	if(!Adjacent(destination_turf) || (destination_turf == loc && pulling.density))
		return FALSE
	pulling.Move(destination_turf, move_dir)
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
	if(pulledby && get_dist(src, pulledby) > 1)		//separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


/atom/movable/proc/can_be_pulled(user, force)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || throwing)
		return FALSE
	if(buckled && buckle_flags & BUCKLE_PREVENTS_PULL)
		return FALSE
	if(status_flags & INCORPOREAL) //Incorporeal things can't be grabbed.
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		return FALSE
	return TRUE


/atom/movable/proc/is_buckled()
	return buckled


/atom/movable/proc/set_glide_size(target = 8)
	if(glide_size == target)
		return FALSE
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target
	if(pulling && pulling.glide_size != target)
		pulling.set_glide_size(target)
	return TRUE

/obj/set_glide_size(target = 8)
	. = ..()
	if(!.)
		return
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(buckled_mob.glide_size == target)
			continue
		buckled_mob.set_glide_size(target)

/obj/structure/bed/set_glide_size(target = 8)
	. = ..()
	if(!.)
		return
	if(buckled_bodybag && buckled_bodybag.glide_size != target)
		buckled_bodybag.set_glide_size(target)
	glide_size = target


/atom/movable/proc/reset_glide_size()
	if(glide_modifier_flags)
		return
	set_glide_size(initial(glide_size))

/obj/vehicle/reset_glide_size()
	if(glide_modifier_flags)
		return
	set_glide_size(DELAY_TO_GLIDE_SIZE_STATIC(move_delay))

/mob/reset_glide_size()
	if(glide_modifier_flags)
		return
	set_glide_size(DELAY_TO_GLIDE_SIZE(cached_multiplicative_slowdown))

///Change the direction of the atom to face the targeted atom
/atom/movable/proc/face_atom(atom/A)
	if(!A || !x || !y || !A.x || !A.y)
		return
	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy) // Wall items are graphically shifted but on the floor
		if(A.pixel_y > 16)
			setDir(NORTH)
		else if(A.pixel_y < -16)
			setDir(SOUTH)
		else if(A.pixel_x > 16)
			setDir(EAST)
		else if(A.pixel_x < -16)
			setDir(WEST)
		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			setDir(NORTH)
		else
			setDir(SOUTH)
	else
		if(dx > 0)
			setDir(EAST)
		else
			setDir(WEST)

/mob/face_atom(atom/A)
	if(buckled || stat != CONSCIOUS)
		return
	return ..()


/atom/movable/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("x")
			var/turf/T = locate(var_value, y, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("y")
			var/turf/T = locate(x, var_value, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("z")
			var/turf/T = locate(x, y, var_value)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("loc")
			if(istype(var_value, /atom))
				forceMove(var_value)
				return TRUE
			else if(isnull(var_value))
				moveToNullspace()
				return TRUE
			return FALSE
	return ..()


/atom/movable/proc/resisted_against(datum/source) //COMSIG_LIVING_DO_RESIST
	SIGNAL_HANDLER_DOES_SLEEP

	var/mob/resisting_mob = source
	if(resisting_mob.restrained(RESTRAINED_XENO_NEST))
		return FALSE
	user_unbuckle_mob(resisting_mob, resisting_mob)


/atom/movable/proc/setGrabState(newstate)
	if(newstate == grab_state)
		return
	. = grab_state
	grab_state = newstate

///Toggles AM between throwing states
/atom/movable/proc/set_throwing(new_throwing, flying)
	if(new_throwing == throwing)
		return
	. = throwing
	throwing = new_throwing
	if(throwing)
		pass_flags |= PASS_THROW
	else
		pass_flags &= ~PASS_THROW

///Toggles AM between flying states
/atom/movable/proc/set_flying(flying, new_layer)
	if(flying)
		pass_flags |= HOVERING
		layer = new_layer
		return
	pass_flags &= ~HOVERING
	layer = new_layer ? new_layer : initial(layer)

///returns bool for if we want to get forcepushed
/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

///returns bool for if we want to get handle forcepushing, return is bool if we can move an anchored obj
/atom/movable/proc/force_push(atom/movable/pushed_atom, force = move_force, direction, silent = FALSE)
	. = pushed_atom.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message(span_warning("[src] forcefully pushes against [pushed_atom]!"), span_warning("You forcefully push against [pushed_atom]!"))

///returns bool for if we want to get handle move crushing, return is bool if we can move an anchored obj
/atom/movable/proc/move_crush(atom/movable/crushed_atom, force = move_force, direction, silent = FALSE)
	. = crushed_atom.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message(span_danger("[src] crushes past [crushed_atom]!"), span_danger("You crush [crushed_atom]!"))

///returns bool for if we want to get crushed
/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover in buckled_mobs)
		return TRUE

/// Returns true or false to allow src to move through the blocker, mover has final say
/atom/movable/proc/CanPassThrough(atom/blocker, turf/target, blocker_opinion)
	SHOULD_CALL_PARENT(TRUE)
	if(status_flags & INCORPOREAL) //Incorporeal can normally pass through anything
		blocker_opinion = TRUE

	return blocker_opinion

///allows this movable to hear and adds itself to the important_recursive_contents list of itself and every movable loc its in
/atom/movable/proc/become_hearing_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		//RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HEARING_SENSITIVE), PROC_REF(on_hearing_sensitive_trait_loss))
		for(var/atom/movable/location AS in get_nested_locs(src) + src)
			LAZYADDASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE, src)

		var/turf/our_turf = get_turf(src)
		if(our_turf && SSspatial_grid.initialized)
			SSspatial_grid.enter_cell(src, our_turf)

		else if(our_turf && !SSspatial_grid.initialized)//SSspatial_grid isnt init'd yet, add ourselves to the queue
			SSspatial_grid.enter_pre_init_queue(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)

	ADD_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)

/**
 * removes the hearing sensitivity channel from the important_recursive_contents list of this and all nested locs containing us if there are no more sources of the trait left
 * since RECURSIVE_CONTENTS_HEARING_SENSITIVE is also a spatial grid content type, removes us from the spatial grid if the trait is removed
 *
 * * trait_source - trait source define or ALL, if ALL, force removes hearing sensitivity. if a trait source define, removes hearing sensitivity only if the trait is removed
 */
/atom/movable/proc/lose_hearing_sensitivity(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return
	REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		return

	var/turf/our_turf = get_turf(src)
	if(our_turf && SSspatial_grid.initialized)
		SSspatial_grid.exit_cell(src, our_turf)
	else if(our_turf && !SSspatial_grid.initialized)
		SSspatial_grid.remove_from_pre_init_queue(src, RECURSIVE_CONTENTS_HEARING_SENSITIVE)

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE, src)

///propogates ourselves through our nested contents, similar to other important_recursive_contents procs
///main difference is that client contents need to possibly duplicate recursive contents for the clients mob AND its eye
/mob/proc/enable_client_mobs_in_contents()
	var/turf/our_turf = get_turf(src)
	if(our_turf && SSspatial_grid.initialized)
		SSspatial_grid.enter_cell(src, our_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
	else if(our_turf && !SSspatial_grid.initialized)
		SSspatial_grid.enter_pre_init_queue(src, RECURSIVE_CONTENTS_CLIENT_MOBS)

	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYORASSOCLIST(movable_loc.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS, src)

///Clears the clients channel of this mob
/mob/proc/clear_important_client_contents()

	var/turf/our_turf = get_turf(src)

	if(our_turf && SSspatial_grid.initialized)
		SSspatial_grid.exit_cell(src, our_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
	else if(our_turf && !SSspatial_grid.initialized)
		SSspatial_grid.remove_from_pre_init_queue(src, RECURSIVE_CONTENTS_CLIENT_MOBS)

	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(movable_loc.important_recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS, src)

///Checks the gravity the atom is subjected to
/atom/movable/proc/get_gravity()
	if(z)
		return SSmapping.gravity_by_z_level["[z]"]
	var/turf/src_turf = get_turf(src)
	if(src_turf?.z)
		return SSmapping.gravity_by_z_level["[src_turf.z]"]
	return 1 //if both fail we're in nullspace, just return a 1 as a fallback

///This is called when the AM is thrown into a dense turf
/atom/movable/proc/turf_collision(turf/T, speed)
	return

//Throws AM away from something
/atom/movable/proc/knockback(source, distance, speed, dir)
	throw_at(get_ranged_target_turf(src, dir ? dir : get_dir(source, src), distance), distance, speed, source)
