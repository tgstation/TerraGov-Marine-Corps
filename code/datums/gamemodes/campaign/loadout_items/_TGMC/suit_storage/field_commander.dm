/datum/loadout_item/suit_store/officer_sword
	name = "Officers sword"
	desc = "This appears to be a rather old blade that has been well taken care of, it is probably a family heirloom. \
	Well made and extremely sharp, despite its probable non-combat purpose. Comes in a leather scabbard that an attached to your waist or armor."
	ui_icon = "machete"
	item_typepath = /obj/item/storage/holster/blade/officer/full
	jobs_supported = list(FIELD_COMMANDER)

/datum/loadout_item/suit_store/officer_sword/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!isstorageobj(wearer.back))
		return

	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet/fieldcommand, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/fc_pistol
	name = "P-1911A1-C pistol"
	desc = "The P-1911A1-C is a custom modified pistol with impressive stopping power for its size. \
	Light and easy to use one handed, it suffers from a small magazine size and no auto eject feature. Comes in a holster that fits on your waist or armor. Uses .45 ACP ammunition."
	ui_icon = "m1911c"
	item_typepath = /obj/item/storage/holster/belt/pistol/m4a3/fieldcommander
	jobs_supported = list(FIELD_COMMANDER)

/datum/loadout_item/suit_store/fc_pistol/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars/fire_support/campaign, SLOT_IN_ACCESSORY)

	if(!isstorageobj(wearer.back))
		return

	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/deployable_camera, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/hud_tablet/fieldcommand, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander
	jobs_supported = list(FIELD_COMMANDER)

/datum/loadout_item/suit_store/main_gun/field_commander/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/suit_store/main_gun/field_commander/pulse_rifle
	name = "PR-11"
	desc = "Equipped with a red dot sight, extended barrel and integrated underbarrel grenade launcher. The PR-11 is a relic from an earlier time. \
	Larger and more cumbersome than modern rifles and lacking any precision aimming, it makes up for this with its tremendous magazine capacity, making it more akin to a light machinegun that a rifle. Uses 10x24mm caseless ammunition."
	ui_icon = "m41a"
	item_typepath = /obj/item/weapon/gun/rifle/m41a/field_commander
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/field_commander/pulse_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander/combat_rifle
	name = "AR-11"
	desc = "Equipped with a red dot sight and laser sight. The AR-11 is an old rifle of the TGMC, but is now a relatively uncommon sight. \
	It has a very large magazine capacity, and can inflict incredible damage at long range with its HV ammo, making it particularly effective at well armored targets. \
	However it suffers from relatively poor handling and mobility, and lacks any underbarrel weapon attachments, making it an effective but less flexible weapon. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "tx11"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/field_commander/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/suit_store/main_gun/field_commander/laser_rifle
	name = "Laser rifle"
	desc = "Equipped with a red dot sight, bayonet and miniflamer. The Terra Experimental laser rifle, is a powerful and flexible weapon thanks to a variety of firemodes. \
	Has good mobility and excellent falloff, although lacks the power offered by weapons with an underbarrel grenade launcher.\
	Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "ter"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman

/datum/loadout_item/suit_store/main_gun/field_commander/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/suit_store/main_gun/field_commander/laser_mg
	name = "Laser machinegun"
	desc = "Equipped with a mag harness, bayonet and underbarrel grenade launcher. The Terra Experimental machine laser gun is a more flexible weapon than its ballistic counterparts. \
	It has better mobility and handling than ballistic machineguns, which combined with its variable firemodes and underbarrel weaponry makes it effective in a variety of situations, \
	but still ultimately excels at apply sustained supporting fire. Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "tem"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol

/datum/loadout_item/suit_store/main_gun/field_commander/laser_mg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(!isstorageobj(wearer.back))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
		return ..()
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander/standard_rifle
	name = "AR-12"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses 10x24mm caseless ammunition."
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman

/datum/loadout_item/suit_store/main_gun/field_commander/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/suit_store/main_gun/field_commander/standard_rifle/enhanced
	name = "AR-12+"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle/ap

/datum/loadout_item/suit_store/main_gun/field_commander/carbine
	name = "AR-18"
	desc = "Equipped with red dot sight, extended barrel and plasma pistol. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. Uses 10x24mm caseless ammunition."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/plasma_pistol

/datum/loadout_item/suit_store/main_gun/field_commander/carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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

/datum/loadout_item/suit_store/main_gun/field_commander/carbine/enhanced
	name = "AR-18+"
	desc = "Equipped with red dot sight, extended barrel and plasma pistol. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/field_commander/plasma_smg
	name = "PL-51"
	desc = "Unlocked for free with the Advanced SMG training perk. Equipped with a motion sensor, bayonet and vertical grip. The PL-51 plasma SMG is a powerful close range weapon, with great mobility and handling. \
	Has two firemodes, with a standard reflecting shot, or a more powerful AOE overcharged shot. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg/motion_sensor
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/field_commander/plasma_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/field_commander/plasma_rifle
	name = "PL-38"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a red dot sight, bayonet and miniflamer. The PL-38 plasma rifle is a powerful heavy rifle, able to unleash significant damage at any range. \
	Has three firemodes, with a standard high ROF mode, a piercing shatter shot, or a melting blast mode. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle/standard
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/field_commander/plasma_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
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
