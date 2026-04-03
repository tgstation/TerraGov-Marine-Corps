/datum/loadout_item/secondary/corpsman
	ui_icon = "medkit"
	jobs_supported = list(SQUAD_CORPSMAN, SOM_SQUAD_CORPSMAN)

/datum/loadout_item/secondary/corpsman/heal_foam
	name = "Healing foam"
	desc = "Three healing foam grenades. Provides strong area of effect healing"
	ui_icon = "medkit"
	purchase_cost = 15

/datum/loadout_item/secondary/corpsman/heal_foam/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/healing_foam, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/healing_foam, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/healing_foam, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
