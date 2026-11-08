/datum/loadout_item/secondary/engineer
	ui_icon = "construction"
	jobs_supported = list(SQUAD_ENGINEER, SOM_SQUAD_ENGINEER)

/datum/loadout_item/secondary/engineer/large_mines
	name = "Claymores"
	desc = "Two large boxes of claymores. Mines are extremely effective for creating deadzones or setting up traps. Great on the defence."
	ui_icon = "claymore"

/datum/loadout_item/secondary/engineer/large_mines/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/large, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/engineer/materials
	name = "Metal/plasteel"
	desc = "A full stack of metal and plasteel. For maximum construction."
	ui_icon = "materials"

/datum/loadout_item/secondary/engineer/materials/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/metal/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sheet/plasteel/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/engineer/barricade_capsule
	name = "Cade Capsule"
	desc = "Three barricade capsules. Used to create instant fortifications in open areas."
	ui_icon = "construction"
	purchase_cost = 30

/datum/loadout_item/secondary/engineer/barricade_capsule/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/deploy_capsule/barricade/no_stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deploy_capsule/barricade/no_stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deploy_capsule/barricade/no_stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

	var/datum/loadout_item/suit_store/main_gun/primary = holder.equipped_things["[ITEM_SLOT_SUITSTORE]"]
	if(!istype(primary))
		return
	wearer.equip_to_slot_or_del(new primary.ammo_type, SLOT_IN_BACKPACK)
