/obj/effect/landmark/campaign_structure/tele_blocker
	name = "\improper Bluespace quantum disruption emitter"
	icon = 'icons/obj/structures/campaign/tele_blocker.dmi'
	icon_state = "tele_blocker"
	pixel_x = -16
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid/som, /datum/campaign_mission/destroy_mission/fire_support_raid/som, /datum/campaign_mission/capture_mission/asat)
	spawn_object = /obj/structure/campaign_deployblocker

/obj/structure/campaign_deployblocker
	name = "\improper Bluespace quantum disruption emitter"
	desc = "A cutting edge piece of technology designed to disrupt long range bluespace interference in a given radius. The SOM's long range teleporters are unlikely to work here while this is active."
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	destroy_sound = 'sound/effects/meteorimpact.ogg'
	icon = 'icons/obj/structures/campaign/tele_blocker.dmi'
	icon_state = "tele_blocker"
	pixel_x = -16
	///What flag this removes from the mission
	var/flags_to_remove = MISSION_DISALLOW_TELEPORT
	///The faction this belongs to
	var/faction = FACTION_TERRAGOV

/obj/structure/campaign_deployblocker/Initialize(mapload)
	. = ..()
	GLOB.campaign_structures += src
	SSminimaps.add_marker(src, MINIMAP_FLAG_ALL, image('icons/UI_icons/map_blips.dmi', null, "tele_block"))

/obj/structure/campaign_deployblocker/Destroy()
	deactivate()
	return ..()

/obj/structure/campaign_deployblocker/ex_act()
	return

/obj/structure/campaign_deployblocker/plastique_act()
	qdel(src)

///Signals its destruction, enabling the use of the teleporter asset
/obj/structure/campaign_deployblocker/proc/deactivate()
	SEND_SIGNAL(SSdcs, COMSIG_GLOB_CAMPAIGN_TELEBLOCKER_DISABLED, src, flags_to_remove, faction)
	SSminimaps.remove_marker(src)
	GLOB.campaign_structures -= src

/obj/effect/landmark/campaign_structure/drop_blocker
	name = "TELEBLOCKER"
	icon = 'icons/obj/structures/campaign_structures.dmi'
	icon_state = "drop_block"
	mission_types = list(/datum/campaign_mission/destroy_mission/supply_raid, /datum/campaign_mission/destroy_mission/fire_support_raid)
	spawn_object = /obj/structure/campaign_deployblocker/drop_blocker

/obj/structure/campaign_deployblocker/drop_blocker
	name = "DROPBLOCKER"
	desc = "THIS PROBABLY BLOCKS DROPPODS OR SOMETHING, PAY A SPRITER FOR A NONPLACEHOLDER"
	flags_to_remove = MISSION_DISALLOW_DROPPODS
	faction = FACTION_SOM
