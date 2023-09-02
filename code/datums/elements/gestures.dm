/datum/element/gesture
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/turf/starting_mob_turf
	var/turf/starting_turf

/datum/element/gesture/Attach(datum/target)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_MOB_MOUSEDOWN, PROC_REF(start_gesture))
	RegisterSignal(target, COMSIG_MOB_MOUSEUP, PROC_REF(end_gesture))

/datum/element/gesture/Detach(datum/source, force)
	UnregisterSignal(source, list(
		COMSIG_MOB_MOUSEDOWN,
		COMSIG_MOB_MOUSEUP,
	))
	return ..()

/// Handle weird clicks outside the map or on screen objects
/datum/element/gesture/proc/get_click_object(mob/living/source, atom/object, location, control, params)
	var/list/modifiers = params2list(params)
	if(!modifiers["alt"] || !modifiers["middle"] || modifiers["shift"] || modifiers["ctrl"] || modifiers["left"] || modifiers["right"])
		return
	//Checks if the intended target is in deep darkness and adjusts A based on params.
	if(isnull(location) && object.plane == CLICKCATCHER_PLANE)
		object = params2turf(modifiers["screen-loc"], get_turf(source.client.eye), source.client)
		modifiers["icon-x"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-x"])))
		modifiers["icon-y"] = num2text(ABS_PIXEL_TO_REL(text2num(modifiers["icon-y"])))
		params = list2params(modifiers)
	else if(isnull(location))
		return

	return object

/datum/element/gesture/proc/start_gesture(mob/living/source, atom/object, location, control, params)
	SIGNAL_HANDLER
	if(source.stat != CONSCIOUS)
		return
	object = get_click_object(source, object, location, control, params)
	if(!object)
		return

	starting_turf = get_turf(object)
	starting_mob_turf = get_turf(source) // We use a ref and not the mob, since they can move while doin g this action
	return COMSIG_MOB_CLICK_CANCELED

/datum/element/gesture/proc/end_gesture(mob/living/source, atom/object, location, control, params)
	SIGNAL_HANDLER_DOES_SLEEP
	if(source.stat != CONSCIOUS)
		return
	object = get_click_object(source, object, location, control, params)
	if(!object)
		return

	var/turf/finish_turf = get_turf(object)
	if(starting_turf == finish_turf)
		return

	var/gesture_dir = get_dir(starting_turf, finish_turf)
	var/start_dir_from_mob = get_dir(starting_mob_turf, starting_turf)
	var/end_dir_from_mob = get_dir(starting_mob_turf, finish_turf)

	var/loudness = ""
	switch(get_dist(starting_turf, finish_turf))
		if(0 to 2)
			loudness = ""
		if(3 to 7)
			loudness = "!"
		if(7 to INFINITY)
			loudness = "!!"


	// Simple gesture away from mob
	if(start_dir_from_mob == end_dir_from_mob && end_dir_from_mob == gesture_dir)
		source.say("[dir2text(gesture_dir)][loudness]")
		return COMSIG_MOB_CLICK_CANCELED
	// Gestured across mob
	else if(start_dir_from_mob == REVERSE_DIR(gesture_dir) && end_dir_from_mob == gesture_dir)
		source.say("Push [dir2text(gesture_dir)][loudness]")
		return COMSIG_MOB_CLICK_CANCELED
	// Gesture torwards mob
	else if(start_dir_from_mob == end_dir_from_mob)
		source.say("Pull back [dir2text(gesture_dir)][loudness]")
		return COMSIG_MOB_CLICK_CANCELED

