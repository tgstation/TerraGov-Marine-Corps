/**
 * Handles clients getting the action to join the larva queue when they're eligible
 */
/datum/component/larva_queue
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// The client we track (instead of having to cast every time)
	var/client/waiter
	/// The position we have in the larva queue (0 means you're not in it)
	var/position = 0
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
	if (xeno_caste.tier == XENO_TIER_MINION)
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
		if (position != 0)
			action.set_toggle(TRUE)
	else
		// Leave the queue since they logged into an ineligible mob
		var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HS.remove_from_larva_candidate_queue(waiter)

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
/datum/component/larva_queue/proc/get_queue_position(waiter)
	SIGNAL_HANDLER
	return position

/**
 * Sets the current position in the larva queue
 */
/datum/component/larva_queue/proc/set_queue_position(waiter, new_position)
	SIGNAL_HANDLER
	position = new_position
	if (position == 0) // No longer in queue
		action.set_toggle(FALSE)


/// Action for joining the larva queue
/datum/action/join_larva_queue
	name = "Join Larva Queue"
	action_icon_state = "larva_queue"
	action_type = ACTION_TOGGLE

/datum/action/join_larva_queue/can_use_action()
	. = ..()
	if(!.)
		return FALSE
	if(owner.can_wait_in_larva_queue())
		return TRUE
	return FALSE

/datum/action/join_larva_queue/action_activate()
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(HS.add_to_larva_candidate_queue(owner.client))
		set_toggle(TRUE)
		return
	set_toggle(FALSE)
