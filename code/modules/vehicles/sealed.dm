/obj/vehicle/sealed
	atom_flags = PREVENT_CONTENTS_EXPLOSION|CRITICAL_ATOM
	var/enter_delay = 2 SECONDS
	var/mouse_pointer
	var/headlights_toggle = FALSE
	///Modifiers for directional damage reduction
	var/list/facing_modifiers = list(VEHICLE_FRONT_ARMOUR = 1, VEHICLE_SIDE_ARMOUR = 1, VEHICLE_BACK_ARMOUR = 1)


/obj/vehicle/sealed/Initialize(mapload)
	. = ..()
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/vehicle/sealed/generate_actions()
	. = ..()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/climb_out)

/obj/vehicle/sealed/generate_action_type()
	var/datum/action/vehicle/sealed/E = ..()
	. = E
	if(istype(E))
		E.vehicle_entered_target = src

/obj/vehicle/sealed/MouseDrop_T(atom/dropping, mob/M)
	if(!istype(dropping) || !istype(M))
		return ..()
	if(M == dropping)
		mob_try_enter(M)
	return ..()

/obj/vehicle/sealed/Exited(atom/movable/gone, direction)
	. = ..()
	if(ismob(gone))
		remove_occupant(gone)

// so that we can check the access of the vehicle's occupants. Ridden vehicles do this in the riding component, but these don't have that
/obj/vehicle/sealed/Bump(atom/A)
	. = ..()
	if(istype(A, /obj/machinery/door))
		var/obj/machinery/door/conditionalwall = A
		for(var/occupant in occupants)
			conditionalwall.bumpopen(occupant)

/obj/vehicle/sealed/onZImpact(turf/impacted_turf, levels, impact_flags = NONE)
	impact_flags |= ZIMPACT_NO_SPIN
	return ..()

/obj/vehicle/sealed/after_add_occupant(mob/M)
	. = ..()
	ADD_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/vehicle/sealed/after_remove_occupant(mob/M)
	. = ..()
	REMOVE_TRAIT(M, TRAIT_HANDS_BLOCKED, VEHICLE_TRAIT)

/obj/vehicle/sealed/modify_by_armor(damage_amount, armor_type, penetration, def_zone, attack_dir)
	. = ..()
	if(!.)
		return
	if(!attack_dir)
		return
	. *= get_armour_facing(abs(dir2angle(dir) - dir2angle(attack_dir)))

/obj/vehicle/sealed/take_damage(damage_amount, damage_type = BRUTE, armor_type = null, effects = TRUE, attack_dir, armour_penetration = 0, mob/living/blame_mob)
	. = ..()
	if(. < 50)
		return
	if(QDELETED(src))
		return
	var/shake_strength = 2
	var/shake_duration = 0.2 SECONDS
	if(. < 300)
		shake_duration = 0.4 SECONDS
	else
		shake_strength = 4
		shake_duration = 0.6 SECONDS
	Shake(shake_strength, shake_strength, shake_duration, 0.04 SECONDS)
	for(var/mob/living/living_victim AS in occupants)
		shake_camera(living_victim, shake_duration * 0.5, shake_strength * 0.5)

///Entry checks for the mob before entering the vehicle
/obj/vehicle/sealed/proc/mob_try_enter(mob/entering_mob, mob/user, loc_override = FALSE)
	if(!istype(entering_mob))
		return FALSE
	if(!user)
		user = entering_mob
	if(do_after(user, get_enter_delay(entering_mob), target = entering_mob, user_display = BUSY_ICON_FRIENDLY, extra_checks = CALLBACK(src, PROC_REF(enter_checks), entering_mob, loc_override)))
		mob_enter(entering_mob)
		return TRUE
	return FALSE


/// returns enter do_after delay for the given mob in ticks
/obj/vehicle/sealed/proc/get_enter_delay(mob/M)
	return enter_delay

///Extra checks to perform during the do_after to enter the vehicle
/obj/vehicle/sealed/proc/enter_checks(mob/entering_mob, loc_override = FALSE)
	return occupant_amount() < max_occupants

///Enters the vehicle
/obj/vehicle/sealed/proc/mob_enter(mob/M, silent = FALSE)
	if(!istype(M))
		return FALSE
	if(!silent)
		M.visible_message(span_notice("[M] climbs into \the [src]!"))
	M.forceMove(src)
	add_occupant(M)
	return TRUE

///Exit checks for the mob before exiting the vehicle
/obj/vehicle/sealed/proc/mob_try_exit(mob/M, mob/user, silent = FALSE, randomstep = FALSE)
	mob_exit(M, silent, randomstep)

///Exits the vehicle
/obj/vehicle/sealed/proc/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	SIGNAL_HANDLER
	if(!istype(M))
		return FALSE
	remove_occupant(M)
	if(!isAI(M))//This is the ONE mob we dont want to be moved to the vehicle that should be handeled when used
		M.forceMove(exit_location(M))
	if(randomstep)
		var/turf/target_turf = get_step(exit_location(M), pick(GLOB.cardinals))
		M.throw_at(target_turf, 5, 10)

	if(!silent)
		M.visible_message(span_notice("[M] drops out of \the [src]!"))
	return TRUE

/obj/vehicle/sealed/proc/exit_location(mob/M)
	return drop_location()

/obj/vehicle/sealed/attackby(obj/item/I, mob/user, params)
	if(key_type && !is_key(inserted_key) && is_key(I))
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("You insert [I] into [src]."))
			if(inserted_key) //just in case there's an invalid key
				inserted_key.forceMove(drop_location())
			inserted_key = I
		else
			to_chat(user, span_warning("[I] seems to be stuck to your hand!"))
		return
	return ..()

/obj/vehicle/sealed/proc/remove_key(mob/user)
	if(!inserted_key)
		to_chat(user, span_warning("There is no key in [src]!"))
		return
	if(!is_occupant(user) || !(occupants[user] & VEHICLE_CONTROL_DRIVE))
		to_chat(user, span_warning("You must be driving [src] to remove [src]'s key!"))
		return
	to_chat(user, span_notice("You remove [inserted_key] from [src]."))
	inserted_key.forceMove(drop_location())
	if(!HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		user.put_in_hands(inserted_key)
	inserted_key = null

/obj/vehicle/sealed/Destroy()
	dump_mobs()
	return ..()

/obj/vehicle/sealed/proc/dump_mobs(randomstep = TRUE)
	for(var/i in occupants)
		mob_exit(i, null, randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/Carbon = i
			Carbon.Paralyze(4 SECONDS)

/obj/vehicle/sealed/proc/dump_specific_mobs(flag, randomstep = TRUE)
	for(var/i in occupants)
		if(!(occupants[i] & flag))
			continue
		mob_exit(i, null, randomstep)
		if(iscarbon(i))
			var/mob/living/carbon/C = i
			C.Paralyze(4 SECONDS)


/obj/vehicle/sealed/AllowDrop()
	return FALSE

/obj/vehicle/sealed/relaymove(mob/living/user, direction)
	if(is_driver(user) && canmove)
		vehicle_move(user, direction)
	return TRUE

/// Sinced sealed vehicles (cars and mechs) don't have riding components, the actual movement is handled here from [/obj/vehicle/sealed/proc/relaymove]
/obj/vehicle/sealed/proc/vehicle_move(mob/living/user, direction)
	SHOULD_CALL_PARENT(TRUE)
	if(!COOLDOWN_FINISHED(src, cooldown_vehicle_move))
		return FALSE
	COOLDOWN_START(src, cooldown_vehicle_move, move_delay)
	return !(SEND_SIGNAL(src, COMSIG_VEHICLE_MOVE, user, direction) & COMPONENT_DRIVER_BLOCK_MOVE)

/// returns a number for the damage multiplier for this relative angle/dir
/obj/vehicle/sealed/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(180) // BACKSTAB!
			return facing_modifiers[VEHICLE_BACK_ARMOUR]
		if(0, 45) // direct or 45 degrees off
			return facing_modifiers[VEHICLE_FRONT_ARMOUR]
	return facing_modifiers[VEHICLE_SIDE_ARMOUR] //if its not a front hit or back hit then assume its from the side
