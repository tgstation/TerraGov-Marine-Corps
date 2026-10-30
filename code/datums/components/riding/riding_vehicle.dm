// For any /obj/vehicle's that can be ridden

/datum/component/riding/vehicle/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = (RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS), potion_boost = FALSE)
	if(!isvehicle(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/riding/vehicle/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, PROC_REF(driver_move))

/datum/component/riding/vehicle/driver_move(atom/movable/movable_parent, mob/living/user, direction, glide_size_override)
	if(!COOLDOWN_FINISHED(src, vehicle_move_cooldown))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/vehicle/vehicle_parent = parent

	if(!keycheck(user))
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>[vehicle_parent] has no key inserted!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You slip off \the [vehicle_parent] as your body slumps!</span>")

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You cannot operate \the [vehicle_parent] right now!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it while unable to stand!</span>")

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that while unable to stand up enough to move \the [vehicle_parent]...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_ARMS && user.restrained())
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it without being able to hold on!</span>")

		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to hold onto \the [vehicle_parent] to move it...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	last_move_diagonal = ISDIAGONALDIR(direction)
	var/new_delay = (last_move_diagonal ? DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER : 1) * vehicle_move_delay + calculate_additional_delay(user)
	glide_size_override = DELAY_TO_GLIDE_SIZE(new_delay)
	. = ..()
	handle_ride(user, direction, new_delay)

/datum/component/riding/vehicle/riding_can_z_move(atom/movable/movable_parent, direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	if(!(z_move_flags & ZMOVE_CAN_FLY_CHECKS))
		return COMPONENT_RIDDEN_ALLOW_Z_MOVE

	if(!keycheck(rider))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider, span_warning("[movable_parent] has no key inserted!"))
		return COMPONENT_RIDDEN_STOP_Z_MOVE
	if(HAS_TRAIT(rider, TRAIT_INCAPACITATED))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider, span_warning("You cannot operate [movable_parent] right now!"))
		return COMPONENT_RIDDEN_STOP_Z_MOVE
	if(ride_check_flags & RIDER_NEEDS_LEGS && HAS_TRAIT(rider, TRAIT_FLOORED))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider, span_warning("You can't seem to manage that while unable to stand up enough to move [movable_parent]..."))
		return COMPONENT_RIDDEN_STOP_Z_MOVE
	if(ride_check_flags & RIDER_NEEDS_ARMS && HAS_TRAIT(rider, TRAIT_HANDS_BLOCKED))
		if(z_move_flags & ZMOVE_FEEDBACK)
			to_chat(rider, span_warning("You can't seem to hold onto [movable_parent] to move it..."))
		return COMPONENT_RIDDEN_STOP_Z_MOVE

	return COMPONENT_RIDDEN_ALLOW_Z_MOVE

/// This handles the actual movement for vehicles once [/datum/component/riding/vehicle/proc/driver_move] has given us the green light
/datum/component/riding/vehicle/proc/handle_ride(mob/living/user, direction, cooldown_duration)
	var/atom/movable/movable_parent = parent

	var/turf/next = get_step(movable_parent, direction)
	var/turf/current = get_turf(movable_parent)
	if(!istype(next) || !istype(current))
		return //not happening.
	if(!turf_check(next, current))
		to_chat(user, "<span class='warning'>\The [movable_parent] can not go onto [next]!</span>")
		return
	if(!isturf(movable_parent.loc))
		return

	//movable_parent.Move(next, direction, glide_size_override)
	step(movable_parent, direction)
	COOLDOWN_START(src, vehicle_move_cooldown, cooldown_duration)

	if(QDELETED(src))
		return
	handle_vehicle_layer(movable_parent.dir)
	handle_vehicle_offsets(movable_parent.dir)

/datum/component/riding/vehicle/atv
	keytype = /obj/item/key/atv
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/vehicle/atv/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list(0, 4)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/powerloader
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS
	vehicle_move_delay = 4

/datum/component/riding/vehicle/powerloader/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 2), TEXT_SOUTH = list(0, 2), TEXT_EAST = list(0, 2), TEXT_WEST = list(0, 2)))
	set_vehicle_dir_layer(SOUTH, VEHICLE_LAYER)
	set_vehicle_dir_layer(NORTH, VEHICLE_LAYER)
	set_vehicle_dir_layer(EAST, VEHICLE_LAYER)
	set_vehicle_dir_layer(WEST, VEHICLE_LAYER)

/datum/component/riding/vehicle/bicycle
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 0

/datum/component/riding/vehicle/bicycle/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list(0, 4)))

/datum/component/riding/vehicle/wheelchair
	vehicle_move_delay = 6
	ride_check_flags = RIDER_NEEDS_ARMS

/datum/component/riding/vehicle/wheelchair/driver_move(atom/movable/movable_parent, mob/living/user, direction, glide_size_override)
	if(!iscarbon(user))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/mob/living/carbon/carbon_user = user

	var/datum/limb/left_hand = carbon_user.get_limb(BODY_ZONE_PRECISE_R_HAND)
	var/datum/limb/right_hand = carbon_user.get_limb(BODY_ZONE_PRECISE_L_HAND)
	var/working_hands = 2

	if(!left_hand?.is_usable() || user.get_item_for_held_index(1))
		working_hands--
	if(!right_hand?.is_usable() || user.get_item_for_held_index(2))
		working_hands--
	if(!working_hands)
		to_chat(user, span_warning("You have no arms to propel [movable_parent]!"))
		return COMPONENT_DRIVER_BLOCK_MOVE // No hands to drive your chair? Tough luck!
	return ..()

/datum/component/riding/vehicle/wheelchair/calculate_additional_delay(mob/living/user)
	if(!iscarbon(user))
		return 0
	var/mob/living/carbon/carbon_user = user

	var/datum/limb/left_hand = carbon_user.get_limb(BODY_ZONE_PRECISE_R_HAND)
	var/datum/limb/right_hand = carbon_user.get_limb(BODY_ZONE_PRECISE_L_HAND)
	var/delay_to_add = 0

	if(!left_hand?.is_usable() || user.get_item_for_held_index(1))
		delay_to_add += vehicle_move_delay * 0.5 //harder to move a wheelchair with a single hand
	else if(left_hand?.is_broken())
		delay_to_add = vehicle_move_delay * 0.33
	if(!right_hand?.is_usable() || user.get_item_for_held_index(2))
		delay_to_add += vehicle_move_delay * 0.5
	else if(right_hand.is_broken())
		delay_to_add = vehicle_move_delay * 0.33

	return delay_to_add

/datum/component/riding/vehicle/wheelchair/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vehicle/wheelchair/weaponized
	vehicle_move_delay = 5

/datum/component/riding/vehicle/motorbike
	vehicle_move_delay = 2
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/motorbike/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 3), TEXT_SOUTH = list(0, 3), TEXT_EAST = list(-2, 3), TEXT_WEST = list(2, 3)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/vehicle/motorbike/sidecar/Initialize(mob/living/riding_mob, force, ride_check_flags, potion_boost)
	. = ..()
	riding_mob.density = FALSE

/datum/component/riding/vehicle/motorbike/sidecar/vehicle_mob_unbuckle(datum/source, mob/living/former_rider, force = FALSE)
	former_rider.density = TRUE
	return ..()

//sidecar
/datum/component/riding/vehicle/motorbike/sidecar/handle_specials()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(-10, 3), TEXT_SOUTH = list(10, 3), TEXT_EAST = list(-2, 3), TEXT_WEST = list(2, 3)))
	set_vehicle_dir_layer(SOUTH, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_offsets(NORTH, -10, 0)
	set_vehicle_dir_offsets(SOUTH, 10, 0)

/datum/component/riding/vehicle/motorbike/sidecar/get_offsets(pass_index, mob_type)
	switch(pass_index)
		if(1) //first one buckled, so driver
			return list(TEXT_NORTH = list(9, 3), TEXT_SOUTH = list(-9, 3), TEXT_EAST = list(-2, 3), TEXT_WEST = list(2, 3))
		if(2) //second one buckled, so sidecar rider
			return list(TEXT_NORTH = list(-6, 2), TEXT_SOUTH = list(6, 2), TEXT_EAST = list(-3, 0, ABOVE_OBJ_LAYER), TEXT_WEST = list(3, 0, LYING_MOB_LAYER))

/datum/component/riding/vehicle/hover_bike
	vehicle_move_delay = 1.2
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/hover_bike/Initialize(mob/living/riding_mob, force, ride_check_flags, potion_boost)
	. = ..()
	riding_mob.density = FALSE

/datum/component/riding/vehicle/hover_bike/vehicle_mob_unbuckle(datum/source, mob/living/former_rider, force = FALSE)
	former_rider.density = TRUE
	return ..()

/datum/component/riding/vehicle/hover_bike/handle_specials()
	set_riding_offsets(1, list(TEXT_NORTH = list(0, 8, MOB_LAYER), TEXT_SOUTH = list(0, -11, ABOVE_MOB_LAYER), TEXT_EAST = list(17, 7, ABOVE_MOB_LAYER), TEXT_WEST = list(-11, 7, ABOVE_MOB_LAYER)))
	set_riding_offsets(2, list(TEXT_NORTH = list(0, 4, ABOVE_MOB_LAYER), TEXT_SOUTH = list(0, -1, MOB_LAYER), TEXT_EAST = list(4, 9, MOB_LAYER), TEXT_WEST = list(1, 9, MOB_LAYER)))
	set_vehicle_dir_layer(SOUTH, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(NORTH, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(EAST, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(WEST, MOB_BELOW_PIGGYBACK_LAYER)

/datum/component/riding/vehicle/big_bike
	vehicle_move_delay = 1.2
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/big_bike/Initialize(mob/living/riding_mob, force, ride_check_flags, potion_boost)
	. = ..()
	riding_mob.density = FALSE

/datum/component/riding/vehicle/big_bike/vehicle_mob_unbuckle(datum/source, mob/living/former_rider, force = FALSE)
	former_rider.density = TRUE
	return ..()

/datum/component/riding/vehicle/big_bike/handle_specials()
	set_riding_offsets(1, list(TEXT_NORTH = list(0, 6, MOB_LAYER), TEXT_SOUTH = list(0, 12, ABOVE_MOB_LAYER), TEXT_EAST = list(-4, 19, ABOVE_MOB_LAYER), TEXT_WEST = list(4, 19, ABOVE_MOB_LAYER)))
	set_riding_offsets(2, list(TEXT_NORTH = list(0, 0, ABOVE_MOB_LAYER), TEXT_SOUTH = list(0, 21, MOB_LAYER), TEXT_EAST = list(-13, 21, MOB_LAYER), TEXT_WEST = list(13, 21, MOB_LAYER)))
	set_vehicle_dir_layer(SOUTH, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(NORTH, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(EAST, MOB_BELOW_PIGGYBACK_LAYER)
	set_vehicle_dir_layer(WEST, MOB_BELOW_PIGGYBACK_LAYER)
