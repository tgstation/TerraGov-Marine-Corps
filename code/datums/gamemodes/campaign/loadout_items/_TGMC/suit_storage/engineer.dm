/datum/loadout_item/suit_store/main_gun/engineer
	jobs_supported = list(SQUAD_ENGINEER)

/datum/loadout_item/suit_store/main_gun/engineer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/engineer/carbine
	name = "AR-18"
	desc = "Equipped with mag harness, extended barrel and vertical grip. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. Uses 10x24mm caseless ammunition."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/engineer
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/engineer/carbine/enhanced
	name = "AR-18+"
	desc = "Equipped with mag harness, extended barrel and vertical grip. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/engineer/assault_rifle
	name = "AR-12"
	desc = "Equipped with mag harness, extended barrel and miniflamer. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses 10x24mm caseless ammunition."
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/engineer

/datum/loadout_item/suit_store/main_gun/engineer/assault_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/chem_grenade/razorburn_large, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/engineer/assault_rifle/enhanced
	name = "AR-12+"
	desc = "Equipped with mag harness, extended barrel and miniflamer. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle/ap

/datum/loadout_item/suit_store/main_gun/engineer/auto_shotgun
	name = "SH-15"
	desc = "Equipped with a mag harness and underbarrel grenade launcher. \
	The SH-15 automatic shotgun has excellent mobility and handling, and offers powerful damage per shot. Its comparatively slow rate of fire means in a straight gunfight its overall damage output is somewhat lacking.\
	Uses 12-round 16 gauge magazines with slugs and flechette."
	ui_icon = "tx15"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/tx15_flechette

/datum/loadout_item/suit_store/main_gun/engineer/auto_shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/engineer/combat_rifle
	name = "AR-11"
	desc = "Equipped with a red dot sight and laser sight. The AR-11 is an old rifle of the TGMC, but is now a relatively uncommon sight. \
	It has a very large magazine capacity, and can inflict incredible damage at long range with its HV ammo, making it particularly effective at well armored targets. \
	However it suffers from relatively poor handling and mobility, and lacks any underbarrel weapon attachments, making it an effective but less flexible weapon. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "tx11"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/engineer/laser_carbine
	name = "Laser carbine"
	desc = "Equipped with a red dot sight and gyroscopic stabilizer. The TerraGov laser carbine is the high tech equivilent to the AR-18, with extremely good mobility and handling, and powerful medium range damage. \
	Variable firemodes gives it additional flexibility over its ballistic counterpart. Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "tec"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/gyro

/datum/loadout_item/suit_store/main_gun/engineer/standard_smg
	name = "SMG-25"
	desc = "Equipped with a mag harness, recoil compensator and vertical grip. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses 10x20mm caseless ammunition."
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/vgrip

/datum/loadout_item/suit_store/main_gun/engineer/standard_smg/enhanced
	name = "SMG-25+"
	desc = "Equipped with a mag harness, recoil compensator and vertical grip. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses a mix of standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/m25/ap

/datum/loadout_item/suit_store/main_gun/engineer/plasma_smg
	name = "PL-51"
	desc = "Unlocked for free with the Advanced SMG training perk. Equipped with a red dot sight, bayonet and vertical grip. The PL-51 plasma SMG is a powerful close range weapon, with great mobility and handling. \
	Has two firemodes, with a standard reflecting shot, or a more powerful AOE overcharged shot. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg/standard
	unlock_cost = 300
	purchase_cost = 80
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/engineer/plasma_rifle
	name = "PL-38"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a red dot sight, bayonet and vertical grip. The PL-38 plasma rifle is a powerful heavy rifle, able to unleash significant damage at any range. \
	Has three firemodes, with a standard high ROF mode, a piercing shatter shot, or a melting blast mode. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle/v_grip
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE
