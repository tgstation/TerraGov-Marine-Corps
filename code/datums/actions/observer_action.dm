/datum/action/observer_action/can_use_action()
	. = ..()
	if(!.)
		return FALSE
	if(!isobserver(owner))
		return FALSE
	return TRUE


/datum/action/observer_action/crew_manifest
	name = "Show Crew manifest"
	action_icon = 'icons/obj/items/books.dmi'
	action_icon_state = "book"


/datum/action/observer_action/crew_manifest/action_activate()
	if(!can_use_action())
		return FALSE
	var/mob/dead/observer/O = owner
	O.view_manifest()


/datum/action/observer_action/show_hivestatus
	name = "Show Hive status"
	action_icon_state = "watch_xeno"


/datum/action/observer_action/show_hivestatus/action_activate()
	if(!can_use_action())
		return FALSE
	check_hive_status(usr)

/datum/action/observer_action/join_larva_queue
	name = "Join Larva Queue"
	action_icon_state = "larva_queue"

/datum/action/observer_action/join_larva_queue/action_activate()
	var/datum/hive_status/normal/HS = GLOB.hive_datums[XENO_HIVE_NORMAL]
	if(HS.add_to_larva_candidate_queue(owner))
		add_selected_frame()
		return
	remove_selected_frame()
