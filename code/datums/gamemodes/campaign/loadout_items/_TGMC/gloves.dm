/datum/loadout_item/gloves
	item_slot = ITEM_SLOT_GLOVES

/datum/loadout_item/gloves/empty
	name = "no gloves"
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


/datum/loadout_item/gloves/marine_gloves
	name = "Combat gloves"
	desc = "Standard issue marine tactical gloves. It reads: 'knit by Marine Widows Association'."
	item_typepath = /obj/item/clothing/gloves/marine/tdf
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/gloves/marine_fingerless
	name = "Fingerless gloves"
	desc = "Standard issue marine tactical gloves but fingerless! It reads: 'knit by Marine Widows Association'."
	item_typepath = /obj/item/clothing/gloves/marine/fingerless
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/gloves/white_dress
	name = "Dress gloves"
	desc = "Fancy white gloves to go with your white dress uniform."
	item_typepath = /obj/item/clothing/gloves/white
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

//corpsman
/datum/loadout_item/gloves/defib_gloves
	name = "Defib gloves"
	desc = "Advanced medical gloves, these include small electrodes to defibrilate a patient No more bulky units!"
	purchase_cost = 50
	item_typepath = /obj/item/clothing/gloves/defibrillator
	jobs_supported = list(SQUAD_CORPSMAN)

//engineer
/datum/loadout_item/gloves/insulated
	name = "Insulated gloves"
	desc = "Insulated marine tactical gloves that protect against electrical shocks."
	item_typepath = /obj/item/clothing/gloves/marine/insulated
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

//FC
/datum/loadout_item/gloves/officer_gloves
	name = "Officer gloves"
	desc = "Shiny and impressive. They look expensive."
	item_typepath = /obj/item/clothing/gloves/marine/officer
	jobs_supported = list(FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

//captain
/datum/loadout_item/gloves/captain_gloves
	name = "Captain's gloves"
	desc = "You may like these gloves, but THEY think you are unworthy of them."
	item_typepath = /obj/item/clothing/gloves/marine/techofficer/captain
	jobs_supported = list(CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
