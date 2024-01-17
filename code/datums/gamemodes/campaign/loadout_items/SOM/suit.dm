/datum/loadout_item/suit_slot/som_light_shield
	name = "Light Aegis armor"
	desc = "M-11 scout armor with a Aegis shield module. Provides excellent mobility but lower protection."
	item_typepath = /obj/item/clothing/suit/modular/som/light/shield
	jobs_supported = list(SOM_SQUAD_MARINE)

/datum/loadout_item/suit_slot/som_light_shield/veteran
	jobs_supported = list(SOM_SQUAD_VETERAN)
	req_desc = "Requires a blink drive."
	item_whitelist = list(/obj/item/blink_drive = ITEM_SLOT_BACK)

/datum/loadout_item/suit_slot/som_medium_shield
	name = "Medium Aegis armor"
	desc = "M-21 battle armor with a Aegis shield module. Provides balanced mobility and protection."
	item_typepath = /obj/item/clothing/suit/modular/som/shield
	jobs_supported = list(SOM_SQUAD_MARINE, SOM_SQUAD_VETERAN, SOM_SQUAD_LEADER, SOM_FIELD_COMMANDER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_heavy_shield
	name = "Heavy Aegis armor"
	desc = "M-31 combat armor with a Aegis shield module. Provides excellent protection but lower mobility."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/shield
	jobs_supported = list(SOM_SQUAD_VETERAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_heavy_shield/breacher
	jobs_supported = list(SOM_SQUAD_MARINE)
	req_desc = "Requires a V-21 and boarding shield."
	item_whitelist = list(
		/obj/item/weapon/gun/smg/som/one_handed = ITEM_SLOT_SUITSTORE,
	)

/datum/loadout_item/suit_slot/som_heavy_surt
	name = "Heavy Hades armor"
	desc = "M-31 combat armor with a Hades fireproof module. Provides excellent protection and almost total fire immunity, but has poor mobility."
	req_desc = "Requires a V-62 incinerator."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/pyro
	jobs_supported = list(SOM_SQUAD_MARINE)
	item_whitelist = list(/obj/item/weapon/gun/flamer/som/mag_harness = ITEM_SLOT_SUITSTORE)

/datum/loadout_item/suit_slot/som_heavy_tyr
	name = "Heavy Lorica armor"
	desc = "M-31 combat armor with a Lorica extra armor module. Provides incredible protection at the cost of further reduced mobility."
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

/datum/loadout_item/suit_slot/gorgon
	name = "Gorgon armor"
	desc = "M-35 'Gorgon' armor with integrated Apollo automedical module. Provides outstanding protection without severely limiting mobility. \
	Typically seen on SOM leaders or their most elite combat units due to the significant construction and maintenance requirements."
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
	name = "Heavy Mith armor"
	desc = "M-31 combat armor with a Mithridatius 'Mith' environmental protection module. Provides excellent armor and total immunity to chemical attacks, and improved radiological protection. Has lower mobility."
	req_desc = "Requires a helmet with a Mithridatius environmental protection module."
	item_typepath = /obj/item/clothing/suit/modular/som/heavy/mithridatius
	jobs_supported = list(SOM_SQUAD_VETERAN)
	item_whitelist = list(/obj/item/clothing/head/modular/som/bio = ITEM_SLOT_HEAD)
	quantity = 2

//engineer
/datum/loadout_item/suit_slot/som_engineer
	name = "Medium armor"
	desc = "M-21 battle armor with engineering storage. Provides balanced armor and mobility."
	item_typepath = /obj/item/clothing/suit/modular/som/engineer
	jobs_supported = list(SOM_SQUAD_ENGINEER)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_engineer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/circuitboard/apc, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/cell/high, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/medium_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/stack/barbed_wire/half_stack, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_engineer/light
	name = "Light armor"
	desc = "M-11 scout armor with engineering storage. Provides excellent mobility but lower protection."
	item_typepath = /obj/item/clothing/suit/modular/som/light/engineer

//medic
/datum/loadout_item/suit_slot/som_medic
	name = "Medium armor"
	desc = "M-21 battle armor with medical storage. Provides balanced armor and mobility."
	item_typepath = /obj/item/clothing/suit/modular/som/medic
	jobs_supported = list(SOM_SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_slot/som_medic/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_SUIT)
	wearer.equip_to_slot_or_del(new /obj/item/defibrillator, SLOT_IN_SUIT)

/datum/loadout_item/suit_slot/som_medic/light
	name = "Light armor"
	desc = "M-11 scout armor with medical storage. Provides excellent mobility but lower protection."
	item_typepath = /obj/item/clothing/suit/modular/som/light/medic
