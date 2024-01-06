/datum/loadout_item/mask
	item_slot = ITEM_SLOT_MASK

/datum/loadout_item/mask/empty
	name = "no mask"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/mask/standard
	name = "Standard gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	item_typepath = /obj/item/clothing/mask/gas
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/mask/tactical
	name = "Tactical gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air. This one is supposedly more tactical than the standard model."
	item_typepath = /obj/item/clothing/mask/gas/tactical
	jobs_supported = list(SQUAD_MARINE)
