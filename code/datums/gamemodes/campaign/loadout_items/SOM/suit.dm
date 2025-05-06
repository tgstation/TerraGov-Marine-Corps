/datum/loadout_item/suit_slot/som_light_shield
	name = "L Aegis armor"
	desc = "M-11 scout armor with a Aegis shield module. Provides excellent mobility but lower protection."
	ui_icon = "light_armour_shield"
	item_typepath = /obj/item/clothing/suit/modular/som/light/shield
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_slot/som_light_shield/veteran
	jobs_supported = list(SOM_SQUAD_VETERAN)
	req_desc = "Requires a blink drive."
	item_whitelist = list(/obj/item/blink_drive = ITEM_SLOT_BACK)

/datum/loadout_item/suit_slot/som_light_shield/overclocked
	desc = "M-11 scout armor with a Aegis shield module. Provides excellent mobility but lower protection. The shield module has been overclocked for improved performance."
	item_typepath = /obj/item/clothing/suit/modular/som/light/shield_overclocked
	jobs_supported = list(SOM_SQUAD_MARINE)
	loadout_item_flags = null

/datum/loadout_item/suit_slot/som_light_shield/overclocked/medic
	item_typepath = /obj/item/clothing/suit/modular/som/light/shield_overclocked/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)

/datum/loadout_item/suit_slot/som_light_shield/overclocked/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_light_shield/overclocked/engineer
	item_typepath = /obj/item/clothing/suit/modular/som/light/shield_overclocked/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)

/datum/loadout_item/suit_slot/som_light_shield/overclocked/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_light_shield/overclocked/veteran
	jobs_supported = list(SOM_SQUAD_VETERAN)
	req_desc = "Requires a blink drive."
	item_whitelist = list(/obj/item/blink_drive = ITEM_SLOT_BACK)

/datum/loadout_item/suit_slot/som_medium_shield
	name = "M Aegis armor"
	desc = "M-21 battle armor with a Aegis shield module. Provides balanced mobility and protection."
	ui_icon = "medium_armour_shield"
	item_typepath = /obj/item/clothing/suit/modular/som/shield
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_medium_shield/overclocked
	desc = "M-21 battle armor with a Aegis shield module. Provides balanced mobility and protection. The shield module has been overclocked for improved performance."
	item_typepath = /obj/item/clothing/suit/modular/som/shield_overclocked
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = null

/datum/loadout_item/suit_slot/som_medium_shield/overclocked/medic
	item_typepath = /obj/item/clothing/suit/modular/som/shield_overclocked/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)

/datum/loadout_item/suit_slot/som_medium_shield/overclocked/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_medium_shield/overclocked/engineer
	item_typepath = /obj/item/clothing/suit/modular/som/shield_overclocked/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)

/datum/loadout_item/suit_slot/som_medium_shield/overclocked/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_heavy_shield
	name = "H Aegis armor"
	desc = "M-31 combat armor with a Aegis shield module. Provides excellent protection but lower mobility."
	ui_icon = "heavy_armour_shield"
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/shield
	jobs_supported = list(SOM_SQUAD_VETERAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_heavy_shield/overclocked
	desc = "M-31 combat armor with a Aegis shield module. Provides excellent protection but lower mobility. The shield module has been overclocked for improved performance."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/shield_overclocked
	jobs_supported = list(SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = null

/datum/loadout_item/suit_slot/som_heavy_shield/breacher
	jobs_supported = list(SOM_SQUAD_MARINE)
	req_desc = "Requires a V-21 and boarding shield."
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION
	item_whitelist = list(
		/obj/item/weapon/gun/smg/som/one_handed = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/suit_slot/som_heavy_shield/breacher/overclocked
	desc = "M-31 combat armor with a Aegis shield module. Provides excellent protection but lower mobility. The shield module has been overclocked for improved performance."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/shield_overclocked
	loadout_item_flags = null

/datum/loadout_item/suit_slot/som_heavy_surt
	name = "H Hades armor"
	desc = "M-31 combat armor with a Hades fireproof module. Provides excellent protection and almost total fire immunity, but has poor mobility."
	ui_icon = "heavy_armour"
	req_desc = "Requires a V-62 incinerator."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/pyro
	jobs_supported = list(SOM_SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/som/mag_harness = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/suit_slot/som_heavy_tyr
	name = "H Lorica armor"
	desc = "M-31 combat armor with a Lorica extra armor module. Provides incredible protection at the cost of further reduced mobility."
	ui_icon = "lorica"
	req_desc = "Requires a boarding axe primary weapon."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/lorica
	jobs_supported = list(SOM_SQUAD_MARINE)
	item_whitelist = list(
		/obj/item/weapon/twohanded/fireaxe/som = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/suit_slot/som_heavy_tyr/veteran
	req_desc = "Requires a VX-32 charger and boarding shield."
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/charger/somvet = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/suit_slot/som_heavy_tyr/medic
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/lorica/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)
	loadout_item_flags = null
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/som_heavy_tyr/medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_heavy_tyr/engineer
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/lorica/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = null
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/som_heavy_tyr/engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_heavy_tyr/universal
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = null
	item_whitelist = null
	req_desc = null

/datum/loadout_item/suit_slot/gorgon
	name = "Gorgon armor"
	desc = "M-35 'Gorgon' armor with integrated Apollo automedical module. Provides outstanding protection without severely limiting mobility. \
	Typically seen on SOM leaders or their most elite combat units due to the significant construction and maintenance requirements."
	ui_icon = "gorgon"
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/leader/valk
	jobs_supported = list(SOM_SQUAD_LEADER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/gorgon/fc
	name = "Gorgon armor"
	desc = "M-35 'Gorgon' armor with integrated Apollo automedical module. Provides outstanding protection without severely limiting mobility. \
	Typically seen on SOM leaders or their most elite combat units due to the significant construction and maintenance requirements. \
	The gold markings on this one signify it is worn by a high ranking field officer"
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/leader/officer
	jobs_supported = list(SOM_FIELD_COMMANDER)

/datum/loadout_item/suit_slot/som_heavy_mimir
	name = "H Mith armor"
	desc = "M-31 combat armor with a Mithridatius 'Mith' environmental protection module. Provides excellent armor and total immunity to chemical attacks, and improved radiological protection. Has lower mobility."
	req_desc = "Requires a helmet with a Mithridatius environmental protection module."
	ui_icon = "heavy_armour"
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/mithridatius
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(/obj/item/clothing/head/modular/som/bio = ITEM_SLOT_HEAD)
	purchase_cost = 75
	quantity = 4

//engineer
/datum/loadout_item/suit_slot/som_engineer
	name = "M armor"
	desc = "M-21 battle armor with engineering storage. Provides balanced armor and mobility."
	ui_icon = "medium_armour"
	item_typepath = /obj/item/clothing/suit/modular/som/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_engineer/light
	name = "L armor"
	desc = "M-11 scout armor with engineering storage. Provides excellent mobility but lower protection."
	ui_icon = "light_armour"
	item_typepath = /obj/item/clothing/suit/modular/som/light/engineer

//medic
/datum/loadout_item/suit_slot/som_medic
	name = "M armor"
	desc = "M-21 battle armor with medical storage. Provides balanced armor and mobility."
	ui_icon = "medium_armour"
	item_typepath = /obj/item/clothing/suit/modular/som/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_medic/light
	name = "L armor"
	desc = "M-11 scout armor with medical storage. Provides excellent mobility but lower protection."
	ui_icon = "light_armour"
	item_typepath = /obj/item/clothing/suit/modular/som/light/medic
