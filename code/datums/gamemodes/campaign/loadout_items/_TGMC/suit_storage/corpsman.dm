/datum/loadout_item/suit_store/main_gun/corpsman
	jobs_supported = list(SQUAD_CORPSMAN)

/datum/loadout_item/suit_store/main_gun/corpsman/laser_carbine
	name = "Laser carbine"
	desc = "Equipped with a red dot sight and underbarrel grenade launcher. The TerraGov laser carbine is the high tech equivilent to the AR-18, with extremely good mobility and handling, and powerful medium range damage. \
	Variable firemodes gives it additional flexibility over its ballistic counterpart. Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "tec"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/corpsman/laser_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/laser_rifle
	name = "Laser rifle"
	desc = "Equipped with amag harness, bayonet and miniflamer. The Terra Experimental laser rifle, is a powerful and flexible weapon thanks to a variety of firemodes. \
	Has good mobility and excellent falloff, although lacks the power offered by weapons with an underbarrel grenade launcher.\
	Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "ter"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/medic

/datum/loadout_item/suit_store/main_gun/corpsman/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/auto_shotgun
	name = "SH-15"
	desc = "Equipped with a mag harness and underbarrel grenade launcher. \
	The SH-15 automatic shotgun has excellent mobility and handling, and offers powerful damage per shot. Its comparatively slow rate of fire means in a straight gunfight its overall damage output is somewhat lacking.\
	Uses 12-round 16 gauge magazines with slugs and flechette."
	ui_icon = "tx15"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/engineer
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/tx15_flechette

/datum/loadout_item/suit_store/main_gun/corpsman/auto_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
/datum/loadout_item/suit_store/main_gun/corpsman/skirmish_rifle
	name = "AR-21"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. \
	The AR-21 is an less common rifle in the TGMC, attempting to bridge the gap between lighter, lower calibre rifles and heavier rifles like the BR-64. \
	Its compromises between the two groups means it fails to particularly outshine any of them, but never the less is a respective and flexible rifle."
	ui_icon = "t21"
	item_typepath = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard

/datum/loadout_item/suit_store/main_gun/corpsman/skirmish_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/standard_smg
	name = "SMG-25"
	desc = "Equipped with a mag harness, recoil compensator and gyroscopic stabilizer. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses 10x20mm caseless ammunition."
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness

/datum/loadout_item/suit_store/main_gun/corpsman/standard_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/standard_smg/enhanced
	name = "SMG-25+"
	desc = "Equipped with a mag harness, recoil compensator and gyroscopic stabilizer. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses a mix of standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/m25/ap

/datum/loadout_item/suit_store/main_gun/corpsman/carbine
	name = "AR-18"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. Uses 10x24mm caseless ammunition."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/standard

/datum/loadout_item/suit_store/main_gun/corpsman/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/carbine/enhanced
	name = "AR-18+"
	desc = "Equipped with mag harness, extended barrel and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle
	name = "AR-12"
	desc = "Equipped with mag harness, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses 10x24mm caseless ammunition."
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/medic

/datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/assault_rifle/enhanced
	name = "AR-12+"
	desc = "Equipped with mag harness, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle/ap

/datum/loadout_item/suit_store/main_gun/corpsman/combat_rifle
	name = "AR-11"
	desc = "Equipped with a red dot sight and laser sight. The AR-11 is an old rifle of the TGMC, but is now a relatively uncommon sight. \
	It has a very large magazine capacity, and can inflict incredible damage at long range with its HV ammo, making it particularly effective at well armored targets. \
	However it suffers from relatively poor handling and mobility, and lacks any underbarrel weapon attachments, making it an effective but less flexible weapon. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "tx11"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/corpsman/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/plasma_smg
	name = "PL-51"
	desc = "Unlocked for free with the Advanced SMG training perk. Equipped with a red dot sight, bayonet and vertical grip. The PL-51 plasma SMG is a powerful close range weapon, with great mobility and handling. \
	Has two firemodes, with a standard reflecting shot, or a more powerful AOE overcharged shot. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg/standard
	unlock_cost = 300
	purchase_cost = 80
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/corpsman/plasma_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/corpsman/plasma_rifle
	name = "PL-38"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a red dot sight, bayonet and miniflamer. The PL-38 plasma rifle is a powerful heavy rifle, able to unleash significant damage at any range. \
	Has three firemodes, with a standard high ROF mode, a piercing shatter shot, or a melting blast mode. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle/standard
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/corpsman/plasma_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclotplus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/corpsman/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/antigas, SLOT_IN_BACKPACK)
