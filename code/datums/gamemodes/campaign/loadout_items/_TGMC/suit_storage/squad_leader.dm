/datum/loadout_item/suit_store/main_gun/squad_leader
	jobs_supported = list(SQUAD_LEADER)

/datum/loadout_item/suit_store/main_gun/squad_leader/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle
	name = "AR-12"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses 10x24mm caseless ammunition."
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_rifle/enhanced
	name = "AR-12+"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle/ap

/datum/loadout_item/suit_store/main_gun/squad_leader/laser_rifle
	name = "Laser rifle"
	desc = "Equipped with a red dot sight, bayonet and miniflamer. The Terra Experimental laser rifle, is a powerful and flexible weapon thanks to a variety of firemodes. \
	Has good mobility and excellent falloff, although lacks the power offered by weapons with an underbarrel grenade launcher.\
	Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "ter"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/squad_leader/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/carbine
	name = "AR-18"
	desc = "Equipped with red dot sight, extended barrel and plasma pistol. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. Uses 10x24mm caseless ammunition."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/plasma_pistol

/datum/loadout_item/suit_store/main_gun/squad_leader/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/carbine/enhanced
	name = "AR-18+"
	desc = "Equipped with red dot sight, extended barrel and plasma pistol. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/squad_leader/combat_rifle
	name = "AR-11"
	desc = "Equipped with a red dot sight and laser sight. The AR-11 is an old rifle of the TGMC, but is now a relatively uncommon sight. \
	It has a very large magazine capacity, and can inflict incredible damage at long range with its HV ammo, making it particularly effective at well armored targets. \
	However it suffers from relatively poor handling and mobility, and lacks any underbarrel weapon attachments, making it an effective but less flexible weapon. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "tx11"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/squad_leader/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)


/datum/loadout_item/suit_store/main_gun/squad_leader/battle_rifle
	name = "BR-64"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. \
	The BR-64 is considered a 'light' marksmen rifle, with good stopping power it can apply effective damage at any range, while still having respectible handling and mobility. Uses 10x26.5smm caseless ammunition."
	ui_icon = "t64"
	item_typepath = /obj/item/weapon/gun/rifle/standard_br/standard

/datum/loadout_item/suit_store/main_gun/squad_leader/battle_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x265mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/auto_shotgun
	name = "SH-15"
	desc = "Equipped with a motion sensor, extended barrel and plasma pistol. \
	The SH-15 automatic shotgun has excellent mobility and handling, and offers powerful damage per shot. Its comparatively slow rate of fire means in a straight gunfight its overall damage output is somewhat lacking.\
	Uses 12-round 16 gauge magazines with slugs and flechette."
	ui_icon = "tx15"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/plasma_pistol
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/tx15_flechette

/datum/loadout_item/suit_store/main_gun/squad_leader/auto_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/oicw
	name = "AR-55"
	desc = "Equipped with a motion sensor, recoil compensator, vertical grip and integrated GL-54. \
	The AR-55 is effectively a GL-54 with a simplified AR-18 strapped to the bottom. It has all the flexible airbursting power of the GL-54 combined with the reliable damage of an assault rifle. \
	While even more bulky and cumbersome than just the GL-54 alone, and the rifle component is inferior to the AR-18 it is derived from, the AR-55 is a far more effective weapon than the sum of its parts. \
	Uses 10x24mm caseless ammunition and 20mm airburst grenades."
	ui_icon = "tx55"
	item_typepath = /obj/item/weapon/gun/rifle/tx55/combat_patrol
	purchase_cost = 100
	quantity = 2

/datum/loadout_item/suit_store/main_gun/squad_leader/oicw/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/oicw/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(loadout.belt == /obj/item/storage/belt/marine)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_BELT)
	if(loadout.l_pocket == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_L_POUCH)
	if(loadout.r_pocket == /obj/item/storage/pouch/magazine/large)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54, SLOT_IN_R_POUCH)

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_smg
	name = "SMG-25"
	desc = "Equipped with a mag harness, recoil compensator and plasma pistol. The SMG-25 submachinegun is a large capacity smg, intended to be used two handed to take advantage of the attached plasma pistol. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses 10x20mm caseless ammunition, and comes with multiple ammo types."
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/plasma

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/plasma_pistol, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/standard_smg/enhanced
	name = "SMG-25+"
	desc = "Equipped with a mag harness, recoil compensator and plasma pistol. The SMG-25 submachinegun is a large capacity smg, intended to be used two handed to take advantage of the attached plasma pistol. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/m25/ap

/datum/loadout_item/suit_store/main_gun/squad_leader/plasma_smg
	name = "PL-51"
	desc = "Unlocked for free with the Advanced SMG training perk. Equipped with a motion sensor, bayonet and vertical grip. The PL-51 plasma SMG is a powerful close range weapon, with great mobility and handling. \
	Has two firemodes, with a standard reflecting shot, or a more powerful AOE overcharged shot. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg/motion_sensor
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/squad_leader/plasma_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/squad_leader/plasma_rifle
	name = "PL-38"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a red dot sight, bayonet and miniflamer. The PL-38 plasma rifle is a powerful heavy rifle, able to unleash significant damage at any range. \
	Has three firemodes, with a standard high ROF mode, a piercing shatter shot, or a melting blast mode. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle/standard
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/squad_leader/plasma_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
