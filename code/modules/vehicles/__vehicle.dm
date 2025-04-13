/obj/vehicle
	name = "generic vehicle"
	desc = "Yell at coderbus."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "fuckyou"
	max_integrity = 300
	soft_armor = list(MELEE = 30, BULLET = 30, LASER = 30, ENERGY = 0, BOMB = 30, FIRE = 60, ACID = 60)
	density = TRUE
	anchored = FALSE
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	obj_flags = CAN_BE_HIT
	atom_flags = CRITICAL_ATOM
	resistance_flags = XENO_DAMAGEABLE
	allow_pass_flags = PASS_AIR
	COOLDOWN_DECLARE(cooldown_vehicle_move)
	///mob = bitflags of their control level.
	var/list/mob/occupants
	///Maximum amount of passengers plus drivers
	var/max_occupants = 1
	////Maximum amount of drivers
	var/max_drivers = 1
	var/move_delay = 2
	///multitile hitbox, set to a hitbox type to make this vehicle multitile.
	var/obj/hitbox/hitbox
	/**
	  * If the driver needs a certain item in hand (or inserted, for vehicles) to drive this. For vehicles, this must be duplicated on their riding component subtype
	  * [/datum/component/riding/var/keytype] variable because only a few specific checks are handled here with this var, and the majority of it is on the riding component
	  * Eventually the remaining checks should be moved to the component and this var removed.
	  */
	var/key_type
	///The inserted key, needed on some vehicles to start the engine
	var/obj/item/key/inserted_key
	/// Whether the vehicle is currently able to move
	var/canmove = TRUE
	///plain list of typepaths
	var/list/autogrant_actions_passenger
	///assoc list "[bitflag]" = list(typepaths)
	var/list/autogrant_actions_controller
	///assoc list mob = list(type = action datum assigned to mob)
	var/list/mob/occupant_actions
	///This vehicle will follow us when we move (like atrailer duh)
	var/obj/vehicle/trailer
	var/are_legs_exposed = FALSE
	/// Whether this vehicle triggers gargoyles
	var/trigger_gargoyle = TRUE

/obj/vehicle/Initialize(mapload)
	. = ..()
	if(hitbox)
		hitbox = new hitbox(loc, src)
	occupants = list()
	autogrant_actions_passenger = list()
	autogrant_actions_controller = list()
	occupant_actions = list()
	generate_actions()

/obj/vehicle/examine(mob/user)
	. = ..()
	if(resistance_flags & ON_FIRE)
		. += span_warning("It's on fire!")
	var/healthpercent = obj_integrity/max_integrity * 100
	switch(healthpercent)
		if(50 to 99)
			. += "It looks slightly damaged."
		if(25 to 50)
			. += "It appears heavily damaged."
		if(0 to 25)
			. += span_warning("It's falling apart!")

/obj/vehicle/ai_should_stay_buckled(mob/living/carbon/npc)
	return !is_driver(npc) //NPC's can't operate vehicles so we generally only want them buckled as a passenger

/obj/vehicle/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount, damage_type, armor_type, effects, armor_penetration, isrightclick)
	if(xeno_attacker.endurance_active)
		return FALSE
	return ..()

/obj/vehicle/proc/is_key(obj/item/I)
	return istype(I, key_type)

/obj/vehicle/proc/return_occupants()
	return occupants

/obj/vehicle/proc/occupant_amount()
	return LAZYLEN(occupants)

/obj/vehicle/proc/return_amount_of_controllers_with_flag(flag)
	. = 0
	for(var/i in occupants)
		if(occupants[i] & flag)
			.++

/obj/vehicle/proc/return_controllers_with_flag(flag)
	RETURN_TYPE(/list/mob)
	. = list()
	for(var/i in occupants)
		if(occupants[i] & flag)
			. += i

/obj/vehicle/proc/return_drivers()
	return return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)

/obj/vehicle/proc/driver_amount()
	return return_amount_of_controllers_with_flag(VEHICLE_CONTROL_DRIVE)

/obj/vehicle/proc/is_driver(mob/M)
	return is_occupant(M) && occupants[M] & VEHICLE_CONTROL_DRIVE

///Is the passed mob an equipment controller?
/obj/vehicle/proc/is_equipment_controller(mob/M)
	return is_occupant(M) && occupants[M] & VEHICLE_CONTROL_EQUIPMENT

/obj/vehicle/proc/is_occupant(mob/M)
	return !isnull(LAZYACCESS(occupants, M))

/obj/vehicle/proc/add_occupant(mob/M, control_flags)
	if(!istype(M) || is_occupant(M))
		return FALSE
	LAZYSET(occupants, M, NONE)
	add_control_flags(M, control_flags)
	after_add_occupant(M)
	grant_passenger_actions(M)
	return TRUE

/obj/vehicle/proc/after_add_occupant(mob/M)
	auto_assign_occupant_flags(M)

/obj/vehicle/proc/auto_assign_occupant_flags(mob/M) //override for each type that needs it. Default is assign driver if drivers is not at max.
	if(driver_amount() < max_drivers)
		add_control_flags(M, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/proc/remove_occupant(mob/M)
	SHOULD_CALL_PARENT(TRUE)
	if(!istype(M))
		return FALSE
	remove_control_flags(M, ALL)
	remove_passenger_actions(M)
	LAZYREMOVE(occupants, M)
	cleanup_actions_for_mob(M)
	after_remove_occupant(M)
	return TRUE

/obj/vehicle/proc/after_remove_occupant(mob/M)
	return

/obj/vehicle/relaymove(mob/living/user, direction)
	if(!canmove)
		return FALSE
	if(is_driver(user))
		return relaydrive(user, direction)
	return FALSE

/obj/vehicle/proc/after_move(direction)
	return

///Adds control flags and any associated changes to a mob
/obj/vehicle/proc/add_control_flags(mob/controller, flags)
	if(!is_occupant(controller) || !flags)
		return FALSE
	occupants[controller] |= flags
	SEND_SIGNAL(src, COMSIG_VEHICLE_GRANT_CONTROL_FLAG, controller, flags)
	for(var/i in GLOB.bitflags)
		if(flags & i)
			grant_controller_actions_by_flag(controller, i)
	return TRUE

///Removes control flags and any associated changes to a mob
/obj/vehicle/proc/remove_control_flags(mob/controller, flags)
	if(!is_occupant(controller) || !flags)
		return FALSE
	occupants[controller] &= ~flags
	SEND_SIGNAL(src, COMSIG_VEHICLE_REVOKE_CONTROL_FLAG, controller, flags)
	for(var/i in GLOB.bitflags)
		if(flags & i)
			remove_controller_actions_by_flag(controller, i)
	return TRUE

///Any special behavior when a desant is added
/obj/vehicle/proc/add_desant(mob/living/new_desant)
	return

///Any special behavior when a desant is removed
/obj/vehicle/proc/remove_desant(mob/living/old_desant)
	return

/obj/vehicle/Moved(atom/old_loc, movement_dir, forced, list/old_locs)
	. = ..()
	if(trailer)
		trailer.Move(old_loc, movement_dir, glide_size)


//TGMC ADDED BELOW
/obj/vehicle/effect_smoke(obj/effect/particle_effect/smoke/S)
	. = ..()
	if(CHECK_BITFIELD(S.smoke_traits, SMOKE_XENO_ACID))
		take_damage(20 * S.strength, BURN, ACID)
