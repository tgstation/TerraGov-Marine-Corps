/datum/ai_behavior/human
	/// Assoc list of hazards to avoid and the range to stay away from them
	var/list/hazard_list = list()

/datum/ai_behavior/human/find_next_dirs()
	. = ..()
	if(!.)
		return
	if(!(human_ai_behavior_flags & HUMAN_AI_AVOID_HAZARDS))
		return

	var/list/dir_options = .
	dir_options = dir_options.Copy()
	var/list/exclude_dirs = list()

	var/turf/owner_turf = get_turf(mob_parent)

	//lava
	if(can_cross_lava_turf(owner_turf)) //if we're already in lava, we skip these checks since we're probs gonna have to walk through more to get out
		for(var/dir_option in dir_options)
			var/turf/turf_option = get_step(owner_turf, dir_option)
			if(!islava(turf_option))
				continue
			if(turf_option.is_covered())
				continue
			exclude_dirs |= dir_option

		dir_options -= exclude_dirs
		if(!length(dir_options))
			return NONE //if we're NOT in lava, we do not deliberately path into lava
			//todo: Need to have NPC path around lava entirely (or jump over it), if their direct path is into lava

	//hazards
	exclude_dirs.Cut()
	for(var/atom/movable/thing AS in hazard_list)
		var/dist = get_dist(mob_parent, thing)
		if(dist > hazard_list[thing] + 1)
			continue
		if(!isturf(thing.loc)) //picked up nade etc
			continue
		if(dist == 0)
			if(length(dir_options)) //we want to get off the hazard, but if we're trying to go somewhere else already, then that dir is fine
				continue
			dir_options = CARDINAL_ALL_DIRS
			continue
		var/dir_to_hazard = get_dir(mob_parent, thing)
		exclude_dirs |= dir_to_hazard
		exclude_dirs |= turn(dir_to_hazard, 45)
		exclude_dirs |= turn(dir_to_hazard, -45)

		dir_options |= REVERSE_DIR(dir_to_hazard)
		if(dist > (ROUND_UP(hazard_list[thing] * 0.5))) //outer half of danger zone, lets add diagonals for variation
			dir_options |= turn(dir_to_hazard, 135)
			dir_options |= turn(dir_to_hazard, 225)

	dir_options -= exclude_dirs
	if(length(dir_options))
		return dir_options
	//if hazards cause movement paralysis, we just say fuck it, and ignore them since apparently every direction is dangerous

///Clear the hazard list if we change z
/datum/ai_behavior/human/proc/on_change_z(atom/movable/source, old_z, new_z)
	SIGNAL_HANDLER
	for(var/hazard in hazard_list)
		remove_hazard(hazard)

///Adds a hazard to watch for
/datum/ai_behavior/human/proc/add_hazard(datum/source, atom/hazard)
	SIGNAL_HANDLER
	var/turf/hazard_turf = get_turf(hazard)
	if(hazard_turf.z != mob_parent.z)
		return
	var/hazard_radius = hazard.get_ai_hazard_radius(mob_parent)
	if(isnull(hazard_radius))
		return
	hazard_list[hazard] = hazard_radius
	RegisterSignals(hazard, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED), PROC_REF(remove_hazard))
	if(get_dist(mob_parent, hazard) > 5)
		return
	if(isgrenade(hazard))
		if(prob(85))
			key_speak(AI_SPEECH_HAZARD_GRENADE)
		return
	if(isfire(hazard))
		if(prob(20))
			key_speak(AI_SPEECH_HAZARD_FIRE)
		return
	if(istype(hazard, /obj/effect/xenomorph/spray))
		if(prob(20))
			key_speak(AI_SPEECH_HAZARD_ACID)
		return
	if(istype(hazard, /obj/effect/abstract/ripple))
		if(prob(20))
			key_speak(AI_SPEECH_HAZARD_SHUTTLE)
		return
	if(istype(hazard, /obj/effect/overlay/blinking_laser/marine))
		if(prob(20))
			key_speak(AI_SPEECH_HAZARD_CAS)
		return
	if(isfacehugger(hazard))
		if(prob(20))
			key_speak(AI_SPEECH_HAZARD_FACEHUGGER)
		return
	if(istype(hazard, /obj/effect/xeno/crush_warning) || istype(hazard, /obj/effect/xeno/abduct_warning) || istype(hazard, /obj/effect/temp_visual/behemoth/warning))
		if(prob(20))
			key_speak(AI_SPEECH_HAZARD_XENO_AOE)
		return

	if(prob(20))
		key_speak(AI_SPEECH_HAZARD_GENERIC)

///Removes a hazard
/datum/ai_behavior/human/proc/remove_hazard(atom/old_hazard)
	SIGNAL_HANDLER
	hazard_list -= old_hazard
	UnregisterSignal(old_hazard, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED))

///Checks if we are safe from any hazards
/datum/ai_behavior/human/proc/check_hazards()
	for(var/atom/movable/thing AS in hazard_list)
		if(get_dist(mob_parent, thing) <= hazard_list[thing])
			return FALSE
	return TRUE
