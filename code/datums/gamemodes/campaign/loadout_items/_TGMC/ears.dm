//ears
/datum/loadout_item/ears
	item_slot = ITEM_SLOT_EARS

/datum/loadout_item/ears/empty
	name = "no headset"
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


/datum/loadout_item/ears/marine_standard
	name = "Standard headset"
	desc = "A headset, allowing for communication with your team and access to the tactical minimap. You're in for a bad time if you don't use this."
	item_typepath = /obj/item/radio/headset/mainship/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/ears/marine_command
	name = "Command headset"
	desc = "A command headset, allowing for communication with all squads and access to the tactical minimap. You're in for a bad time if you don't use this."
	item_typepath = /obj/item/radio/headset/mainship/mcom
	jobs_supported = list(FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
