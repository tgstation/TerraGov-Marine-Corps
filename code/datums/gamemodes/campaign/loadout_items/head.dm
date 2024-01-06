/datum/loadout_item/helmet
	item_slot = ITEM_SLOT_HEAD

/datum/loadout_item/helmet/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)

/datum/loadout_item/helmet/empty
	name = "no helmet"
	desc = ""
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/helmet/standard
	name = "M10X helmet"
	desc = "A standard TGMC combat helmet. Apply to head for best results."
	item_typepath = /obj/item/clothing/head/modular/m10x
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/helmet/leader
	name = "M11X helmet"
	desc = "An upgraded helmet for protecting upgraded brains."
	item_typepath = /obj/item/clothing/head/modular/m10x/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

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
	item_typepath = /obj/item/clothing/head/modular/m10x/tyr
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/helmet/mimir
	name = "M10X-Mimir helmet"
	desc = "A standard combat helmet with a Mimir environmental protection module."
	req_desc = "Requires a suit with a Mimir module."
	item_typepath = /obj/item/clothing/head/modular/m10x/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	item_whitelist = list(/obj/item/clothing/suit/modular/xenonauten/mimir = ITEM_SLOT_OCLOTHING)

/datum/loadout_item/helmet/mimir/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_HEAD)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/neuraline, SLOT_IN_HEAD)
