/datum/loadout_item/eyes
	item_slot = ITEM_SLOT_EYES

/datum/loadout_item/eyes/empty
	name = "no eyewear"
	desc = ""
	ui_icon = "empty"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_CORPSMAN,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		STAFF_OFFICER,
		CAPTAIN,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_CORPSMAN,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
		SOM_STAFF_OFFICER,
		SOM_COMMANDER,
	)


/datum/loadout_item/eyes/ballistic_goggles
	name = "Ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	item_typepath = /obj/item/clothing/glasses/mgoggles
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/eyes/health_hud
	name = "HealthMate HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status. The projector can be attached to compatable eyewear."
	item_typepath = /obj/item/clothing/glasses/hud/health
	jobs_supported = list(SQUAD_CORPSMAN, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN, SOM_SQUAD_CORPSMAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER, SOM_STAFF_OFFICER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/eyes/mesons
	name = "Meson scanner"
	desc = "Used to shield the user's eyes from harmful electromagnetic emissions, also used as general safety goggles. \
	Not adequate as welding protection. Allows the user to see structural information about their surroundings."
	item_typepath = /obj/item/clothing/glasses/meson
	jobs_supported = list(SQUAD_ENGINEER, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/eyes/welding
	name = "Welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	item_typepath = /obj/item/clothing/glasses/welding
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER, SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN)

/datum/loadout_item/eyes/smartgun_imagers
	name = "KTLD sight"
	desc = "A headset and goggles system made to pair with any KTLD weapon, such as the SG type weapons. Has a low-res short range imager, allowing for view of terrain."
	item_typepath = /obj/item/clothing/glasses/night/m56_goggles
	jobs_supported = list(SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
