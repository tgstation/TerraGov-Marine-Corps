
/datum/action/observer_action/crew_manifest
	name = "Show Crew manifest"

/datum/action/observer_action/crew_manifest/action_activate()
	. = ..()
	var/mob/dead/observer/O = owner
	if(!istype(O))
		return // Shouldn't have this action
	O.view_manifest()


/datum/action/observer_action/show_hivestatus
	name = "Show Hive status"

/datum/action/observer_action/show_hivestatus/action_activate()
	. = ..()
	check_hive_status()
