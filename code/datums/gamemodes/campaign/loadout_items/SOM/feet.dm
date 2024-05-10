/datum/loadout_item/feet/som_boots
	name = "Combat shoes"
	desc = "Shoes with origins dating back to the old mining colonies. These were made for more than just walking."
	item_typepath = /obj/item/clothing/shoes/marine/som/knife
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/feet/som_officer
	name = "officer's boots"
	desc = "A shiny pair of boots, normally seen on the feet of SOM officers."
	item_typepath = /obj/item/clothing/shoes/marinechief/som
	jobs_supported = list(SOM_STAFF_OFFICER, SOM_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
