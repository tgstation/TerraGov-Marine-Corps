/obj/item/supply_beacon
	name = "supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "motion0"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/supply_beacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/beacon, TRUE, 60, "motion2")

/obj/item/campaign_beacon
	name = "default campaign beacon"
	desc = "what smelly admin spawned this?"
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "motion4"
	w_class = WEIGHT_CLASS_SMALL
	flags_item = IS_DEPLOYABLE
	var/deployable_type
	var/deploy_time = 2 SECONDS
	var/undeploy_time = 2 SECONDS

/obj/item/campaign_beacon/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_type, deploy_time, undeploy_time, CALLBACK(src, PROC_REF(can_deploy)))

/obj/item/campaign_beacon/proc/can_deploy(mob/user, turf/location)
	return TRUE

/obj/item/campaign_beacon/bunker_buster
	name = "orbital beacon"
	desc = "A bulky device that is used to provide precision guidance to powerful orbital weapon systems."
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "motion4"
	deployable_type = /obj/structure/campaign_objective/destruction_objective/bunker_buster
	deploy_time = 2 SECONDS
	undeploy_time = 2 SECONDS
	var/list/valid_deploy_areas = list(/area/mainship/patrol_base/hanger)

/obj/item/campaign_beacon/bunker_buster/Initialize(mapload)
	. = ..()
	GLOB.campaign_objectives += src

/obj/item/campaign_beacon/bunker_buster/Destroy()
	GLOB.campaign_objectives -= src
	return ..()

///Checks if we can deploy the beacon here
/obj/item/campaign_beacon/bunker_buster/can_deploy(mob/user, turf/location)
	var/area/beacon_area = get_area(location)
	if(beacon_area.type in valid_deploy_areas)
		return TRUE
	if(user)
		user.balloon_alert(user, "Cannot deploy here")
	return FALSE

/obj/structure/campaign_objective/destruction_objective/bunker_buster
	name = "deployed orbital beacon"
	desc = "An ominous red beacon, used to provide precision guidance to powerful orbital weapon systems."
	icon = 'icons/Marine/marine-navigation.dmi'
	icon_state = "motion1"
	faction = FACTION_TERRAGOV
	density = FALSE
	///How long the beacon takes to trigger its effect
	var/beacon_duration = 3 MINUTES
	///Holds the actual timer for the beacon
	var/beacon_timer

/obj/structure/campaign_objective/destruction_objective/bunker_buster/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_CAMPAIGN_OB_BEACON_TRIGGERED, PROC_REF(cancel_beacon))
	SEND_SIGNAL(SSdcs, COMSIG_CAMPAIGN_OB_BEACON_ACTIVATION) //tie a hud alert to this

	beacon_timer = addtimer(CALLBACK(src, PROC_REF(beacon_effect)), beacon_duration, TIMER_STOPPABLE)
	countdown = new(src)
	countdown.start()

/obj/structure/campaign_objective/destruction_objective/bunker_buster/Destroy()
	QDEL_NULL(countdown)
	if(beacon_timer)
		deltimer(beacon_timer)
		beacon_timer = null
	return ..()

/obj/structure/campaign_objective/destruction_objective/bunker_buster/proc/cancel_beacon(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/structure/campaign_objective/destruction_objective/bunker_buster/get_time_left()
	return beacon_timer ? round(timeleft(beacon_timer) MILLISECONDS) : null

///Effects triggered when the timer runs out
/obj/structure/campaign_objective/destruction_objective/bunker_buster/proc/beacon_effect()
	UnregisterSignal(SSdcs, COMSIG_CAMPAIGN_OB_BEACON_TRIGGERED)
	SEND_SIGNAL(SSdcs, COMSIG_CAMPAIGN_OB_BEACON_TRIGGERED) //tie a hud alert to this
	addtimer(CALLBACK(src, PROC_REF(do_explosion)), CAMPAIGN_OB_BEACON_IMPACT_DELAY)
	for(var/mob/mob AS in GLOB.player_list)
		if(mob.z != z)
			continue
		var/play_sound = 'sound/effects/OB_warning_announce_novoiceover.ogg'
		if(isobserver(mob) || mob.faction == faction)
			play_sound = 'sound/effects/OB_warning_announce.ogg'
		mob.playsound_local(loc, play_sound, 125, falloff = 10, distance_multiplier = 0.2)

///Makes the bang
/obj/structure/campaign_objective/destruction_objective/bunker_buster/proc/do_explosion()
	explosion(src, 25, 30)
	qdel(src) //do we do this here or just wrap up after? ideally here but gotta ensure the order is correct so we don't 'lose' for triggering it

