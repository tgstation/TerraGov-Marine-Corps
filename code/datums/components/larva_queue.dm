/**
 * Handles clients getting the button to join the larva queue when they're eligible
 */
/datum/component/larva_queue
	/// The client we track (instead of having to cast every time)
	var/client/waiter
	/// The position we have in the larva queue (0 means you're not in it)
	var/position = 0
	/// Our queue button
	var/datum/action/join_larva_queue/button = null

/datum/component/larva_queue/Initialize()
	. = ..()
	if (QDELETED(parent)) // Client disconnect fuckery
		return COMPONENT_INCOMPATIBLE

	src.waiter = parent
	var/mob/M = waiter.mob // Clients always have a mob
	if(!isxeno(M) && !isobserver(M))
		return COMPONENT_INCOMPATIBLE //Only xenos or observers
	src.button = new
	add_queue_button()

/datum/component/larva_queue/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(add_queue_button))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(remove_queue_button))
	RegisterSignal(parent, COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION, PROC_REF(set_queue_position))
	RegisterSignal(parent, COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION, PROC_REF(get_queue_position))

/datum/component/larva_queue/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_LOGIN,
		COMSIG_MOB_LOGOUT,
		COMSIG_CLIENT_SET_LARVA_QUEUE_POSITION,
		COMSIG_CLIENT_GET_LARVA_QUEUE_POSITION
	))
	src.waiter = null
	QDEL_NULL(src.button)
	. = ..()

/// Returns if the mob is valid to keep waiting in the larva queue
/datum/component/larva_queue/proc/is_valid_to_wait(mob/M)
	. = FALSE
	if (isobserver(M))
		return TRUE
	if (isxeno(M))
		var/mob/living/carbon/xenomorph/xeno = M
		if (xeno.xeno_caste.tier == XENO_TIER_MINION)
			return TRUE

/**
 * Adds the larva queue button whenever the client is eligible to wait
 */
/datum/component/larva_queue/proc/add_queue_button()
	SIGNAL_HANDLER
	if (src.is_valid_to_wait(src.waiter.mob))
		var/datum/action/join_larva_queue/existing_button = src.waiter.mob.actions_by_path[/datum/action/join_larva_queue]
		if(!existing_button) // ZEWAKA TODO: INVEST
			button.give_action(src.waiter.mob)
		// else
			// do we need to fix the toggle

	else
		// Leave the queue since they logged into an ineligible mob
		var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
		HS.remove_from_larva_candidate_queue(src.waiter)

/**
 *  Removes the larva queue button whenever a client leaves a mob
 */
/datum/component/larva_queue/proc/remove_queue_button()
	SIGNAL_HANDLER
	// seemingly nothing? ZEWAKA TODO: DEBUG THE LOGOUT ABILITY BUTTON FLOW

/**
 * Gets the current position in the larva queue
 */
/datum/component/larva_queue/proc/get_queue_position(waiter, return_value)
	SIGNAL_HANDLER
	return_value = src.position

/**
 * Sets the current position in the larva queue
 */
/datum/component/larva_queue/proc/set_queue_position(waiter, new_position)
	SIGNAL_HANDLER
	src.position = new_position
	if (src.position == 0) // We have been removed from the queue
		// ZEWAKA TODO: remove handling idk
		src.remove_queue_button()


/// Action for joining the larva queue
/datum/action/join_larva_queue
	name = "Join Larva Queue"
	action_icon_state = "larva_queue"
	action_type = ACTION_TOGGLE

/datum/action/join_larva_queue/can_use_action()
	. = ..()
	if(!.)
		return FALSE
	if(isobserver(owner) || isxeno(owner))
		return TRUE
	return FALSE

/datum/action/join_larva_queue/action_activate()
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(HS.add_to_larva_candidate_queue(owner.client))
		set_toggle(TRUE)
		return
	set_toggle(FALSE)
