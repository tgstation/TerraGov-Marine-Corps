/datum/loadout_item/suit_slot
	item_slot = ITEM_SLOT_OCLOTHING

/datum/loadout_item/suit_slot/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/empty
	name = "no suit"
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


/datum/loadout_item/suit_slot/light_shield
	name = "Light shielded armor"
	desc = "Light armor with a Svallin shield module. Provides excellent mobility but lower protection."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/light/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/medium_shield
	name = "Medium shielded armor"
	desc = "Medium armor with a Svallin shield module. Provides balanced mobility and protection."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_shield
	name = "Heavy shielded armor"
	desc = "Heavy armor with a Svallin shield module. Provides excellent protection but lower mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/heavy_surt
	name = "Heavy Surt armor"
	desc = "Heavy armor with a Surt fireproof module. Provides excellent protection and almost total fire immunity, but has poor mobility."
	req_desc = "Requires a FL-84 flamethrower."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/suit_slot/heavy_tyr
	name = "Heavy Tyr armor"
	desc = "Heavy armor with a Tyr extra armor module. Provides incredible protection at the cost of with further reduced mobility."
	req_desc = "Requires a ALF-51B or SMG-25."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/tyr_two
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/weapon/gun/rifle/alf_machinecarbine/assault = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/smg/m25/magharness = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/suit_slot/heavy_tyr/smartgunner
	jobs_supported = list(SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_whitelist = null

/datum/loadout_item/suit_slot/medium_valk
	name = "Medium Valkyrie armor"
	desc = "Medium armor with a Valkyrie automedical module. Provides respectable protection, powerful automatic medical assistance, but modest mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/valk
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_valk
	name = "Heavy Valkyrie armor"
	desc = "Heavy armor with a Valkyrie automedical module. Provides excellent protection, powerful automatic medical assistance, but reduced mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/white_dress
	name = "White dress jacket"
	desc = "The perfect white jacket to go with your white dress uniform. WARNING: Incompatible with almost all weapons."
	item_typepath = /obj/item/clothing/suit/white_dress_jacket
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

//corpsman
/datum/loadout_item/suit_slot/medium_mimir
	name = "Medium Mimir armor"
	desc = "Medium armor with a Mimir environmental protection module. Provides respectable armor and total immunity to chemical attacks, and improved radiological protection. Has modest mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/medium_mimir/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

//engineer
/datum/loadout_item/suit_slot/medium_engineer
	name = "Medium armor"
	desc = "Medium armor with engineering storage. Provides balanced armor and mobility."
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/engineer
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/medium_engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_SUIT)
