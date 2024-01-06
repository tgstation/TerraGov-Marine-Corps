/datum/loadout_item/feet
	item_slot = ITEM_SLOT_FEET

/datum/loadout_item/feet/empty
	name = "no footwear"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/feet/marine_boots
	name = "Combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	item_typepath = /obj/item/clothing/shoes/marine/full
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/feet/marine_brown_boots
	name = "Brown combat boots"
	desc = "Standard issue combat boots for combat scenarios or combat situations. All combat, all the time."
	item_typepath = /obj/item/clothing/shoes/marine/brown/full
	jobs_supported = list(SQUAD_MARINE)
