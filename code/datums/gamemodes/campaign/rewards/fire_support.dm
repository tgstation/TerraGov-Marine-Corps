/datum/campaign_asset/fire_support
	name = "CAS mission"
	desc = "Close Air Support is deployed to support this mission"
	detailed_desc = "A limited number of Close Air Support attack runs are available via tactical binoculars for this mission. Excellent for disrupting dug in enemy positions."
	ui_icon = "cas"
	uses = 1
	cost = 15
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_ACTIVE_MISSION_ONLY|ASSET_DISABLE_ON_MISSION_END
	blacklist_mission_flags = MISSION_DISALLOW_FIRESUPPORT
	blacklist_message = "Fire support unavailable during this mission."
	var/list/fire_support_types = list(
		FIRESUPPORT_TYPE_GUN = 4,
		FIRESUPPORT_TYPE_ROCKETS = 2,
		FIRESUPPORT_TYPE_CRUISE_MISSILE = 1,
		FIRESUPPORT_TYPE_LASER = 2,
	)

/datum/campaign_asset/fire_support/activated_effect()
	for(var/firesupport_type in fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[firesupport_type]
		fire_support_option.enable_firesupport(fire_support_types[firesupport_type])

/datum/campaign_asset/fire_support/deactivate()
	. = ..()
	for(var/firesupport_type in fire_support_types)
		var/datum/fire_support/fire_support_option = GLOB.fire_support_types[firesupport_type]
		fire_support_option.disable()

/datum/campaign_asset/fire_support/som_cas
	fire_support_types = list(
		FIRESUPPORT_TYPE_VOLKITE = 3,
		FIRESUPPORT_TYPE_INCEND_ROCKETS = 2,
		FIRESUPPORT_TYPE_RAD_MISSILE = 2,
	)

/datum/campaign_asset/fire_support/mortar
	name = "Mortar support"
	desc = "Mortar teams are activated to provide firesupport for this mission"
	detailed_desc = "Activatable by squad leaders. A limited number of mortar strikes are available via tactical binoculars for this mission. Excellent for disrupting dug in enemy positions."
	ui_icon = "mortar"
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_ACTIVE_MISSION_ONLY|ASSET_DISABLE_ON_MISSION_END|ASSET_SL_AVAILABLE
	cost = 6
	fire_support_types = list(
		FIRESUPPORT_TYPE_HE_MORTAR = 6,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR = 3,
		FIRESUPPORT_TYPE_SMOKE_MORTAR = 2,
		FIRESUPPORT_TYPE_ACID_SMOKE_MORTAR = 2,
	)

/datum/campaign_asset/fire_support/som_mortar
	name = "Mortar support"
	desc = "Mortar teams are activated to provide firesupport for this mission"
	detailed_desc = "Activatable by squad leaders. A limited number of mortar strikes are available via tactical binoculars for this mission. Excellent for disrupting dug in enemy positions."
	ui_icon = "mortar"
	asset_flags = ASSET_ACTIVATED_EFFECT|ASSET_ACTIVE_MISSION_ONLY|ASSET_DISABLE_ON_MISSION_END|ASSET_SL_AVAILABLE
	cost = 6
	fire_support_types = list(
		FIRESUPPORT_TYPE_HE_MORTAR_SOM = 6,
		FIRESUPPORT_TYPE_INCENDIARY_MORTAR_SOM = 3,
		FIRESUPPORT_TYPE_SMOKE_MORTAR_SOM = 2,
		FIRESUPPORT_TYPE_SATRAPINE_SMOKE_MORTAR = 2,
	)
