/datum/loadout_item/feet
	item_slot = ITEM_SLOT_FEET
	ui_icon = "boots"

/datum/loadout_item/feet/empty
	name = "no footwear"
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


/datum/loadout_item/feet/marine_boots
	name = "Combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	item_typepath = /obj/item/clothing/shoes/marine/tdf/full
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/feet/marine_brown_boots
	name = "Brown boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	item_typepath = /obj/item/clothing/shoes/marine/brown/full
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

/datum/loadout_item/feet/white_dress
	name = "Dress shoes"
	desc = "Fancy white shoes to go with your white dress uniform. Do not come with a combat knife."
	item_typepath = /obj/item/clothing/shoes/white
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

//Captain
/datum/loadout_item/feet/captain
	name = "Captain's shoes"
	desc = "Has special soles for better trampling those underneath."
	item_typepath = /obj/item/clothing/shoes/marinechief/captain
	jobs_supported = list(CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
