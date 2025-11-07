/datum/ai_behavior/human
		///assoc list of hazards to avoid and the range to stay away from them
	var/list/hazard_list = list()
	///Chat lines for avoiding uncategorized hazards
	var/list/default_avoid_chat = list("Watch out!", "Watch out, hazard!", "hazard!", "Keep away from the hazard!", "Well I've never seen a hazard like this before.")
	///Chat lines for avoiding a live nade
	var/list/nade_avoid_chat = list("Watch out!", "Watch out, grenade!", "Grenade!", "Run!", "Get out of the way!", "Grenade, move!")
	///Chat lines for avoiding fire
	var/list/fire_avoid_chat = list("Watch out!", "Watch out, fire!", "fire!", "Keep away from the fire!", "Someone put out that fire!", "Clear that fire!", "Keep clear of the flames!", "It's only a bit of fire!")
	///Chat lines for avoiding acid
	var/list/acid_avoid_chat = list("Watch out!", "Watch out, acid!", "acid!", "Keep away from the acid!", "Don't step in that acid.", "They're spraying acid!")
	///Chat lines for avoiding shuttles
	var/list/shuttle_avoid_chat = list("Watch out!", "Watch out, it's landing!", "Landing!", "Keep away from landing zone!", "Don't step in under that ship!", "They're landing, keep clear!", "Keep clear!", "Make way!")
	///Chat lines for avoiding cas
	var/list/cas_avoid_chat = list("Watch out!", "Watch out, CAS!", "CAS!", "Keep away from the CAS!", "Don't get bombed!.", "They're dropping CAS!", "CAS, move!", "Take cover!")
	///Chat lines for avoiding xeno warnings
	var/list/xeno_avoid_chat = list("Watch out!", "Watch out, xeno!", "xeno!", "Keep away from the xeno!", "Don't step get hit by that xeno!", "They're doing something here!")

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
			try_speak(pick(nade_avoid_chat))
		return
	if(isfire(hazard))
		if(prob(20))
			try_speak(pick(fire_avoid_chat))
		return
	if(istype(hazard, /obj/effect/xenomorph/spray))
		if(prob(20))
			try_speak(pick(acid_avoid_chat))
		return
	if(istype(hazard, /obj/effect/abstract/ripple))
		if(prob(20))
			try_speak(pick(shuttle_avoid_chat))
		return
	if(istype(hazard, /obj/effect/overlay/blinking_laser/marine))
		if(prob(20))
			try_speak(pick(cas_avoid_chat))
		return
	if(isfacehugger(hazard) || istype(hazard, /obj/effect/xeno/crush_warning) || istype(hazard, /obj/effect/xeno/abduct_warning) || istype(hazard, /obj/effect/temp_visual/behemoth/warning))
		if(prob(20))
			try_speak(pick(xeno_avoid_chat))
		return

	if(prob(20))
		try_speak(pick(default_avoid_chat))

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
