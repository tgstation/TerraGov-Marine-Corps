/obj/item/campaign_beacon
	name = "default campaign beacon"
	desc = "what smelly admin spawned this?"
	icon = 'icons/obj/items/beacon.dmi'
	icon_state = "motion_4"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = IS_DEPLOYABLE
	///Type path for what this deploys into
	var/deployable_type
	///Time to deploy
	var/deploy_time = 2 SECONDS
	///Time to undeploy
	var/undeploy_time = 2 SECONDS

/obj/item/campaign_beacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_type, deploy_time, undeploy_time, CALLBACK(src, PROC_REF(can_deploy)))

///Any Additional checks for deploying validity
/obj/item/campaign_beacon/proc/can_deploy(mob/user, turf/location)
	return TRUE

/obj/item/campaign_beacon/bunker_buster
	name = "orbital beacon"
	desc = "A bulky device that is used to provide precision guidance to powerful orbital weapon systems."
	icon_state = "motion_4"
	deployable_type = /obj/structure/campaign_objective/destruction_objective/bunker_buster
	deploy_time = 2 SECONDS
	undeploy_time = 2 SECONDS
	///Can only be deployed in map areas listed here
	var/list/valid_deploy_areas

/obj/item/campaign_beacon/bunker_buster/Initialize(mapload)
	. = ..()
	GLOB.campaign_objectives += src
	var/datum/campaign_mission/raiding_base/current_mission = get_current_mission()
	if(!istype(current_mission))
		return
	valid_deploy_areas = current_mission.get_valid_beacon_areas()

/obj/item/campaign_beacon/bunker_buster/Destroy()
	GLOB.campaign_objectives -= src
	return ..()

/obj/item/campaign_beacon/bunker_buster/examine(mob/user)
	. = ..()
	if(!length(valid_deploy_areas))
		return
	var/location_info
	location_info += "Can be deployed in the following areas: \n"
	for(var/area/valid_area AS in valid_deploy_areas)
		location_info += "[valid_area::name]\n"
	. += location_info

///Checks if we can deploy the beacon here
/obj/item/campaign_beacon/bunker_buster/can_deploy(mob/user, turf/location)
	var/area/beacon_area = get_area(location)
	if(beacon_area.type in valid_deploy_areas)
		return TRUE
	if(user)
		user.balloon_alert(user, "can't deploy here!")
	return FALSE

/obj/item/campaign_beacon/bunker_buster/bluespace
	name = "bluespace beacon"
	desc = "A bulky device that is used to provide precision guidance for powerful bluespace weapon systems."
	icon_state = "bluespace"
	deployable_type = /obj/structure/campaign_objective/destruction_objective/bunker_buster/bluespace

///Delay between beacon timer finishing and the actual explosion
#define CAMPAIGN_OB_BEACON_IMPACT_DELAY 10 SECONDS

/obj/structure/campaign_objective/destruction_objective/bunker_buster
	name = "deployed orbital beacon"
	desc = "An ominous red beacon, used to provide precision guidance to powerful orbital weapon systems."
	icon = 'icons/obj/items/beacon.dmi'
	icon_state = "motion_1"
	faction = FACTION_TERRAGOV
	density = FALSE
	///How long the beacon takes to trigger its effect
	var/beacon_duration = 3 MINUTES
	///Holds the actual timer for the beacon
	var/beacon_timer

/obj/structure/campaign_objective/destruction_objective/bunker_buster/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OB_BEACON_TRIGGERED, PROC_REF(cancel_beacon))
	SEND_SIGNAL(SSdcs, COMSIG_GLOB_CAMPAIGN_OB_BEACON_ACTIVATION, src)

	beacon_timer = addtimer(CALLBACK(src, PROC_REF(beacon_effect)), beacon_duration, TIMER_STOPPABLE)
	countdown = new(src)
	countdown.pixel_x = 7
	countdown.pixel_y = 24
	countdown.start()

/obj/structure/campaign_objective/destruction_objective/bunker_buster/Destroy()
	QDEL_NULL(countdown)
	if(beacon_timer)
		deltimer(beacon_timer)
		beacon_timer = null
	return ..()

/obj/structure/campaign_objective/destruction_objective/bunker_buster/get_time_left()
	return beacon_timer ? round(timeleft(beacon_timer) MILLISECONDS) : null

///Clears the beacon if another beacon successfully activates
/obj/structure/campaign_objective/destruction_objective/bunker_buster/proc/cancel_beacon(datum/source)
	SIGNAL_HANDLER
	qdel(src)

///Effects triggered when the timer runs out
/obj/structure/campaign_objective/destruction_objective/bunker_buster/proc/beacon_effect()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OB_BEACON_TRIGGERED)
	SEND_SIGNAL(SSdcs, COMSIG_GLOB_CAMPAIGN_OB_BEACON_TRIGGERED, src, CAMPAIGN_OB_BEACON_IMPACT_DELAY)
	play_trigger_sound()

///Alerts player on the z-level that the beacon has triggered successfully
/obj/structure/campaign_objective/destruction_objective/bunker_buster/proc/play_trigger_sound()
	for(var/mob/mob AS in GLOB.player_list)
		var/turf/mob_turf = get_turf(mob)
		if(mob_turf.z != z)
			continue
		var/play_sound = 'sound/effects/OB_warning_announce_novoiceover.ogg'
		if(isobserver(mob) || mob.faction == faction)
			play_sound = 'sound/effects/OB_warning_announce.ogg'
		mob.playsound_local(loc, play_sound, 125, falloff = 10, distance_multiplier = 0.2)

/obj/structure/campaign_objective/destruction_objective/bunker_buster/bluespace
	name = "deployed bluespace beacon"
	desc = "An ominous blue beacon, used to provide precision guidance for powerful bluespace weapon systems."
	icon_state = "bluespace_deployed"
	faction = FACTION_SOM

/obj/structure/campaign_objective/destruction_objective/bunker_buster/bluespace/beacon_effect()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(do_visual_effect)), CAMPAIGN_OB_BEACON_IMPACT_DELAY - 1.5 SECONDS)

/obj/structure/campaign_objective/destruction_objective/bunker_buster/bluespace/play_trigger_sound()
	for(var/mob/mob AS in GLOB.player_list)
		var/turf/mob_turf = get_turf(mob)
		if(mob_turf.z != z)
			continue
		mob.playsound_local(loc, 'sound/magic/lightning_chargeup.ogg', 125, falloff = 10, distance_multiplier = 0.2)

///Visual effect right before the blast
/obj/structure/campaign_objective/destruction_objective/bunker_buster/bluespace/proc/do_visual_effect()
	new /obj/effect/temp_visual/teleporter_array(get_turf(src))

#undef CAMPAIGN_OB_BEACON_IMPACT_DELAY
