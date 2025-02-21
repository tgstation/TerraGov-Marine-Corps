/datum/fire_support/droppod
	name = "Sentry drop pod"
	fire_support_type = FIRESUPPORT_TYPE_SENTRY_POD
	scatter_range = 1
	uses = -1
	icon_state = "sentry_pod"
	initiate_chat_message = "TARGET ACQUIRED SENTRY POD LAUNCHING."
	initiate_screen_message = "Co-ordinates confirmed, sentry pod launching."
	initiate_sound = null
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/pod_officer
	start_visual = null
	start_sound = null
	cooldown_duration = 1 SECONDS
	delay_to_impact = 0.5 SECONDS
	///The special pod type for this fire support mode
	var/pod_type = /obj/structure/droppod/nonmob/turret_pod

/datum/fire_support/droppod/New()
	. = ..()
	disable_pods()

/datum/fire_support/droppod/select_target(turf/target_turf)
	for(var/obj/structure/droppod/nonmob/droppod AS in GLOB.droppod_list)
		if(droppod.type != pod_type)
			continue
		if(!droppod.stored_object)
			continue
		if(!droppod.set_target(target_turf.x, target_turf.y))
			return
		droppod.start_launch_pod()
		return

///Enabled the datum for use
/datum/fire_support/droppod/proc/enable_pods(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(disable_pods))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS)
	enable_firesupport(-1) //pods can be used separately, restocked, emptied, etc. select_target will check if there's actually a pod available.

///Disabled the datum from use
/datum/fire_support/droppod/proc/disable_pods(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS, PROC_REF(enable_pods))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)
	disable(TRUE)

/datum/fire_support/droppod/supply
	name = "Supply drop pod"
	fire_support_type = FIRESUPPORT_TYPE_SUPPLY_POD
	icon_state = "supply_pod"
	initiate_chat_message = "TARGET ACQUIRED SUPPLY POD LAUNCHING."
	initiate_screen_message = "Co-ordinates confirmed, supply pod launching."
	pod_type = /obj/structure/droppod/nonmob/supply_pod
