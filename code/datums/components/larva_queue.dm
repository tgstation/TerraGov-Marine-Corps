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
	/// Hive we're queueing for
	var/datum/hive_status/hive

/datum/component/larva_queue/Initialize(datum/hive_status/hive)
	. = ..()
	if (QDELETED(parent)) // Client disconnect fuckery
		return COMPONENT_INCOMPATIBLE
	if(!istype(hive))
		return COMPONENT_INCOMPATIBLE
	src.hive = hive

	var/client/client = parent
	var/mob/double_check = client.mob // Clients always have a mob
	if(!double_check.can_wait_in_larva_queue())
		return COMPONENT_INCOMPATIBLE

	waiter = client
	action = new
	add_queue_action()
	RegisterSignal(hive, COMSIG_HIVE_LARVA_UPDATE, PROC_REF(update_button_maptext))
	update_button_maptext(hive, LAZYLEN(hive.candidates))

/datum/component/larva_queue/Destroy(force, silent)
	UnregisterSignal(hive, COMSIG_HIVE_LARVA_UPDATE)
	hive = null
	return ..()

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

/datum/component/larva_queue/proc/update_button_maptext(datum/hive_status/hive, queue_size)
	if(!position)
		action.position_text = "[queue_size]"
		return
	action.position_text = "[position]/[queue_size]"
	action.update_button_icon()

/// Action for joining the larva queue
/datum/action/join_larva_queue
	name = "Join Larva Queue"
	action_icon_state = "larva_queue"
	action_type = ACTION_TOGGLE
	var/position_text

/datum/action/join_larva_queue/can_use_action(silent, override_flags, selecting)
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

/datum/action/join_larva_queue/give_action(mob/M)
	. = ..()
	
	var/mutable_appearance/larva_queue_maptext = mutable_appearance(icon = null, icon_state = null, layer = ACTION_LAYER_MAPTEXT)
	visual_references[VREF_IMAGE_ONTOP] = larva_queue_maptext
	larva_queue_maptext.maptext = MAPTEXT_TINY_UNICODE(span_center("0"))
	button.add_overlay(visual_references[VREF_IMAGE_ONTOP])

/datum/action/join_larva_queue/remove_action(mob/M)
	. = ..()
	button.cut_overlay(visual_references[VREF_IMAGE_ONTOP])
	visual_references -= VREF_IMAGE_ONTOP

/datum/action/join_larva_queue/update_button_icon()
	if(!visual_references.Find(VREF_IMAGE_ONTOP))
		return ..()
	button.cut_overlay(visual_references[VREF_IMAGE_ONTOP])
	var/mutable_appearance/larva_queue_maptext = visual_references[VREF_IMAGE_ONTOP]
	larva_queue_maptext.maptext = MAPTEXT_TINY_UNICODE(span_center(position_text))
	button.add_overlay(visual_references[VREF_IMAGE_ONTOP])

	return ..()