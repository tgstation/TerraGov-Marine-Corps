/obj/effect/landmark/campaign_structure/tele_blocker
	name = "\improper Bluespace quantum disruption emitter"
	icon = 'icons/obj/structures/campaign/blockers.dmi'
	icon_state = "tele_blocker"
	pixel_w = -16
	spawn_object = /obj/structure/campaign_deployblocker
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid/som,
	/datum/campaign_mission/destroy_mission/fire_support_raid/som,
	/datum/campaign_mission/capture_mission/asat,
	/datum/campaign_mission/destroy_mission/airbase/som,
	)

/obj/structure/campaign_deployblocker
	name = "\improper Bluespace quantum disruption emitter"
	desc = "A cutting edge piece of technology designed to disrupt long range bluespace interference in a given radius. The SOM's long range teleporters are unlikely to work here while this is active."
	density = TRUE
	anchored = TRUE
	atom_flags = CRITICAL_ATOM
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	destroy_sound = 'sound/effects/meteorimpact.ogg'
	icon = 'icons/obj/structures/campaign/blockers.dmi'
	icon_state = "tele_blocker"
	pixel_w = -16
	faction = FACTION_TERRAGOV
	///What flag this removes from the mission
	var/to_remove_flags = MISSION_DISALLOW_TELEPORT
	var/owning_faction_notification = "A teleportation disruptor has been deployed in this area. Protect the disruptor to ensure hostile forces cannot deploy via teleportation. "
	var/hostile_faction_notification = "The enemy has a device in this area that will prevent the use of the teleporter array. Destroy this first to allow for teleportation insertion against primary objectives. "

/obj/structure/campaign_deployblocker/Initialize(mapload)
	. = ..()
	GLOB.campaign_structures += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "tele_block", MINIMAP_BLIPS_LAYER))
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	if(!istype(mode))
		return
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(!current_mission)
		return
	current_mission.starting_faction_mission_parameters += current_mission.starting_faction == faction ? owning_faction_notification : hostile_faction_notification
	current_mission.hostile_faction_mission_parameters += current_mission.starting_faction == faction ? hostile_faction_notification : owning_faction_notification

/obj/structure/campaign_deployblocker/Destroy()
	deactivate()
	return ..()

/obj/structure/campaign_deployblocker/ex_act()
	return

/obj/structure/campaign_deployblocker/plastique_act(mob/living/plastique_user)
	if(plastique_user && plastique_user.ckey)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[plastique_user.ckey]
		personal_statistics.mission_blocker_destroyed += (faction != plastique_user.faction ? 1 : -1)
	qdel(src)

///Signals its destruction, enabling the use of the teleporter asset
/obj/structure/campaign_deployblocker/proc/deactivate()
	SEND_SIGNAL(SSdcs, COMSIG_GLOB_CAMPAIGN_TELEBLOCKER_DISABLED, src, to_remove_flags, faction)
	SSminimaps.remove_marker(src)
	GLOB.campaign_structures -= src

/obj/effect/landmark/campaign_structure/drop_blocker
	name = "TELEBLOCKER"
	icon = 'icons/obj/structures/campaign/blockers.dmi'
	icon_state = "drop_blocker"
	pixel_w = -16
	mission_types = list(
		/datum/campaign_mission/destroy_mission/supply_raid,
		/datum/campaign_mission/destroy_mission/fire_support_raid,
		/datum/campaign_mission/raiding_base,
	)
	spawn_object = /obj/structure/campaign_deployblocker/drop_blocker

/obj/structure/campaign_deployblocker/drop_blocker
	name = "drop pod guidance disruptor array"
	desc = "A sophisticated device intended to severely disrupt drop pod guidance systems, rendering them unusable while the tower stands."
	icon_state = "drop_blocker"
	pixel_w = -16
	to_remove_flags = MISSION_DISALLOW_DROPPODS
	faction = FACTION_SOM
	owning_faction_notification = "A drop pod disruptor has been deployed in this area. Protect the disruptor to ensure hostile forces cannot deploy via drop pod. "
	hostile_faction_notification = "The enemy has a device in this area that will prevent the use of our drop pods. Destroy this first to allow for drop pod assault against primary objectives. "
