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
	///Does this apply instantly?
	var/instant_use = FALSE

/datum/campaign_asset/asset_disabler/immediate_effect()
	if(instant_use)
		trigger_disabler()
	else
		RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, PROC_REF(trigger_disabler))

	RegisterSignal(faction, COMSIG_CAMPAIGN_NEW_ASSET, PROC_REF(disable_asset))

/datum/campaign_asset/asset_disabler/deactivate()
	if(!uses)
		UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_LOADED)
		UnregisterSignal(faction, COMSIG_CAMPAIGN_NEW_ASSET)
		asset_flags &= ~ASSET_DEBUFF
	for(var/datum/campaign_asset/asset_type AS in types_currently_disabled)
		asset_type.asset_flags &= ~ASSET_DISABLED
	types_currently_disabled.Cut()
	UnregisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED)

///Handles the actual disabling activation
/datum/campaign_asset/asset_disabler/proc/trigger_disabler(datum/source)
	SIGNAL_HANDLER
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(current_mission.mission_flags & blacklist_mission_flags)
		return

	for(var/i in faction.faction_assets)
		disable_asset(asset = faction.faction_assets[i])

	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, TYPE_PROC_REF(/datum/campaign_asset, deactivate))
	uses --
	SEND_SIGNAL(src, COMSIG_CAMPAIGN_DISABLER_ACTIVATION)


///Actually disables an asset
/datum/campaign_asset/asset_disabler/proc/disable_asset(datum/source, datum/campaign_asset/asset)
	SIGNAL_HANDLER
	if(!istype(asset))
		return
	if(!(asset.type in types_disabled))
		return
	asset.asset_flags |= ASSET_DISABLED
	types_currently_disabled += asset

/datum/campaign_asset/asset_disabler/tgmc_cas
	name = "CAS disabled"
	desc = "CAS fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to close air support"
	ui_icon = "cas_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support)
	blacklist_mission_flags = MISSION_DISALLOW_CAS

/datum/campaign_asset/asset_disabler/tgmc_cas/instant
	uses = 1
	instant_use = TRUE
	detailed_desc = "Hostile assets in the AO are preventing the use of close air support during this mission."

/datum/campaign_asset/asset_disabler/som_cas
	name = "CAS disabled"
	desc = "CAS fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to close air support"
	ui_icon = "cas_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support/som_cas)
	blacklist_mission_flags = MISSION_DISALLOW_CAS

/datum/campaign_asset/asset_disabler/som_cas/instant
	uses = 1
	instant_use = TRUE
	detailed_desc = "Hostile assets in the AO are preventing the use of close air support during this mission."

/datum/campaign_asset/asset_disabler/tgmc_mortar
	name = "Mortar support disabled"
	desc = "Mortar fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to mortar fire support"
	ui_icon = "mortar_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support/mortar)
	blacklist_mission_flags = MISSION_DISALLOW_MORTAR

/datum/campaign_asset/asset_disabler/tgmc_mortar/long
	uses = 3

/datum/campaign_asset/asset_disabler/tgmc_mortar/instant
	uses = 1
	instant_use = TRUE
	detailed_desc = "Hostile assets in the AO are preventing the use of mortar support during this mission."

/datum/campaign_asset/asset_disabler/som_mortar
	name = "Mortar support disabled"
	desc = "Mortar fire support temporarily disabled"
	detailed_desc = "Hostile actions have resulted in the temporary loss of our access to mortar fire support"
	ui_icon = "mortar_disabled"
	types_disabled = list(/datum/campaign_asset/fire_support/som_mortar)
	blacklist_mission_flags = MISSION_DISALLOW_MORTAR

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
