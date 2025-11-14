/datum/loadout_item/suit_slot
	item_slot = ITEM_SLOT_OCLOTHING

/datum/loadout_item/suit_slot/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/empty
	name = "no suit"
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


/datum/loadout_item/suit_slot/light_shield
	name = "L shield armor"
	desc = "Light armor with a Svallin shield module. Provides excellent mobility but lower protection."
	ui_icon = "light_armour_shield"
	req_desc = "Requires a light helmet."
	item_typepath = /obj/item/clothing/suit/modular/tdf/light/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/light_shield/overclocked
	desc = "Light armor with a Svallin shield module. Provides excellent mobility but lower protection. The shield module has been overclocked for improved performance."
	item_typepath = /obj/item/clothing/suit/modular/tdf/light/shield_overclocked
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = null

/datum/loadout_item/suit_slot/light_shield/overclocked/medic
	item_typepath = /obj/item/clothing/suit/modular/tdf/light/shield_overclocked/medic
	jobs_supported = list(SQUAD_CORPSMAN)

/datum/loadout_item/suit_slot/light_shield/overclocked/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/light_shield/overclocked/engineer
	item_typepath = /obj/item/clothing/suit/modular/tdf/light/shield_overclocked/engineer
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/suit_slot/light_shield/overclocked/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/medium_shield
	name = "M shield armor"
	desc = "Medium armor with a Svallin shield module. Provides balanced mobility and protection."
	ui_icon = "medium_armour_shield"
	req_desc = "Requires a medium helmet."
	item_typepath = /obj/item/clothing/suit/modular/tdf/shield
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/medium_shield/overclocked
	desc = "Medium armor with a Svallin shield module. Provides balanced mobility and protection."
	item_typepath = /obj/item/clothing/suit/modular/tdf/shield_overclocked
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = null

/datum/loadout_item/suit_slot/medium_shield/overclocked/medic
	item_typepath = /obj/item/clothing/suit/modular/tdf/shield_overclocked/medic
	jobs_supported = list(SQUAD_CORPSMAN)

/datum/loadout_item/suit_slot/medium_shield/overclocked/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/medium_shield/overclocked/engineer
	item_typepath = /obj/item/clothing/suit/modular/tdf/shield_overclocked/engineer
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/suit_slot/medium_shield/overclocked/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/heavy_shield
	name = "H shield armor"
	desc = "Heavy armor with a Svallin shield module. Provides excellent protection but lower mobility. The shield module has been overclocked for improved performance."
	ui_icon = "heavy_armour_shield"
	req_desc = "Requires a heavy or smartgunner helmet."
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/shield
	item_whitelist = list(
		/obj/item/clothing/head/modular/tdf/heavy = ITEM_SLOT_HEAD,
		/obj/item/clothing/head/modular/tdf/sg = ITEM_SLOT_HEAD,
	)
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/heavy_shield/overclocked
	desc = "Heavy armor with a Svallin shield module. Provides excellent protection but lower mobility. The shield module has been overclocked for improved performance."
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/shield_overclocked
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER)
	loadout_item_flags = null

/datum/loadout_item/suit_slot/heavy_shield/leader
	item_whitelist = list(
	)
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/leader/shield
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_shield/overclocked/leader
	item_whitelist = list(
	)
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/leader/shield_overclocked
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_surt
	name = "H Surt armor"
	desc = "Heavy armor with a Surt fireproof module. Provides excellent protection and almost total fire immunity, but has poor mobility."
	ui_icon = "heavy_armour"
	req_desc = "Requires a FL-84 flamethrower."
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/surt
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/big_flamer/marinestandard/wide = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/suit_slot/heavy_tyr
	name = "H Tyr armor"
	desc = "Heavy armor with a Tyr extra armor module. Provides incredible protection at the cost of with further reduced mobility."
	req_desc = "Requires a ALF-51B or SMG-25."
	ui_icon = "tyr"
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/tyr_two
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/weapon/gun/rifle/alf_machinecarbine/assault = ITEM_SLOT_SUITSTORE,
		/obj/item/weapon/gun/smg/m25/magharness = ITEM_SLOT_SUITSTORE,
		/obj/item/storage/holster/blade/machete/full_alt = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/suit_slot/heavy_tyr/smartgunner
	jobs_supported = list(SQUAD_SMARTGUNNER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/heavy_tyr/medic
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/tyr_two/corpsman
	jobs_supported = list(SQUAD_CORPSMAN)
	loadout_item_flags = null
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/heavy_tyr/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/heavy_tyr/engineer
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/tyr_two/engineer
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = null
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/heavy_tyr/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/heavy_tyr/universal
	jobs_supported = list(SQUAD_MARINE, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = NONE
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/medium_valk
	name = "M Valkyrie armor"
	desc = "Medium armor with a Valkyrie automedical module. Provides respectable protection, powerful automatic medical assistance, but modest mobility."
	ui_icon = "medium_armour"
	item_typepath = /obj/item/clothing/suit/modular/tdf/valk
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)

/datum/loadout_item/suit_slot/heavy_valk
	name = "H Valkyrie armor"
	desc = "Heavy armor with a Valkyrie automedical module. Provides excellent protection, powerful automatic medical assistance, but reduced mobility."
	ui_icon = "heavy_armour"
	item_typepath = /obj/item/clothing/suit/modular/tdf/heavy/leader
	jobs_supported = list(SQUAD_LEADER, FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/white_dress
	name = "Dress jacket"
	desc = "The perfect white jacket to go with your white dress uniform. WARNING: Incompatible with almost all weapons."
	item_typepath = /obj/item/clothing/suit/white_dress_jacket
	jobs_supported = list(SQUAD_MARINE, SQUAD_CORPSMAN, SQUAD_ENGINEER, SQUAD_SMARTGUNNER, SQUAD_LEADER, FIELD_COMMANDER, STAFF_OFFICER, CAPTAIN)

//corpsman
/datum/loadout_item/suit_slot/medium_mimir
	name = "M Mimir armor"
	desc = "Medium armor with a Mimir environmental protection module. Provides respectable armor and total immunity to chemical attacks, and improved radiological protection. Has modest mobility."
	ui_icon = "medium_armour"
	item_typepath = /obj/item/clothing/suit/modular/tdf/mimir
	jobs_supported = list(SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/medium_mimir/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

//engineer
/datum/loadout_item/suit_slot/medium_engineer
	name = "M armor"
	desc = "Medium armor with engineering storage. Provides balanced armor and mobility."
	ui_icon = "medium_armour"
	item_typepath = /obj/item/clothing/suit/modular/tdf/engineer
	jobs_supported = list(SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/medium_engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
