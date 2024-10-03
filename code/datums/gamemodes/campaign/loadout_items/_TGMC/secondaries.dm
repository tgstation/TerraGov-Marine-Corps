/datum/loadout_item/secondary_weapon/gun/marine
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)
	item_whitelist = list(
		/obj/item/storage/holster/belt/pistol/m4a3 = ITEM_SLOT_BELT,
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
	)

/datum/loadout_item/secondary_weapon/gun/marine/standard_pistol
	name = "P-14"
	desc = "placeholder basic pistol"
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/pistol/standard_pistol
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/secondary_weapon/gun/marine/standard_heavypistol
	name = "P-23"
	desc = "better pistol"
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/pistol/standard_heavypistol/tactical

/datum/loadout_item/secondary_weapon/gun/marine/laser_pistol
	name = "TE-P"
	desc = "laser pew pew"
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol

/datum/loadout_item/secondary_weapon/gun/marine/standard_machinepistol
	name = "MP-19"
	desc = "compact MP-19"
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/smg/standard_machinepistol/compact
	item_whitelist = list(
		/obj/item/storage/backpack/marine/satchel = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/marine = ITEM_SLOT_BACK,
		/obj/item/storage/backpack/lightpack = ITEM_SLOT_BACK,
	)

/datum/loadout_item/secondary_weapon/gun/marine/standard_machinepistol/scanner
	name = "MP-19-m"
	desc = "MP-19 with motion scanner"
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/smg/standard_machinepistol/scanner

/datum/loadout_item/secondary_weapon/gun/marine/standard_smg
	name = "SMG-25"
	desc = "laser pew pew"
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/holstered
	item_whitelist = list(/obj/item/storage/holster/m25 = ITEM_SLOT_BELT)

/////kits
/datum/loadout_item/secondary_weapon/primary_ammo
	name = "Extra ammo"
	desc = "Additional ammo for your primary weapon."
	ui_icon = "t12"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/primary_ammo/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	var/datum/loadout_item/suit_store/main_gun/primary = holder.equipped_things["[ITEM_SLOT_SUITSTORE]"]
	wearer.equip_to_slot_or_del(new primary.secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new primary.secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/emp_nades
	name = "EMP nades"
	desc = "Three EMP grenades, excellent against energy weapons and mechs."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/emp_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/mirage_nades
	name = "Mirage nades"
	desc = "Three mirage grenades, can provide a handy distraction against unwitting opponents."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/mirage_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/he_nades
	name = "HE nades"
	desc = "Three HE grenades, for a bit more bang."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/he_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/stun_nades
	name = "Stun nades"
	desc = "Three stun grenades, able to stagger, slow, and temporarily blind victims."
	ui_icon = "grenade"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/stun_nades/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/secondary_weapon/sandbags
	name = "Sandbags"
	desc = "Bags, filled with sand. They catch bullets instead of your face."
	ui_icon = "construction"
	jobs_supported = list(SQUAD_MARINE, SQUAD_LEADER, SQUAD_SMARTGUNNER, FIELD_COMMANDER)

/datum/loadout_item/secondary_weapon/sandbags/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/stack/sandbags/large_stack, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
