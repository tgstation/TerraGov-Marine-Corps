/datum/loadout_item/helmet/som_standard
	name = "Infantry helmet"
	desc = "The standard combat helmet worn by SOM combat troops. Made using advanced polymers to provide very effective protection without compromising visibility."
	item_typepath = /obj/item/clothing/head/modular/som
	jobs_supported = list(SOM_SQUAD_MARINE)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/som_standard/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)

/datum/loadout_item/helmet/som_standard/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

/datum/loadout_item/helmet/som_veteran
	name = "Veteran helmet"
	desc = "The standard combat helmet worn by SOM combat specialists. State of the art materials provides more protection for more valuable brains."
	item_typepath = /obj/item/clothing/head/modular/som/veteran
	jobs_supported = list(SOM_SQUAD_VETERAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/gorgon
	name = "Gorgon helmet"
	desc = "Made for use with Gorgon pattern assault armor, providing superior protection. Typically seen on SOM leaders or their most elite combat units."
	item_typepath = /obj/item/clothing/head/modular/som/leader
	jobs_supported = list(SOM_SQUAD_LEADER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/gorgon/fc
	name = "Gorgon helmet"
	desc = "Made for use with Gorgon pattern assault armor, providing superior protection. This one has gold markings indicating it belongs to a high ranking field officer."
	item_typepath = /obj/item/clothing/head/modular/som/leader/officer
	jobs_supported = list(SOM_FIELD_COMMANDER)

/datum/loadout_item/helmet/som_surt
	name = "'Hades' incendiary insulation system helmet"
	desc = "A standard combat helmet with a Hades fireproof module."
	req_desc = "Requires a suit with a Hades module."
	item_typepath = /obj/item/clothing/head/modular/som/hades
	jobs_supported = list(SOM_SQUAD_MARINE)
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/pyro = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/helmet/som_tyr
	name = "'Lorica' armor reinforcement system helmet"
	desc = "A bulky helmet paired with the 'Lorica' armor module, designed for outstanding protection at the cost of significant weight and reduced flexibility. \
	Substantial additional armor improves protection against all damage."
	req_desc = "Requires a suit with a Lorica module."
	ui_icon = "lorica"
	item_typepath = /obj/item/clothing/head/modular/som/lorica
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN)
	item_whitelist = list(
		/obj/item/clothing/suit/modular/som/heavy/lorica = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/som/heavy/lorica/medic = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/som/heavy/lorica/engineer = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/helmet/som_tyr/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)
	loadout_item_flags = NONE

/datum/loadout_item/helmet/som_tyr/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/russian_red, SLOT_IN_HEAD)

/datum/loadout_item/helmet/som_tyr/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = NONE

/datum/loadout_item/helmet/som_tyr/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)

/datum/loadout_item/helmet/som_tyr/universal
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_CORPSMAN, SOM_SQUAD_ENGINEER, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = NONE

/datum/loadout_item/helmet/som_mimir
	name = "'Mithridatius' hostile environment protection helmet"
	desc = "A standard combat helmet with an integrated Mithridatius 'Mith' hostile environment protection module."
	req_desc = "Requires a suit with a Mithridatius environmental protection module."
	item_typepath = /obj/item/clothing/head/modular/som/bio
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(/obj/item/clothing/suit/modular/som/heavy/mithridatius = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/helmet/som_engineer
	name = "Engineer helmet"
	desc = "A specialised helmet designed for use by combat engineers. Its main feature being an integrated welding mask."
	item_typepath = /obj/item/clothing/head/modular/som/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/som_engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_HEAD)
