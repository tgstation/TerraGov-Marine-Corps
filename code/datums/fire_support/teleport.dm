/datum/fire_support/tele_cope
	name = "teleport COPE"
	fire_support_type = FIRESUPPORT_TYPE_TELE_COPE
	scatter_range = 1
	cooldown_duration = 10 SECONDS
	uses = 2
	icon_state = "tele"
	initiate_chat_message = "COORDINATES CONFIRMED. TELEPORTER ACTIVATING."
	initiate_screen_message = "Coordinates confirmed, teleporting in COPE now!"
	initiate_title = "Rhino-1"
	initiate_sound = null
	portrait_type = /atom/movable/screen/text/screen_text/picture/potrait/som_scientist
	start_visual = null
	start_sound = null
	delay_to_impact = 10 SECONDS

/datum/fire_support/tele_cope/select_target(turf/target_turf)
	playsound(target_turf, 'sound/magic/lightningbolt.ogg', 75, 0)
	new /obj/effect/temp_visual/teleporter_array(target_turf)
	new /obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/predeployed(target_turf)
	var/list/destination_mobs = cheap_get_living_near(target_turf, 5)
	for(var/mob/living/victim AS in destination_mobs)
		victim.adjust_stagger(3 SECONDS)
		victim.add_slowdown(3)
		to_chat(victim, span_warning("You feel nauseous as reality warps around you!"))

/datum/fire_support/tele_cope/New()
	. = ..()
	disable_use()

///Enabled the datum for use
/datum/fire_support/tele_cope/proc/enable_use(datum/source, obj/structure/teleporter_array/teleporter)
	SIGNAL_HANDLER
	if(teleporter.faction != FACTION_SOM)
		return
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, PROC_REF(disable_use))
	UnregisterSignal(SSdcs, COMSIG_GLOB_TELEPORTER_ARRAY_ENABLED)
	enable_firesupport(initial(uses))

///Disabled the datum from use
/datum/fire_support/tele_cope/proc/disable_use(datum/source)
	SIGNAL_HANDLER
	RegisterSignal(SSdcs, COMSIG_GLOB_TELEPORTER_ARRAY_ENABLED, PROC_REF(enable_use))
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)
	disable(TRUE)
