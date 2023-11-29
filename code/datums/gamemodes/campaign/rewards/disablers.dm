//These are TEMPORARY malus effects, attached to the victim faction. The asset activates at the start of every mission unless the asset is disables is already unavailable.
/datum/campaign_asset/asset_disabler
	name = "REWARD_DISABLER"
	desc = "base type of disabler, you shouldn't see this."
	detailed_desc = "Why can you see this? Report on github."
	uses = 2
	asset_flags = ASSET_IMMEDIATE_EFFECT|ASSET_DEBUFF
	///The types of asset disabled
	var/list/types_disabled
	///Rewards currently disabled. Recorded to reenable later
	var/list/types_currently_disabled = list()

/datum/campaign_asset/asset_disabler/immediate_effect()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, PROC_REF(trigger_disabler))

/datum/campaign_asset/asset_disabler/deactivate()
	for(var/datum/campaign_asset/asset_type AS in types_currently_disabled)
		asset_type.asset_flags &= ~ASSET_DISABLED
	types_currently_disabled.Cut()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)

///Handles the actual disabling activation
/datum/campaign_asset/asset_disabler/proc/trigger_disabler()
	SIGNAL_HANDLER
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_flags & blacklist_mission_flags)
		return

	for(var/i in faction.faction_assets)
		var/datum/campaign_asset/asset_type = faction.faction_assets[i]
		if(!asset_type)
			continue
		if(asset_type.type in types_disabled)
			asset_type.asset_flags |= ASSET_DISABLED
			types_currently_disabled += asset_type

	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_asset, deactivate))
	uses --
	if(!uses)
		UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED)
		asset_flags &= ~ASSET_DEBUFF
	SEND_SIGNAL(src, COMSIG_CAMPAIGN_DISABLER_ACTIVATION)

/datum/campaign_asset/asset_disabler/tgmc_cas
	name = "CAS disabled"
	desc = "CAS fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to close air support"
	ui_icon = "cas_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support)
	blacklist_mission_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_asset/asset_disabler/som_cas
	name = "CAS disabled"
	desc = "CAS fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to close air support"
	ui_icon = "cas_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support/som_cas)
	blacklist_mission_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_asset/asset_disabler/tgmc_mortar
	name = "Mortar support disabled"
	desc = "Mortar fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to mortar fire support"
	ui_icon = "mortar_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support/mortar)
	blacklist_mission_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_asset/asset_disabler/tgmc_mortar/long
	uses = 3

/datum/campaign_asset/asset_disabler/som_mortar
	name = "Mortar support disabled"
	desc = "Mortar fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to mortar fire support"
	ui_icon = "mortar_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support/som_mortar)
	blacklist_mission_flags = MISSION_DISALLOW_FIRESUPPORT

/datum/campaign_asset/asset_disabler/som_mortar/long
	uses = 3

/datum/campaign_asset/asset_disabler/drop_pods
	name = "Drop pods disabled"
	desc = "Drop pod access temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to drop pod deployment"
	ui_icon = "droppod_disabled"
	types_disabled = list(/datum/campaign_asset/droppod_enabled)
	blacklist_mission_flags = MISSION_DISALLOW_DROPPODS

/datum/campaign_asset/asset_disabler/teleporter
	name = "Teleporter disabled"
	desc = "Teleporter temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to teleporter deployment"
	ui_icon = "tele_disabled"
	types_disabled = list(/datum/campaign_asset/teleporter_enabled)
