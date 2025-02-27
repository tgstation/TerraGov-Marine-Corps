/datum/ai_behavior/human
		///assoc list of hazards to avoid and the range to stay away from them
	var/list/hazard_list = list()
	///Chat lines for avoiding uncategorized hazards
	var/list/default_avoid_chat = list("Watch out!", "Watch out, hazard!", "hazard!", "Keep away from the hazard!", "Well I've never seen a hazard like this before.")
	///Chat lines for avoiding a live nade
	var/list/nade_avoid_chat = list("Watch out!", "Watch out, grenade!", "Grenade!", "Run!", "Get out of the way!", "Grenade, move!")
	///Chat lines for avoiding fire
	var/list/fire_avoid_chat = list("Watch out!", "Watch out, fire!", "fire!", "Keep away from the fire!")

/datum/ai_behavior/human/find_next_dirs()
	. = ..()
	if(!.)
		return
	if(!(human_ai_behavior_flags & HUMAN_AI_AVOID_HAZARDS))
		return

	var/list/dir_options = .
	dir_options = dir_options.Copy()
	var/list/exclude_dirs = list()
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

	if(prob(20))
		try_speak(pick(default_avoid_chat))

///Removes a hazard
/datum/ai_behavior/human/proc/remove_hazard(atom/old_hazard)
	SIGNAL_HANDLER
	hazard_list -= old_hazard
	UnregisterSignal(old_hazard, list(COMSIG_QDELETING, COMSIG_MOVABLE_Z_CHANGED))

///Checks if we are in range of any hazards
/datum/ai_behavior/human/proc/check_hazards()
	for(var/atom/movable/thing AS in hazard_list)
		if(get_dist(mob_parent, thing) <= hazard_list[thing])
			return FALSE
	return TRUE

//maybe move
///Notifies AI of a new hazard
/atom/proc/notify_ai_hazard()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_HAZARD_NOTIFIED, src)

///Returns the radius around this considered a hazard
/atom/proc/get_ai_hazard_radius(mob/living/victim)
	return null //null means no danger, vs 0 means stay off the hazard's turf

/obj/item/explosive/grenade/get_ai_hazard_radius(mob/living/victim)
	if(!dangerous)
		return null
	if((victim.get_soft_armor(BOMB) >= 100))
		return null
	return light_impact_range ? light_impact_range : 3

/obj/item/explosive/grenade/smokebomb/get_ai_hazard_radius(mob/living/victim)
	if(!dangerous)
		return null
	if((victim.get_soft_armor(BIO) >= 100))
		return null
	return smokeradius

/obj/fire/get_ai_hazard_radius(mob/living/victim)
	if((victim.get_soft_armor(FIRE) >= 100))
		return null
	return 0
