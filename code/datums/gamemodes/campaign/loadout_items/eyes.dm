/datum/loadout_item/eyes
	item_slot = ITEM_SLOT_EYES

/datum/loadout_item/eyes/empty
	name = "no eyewear"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/eyes/ballistic_goggles
	name = "Ballistic goggles"
	desc = "Standard issue TGMC goggles. Mostly used to decorate one's helmet."
	item_typepath = /obj/item/clothing/glasses/mgoggles
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/eyes/health_hud
	name = "HealthMate HUD"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/glasses/hud/health
	jobs_supported = list(SQUAD_CORPSMAN, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/eyes/mesons
	name = "Optical meson scanner"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/glasses/meson
	jobs_supported = list(SQUAD_ENGINEER)
	purchase_cost = 12 //test only

/datum/loadout_item/eyes/welding
	name = "Welding goggles"
	desc = "Protects the eyes from welders, approved by the mad scientist association."
	item_typepath = /obj/item/clothing/glasses/welding
	jobs_supported = list(SQUAD_MARINE, SQUAD_ENGINEER)
