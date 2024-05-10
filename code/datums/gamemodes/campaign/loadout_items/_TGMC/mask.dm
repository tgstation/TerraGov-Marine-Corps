/datum/loadout_item/mask
	item_slot = ITEM_SLOT_MASK

/datum/loadout_item/mask/empty
	name = "no mask"
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

/datum/loadout_item/mask/standard
	name = "Std gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air."
	item_typepath = /obj/item/clothing/mask/gas
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/mask/tactical
	name = "Tac gas mask"
	desc = "A face-covering mask that can be connected to an air supply. Filters harmful gases from the air. This one is supposedly more tactical than the standard model."
	item_typepath = /obj/item/clothing/mask/gas/tactical
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)

/datum/loadout_item/mask/skimask
	name = "Ski mask"
	desc = "A stylish skimask, can be recolored. Makes you feel like an operator just looking at it."
	item_typepath = /obj/item/clothing/mask/gas/modular/skimask
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/mask/coof
	name = "Combat face mask"
	desc = "The CFCC is a prime and readied, yet stylish facemask ready to... cover your face."
	item_typepath = /obj/item/clothing/mask/gas/modular/coofmask
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
