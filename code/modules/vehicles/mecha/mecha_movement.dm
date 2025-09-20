/// Sets the direction of the mecha and all of its occcupents, required for FOV. Alternatively one could make a recursive contents registration and register topmost direction changes in the fov component
/obj/vehicle/sealed/mecha/setDir(newdir)
	. = ..()
	for(var/mob/living/occupant AS in occupants)
		occupant.setDir(newdir)

///Plays the mech step sound effect. Split from movement procs so that other mechs (HONK) can override this one specific part.
/obj/vehicle/sealed/mecha/proc/play_stepsound(atom/movable/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	if(forced)
		return
	if(HAS_TRAIT(src, TRAIT_SILENT_FOOTSTEPS))
		return
	playsound(src, stepsound, 40, TRUE)

///Disconnects air tank- air port connection on mecha move
/obj/vehicle/sealed/mecha/proc/disconnect_air()
	SIGNAL_HANDLER
	if(internal_tank.disconnect()) // Something moved us and broke connection
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("Air port connection has been severed!")]")
		log_message("Lost connection to gas port.", LOG_MECHA)

///Called when the driver turns with the movement lock key
/obj/vehicle/sealed/mecha/proc/on_turn(mob/living/driver, direction)
	SIGNAL_HANDLER
	return COMSIG_IGNORE_MOVEMENT_LOCK

/obj/vehicle/sealed/mecha/relaymove(mob/living/user, direction)
	. = TRUE
	if(!canmove || !(user in return_drivers()))
		return
	vehicle_move(user, direction)

/obj/vehicle/sealed/mecha/vehicle_move(mob/living/user, direction, forcerotate = FALSE)
	. = ..()
	if(!.)
		return
	if(completely_disabled)
		return FALSE
	if(!direction)
		return FALSE
	if(ismovable(loc)) //Mech is inside an object, tell it we moved
		var/atom/loc_atom = loc
		return loc_atom.relaymove(src, direction)
	if(internal_tank?.connected_port)
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to move while connected to the air system port!")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(construction_state)
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_danger("Maintenance protocols in effect.")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE

	if(zoom_mode)
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Unable to move while in zoom mode!")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!cell)
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Missing power cell.")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(!scanmod || !capacitor)
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Missing [scanmod? "capacitor" : "scanning module"].")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		return FALSE
	if(step_energy_drain && !use_power(step_energy_drain))
		if(TIMER_COOLDOWN_FINISHED(src, COOLDOWN_MECHA_MESSAGE))
			to_chat(occupants, "[icon2html(src, occupants)][span_warning("Insufficient power to move!")]")
			TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_MESSAGE, 2 SECONDS)
		if(leg_overload_mode)
			for(var/mob/booster AS in occupant_actions)
				var/action_type = /datum/action/vehicle/sealed/mecha/mech_overload_mode
				var/datum/action/vehicle/sealed/mecha/mech_overload_mode/overload = occupant_actions[booster][action_type]
				if(!overload)
					continue
				overload.action_activate(NONE, FALSE)
				break
		return FALSE

	var/olddir = dir

	if(internal_damage & MECHA_INT_CONTROL_LOST)
		direction = pick(GLOB.alldirs)

	//only mechs with diagonal movement may move diagonally
	if(!allow_diagonal_movement && ISDIAGONALDIR(direction))
		return TRUE

	var/keyheld = FALSE
	if(strafe)
		for(var/mob/driver AS in return_drivers())
			if(driver.client?.keys_held["Alt"])
				keyheld = TRUE
				break

	//if we're not facing the way we're going rotate us
	// if we're not strafing or if we are forced to rotate or if we are holding down the key
	if(dir != direction && (!strafe || forcerotate || keyheld))
		// remove diag dirs so it doesnt fuck up any directional stuff
		var/dir_to_set = ISDIAGONALDIR(direction) ? (direction & ~(NORTH|SOUTH)) : direction
		setDir(dir_to_set)
		if(!(mecha_flags & QUIET_TURNS))
			playsound(src, turnsound, 40, TRUE)
		if(keyheld || !pivot_step) //If we pivot step, we don't return here so we don't just come to a stop
			return TRUE

	set_glide_size(DELAY_TO_GLIDE_SIZE(move_delay))
	//Otherwise just walk normally
	. = try_step_multiz(direction)

	if(phasing)
		use_power(phasing_energy_drain)
	if(strafe)
		setDir(olddir)

/obj/vehicle/sealed/mecha/Bump(atom/obstacle)
	. = ..()
	if(phasing) //Theres only one cause for phasing canpass fails
		to_chat(occupants, "[icon2html(src, occupants)][span_warning("A dull, universal force is preventing you from [phasing] here!")]")
		spark_system.start()
		return
	if(.) //mech was thrown/door/whatever
		return
	if(bumpsmash) //Need a pilot to push the PUNCH button.
		if(COOLDOWN_FINISHED(src, mecha_bump_smash))
			var/list/mob/mobster = return_drivers()
			obstacle.mech_melee_attack(src, mobster[1])
			COOLDOWN_START(src, mecha_bump_smash, smashcooldown)
			if(!obstacle || obstacle.CanPass(src, get_dir(obstacle, src) || dir)) // The else is in case the obstacle is in the same turf.
				step(src, dir)

/obj/vehicle/sealed/mecha/set_submerge_level(turf/new_loc, turf/old_loc, submerge_icon = 'icons/turf/alpha_128.dmi', submerge_icon_state = "liquid_alpha", duration = move_delay)
	return ..()
