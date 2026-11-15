#define ZFALL_DURATION 0.5 SECONDS
#define ZFALL_EFFECT "zfall_effect"
#define ZFALL_HEIGHT 128

/atom/movable/proc/onZImpact(turf/impacted_turf, levels, impact_flags = NONE, duration = ZFALL_DURATION)
	SHOULD_CALL_PARENT(TRUE)

	z_impact_effects(impacted_turf, levels, impact_flags, duration)
	addtimer(CALLBACK(src, PROC_REF(post_z_impact), impacted_turf, levels, impact_flags), duration)
	return TRUE

///Special effects during a z fall
/atom/movable/proc/z_impact_effects(turf/impacted_turf, levels, impact_flags, duration)
	//if(!(impact_flags & ZIMPACT_NO_SPIN))
	//	INVOKE_ASYNC(src, PROC_REF(SpinAnimation), duration, 2)

	start_drop_down_effect(src, ismob(src) ? list(src) : null, list(src), duration)

///Special effects when a z impact is completed
/atom/movable/proc/post_z_impact(turf/impacted_turf, levels, impact_flags)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_ON_Z_IMPACT, impacted_turf, levels)

	if(!(impact_flags & ZIMPACT_NO_MESSAGE))
		visible_message(
			span_danger("[src] crashes into [impacted_turf]!"),
			span_userdanger("You crash into [impacted_turf]!"),
		)

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

//procs for generic dropping. used for zfall and rappel effects, and are purely visual

///standard drop down effect for falling/rappelling down etc
/proc/start_drop_down_effect(atom/movable/movable_to_move, list/mobs_moving, list/deploy_list, drop_time)
	var/list/layer_list = list()

	for(var/atom/movable/AM AS in deploy_list)
		layer_list[AM] = AM.layer

		if(isliving(AM))
			var/mob/living/living_deployer = AM
			living_deployer.ImmobilizeNoChain(drop_time) //looks weird if they can move while rappeling
		else if(isvehicle(AM))
			var/obj/vehicle/vehicle_deployer = AM
			COOLDOWN_INCREMENT(vehicle_deployer, cooldown_vehicle_move, drop_time)

		AM.add_filter(ZFALL_EFFECT, 2, drop_shadow_filter(y = -ZFALL_HEIGHT, color = COLOR_TRANSPARENT_SHADOW, size = 4))
		var/shadow_filter = AM.get_filter(ZFALL_EFFECT)

		layer_list[AM] = AM.layer
		AM.pixel_z += ZFALL_HEIGHT
		AM.layer = FLY_LAYER

		animate(AM, pixel_z = AM.pixel_z - ZFALL_HEIGHT, time = drop_time)
		animate(shadow_filter, y = 0, size = 0.9, time = drop_time, flags = ANIMATION_PARALLEL)

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(end_drop_down_effect), deploy_list, layer_list, mobs_moving), drop_time)

///effects when drop down completes
/proc/end_drop_down_effect(list/atom/movable/movables_to_move, list/layer_list, list/mobs_moving)
	for(var/atom/movable/AM AS in movables_to_move)
		AM.remove_filter(ZFALL_EFFECT)
		AM.layer = layer_list[AM]
		if(ismecha(AM) || isarmoredvehicle(AM))
			new /obj/effect/temp_visual/rappel_dust(AM.loc, 3)
			playsound(AM.loc, 'sound/effects/alien/behemoth/stomp.ogg', 40, TRUE, LOUD_SOUND_RANGE)
	for(var/mob/living/living in mobs_moving)
		var/shake_amount = 1
		if(HAS_TRAIT(living, TRAIT_CATLIKE_GRACE) && !living.incapacitated(TRUE) && !living.lying_angle)
			shake_amount *= 0.5
		shake_camera(living, 0.3 SECONDS, shake_amount)
