/datum/campaign_asset/droppod_enabled
	name = "Enable drop pods"
	desc = "Enables the use of drop pods for the current or next mission"
	detailed_desc = "Repositions the ship to allow for orbital drop pod insertion during the current or next mission."
	ui_icon = "droppod_active"
	uses = 3
	cost = 9
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_ACTIVE_MISSION_ONLY|ASSET_DISABLE_ON_MISSION_END|ASSET_DISALLOW_REPEAT_USE
	already_active_message = "Ship already repositioned to allow for drop pod usage."
	blacklist_mission_flags = MISSION_DISALLOW_DROPPODS
	blacklist_message = "External factors prevent the ship from repositioning at this time. Drop pods unavailable."

/datum/campaign_asset/droppod_enabled/activation_checks()
	. = ..()
	if(.)
		return
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(!current_mission.mission_z_level)
		to_chat(faction.faction_leader, span_warning("New battlefield co-ordinates loading. Please try again in a moment."))
		return TRUE

/datum/campaign_asset/droppod_enabled/activated_effect()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_ENABLE_DROPPODS)
	to_chat(faction.faction_leader, span_warning("Ship repositioned, drop pods are now ready for use."))

/datum/campaign_asset/droppod_refresh
	name = "Rearm drop pod bays"
	desc = "replace all used drop pods"
	detailed_desc = "Replace all drop pods that have been previously deployed with refurbished units or ones from fleet storage, ready for immediate use."
	ui_icon = "droppod_refresh"
	uses = 1
	cost = 10

/datum/campaign_asset/droppod_refresh/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	var/z_level = mode?.current_mission?.mission_z_level.z_value
	var/active = FALSE
	if(current_mission.mission_state == MISSION_STATE_ACTIVE)
		for(var/datum/campaign_asset/droppod_enabled/droppod_enabled in faction.faction_assets)
			if(droppod_enabled.asset_flags & ASSET_ACTIVE)
				active = TRUE
			break

	for(var/obj/structure/drop_pod_launcher/launcher AS in GLOB.droppod_bays)
		launcher.refresh_pod(z_level, active)
	to_chat(faction.faction_leader, span_warning("All drop pods have been restocked."))

/datum/campaign_asset/droppod_disable
	name = "Disable drop pods"
	desc = "Prevents the enemy from using drop pods in the current or next mission"
	detailed_desc = "Ground to Space weapon systems are activated to prevent TGMC close orbit support ships from positioning themselves for drop pod orbital assaults during the current or next mission."
	ui_icon = "droppod_broken"
	uses = 2
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_ACTIVE_MISSION_ONLY
	blacklist_mission_flags = MISSION_DISALLOW_DROPPODS
	blacklist_message = "Enemy drop pods already unable to deploy during this mission."

/datum/campaign_asset/droppod_disable/activated_effect()
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	current_mission.mission_flags |= MISSION_DISALLOW_DROPPODS
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_DISABLE_DROPPODS)
	to_chat(faction.faction_leader, span_warning("Orbital deterrence systems activated. Enemy drop pods disabled for this mission."))
