//turns it on
/datum/campaign_asset/teleporter_enabled
	name = "Enable Teleporter Array"
	desc = "Enables the use of the Teleporter Array for the current or next mission"
	detailed_desc = "Established a link between our Teleporter Array and its master Bluespace drive, allowing its operation during the current or next mission."
	ui_icon = "tele_active"
	uses = 2
	cost = 5
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_ACTIVE_MISSION_ONLY|ASSET_DISABLE_ON_MISSION_END|ASSET_DISALLOW_REPEAT_USE
	already_active_message = "The Teleporter Array is already activated!"
	blacklist_mission_flags = MISSION_DISALLOW_TELEPORT
	blacklist_message = "External factors prevent the use of the teleporter at this time. Teleporter unavailable."
	///The teleporter associated with this asset
	var/obj/structure/teleporter_array/linked_teleporter

/datum/campaign_asset/teleporter_enabled/activation_checks()
	. = ..()
	if(.)
		return
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	var/datum/campaign_mission/current_mission = mode.current_mission
	if(!current_mission.mission_z_level)
		to_chat(faction.faction_leader, span_warning("New battlefield co-ordinates loading. Please try again in a moment."))
		return TRUE
	if(linked_teleporter)
		return FALSE
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		if(teleporter.teleporter_status == TELEPORTER_ARRAY_INOPERABLE)
			to_chat(faction.faction_leader, span_warning("The Teleporter Array has been permanently disabled due to the destruction of the linked Bluespace drive."))
			return TRUE
		linked_teleporter = teleporter
		return FALSE
	return TRUE

/datum/campaign_asset/teleporter_enabled/activated_effect()
	linked_teleporter.teleporter_status = TELEPORTER_ARRAY_READY
	to_chat(faction.faction_leader, span_warning("Teleporter Array powered up. Link to Bluespace drive confirmed. Ready for teleportation."))

//adds more charges
/datum/campaign_asset/teleporter_charges
	name = "Teleporter Array charges"
	desc = "+2 uses of the Teleporter Array"
	detailed_desc = "Central command have allocated the battalion with two additional uses of the Teleporter Array. Its extremely costly to run and demand is high across the conflict zone, so make them count."
	ui_icon = "tele_uses"
	uses = 3
	cost = 6

/datum/campaign_asset/teleporter_charges/activated_effect()
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		teleporter.charges ++
		to_chat(faction.faction_leader, span_warning("An additional activation of the Teleporter Array is now ready for use."))
		return

//Turns it off for good
/datum/campaign_asset/teleporter_disabled
	name = "Teleporter Array disabled"
	desc = "Teleporter Array has been permenantly disabled"
	detailed_desc = "The Bluespace drive powering all Teleporter Arrays in the conflict zone has been destroyed, rending all Teleporter Arrays inoperable. You'll have to deploy the old fashion way from here on out."
	asset_flags = ASSET_IMMEDIATE_EFFECT|ASSET_DEBUFF
	ui_icon = "tele_broken"

/datum/campaign_asset/teleporter_disabled/immediate_effect()
	for(var/obj/structure/teleporter_array/teleporter AS in GLOB.teleporter_arrays)
		if(teleporter.faction != faction.faction)
			continue
		teleporter.teleporter_status = TELEPORTER_ARRAY_INOPERABLE
		to_chat(faction.faction_leader, span_warning("Error: The Teleporter Array has been rendered permanently inoperable."))
		return
