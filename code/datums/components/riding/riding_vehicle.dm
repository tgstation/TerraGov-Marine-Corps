// For any /obj/vehicle's that can be ridden

/datum/component/riding/vehicle/Initialize(mob/living/riding_mob, force = FALSE, ride_check_flags = (RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS), potion_boost = FALSE)
	if(!isvehicle(parent))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/riding/vehicle/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_RIDDEN_DRIVER_MOVE, .proc/driver_move)

/datum/component/riding/vehicle/driver_move(atom/movable/movable_parent, mob/living/user, direction)
	if(!COOLDOWN_CHECK(src, vehicle_move_cooldown))
		return COMPONENT_DRIVER_BLOCK_MOVE
	var/obj/vehicle/vehicle_parent = parent

	if(!keycheck(user))
		if(COOLDOWN_CHECK(src, message_cooldown))
			to_chat(user, "<span class='warning'>[vehicle_parent] has no key inserted!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(HAS_TRAIT(user, TRAIT_INCAPACITATED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You slip off \the [vehicle_parent] as your body slumps!</span>")

		if(COOLDOWN_CHECK(src, message_cooldown))
			to_chat(user, "<span class='warning'>You cannot operate \the [vehicle_parent] right now!</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_LEGS && HAS_TRAIT(user, TRAIT_FLOORED))
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it while unable to stand!</span>")

		if(COOLDOWN_CHECK(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to manage that while unable to stand up enough to move \the [vehicle_parent]...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	if(ride_check_flags & RIDER_NEEDS_ARMS && user.restrained())
		if(ride_check_flags & UNBUCKLE_DISABLED_RIDER)
			vehicle_parent.unbuckle_mob(user, TRUE)
			user.visible_message("<span class='danger'>[user] falls off \the [vehicle_parent].</span>",\
			"<span class='danger'>You fall off \the [vehicle_parent] while trying to operate it without being able to hold on!</span>")

		if(COOLDOWN_CHECK(src, message_cooldown))
			to_chat(user, "<span class='warning'>You can't seem to hold onto \the [vehicle_parent] to move it...</span>")
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		return COMPONENT_DRIVER_BLOCK_MOVE

	handle_ride(user, direction)

/// This handles the actual movement for vehicles once [/datum/component/riding/vehicle/proc/driver_move] has given us the green light
/datum/component/riding/vehicle/proc/handle_ride(mob/user, direction)
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

	step(movable_parent, direction)
	last_move_diagonal = ((direction & (direction - 1)) && (movable_parent.loc == next))
	COOLDOWN_START(src, vehicle_move_cooldown, (last_move_diagonal? 2 : 1) * vehicle_move_delay)

	if(QDELETED(src))
		return
	handle_vehicle_layer(movable_parent.dir)
	handle_vehicle_offsets(movable_parent.dir)
	return TRUE

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
	set_vehicle_dir_layer(SOUTH, POWERLOADER_LAYER)
	set_vehicle_dir_layer(NORTH, POWERLOADER_LAYER)
	set_vehicle_dir_layer(EAST, POWERLOADER_LAYER)
	set_vehicle_dir_layer(WEST, POWERLOADER_LAYER)

/datum/component/riding/vehicle/bicycle
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 0

/datum/component/riding/vehicle/bicycle/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list(0, 4)))

/datum/component/riding/vehicle/wheelchair
	vehicle_move_delay = 0
	ride_check_flags = RIDER_NEEDS_ARMS

/datum/component/riding/vehicle/wheelchair/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

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
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_LYING_MOB_LAYER)
	set_vehicle_dir_offsets(NORTH, -10, 0)
	set_vehicle_dir_offsets(SOUTH, 10, 0)

/datum/component/riding/vehicle/motorbike/sidecar/get_offsets(pass_index, mob_type)
	switch(pass_index)
		if(1) //first one buckled, so driver
			return list(TEXT_NORTH = list(9, 3), TEXT_SOUTH = list(-9, 3), TEXT_EAST = list(-2, 3), TEXT_WEST = list(2, 3))
		if(2) //second one buckled, so sidecar rider
			return list(TEXT_NORTH = list(-6, 2), TEXT_SOUTH = list(6, 2), TEXT_EAST = list(-3, 0, ABOVE_OBJ_LAYER), TEXT_WEST = list(3, 0, LYING_MOB_LAYER))
