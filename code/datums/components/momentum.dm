/datum/component/slidey_movement
	var/extra_speed_per_tile = 0.1
	var/max_additional_speed = 1
	var/max_speed_reduction = -1
	var/movespeed_gain_per_tile = 0.1
	var/ninety_degree_speed_loss = 0.1

	var/movespeed_modifier = 0
	var/old_movespeed_modifier = 0
	var/old_dir

/datum/component/slidey_movement/Initialize(
	extra_speed_per_tile = 0.1,
	max_additional_speed = 1,
	max_speed_reduction = -1, 
	movespeed_gain_per_tile = 0.1,
	ninety_degree_speed_loss = 0.1,
	)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.extra_speed_per_tile = extra_speed_per_tile
	src.max_additional_speed = max_additional_speed
	src.max_speed_reduction = max_speed_reduction
	src.movespeed_gain_per_tile = movespeed_gain_per_tile
	src.ninety_degree_speed_loss = ninety_degree_speed_loss
	
/datum/component/slidey_movement/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/on_moved)

/datum/component/slidey_movement/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	var/mob/living/living = parent
	living.remove_movespeed_modifier(MOVESPEED_ID_SLIDEY_MOVEMENT)

/datum/component/slidey_movement/proc/on_moved(atom/movable/AM, oldloc, dir)
	if(!dir)
		return

	var/turf/current_turf = get_turf(AM)
	// If we're not moving in the same direction as before, reduce the speed
	if(current_turf == oldloc)
		movespeed_modifier = 0

	var/value_to_add = dir != old_dir ? calculate_speed_loss(dir) : movespeed_gain_per_tile
	movespeed_modifier = clamp(value_to_add + movespeed_modifier, max_speed_reduction, max_additional_speed)
	old_dir = dir

	var/mob/living/living = parent
	if(movespeed_modifier == old_movespeed_modifier)
		return

	living.add_movespeed_modifier(MOVESPEED_ID_SLIDEY_MOVEMENT, TRUE, 2, NONE, TRUE, movespeed_modifier)
	old_movespeed_modifier = movespeed_modifier

// Calculate the speed loss based on the direction we're moving in
/datum/component/slidey_movement/proc/calculate_speed_loss(dir)
	// with olddir and dir, check how many degrees the difference is
	var/difference = abs(dir2angle(dir) - dir2angle(old_dir))
	// Based on the difference, return the speed loss with math
	switch(difference)
		if(45)
			return -ninety_degree_speed_loss * 0.5
		if(90)
			return -ninety_degree_speed_loss
		if(180)
			// Go all the way down to minimum speed
			return -max_speed_reduction * 2
	return 0
