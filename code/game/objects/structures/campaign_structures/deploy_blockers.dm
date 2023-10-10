/obj/structure/campaign_deployblocker
	name = "TELEBLOCKER"
	desc = "THIS PROBABLY BLOCKS TELEPORTERS OR SOMETHING, PAY A SPRITER FOR A NONPLACEHOLDER"
	density = TRUE
	anchored = TRUE
	allow_pass_flags = PASS_PROJECTILE|PASS_AIR
	destroy_sound = 'sound/effects/meteorimpact.ogg'
	icon = 'icons/obj/structures/campaign_structures.dmi'
	icon_state = "tele_block"
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

/obj/structure/campaign_deployblocker/dropblocker
	name = "DROPBLOCKER"
	desc = "THIS PROBABLY BLOCKS DROPPODS OR SOMETHING, PAY A SPRITER FOR A NONPLACEHOLDER"
	icon_state = "drop_block"
	flags_to_remove = MISSION_DISALLOW_DROPPODS
	faction = FACTION_SOM
