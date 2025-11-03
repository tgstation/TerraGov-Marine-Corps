
/datum/loadout_item/secondary/kit //faction generic secondaries
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_CORPSMAN,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_CORPSMAN,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
	)

/datum/loadout_item/secondary/kit/primary_ammo
	name = "Extra ammo"
	desc = "Additional ammo for your primary weapon."
	ui_icon = "default"
	jobs_supported = list(
		SQUAD_MARINE,
		SQUAD_ENGINEER,
		SQUAD_SMARTGUNNER,
		SQUAD_LEADER,
		FIELD_COMMANDER,
		SOM_SQUAD_MARINE,
		SOM_SQUAD_ENGINEER,
		SOM_SQUAD_VETERAN,
		SOM_SQUAD_LEADER,
		SOM_FIELD_COMMANDER,
	)

/datum/loadout_item/secondary/kit/primary_ammo/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	var/datum/loadout_item/suit_store/main_gun/primary = holder.equipped_things["[ITEM_SLOT_SUITSTORE]"]
	if(!istype(primary))
		return
	wearer.equip_to_slot_or_del(new primary.ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new primary.secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/primary_ammo/default
	jobs_supported = list(SQUAD_CORPSMAN, SOM_SQUAD_CORPSMAN)
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary/kit/emp_nades
	name = "EMP nades"
	desc = "Three EMP grenades, excellent against energy weapons and mechs."
	ui_icon = "grenade"
	purchase_cost = 20

/datum/loadout_item/secondary/kit/emp_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/stun_nades
	name = "Stun nades"
	desc = "Three stun grenades, able to stagger, slow, and temporarily blind victims."
	ui_icon = "stun_nade"

/datum/loadout_item/secondary/kit/stun_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/antigas_nades
	name = "Antigas nades"
	desc = "Three antigas grenades, able to completely clear gas from an area."
	ui_icon = "grenade"
	purchase_cost = 15

/datum/loadout_item/secondary/kit/antigas_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/sandbags
	name = "Sandbags"
	desc = "Bags, filled with sand. They catch bullets instead of your face."
	ui_icon = "construction"

/datum/loadout_item/secondary/kit/sandbags/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/throwing_knives
	name = "Throwing knives"
	desc = "Some knives. You throw them at people with guns and hope for the best."
	ui_icon = "default"

/datum/loadout_item/secondary/kit/throwing_knives/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/throwing_knife, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/throwing_knife, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/throwing_knife, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/throwing_knife, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/throwing_knife, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/throwing_knife, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/plastique
	name = "C4 pack"
	desc = "Enough C4 to blow you back in time. Or atleast destroy some objectives."
	ui_icon = "default"

/datum/loadout_item/secondary/kit/plastique/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary/kit/anti_tank
	name = "Anti-tank"
	desc = "A disposable AT rocket launcher, and a box of AT mines. Good if you have an armor problem."
	ui_icon = "t72"
	purchase_cost = 30

/datum/loadout_item/secondary/kit/anti_tank/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/gun/launcher/rocket/oneuse/anti_tank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/explosive_mines/antitank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
