/datum/loadout_item/helmet
	item_slot = ITEM_SLOT_HEAD
	ui_icon = "helmet"

/datum/loadout_item/helmet/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)

/datum/loadout_item/helmet/empty
	name = "no helmet"
	desc = ""
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


/datum/loadout_item/helmet/standard
	name = "M10X helmet"
	desc = "A standard TGMC combat helmet. Apply to head for best results."
	item_typepath = /obj/item/clothing/head/modular/m10x
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/leader
	name = "M11X helmet"
	desc = "An upgraded helmet for protecting upgraded brains."
	item_typepath = /obj/item/clothing/head/modular/m10x/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/surt
	name = "M10X-Surt helmet"
	desc = "A standard combat helmet with a Surt fireproof module."
	req_desc = "Requires a suit with a Surt module."
	item_typepath = /obj/item/clothing/head/modular/m10x/surt
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/heavy/surt = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/helmet/tyr
	name = "M10X-Tyr helmet"
	desc = "A standard combat helmet with a Tyr extra armor module."
	req_desc = "Requires a suit with a Tyr module."
	ui_icon = "tyr"
	item_typepath = /obj/item/clothing/head/modular/m10x/tyr
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two = ITEM_SLOT_OCLOTHING)


/datum/loadout_item/helmet/tyr/smartgunner
	jobs_supported = list(SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/white_dress
	name = "Dress White Cap"
	desc = "The dress white cap for your dress uniform. Pride is your shield, because this isn't."
	item_typepath = /obj/item/clothing/head/white_dress
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

/datum/loadout_item/helmet/mimir
	name = "M10X-Mimir helmet"
	desc = "A standard combat helmet with a Mimir environmental protection module."
	req_desc = "Requires a suit with a Mimir module."
	item_typepath = /obj/item/clothing/head/modular/m10x/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/mimir/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/neuraline, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/neuraline, SLOT_IN_HEAD)

/datum/loadout_item/helmet/engineer
	name = "M10X-W helmet"
	desc = "A standard combat helmet with a welding module."
	item_typepath = /obj/item/clothing/head/modular/m10x/welding
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)

/datum/loadout_item/helmet/field_commander_beret
	name = "FC beret"
	desc = "A beret with the field commander insignia emblazoned on it. It commands loyalty and bravery in all who gaze upon it."
	item_typepath = /obj/item/clothing/head/tgmcberet/fc
	jobs_supported = list(FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/staff_officer_cap
	name = "Officer cap"
	desc = "A hat usually worn by officers in the TGMC. While it has limited combat functionality, some prefer to wear it instead of the standard issue helmet."
	item_typepath = /obj/item/clothing/head/tgmccap/ro
	jobs_supported = list(STAFF_OFFICER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/captain_beret
	name = "Captains Beret"
	desc = "A beret worn by ship's captains. You thought it would have been more fancy."
	item_typepath = /obj/item/clothing/head/tgmcberet/tan
	jobs_supported = list(CAPTAIN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
