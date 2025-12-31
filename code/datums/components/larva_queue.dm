/**
 * Handles clients getting the action to join the larva queue when they're eligible
 */
/datum/component/larva_queue
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The client we track (instead of having to cast every time)
	var/client/waiter
	/// The position we have in the larva queue (0 means you're not in it)
	var/list/positions = list()
	/// Our queue action
	var/datum/action/join_larva_queue/action = null

/datum/component/larva_queue/Initialize()
	. = ..()
	if (QDELETED(parent)) // Client disconnect fuckery
		return COMPONENT_INCOMPATIBLE

	var/client/client = parent
	var/mob/double_check = client.mob // Clients always have a mob
	if(!double_check.can_wait_in_larva_queue())
		return COMPONENT_INCOMPATIBLE

	waiter = client
	action = new
	action.HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	add_queue_action()

/datum/component/larva_queue/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CLIENT_MOB_LOGIN, PROC_REF(add_queue_action))
	RegisterSignal(parent, COMSIG_CLIENT_MOB_LOGOUT, PROC_REF(remove_queue_action))
	RegisterSignal(parent, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, PROC_REF(set_queue_position))
	RegisterSignal(parent, COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION, PROC_REF(get_queue_position))

/datum/component/larva_queue/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_CLIENT_MOB_LOGIN,
		COMSIG_CLIENT_MOB_LOGOUT,
		COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION,
		COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION
	))
	waiter = null
	QDEL_NULL(action)
	return ..()

/// Returns if the mob is valid to keep waiting in the larva queue
/mob/proc/can_wait_in_larva_queue()
	return FALSE

/mob/dead/observer/can_wait_in_larva_queue()
	return TRUE

/mob/living/carbon/xenomorph/can_wait_in_larva_queue()
	. = FALSE
	if (xeno_caste.tier == XENO_TIER_MINION || get_xeno_hivenumber() == XENO_HIVE_FALLEN)
		return TRUE

/**
 * Adds the larva queue action whenever the client is eligible to wait
 * Removes from queue if they were no longer eligible
 */
/datum/component/larva_queue/proc/add_queue_action()
	SIGNAL_HANDLER
	if (waiter.mob.can_wait_in_larva_queue())
		var/datum/action/join_larva_queue/existing_action = waiter.mob.actions_by_path[/datum/action/join_larva_queue]
		if(!existing_action)
			action.give_action(waiter.mob)
		if(!action.HS)
			action.HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
		if (action.HS.hivenumber in positions)
			action.set_toggle(TRUE)
	else
		// Leave the queue since they logged into an ineligible mob
		for(var/hivenumber in GLOB.hive_datums)
			GLOB.hive_datums[hivenumber].remove_from_larva_candidate_queue(waiter)

/**
 * Removes the larva queue action whenever the client leaves a mob
 */
/datum/component/larva_queue/proc/remove_queue_action(client/our_client, mob/old_mob)
	SIGNAL_HANDLER
	var/datum/action/join_larva_queue/existing_action = old_mob.actions_by_path[/datum/action/join_larva_queue]
	existing_action?.remove_action(old_mob)

/**
 * Gets the current position in the larva queue
 */
/datum/component/larva_queue/proc/get_queue_position(waiter, hivenumber)
	SIGNAL_HANDLER
	if(hivenumber in positions)
		return positions[hivenumber]
	return 0

/**
 * Sets the current position in the larva queue
 */
/datum/component/larva_queue/proc/set_queue_position(waiter, new_position, hivenumber)
	SIGNAL_HANDLER
	if(new_position == 0)
		LAZYREMOVE(positions, hivenumber)
	else
		LAZYSET(positions, hivenumber, new_position)
	if(!action.HS)
		action.HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(action.HS.hivenumber != hivenumber)
		return
	action.button.maptext = MAPTEXT_TINY_UNICODE(span_center("[new_position]/[LAZYLEN(action.HS.candidates)]"))
	action.button.maptext_x = 1
	action.button.maptext_y = 3
	if (new_position == 0) // No longer in queue
		action.set_toggle(FALSE)
		action.button.maptext = null

/// Action for joining the larva queue
/datum/action/join_larva_queue
	name = "Join Larva Queue"
	action_icon_state = "larva_queue"
	action_type = ACTION_TOGGLE
	var/datum/hive_status/HS

/datum/action/join_larva_queue/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return FALSE
	if(owner.can_wait_in_larva_queue())
		return TRUE
	return FALSE

/datum/action/join_larva_queue/action_activate()
	HS.add_to_larva_candidate_queue(owner.client)
	update_button_icon()

/datum/action/join_larva_queue/update_button_icon()
	. = ..()
	if(!.)
		return
	var/larva_position = SEND_SIGNAL(owner.client, COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION, HS.hivenumber)
	set_toggle(!!larva_position)
	if(larva_position)
		button.maptext = MAPTEXT_TINY_UNICODE(span_center("[larva_position]/[LAZYLEN(HS.candidates)]"))
	else
		button.maptext = ""
	button.color = HS.color

/datum/action/join_larva_queue/alternate_action_activate()
	ASYNC
		var/hivechoice = tgui_input_list(owner, "Choose your hive.", "Join Larva Queue", list("Normal", "Corrupted"))
		switch(hivechoice)
			if("Normal")
				HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
			if("Corrupted")
				HS = GLOB.hive_datums[XENO_HIVE_CORRUPTED]
		update_button_icon()
