/datum/loadout_item/ears/som_standard
	name = "Standard headset"
	desc = "A headset, allowing for communication with your team and access to the tactical minimap. You're in for a bad time if you don't use this."
	item_typepath = /obj/item/radio/headset/mainship/som
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_SLUT, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION

/datum/loadout_item/ears/som_command
	name = "Command headset"
	desc = "A command headset, allowing for communication with all squads and access to the tactical minimap. You're in for a bad time if you don't use this."
	item_typepath = /obj/item/radio/headset/mainship/som/command
	jobs_supported = list(SOM_FIELD_COMMANDER, SOM_STAFF_OFFICER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION
