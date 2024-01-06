/datum/loadout_item/gloves
	item_slot = ITEM_SLOT_GLOVES

/datum/loadout_item/gloves/empty
	name = "no gloves"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/marine_gloves
	name = "Combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	item_typepath = /obj/item/clothing/gloves/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/gloves/marine_black_gloves
	name = "Black combat gloves"
	desc = "Standard issue marine tactical gloves but black! It reads: 'knit by Marine Widows Association'."
	item_typepath = /obj/item/clothing/gloves/marine/black
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/gloves/defib_gloves
	name = "Defib gloves"
	desc = "Advanced medical gloves, these include small electrodes to defibrilate a patiant. No more bulky units!"
	purchase_cost = 1
	item_typepath = /obj/item/defibrillator/gloves
	jobs_supported = list(SQUAD_CORPSMAN)
