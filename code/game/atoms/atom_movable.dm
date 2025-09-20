/atom/movable
	layer = OBJ_LAYER
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	///The faction this AM is associated with, if any
	var/faction = null
	var/last_move = null
	var/last_move_time = 0
	/// A list containing arguments for Moved().
	VAR_PRIVATE/tmp/list/active_movement
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
	///AM that is pulling us
	var/mob/pulledby = null
	///AM we are pulling
	var/atom/movable/pulling
	var/atom/movable/moving_from_pull		//attempt to resume grab after moving instead of before.
	var/glide_modifier_flags = NONE

	var/status_flags = CANSTUN|CANKNOCKDOWN|CANKNOCKOUT|CANPUSH|CANUNCONSCIOUS|CANCONFUSE	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)
	var/generic_canpass = TRUE
	///What things this atom can move past, if it has the corrosponding flag. Should not be directly modified
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

	///is the mob currently ascending or descending through z levels?
	var/currently_z_moving

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = EMISSIVE_BLOCK_NONE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/render_step/emissive_blocker/em_block

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

	/// String representing the spatial grid groups we want to be held in.
	/// acts as a key to the list of spatial grid contents types we exist in via SSspatial_grid.spatial_grid_categories.
	/// We do it like this to prevent people trying to mutate them and to save memory on holding the lists ourselves
	var/spatial_grid_key

/mutable_appearance/emissive_blocker

/mutable_appearance/emissive_blocker/New()
	. = ..()
	// Need to do this here because it's overridden by the parent call
	color = EM_BLOCK_COLOR
	appearance_flags = EMISSIVE_APPEARANCE_FLAGS

//===========================================================================
/atom/movable/Initialize(mapload, ...)
	. = ..()

#if EMISSIVE_BLOCK_GENERIC != 0
	#error EMISSIVE_BLOCK_GENERIC is expected to be 0 to facilitate a weird optimization hack where we rely on it being the most common.
	#error Read the comment in code/game/atoms_movable.dm for details.
#endif

	// This one is incredible.
	// `if (x) else { /* code */ }` is surprisingly fast, and it's faster than a switch, which is seemingly not a jump table.
	// From what I can tell, a switch case checks every single branch individually, although sane, is slow in a hot proc like this.
	// So, we make the most common `blocks_emissive` value, EMISSIVE_BLOCK_GENERIC, 0, getting to the fast else branch quickly.
	// If it fails, then we can check over every value it can be (here, EMISSIVE_BLOCK_UNIQUE is the only one that matters).
	// This saves several hundred milliseconds of init time.
	if (blocks_emissive)
		if (blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(null, src)
			overlays += em_block
			if(managed_overlays)
				if(islist(managed_overlays))
					managed_overlays += em_block
				else
					managed_overlays = list(managed_overlays, em_block)
			else
				managed_overlays = em_block
	else
		var/static/mutable_appearance/emissive_blocker/blocker = new()
		blocker.icon = icon
		blocker.icon_state = icon_state
		blocker.dir = dir
		blocker.appearance_flags |= appearance_flags
		blocker.plane = GET_NEW_PLANE(EMISSIVE_PLANE, PLANE_TO_OFFSET(plane))
		// Ok so this is really cursed, but I want to set with this blocker cheaply while
		// Still allowing it to be removed from the overlays list later
		// So I'm gonna flatten it, then insert the flattened overlay into overlays AND the managed overlays list, directly
		// I'm sorry
		var/mutable_appearance/flat = blocker.appearance
		overlays += flat
		if(managed_overlays)
			if(islist(managed_overlays))
				managed_overlays += flat
			else
				managed_overlays = list(managed_overlays, flat)
		else
			managed_overlays = flat


	if(opacity)
		AddElement(/datum/element/light_blocking)
	if(light_system == MOVABLE_LIGHT)
		AddComponent(/datum/component/overlay_lighting)

	if(pass_flags)
		add_pass_flags(pass_flags, INNATE_TRAIT)

/atom/movable/Destroy()
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


	if(spatial_grid_key)
		SSspatial_grid.force_remove_from_grid(src)

	. = ..()

	for(var/movable_content in contents)
		qdel(movable_content)

	moveToNullspace()


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

/atom/movable/proc/update_emissive_block()
	// This one is incredible.
	// `if (x) else { /* code */ }` is surprisingly fast, and it's faster than a switch, which is seemingly not a jump table.
	// From what I can tell, a switch case checks every single branch individually, although sane, is slow in a hot proc like this.
	// So, we make the most common `blocks_emissive` value, EMISSIVE_BLOCK_GENERIC, 0, getting to the fast else branch quickly.
	// If it fails, then we can check over every value it can be (here, EMISSIVE_BLOCK_UNIQUE is the only one that matters).
	// This saves several hundred milliseconds of init time.
	if (blocks_emissive)
		if (blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
			if(em_block)
				SET_PLANE(em_block, EMISSIVE_PLANE, src)
			else if(!QDELETED(src))
				render_target = ref(src)
				em_block = new(null, src)
			return em_block
		// Implied else if (blocks_emissive == EMISSIVE_BLOCK_NONE) -> return
	// EMISSIVE_BLOCK_GENERIC == 0
	else
		return fast_emissive_blocker(src)

/atom/movable/update_overlays()
	var/list/overlays = ..()
	var/emissive_block = update_emissive_block()
	if(emissive_block)
		// Emissive block should always go at the beginning of the list
		overlays.Insert(1, emissive_block)
	return overlays

/atom/movable/proc/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	SHOULD_CALL_PARENT(TRUE)
	if(!(impact_flags & ZIMPACT_NO_MESSAGE))
		visible_message(
			span_danger("[src] crashes into [impacted_turf]!"),
			span_userdanger("You crash into [impacted_turf]!"),
		)
	if(!(impact_flags & ZIMPACT_NO_SPIN))
		INVOKE_ASYNC(src, PROC_REF(SpinAnimation), 5, 2)
	SEND_SIGNAL(src, COMSIG_ATOM_ON_Z_IMPACT, impacted_turf, levels)
	return TRUE

/*
 * Attempts to move using zMove if direction is UP or DOWN, step if not
 *
 * Args:
 * direction: The direction to go
 * z_move_flags: bitflags used for checks in zMove and can_z_move
*/
/atom/movable/proc/try_step_multiz(direction, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(direction == UP || direction == DOWN)
		return zMove(direction, null, z_move_flags)
	return step(src, direction)

/*
 * The core multi-z movement proc. Used to move a movable through z levels.
 * If target is null, it'll be determined by the can_z_move proc, which can potentially return null if
 * conditions aren't met (see z_move_flags defines in __DEFINES/movement.dm for info) or if dir isn't set.
 * Bear in mind you don't need to set both target and dir when calling this proc, but at least one or two.
 * This will set the currently_z_moving to CURRENTLY_Z_MOVING_GENERIC if unset, and then clear it after
 * Forcemove().
 *
 *
 * Args:
 * * dir: the direction to go, UP or DOWN, only relevant if target is null.
 * * target: The target turf to move the src to. Set by can_z_move() if null.
 * * z_move_flags: bitflags used for various checks in both this proc and can_z_move(). See __DEFINES/movement.dm.
 */
/atom/movable/proc/zMove(dir, turf/target, z_move_flags = ZMOVE_FLIGHT_FLAGS)
	if(!target)
		target = can_z_move(dir, get_turf(src), null, z_move_flags)
		if(!target)
			set_currently_z_moving(FALSE, TRUE)
			return FALSE

	var/list/moving_movs = get_z_move_affected(z_move_flags)

	for(var/atom/movable/movable as anything in moving_movs)
		movable.currently_z_moving = currently_z_moving || CURRENTLY_Z_MOVING_GENERIC
		movable.forceMove(target)
		movable.set_currently_z_moving(FALSE, TRUE)
	// This is run after ALL movables have been moved, so pulls don't get broken unless they are actually out of range.
	if(z_move_flags & ZMOVE_CHECK_PULLS)
		for(var/atom/movable/moved_mov as anything in moving_movs)
			if(z_move_flags & ZMOVE_CHECK_PULLEDBY && moved_mov.pulledby && (moved_mov.z != moved_mov.pulledby.z || get_dist(moved_mov, moved_mov.pulledby) > 1))
				moved_mov.pulledby.stop_pulling()
			if(z_move_flags & ZMOVE_CHECK_PULLING)
				moved_mov.check_pulling(TRUE)
	return TRUE

/// Returns a list of movables that should also be affected when src moves through zlevels, and src.
/atom/movable/proc/get_z_move_affected(z_move_flags)
	. = list(src)
	if(buckled_mobs)
		. |= buckled_mobs
	if(!(z_move_flags & ZMOVE_INCLUDE_PULLED))
		return
	for(var/mob/living/buckled as anything in buckled_mobs)
		if(buckled.pulling)
			. |= buckled.pulling
	if(pulling)
		. |= pulling
		if (pulling.buckled_mobs)
			. |= pulling.buckled_mobs

		//makes conga lines work with ladders and flying up and down; checks if the guy you are pulling is pulling someone,
		//then uses recursion to run the same function again
		if (pulling.pulling)
			. |= pulling.pulling.get_z_move_affected(z_move_flags)

/**
 * Checks if the destination turf is elegible for z movement from the start turf to a given direction and returns it if so.
 * Args:
 * * direction: the direction to go, UP or DOWN, only relevant if target is null.
 * * start: Each destination has a starting point on the other end. This is it. Most of the times the location of the source.
 * * z_move_flags: bitflags used for various checks. See __DEFINES/movement.dm.
 * * rider: A living mob in control of the movable. Only non-null when a mob is riding a vehicle through z-levels.
 */
/atom/movable/proc/can_z_move(direction, turf/start, turf/destination, z_move_flags = ZMOVE_FLIGHT_FLAGS, mob/living/rider)
	if(!start)
		start = get_turf(src)
		if(!start)
			return FALSE
	if(!direction)
		if(!destination)
			return FALSE
		direction = get_dir_multiz(start, destination)
	if(direction != UP && direction != DOWN)
		return FALSE
	if(!destination)
		destination = get_step_multiz(start, direction)
		if(!destination)
			if(z_move_flags & ZMOVE_FEEDBACK)
				to_chat(rider || src, span_warning("There's nowhere to go in that direction!"))
			return FALSE
	if(SEND_SIGNAL(src, COMSIG_CAN_Z_MOVE, start, destination) & COMPONENT_CANT_Z_MOVE)
		return FALSE
	if(z_move_flags & ZMOVE_FALL_CHECKS && (throwing || ((pass_flags & Z_FLYING) == Z_FLYING) || !get_gravity()))
		return FALSE
	if(z_move_flags & ZMOVE_CAN_FLY_CHECKS && !((pass_flags & Z_FLYING) == Z_FLYING) && get_gravity())
		if(z_move_flags & ZMOVE_FEEDBACK)
			if(rider)
				to_chat(rider, span_warning("[src] [p_are()] incapable of flight."))
			else
				to_chat(src, span_warning("You are not Superman."))
		return FALSE
	if((!(z_move_flags & ZMOVE_IGNORE_OBSTACLES) && !(start.zPassOut(direction) && destination.zPassIn(direction))) || (!(z_move_flags & ZMOVE_ALLOW_ANCHORED) && anchored))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider || src, span_warning("You couldn't move there!"))
		return FALSE
	return destination //used by some child types checks and zMove()

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	RESOLVE_ACTIVE_MOVEMENT // This should NEVER happen, but, just in case...
	var/atom/old_loc = loc
	var/direction = get_dir(old_loc, new_loc)
	loc = new_loc
	Moved(old_loc, direction, TRUE)

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
	if(!loc || !newloc || loc == newloc)
		return FALSE

	// A mid-movement... movement... occured, resolve that first.
	RESOLVE_ACTIVE_MOVEMENT
	var/atom/movable/pullee = pulling

	if(!moving_from_pull)
		check_pulling(z_allowed = TRUE)

	if(!direction)
		direction = get_dir(src, newloc)

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc, direction) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return FALSE

	var/can_pass_diagonally = NONE
	if (direction & (direction - 1)) //Check if the first part of the diagonal move is possible
		moving_diagonally = TRUE
		if(!(atom_flags & DIRLOCK))
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
			if(!(atom_flags & DIRLOCK))
				setDir(direction &~ (NORTH|SOUTH))
			return
		moving_diagonally = FALSE
		if(!get_step(loc, can_pass_diagonally)?.Exit(src, direction & ~can_pass_diagonally))
			return Move(get_step(loc, can_pass_diagonally), can_pass_diagonally)
		if(!(atom_flags & DIRLOCK)) //We want to set the direction to be the one of the "second" diagonal move, aka not can_pass_diagonally
			setDir(direction &~ can_pass_diagonally)

	else
		if(!loc.Exit(src, direction))
			return
		if(!(atom_flags & DIRLOCK))
			setDir(direction)

	var/enter_return_value = newloc.Enter(src)
	if(!(enter_return_value & TURF_CAN_ENTER))
		if(can_pass_diagonally && !(enter_return_value & TURF_ENTER_ALREADY_MOVED))
			return Move(get_step(loc, can_pass_diagonally), can_pass_diagonally)
		return

	var/atom/oldloc = loc
	//Early override for some cases like diagonal movement
	if(glide_size_override)
		set_glide_size(glide_size_override)

	SET_ACTIVE_MOVEMENT(oldloc, direction, FALSE, null)
	loc = newloc
	oldloc.Exited(src, direction)

	if(!loc || loc == oldloc)
		last_move = 0
		set_currently_z_moving(FALSE, TRUE)
		return

	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)

	if(oldarea != newarea)
		oldarea.Exited(src, direction)

	newloc.Entered(src, oldloc)

	if(oldarea != newarea)
		newarea.Entered(src, oldarea)

	RESOLVE_ACTIVE_MOVEMENT

	if(pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			var/pull_dir = get_dir(src, pulling)
			//puller and pullee more than one tile away or in diagonal position
			if(get_dist(src, pulling) > 1 || (pull_dir - 1) & pull_dir)
				pulling.moving_from_pull = src
				pulling.Move(oldloc, get_dir(pulling, oldloc), glide_size) //the pullee tries to reach our previous position
				pulling.moving_from_pull = null
			check_pulling(z_allowed=TRUE)

	//glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	//This means that if you don't override it late like this, it will just be set back by the movement update that's called when you move turfs.
	if(glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direction
	last_move_time = world.time

	if(LAZYLEN(buckled_mobs) && !handle_buckled_mob_movement(loc, direction, glide_size_override)) //movement failed due to buckled mob(s)
		return FALSE

	if(currently_z_moving)
		if(loc == newloc)
			var/turf/pitfall = get_turf(src)
			pitfall.zFall(src, falling_from_move = TRUE)
		else
			set_currently_z_moving(FALSE, TRUE)
	return TRUE

/// Called when src is being moved to a target turf because another movable (puller) is moving around.
/atom/movable/proc/move_from_pull(atom/movable/puller, turf/target_turf, glide_size_override)
	moving_from_pull = puller
	Move(target_turf, get_dir(src, target_turf), glide_size_override)
	moving_from_pull = null

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

	if(old_turf?.z != new_turf?.z)
		var/same_z_layer = (GET_TURF_PLANE_OFFSET(old_turf) == GET_TURF_PLANE_OFFSET(new_turf))
		on_changed_z_level(old_turf, new_turf, same_z_layer)

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

/// Sets the currently_z_moving variable to a new value. Used to allow some zMovement sources to have precedence over others.
/atom/movable/proc/set_currently_z_moving(new_z_moving_value, forced = FALSE)
	if(forced)
		currently_z_moving = new_z_moving_value
		return TRUE
	var/old_z_moving_value = currently_z_moving
	currently_z_moving = max(currently_z_moving, new_z_moving_value)
	return currently_z_moving > old_z_moving_value

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
	RESOLVE_ACTIVE_MOVEMENT
	var/atom/oldloc = loc
	var/list/old_locs
	if(length(locs) > 1)
		old_locs = locs

	SET_ACTIVE_MOVEMENT(oldloc, NONE, TRUE, old_locs)
	if(destination)
		if(pulledby && !currently_z_moving)
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

	RESOLVE_ACTIVE_MOVEMENT

/atom/movable/Exited(atom/movable/gone, direction)
	. = ..()
	if(LAZYLEN(gone.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in gone.important_recursive_contents)
			for(var/atom/movable/location AS in nested_locs)
				LAZYREMOVEASSOC(location.important_recursive_contents, channel, gone.important_recursive_contents[channel])

/atom/movable/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(!LAZYLEN(arrived.important_recursive_contents))
		return
	var/list/nested_locs = get_nested_locs(src) + src
	for(var/channel in arrived.important_recursive_contents)
		for(var/atom/movable/location as anything in nested_locs)
			LAZYINITLIST(location.important_recursive_contents)
			var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
			LAZYINITLIST(recursive_contents[channel])
			switch(channel)
				if(RECURSIVE_CONTENTS_CLIENT_MOBS, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
					if(!length(recursive_contents[channel]))
						SSspatial_grid.add_grid_awareness(location, channel)
			recursive_contents[channel] |= arrived.important_recursive_contents[channel]

///called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, speed, bounce = TRUE)
	var/hit_successful
	var/old_throw_source = throw_source
	if(QDELETED(hit_atom))
		return FALSE
	if(SEND_SIGNAL(hit_atom, COMSIG_PRE_MOVABLE_IMPACT, src) & COMPONENT_PRE_MOVABLE_IMPACT_DODGED)
		return FALSE
	hit_successful = hit_atom.hitby(src, speed)
	if(hit_successful)
		SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, speed)
		if(bounce && hit_atom.density && !isliving(hit_atom))
			INVOKE_NEXT_TICK(src, PROC_REF(throw_bounce), hit_atom, old_throw_source)
	return hit_successful //if the throw missed, it continues

///Bounces the AM off hit_atom
/atom/movable/proc/throw_bounce(atom/hit_atom, turf/old_throw_source)
	if(QDELETED(src))
		return
	if(QDELETED(hit_atom))
		return
	if(!isturf(loc))
		return
	var/dir_to_proj = angle_to_cardinal_dir(Get_Angle(hit_atom, old_throw_source))
	if(ISDIAGONALDIR(dir_to_proj))
		var/list/cardinals = list(turn(dir_to_proj, 45), turn(dir_to_proj, -45))
		for(var/direction in cardinals)
			var/turf/turf_to_check = get_step(hit_atom, direction)
			if(turf_to_check.density)
				cardinals -= direction
		dir_to_proj = pick(cardinals)

	var/perpendicular_angle = Get_Angle(hit_atom, get_step(hit_atom, ISDIAGONALDIR(dir_to_proj) ? get_dir(hit_atom, old_throw_source) - dir_to_proj : dir_to_proj))
	var/new_angle = (perpendicular_angle + (perpendicular_angle - Get_Angle(old_throw_source, (loc == old_throw_source ? hit_atom : src)) - 180) + rand(-10, 10))

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

	var/originally_dir_locked = atom_flags & DIRLOCK
	if(!originally_dir_locked)
		setDir(get_dir(src, target))
		atom_flags |= DIRLOCK

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

	var/failed_to_move = FALSE
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y
		while(!gc_destroyed && target &&((((x < target.x && dx == EAST) || (x > target.x && dx == WEST))  && get_dist_euclidean(origin, src) < range) || isspaceturf(loc)) && (!failed_to_move && throwing) && istype(loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				if(!Move(step, glide_size_override = DELAY_TO_GLIDE_SIZE(1 / speed)))
					failed_to_move = TRUE
				error += dist_x
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				if(!Move(step, glide_size_override = DELAY_TO_GLIDE_SIZE(1 / speed)))
					failed_to_move = TRUE
				error -= dist_y
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
	else
		var/error = dist_y/2 - dist_x
		while(!gc_destroyed && target &&((((y < target.y && dy == NORTH) || (y > target.y && dy == SOUTH)) && get_dist_euclidean(origin, src) < range) || isspaceturf(loc)) && (!failed_to_move && throwing) && istype(loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				if(!Move(step, glide_size_override = DELAY_TO_GLIDE_SIZE(1 / speed)))
					failed_to_move = TRUE
				error += dist_y
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				if(!Move(step, glide_size_override = DELAY_TO_GLIDE_SIZE(1 / speed)))
					failed_to_move = TRUE
				error -= dist_x
				dist_since_sleep++
				if(dist_since_sleep >= speed)
					dist_since_sleep = 0
					sleep(0.1 SECONDS)

	//done throwing, either because it hit something or it finished moving
	if(!originally_dir_locked)
		atom_flags &= ~DIRLOCK
	if(isobj(src) && (!failed_to_move && throwing))
		throw_impact(get_turf(src), speed)
	stop_throw(flying, original_layer)

///Clean up all throw vars
/atom/movable/proc/stop_throw(flying = FALSE, original_layer)
	set_throwing(FALSE)
	if(flying)
		set_flying(FALSE, original_layer)
	thrower = null
	thrown_speed = 0
	throw_source = null

	if(!currently_z_moving) // I don't think you can zfall while thrown but hey, just in case.
		var/turf/T = get_turf(src)
		T?.zFall(src)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW)
	if(loc)
		SEND_SIGNAL(loc, COMSIG_TURF_THROW_ENDED_HERE, src)

/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(buckled_mob.Move(newloc, direct, glide_size_override))
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
		SET_PLANE_EXPLICIT(I, GAME_PLANE, src)

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
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_FOLLOW, "Follow")
	VV_DROPDOWN_OPTION(VV_HK_GET, "Get")
	VV_DROPDOWN_OPTION(VV_HK_SEND, "Send")
	VV_DROPDOWN_OPTION(VV_HK_DELETE_ALL_INSTANCES, "Delete All Instances")
	VV_DROPDOWN_OPTION(VV_HK_UPDATE_ICONS, "Update Icon")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_PARTICLES, "Edit Particles")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_FOLLOW])
		if(!check_rights(NONE))
			return
		var/client/C = usr.client
		if(isnewplayer(C.mob) || isnewplayer(src))
			return
		var/message
		if(!isobserver(C.mob))
			SSadmin_verbs.dynamic_invoke_verb(C, /datum/admin_verb/aghost)
			message = TRUE
		var/mob/dead/observer/O = C.mob
		O.ManualFollow(src)
		if(message)
			log_admin("[key_name(O)] jumped to follow [key_name(src)].")
			message_admins("[ADMIN_TPMONTY(O)] jumped to follow [ADMIN_TPMONTY(src)].")

	if(href_list[VV_HK_GET])
		if(!check_rights(R_DEBUG))
			return
		if(!istype(src))
			return
		var/turf/T = get_turf(usr)
		if(!istype(T))
			return
		forceMove(T)
		log_admin("[key_name(usr)] has sent atom [src] to themselves.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent atom [src] to themselves.")

	if(href_list[VV_HK_SEND])
		if(!check_rights(R_DEBUG))
			return
		if(!istype(src))
			return
		var/atom/target
		switch(input("Where do you want to send it to?", "Send Mob") as null|anything in list("Area", "Mob", "Key", "Coords"))
			if("Area")
				var/area/AR = input("Pick an area.", "Pick an area") as null|anything in get_sorted_areas()
				if(!AR || !src)
					return
				target = pick(get_area_turfs(AR))
			if("Mob")
				var/mob/N = input("Pick a mob.", "Pick a mob") as null|anything in sortList(GLOB.mob_list)
				if(!N || !src)
					return
				target = get_turf(N)
			if("Key")
				var/client/C = input("Pick a key.", "Pick a key") as null|anything in sortKey(GLOB.clients)
				if(!C || !src)
					return
				target = get_turf(C.mob)
			if("Coords")
				var/X = input("Select coordinate X", "Coordinate X") as null|num
				var/Y = input("Select coordinate Y", "Coordinate Y") as null|num
				var/Z = input("Select coordinate Z", "Coordinate Z") as null|num
				if(isnull(X) || isnull(Y) || isnull(Z) || !src)
					return
				target = locate(X, Y, Z)
		if(!target)
			return
		forceMove(target)
		log_admin("[key_name(usr)] has sent atom [src] to [AREACOORD(target)].")
		message_admins("[ADMIN_TPMONTY(usr)] has sent atom [src] to [ADMIN_VERBOSEJMP(target)].")

	if(href_list[VV_HK_DELETE_ALL_INSTANCES])
		if(!check_rights(R_DEBUG|R_SERVER))
			return
		var/obj/O = src
		if(!isobj(O))
			return
		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?", "Type", "Strict type", "Type and subtypes", "Cancel")
		if(action_type == "Cancel" || !action_type)
			return
		if(alert("Are you really sure you want to delete all objects of type [O.type]?", "Warning", "Yes", "No") != "Yes")
			return
		if(alert("Second confirmation required. Delete?", "Warning", "Yes", "No") != "Yes")
			return
		var/O_type = O.type
		var/i = 0
		var/strict
		switch(action_type)
			if("Strict type")
				strict = TRUE
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
			if("Type and subtypes")
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
		log_admin("[key_name(usr)] deleted all objects of type[strict ? "" : " and subtypes"] of [O_type] ([i] objects deleted).")
		message_admins("[ADMIN_TPMONTY(usr)] deleted all objects of type[strict ? "" : " and subtypes"] of [O_type] ([i] objects deleted).")

	if(href_list[VV_HK_UPDATE_ICONS])
		if(!check_rights(R_DEBUG))
			return
		update_icon()
		log_admin("[key_name(usr)] updated the icon of [src].")

	if(href_list[VV_HK_EDIT_PARTICLES])
		if(!check_rights(R_VAREDIT))
			return
		var/client/C = usr.client
		C?.open_particle_editor(src)

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

/**
 * Called when a movable changes z-levels.
 *
 * Arguments:
 * * old_turf - The previous turf they were on before.
 * * new_turf - The turf they have now entered.
 * * same_z_layer - If their old and new z levels are on the same level of plane offsets or not
 * * notify_contents - Whether or not to notify the movable's contents that their z-level has changed. NOTE, IF YOU SET THIS, YOU NEED TO MANUALLY SET PLANE OF THE CONTENTS LATER
 */
/atom/movable/proc/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_turf?.z, new_turf?.z, same_z_layer)

	// If our turfs are on different z "layers", recalc our planes
	if(!same_z_layer && !QDELETED(src))
		SET_PLANE(src, PLANE_TO_TRUE(src.plane), new_turf)
		// a TON of overlays use planes, and thus require offsets
		// so we do this. sucks to suck
		update_appearance()

		if(update_on_z)
			// I so much wish this could be somewhere else. alas, no.
			for(var/image/update as anything in update_on_z)
				SET_PLANE(update, PLANE_TO_TRUE(update.plane), new_turf)
		if(update_overlays_on_z)
			// This EVEN more so
			cut_overlay(update_overlays_on_z)
			// This even more so
			for(var/mutable_appearance/update in update_overlays_on_z)
				SET_PLANE(update, PLANE_TO_TRUE(update.plane), new_turf)
			add_overlay(update_overlays_on_z)

	if(!notify_contents)
		return
	for (var/atom/movable/content as anything in src)
		content.on_changed_z_level(old_turf, new_turf, same_z_layer)

/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, force = MOVE_FORCE_STRONG)
	if(anchored || (force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
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
	pulling.Move(destination_turf, move_dir, glide_size)
	return TRUE


/atom/movable/proc/check_pulling(only_pulling = FALSE, z_allowed = FALSE)
	if(pulling)
		var/atom/movable/pullee = pulling
		if(get_dist(src, pullee) > 1 || (z != pulling.z && !z_allowed))
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
	if(pulledby && (get_dist(src, pulledby) > 1 || (z != pulledby.z && !z_allowed)))	//separated from our puller and not in the middle of a diagonal move.
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
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target

	for(var/mob/buckled_mob AS in buckled_mobs)
		buckled_mob.set_glide_size(target)

/atom/movable/proc/reset_glide_size()
	if(glide_modifier_flags)
		return
	set_glide_size(initial(glide_size))

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
		if("pass_flags")
			if(var_value == pass_flags)
				return FALSE
			var/new_flags = (var_value &= ~pass_flags)
			if(new_flags)
				add_pass_flags(var_value, ADMIN_TRAIT)
				return TRUE
			remove_pass_flags(var_value, ADMIN_TRAIT)
			return TRUE
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
/atom/movable/proc/set_throwing(new_throwing)
	if(throwing == new_throwing)
		return FALSE
	throwing = new_throwing
	if(throwing)
		add_pass_flags(PASS_THROW, THROW_TRAIT)
		add_nosubmerge_trait(THROW_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_NOSUBMERGE, THROW_TRAIT)
		remove_pass_flags(PASS_THROW, THROW_TRAIT)
	return TRUE

///Toggles AM between flying states
/atom/movable/proc/set_flying(flying, new_layer)
	if(flying)
		add_pass_flags(HOVERING, THROW_TRAIT)
		layer = new_layer
		return
	remove_pass_flags(HOVERING, THROW_TRAIT)
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
	var/already_hearing_sensitive = HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE)
	ADD_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)
	if(already_hearing_sensitive) // If we were already hearing sensitive, we don't wanna be in important_recursive_contents twice, else we'll have potential issues like one radio sending the same message multiple times
		return

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYINITLIST(location.important_recursive_contents)
		var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
		if(!length(recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			SSspatial_grid.add_grid_awareness(location, SPATIAL_GRID_CONTENTS_TYPE_HEARING)
		recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] += list(src)

	var/turf/our_turf = get_turf(src)
	SSspatial_grid.add_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_HEARING)

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
	/// We get our awareness updated by the important recursive contents stuff, here we remove our membership
	SSspatial_grid.remove_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_HEARING)

	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		var/list/recursive_contents = location.important_recursive_contents // blue hedgehog velocity
		recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE] -= src
		if(!length(recursive_contents[RECURSIVE_CONTENTS_HEARING_SENSITIVE]))
			SSspatial_grid.remove_grid_awareness(location, SPATIAL_GRID_CONTENTS_TYPE_HEARING)
		ASSOC_UNSETEMPTY(recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE)
		UNSETEMPTY(location.important_recursive_contents)

///propogates ourselves through our nested contents, similar to other important_recursive_contents procs
///main difference is that client contents need to possibly duplicate recursive contents for the clients mob AND its eye
/mob/proc/enable_client_mobs_in_contents()
	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYINITLIST(movable_loc.important_recursive_contents)
		var/list/recursive_contents = movable_loc.important_recursive_contents // blue hedgehog velocity
		if(!length(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))
			SSspatial_grid.add_grid_awareness(movable_loc, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
		LAZYINITLIST(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] |= src

	var/turf/our_turf = get_turf(src)
	/// We got our awareness updated by the important recursive contents stuff, now we add our membership
	SSspatial_grid.add_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)

///Clears the clients channel of this mob
/mob/proc/clear_important_client_contents()
	var/turf/our_turf = get_turf(src)
	SSspatial_grid.remove_grid_membership(src, our_turf, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)

	for(var/atom/movable/movable_loc as anything in get_nested_locs(src) + src)
		LAZYINITLIST(movable_loc.important_recursive_contents)
		var/list/recursive_contents = movable_loc.important_recursive_contents // blue hedgehog velocity
		LAZYINITLIST(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS])
		recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS] -= src
		if(!length(recursive_contents[RECURSIVE_CONTENTS_CLIENT_MOBS]))
			SSspatial_grid.remove_grid_awareness(movable_loc, SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)
		ASSOC_UNSETEMPTY(recursive_contents, RECURSIVE_CONTENTS_CLIENT_MOBS)
		UNSETEMPTY(movable_loc.important_recursive_contents)

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
/atom/movable/proc/knockback(source, distance, speed, dir, knockback_force = MOVE_FORCE_EXTREMELY_STRONG)
	safe_throw_at(get_ranged_target_turf(src, dir ? dir : get_dir(source, src), distance), distance, speed, source, FALSE, knockback_force)

///List of all filter removal timers. Glob to avoid an AM level var
GLOBAL_LIST_EMPTY(submerge_filter_timer_list)

///Sets the submerged level of an AM based on its turf
/atom/movable/proc/set_submerge_level(turf/new_loc, turf/old_loc, submerge_icon, submerge_icon_state, duration = 0)
	if(!submerge_icon) //catch all in case so people don't need to make child types just to specify a return
		return
	var/old_height = istype(old_loc) ? old_loc.get_submerge_height() : 0
	var/new_height = istype(new_loc) ? new_loc.get_submerge_height() : 0
	var/height_diff = new_height - old_height

	var/old_depth = istype(old_loc) ? old_loc.get_submerge_depth() : 0
	var/new_depth = istype(new_loc) ? new_loc.get_submerge_depth() : 0
	var/depth_diff = new_depth - old_depth

	if(!height_diff && !depth_diff)
		return

	var/height_to_use = (64 - get_cached_height()) * 0.5 //gives us the right height based on AM's icon height relative to the 64 high alpha mask

	if(!new_height && !new_depth)
		GLOB.submerge_filter_timer_list[ref(src)] = addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), AM_SUBMERGE_MASK), duration, TIMER_STOPPABLE)
		REMOVE_TRAIT(src, TRAIT_SUBMERGED, SUBMERGED_TRAIT)
	else if(!HAS_TRAIT(src, TRAIT_SUBMERGED)) //we use a trait to avoid some edge cases if things are moving fast or unusually
		if(GLOB.submerge_filter_timer_list[ref(src)])
			deltimer(GLOB.submerge_filter_timer_list[ref(src)])
		//The mask is spawned below the AM, then the animate() raises it up, giving the illusion of dropping into water, combining with the animate to actual drop the pixel_y into the water
		add_filter(AM_SUBMERGE_MASK, 1, alpha_mask_filter(0, height_to_use - AM_SUBMERGE_MASK_HEIGHT, icon(submerge_icon, submerge_icon_state), null, MASK_INVERSE))
		ADD_TRAIT(src, TRAIT_SUBMERGED, SUBMERGED_TRAIT)

	transition_filter(AM_SUBMERGE_MASK, list(y = height_to_use - (AM_SUBMERGE_MASK_HEIGHT - new_height)), duration)
	animate(src, pixel_y = depth_diff, time = duration, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)

///overrides the turf's normal footstep sound
/atom/movable/proc/footstep_override(atom/movable/source, list/footstep_overrides)
	SIGNAL_HANDLER
	return //override as required with the specific footstep sound

///returns that src is covering its turf. Used to prevent turf interactions such as water
/atom/movable/proc/turf_cover_check(atom/movable/source)
	SIGNAL_HANDLER
	return TURF_COVERED

///Wrapper for setting the submerge trait. This trait should ALWAYS be set via this proc so we can listen for the trait removal in all cases
/atom/movable/proc/add_nosubmerge_trait(trait_source = TRAIT_GENERIC)
	if(HAS_TRAIT(src, TRAIT_SUBMERGED))
		set_submerge_level(old_loc = loc, duration = 0.1)
	ADD_TRAIT(src, TRAIT_NOSUBMERGE, trait_source)
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOSUBMERGE), PROC_REF(_do_submerge), override = TRUE) //we can get this trait from multiple sources, but sig is only sent when we lose the trait entirely

///Adds submerge effects to the AM. Should never be called directly
/atom/movable/proc/_do_submerge(atom/movable/source)
	SIGNAL_HANDLER
	UnregisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_NOSUBMERGE))
	set_submerge_level(loc, duration = 0.1)

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	setDir(direction)
