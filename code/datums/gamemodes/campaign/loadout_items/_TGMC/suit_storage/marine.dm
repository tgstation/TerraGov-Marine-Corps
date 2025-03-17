/datum/loadout_item/suit_store/main_gun/marine
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/suit_store/main_gun/marine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle
	name = "AR-12"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses 10x24mm caseless ammunition."
	ui_icon = "t12"
	item_typepath = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle/enhanced
	name = "AR-12+"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-12 is the former main weapon of the TGMC before it was superceded by the AR-18 for general issue. \
	A jack of all trades weapon, effect at close and long range, with good capacity and handling, making it a reliable all-rounder. \
	It does not particularly excel in any area however, and so is overshadowed by other weapons at particular tasks. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_assaultrifle/ap

/datum/loadout_item/suit_store/main_gun/marine/standard_rifle/enhanced/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	return ..()

/datum/loadout_item/suit_store/main_gun/marine/laser_rifle
	name = "Laser rifle"
	desc = "Equipped with a red dot sight, bayonet and miniflamer. The Terra Experimental laser rifle, is a powerful and flexible weapon thanks to a variety of firemodes. \
	Has good mobility and excellent falloff, although lacks the power offered by weapons with an underbarrel grenade launcher.\
	Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "ter"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_rifle/rifleman

/datum/loadout_item/suit_store/main_gun/marine/laser_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_laser_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine
	name = "AR-18"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. Uses 10x24mm caseless ammunition."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/standard

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine/enhanced
	name = "AR-18+"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/marine/standard_carbine/enhanced/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	return ..()

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle
	name = "AR-11"
	desc = "Equipped with a red dot sight and laser sight. The AR-11 is an old rifle of the TGMC, but is now a relatively uncommon sight. \
	It has a very large magazine capacity, and can inflict incredible damage at long range with its HV ammo, making it particularly effective at well armored targets. \
	However it suffers from relatively poor handling and mobility, and lacks any underbarrel weapon attachments, making it an effective but less flexible weapon. It uses 4.92×34mm caseless HV ammunition."
	ui_icon = "tx11"
	item_typepath = /obj/item/weapon/gun/rifle/tx11/standard

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p492x34mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/combat_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/battle_rifle
	name = "BR-64"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. \
	The BR-64 is considered a 'light' marksmen rifle, with good stopping power it can apply effective damage at any range, while still having respectible handling and mobility. Uses 10x26.5smm caseless ammunition."
	ui_icon = "t64"
	item_typepath = /obj/item/weapon/gun/rifle/standard_br/standard

/datum/loadout_item/suit_store/main_gun/marine/battle_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x265mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/skirmish_rifle
	name = "AR-21"
	desc = "Equipped with red dot sight, extended barrel and underbarrel grenade launcher. \
	The AR-21 is an less common rifle in the TGMC, attempting to bridge the gap between lighter, lower calibre rifles and heavier rifles like the BR-64. \
	Its compromises between the two groups means it fails to particularly outshine any of them, but never the less is a respective and flexible rifle."
	ui_icon = "t21"
	item_typepath = /obj/item/weapon/gun/rifle/standard_skirmishrifle/standard

/datum/loadout_item/suit_store/main_gun/marine/skirmish_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x25mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/alf
	name = "ALF-51B"
	desc = "Equipped with a mag harness, bayonet and vertical grip. The ALF-51B is an unusual weapon, being a heavily modified AR-18 modified to SMG length of barrel, rechambered for a larger caliber, and belt fed. \
	Combining its powerful close range damage that can slow targets, impressive mobility and huge capacity, it is a devastating close range weapon. \
	However it suffers from appaling falloff making it highly ineffective at range, and its belt fed nature means it cannot be reloaded quickly, often leaving careless users exposed. Uses 10x25mm caseless ammunition."
	ui_icon = "alf51b"
	item_typepath = /obj/item/weapon/gun/rifle/alf_machinecarbine/assault

/datum/loadout_item/suit_store/main_gun/marine/alf/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/alf/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg
	name = "MG-60"
	desc = "Equipped with a mag harness, extended barrel and bipod. The MG-60 is a powerful machinegun, combining a tremendous capacity good stopping power and blistering rate of fire, it is extremely deadly at any range. \
	It has terrible mobility and poor accuracy on the move, so is generally used as a static weapon where it can lay down blistering firepower for team mates. It uses 10x26mm caseless ammunition."
	ui_icon = "t60"
	item_typepath = /obj/item/weapon/gun/rifle/standard_gpmg/machinegunner
	item_blacklist = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = ITEM_SLOT_SECONDARY)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_gpmg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg
	name = "MG-27"
	desc = "Equipped with an unremovable miniscope and tripod. The MG-27 is large, unwieldy machinegun, with terrible mobility and effectively unmanagable handling outside of point blank range. \
	However the MG-27 is primary used as a deployed weapon, where it offers devastatingly powerful, accurate and long range damage that far exceeds the lighter MG-60. \
	Can quickly mow down any target caught out in the open, it is the final word in static weaponry. It uses 10x27mm caseless ammunition."
	ui_icon = "default"
	item_typepath = LOADOUT_ITEM_MG27
	item_blacklist = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = ITEM_SLOT_SECONDARY)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_mmg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/laser_mg
	name = "Laser machinegun"
	desc = "Equipped with a mag harness, bayonet and underbarrel grenade launcher. The Terra Experimental machine laser gun is a more flexible weapon than its ballistic counterparts. \
	It has better mobility and handling than ballistic machineguns, which combined with its variable firemodes and underbarrel weaponry makes it effective in a variety of situations, \
	but still ultimately excels at apply sustained supporting fire. Uses TE power cells that are shared across all TGMC laser weaponry."
	ui_icon = "tem"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_mlaser/patrol

/datum/loadout_item/suit_store/main_gun/marine/laser_mg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_mg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/flamer
	name = "FL-84"
	desc = "Equipped with a mag harness, wide nozzle and hydrocannon. The FL-84 flamethrower is a simple and unsubtle weapon, used for area control and urban combat. \
	Excels at clearing out enclosed or fortified positions, but suffers from poor mobility and relatively limited range, making it of questionable use in open combat. \
	Uses back or gun mounted fuel tanks."
	req_desc = "Requires a suit with a Surt module."
	ui_icon = "m240"
	item_typepath = LOADOUT_ITEM_TGMC_FLAMER
	item_whitelist = list(/obj/item/clothing/suit/modular/tdf/heavy/surt = ITEM_SLOT_OCLOTHING)
	item_blacklist = list(/obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_pistol = ITEM_SLOT_SECONDARY)

/datum/loadout_item/suit_store/main_gun/marine/flamer/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	if(istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		return
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/large/X, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/flamer/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/shotgun
	name = "SH-35"
	desc = "Equipped with a mag harness, bayonet, angled grip and foldable stock. \
	The SH-35 is the most commonly used shotgun of the TGMC. With good mobility and handling, it has unparalleled close range power when using buckshot. Able to kill or maim all but the most heavily armored targets with a single well aimmed blast. \
	When using flechette rounds, it can provide surprisingly powerful long range damage with good penetration, although its low rate of fire means its sustained damage is relatively poor. \
	Uses 12 gauge shells."
	ui_icon = "t35"
	item_typepath = /obj/item/weapon/gun/shotgun/pump/t35/standard
	ammo_type = /obj/item/ammo_magazine/handful/buckshot
	secondary_ammo_type = /obj/item/ammo_magazine/handful/buckshot

/datum/loadout_item/suit_store/main_gun/marine/shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(istype(secondary) && !isholster(wearer.belt))
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/shotgun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/auto_shotgun
	name = "SH-15"
	desc = "Equipped with a mag harness, barrel charger and underbarrel grenade launcher. \
	The SH-15 automatic shotgun has excellent mobility and handling, and offers powerful damage per shot. Its comparatively slow rate of fire means in a straight gunfight its overall damage output is somewhat lacking.\
	Uses 12-round 16 gauge magazines with slugs and flechette."
	ui_icon = "tx15"
	item_typepath = /obj/item/weapon/gun/rifle/standard_autoshotgun/standard
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/tx15_flechette

/datum/loadout_item/suit_store/main_gun/marine/auto_shotgun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine
	name = "Laser carbine"
	desc = "Equipped with a red dot sight and underbarrel grenade launcher. The TerraGov laser carbine is the high tech equivilent to the AR-18, with extremely good mobility and handling, and powerful medium range damage. \
	Variable firemodes gives it additional flexibility over its ballistic counterpart. Uses TE power cells that are shared across all TGMC laser weaponry."
	req_desc = "Requires a light armour suit."
	ui_icon = "tec"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/standard_marine_carbine/scout

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/laser_carbine/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine
	name = "AR-18-scout"
	desc = "Equipped with motion detector, extended barrel and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. \
	The motion detector on this example makes it excellent for scouting out enemy positions and tracking down hidden enemies. Uses 10x24mm caseless ammunition."
	req_desc = "Requires a light armour suit."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/scout
	item_whitelist = list(
		/obj/item/clothing/suit/modular/tdf/light/shield = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/tdf/light/shield_overclocked = ITEM_SLOT_OCLOTHING,
	)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/scout_carbine/enhanced
	name = "AR-18-S+"
	desc = "Equipped with motion detector, extended barrel and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. \
	The motion detector on this example makes it excellent for scouting out enemy positions and tracking down hidden enemies. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield
	name = "SMG-25 & shield"
	desc = "Equipped with a mag harness, recoil compensator and gyroscopic stabilizer, and comes with a TL-172 defensive shield. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. \
	The defensive shield provides incredible resilience, allowing the user to soak up tremendous amounts of damage while they or their team mates push the enemy. \
	Generally used with Tyr heavy armor for maximum survivability. Uses 10x20mm caseless ammunition."
	ui_icon = "riot_shield"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness
	item_blacklist = list(/obj/item/jetpack_marine/heavy = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine, SLOT_L_HAND)
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/tool/weldingtool/largetank, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/smg_and_shield/enhanced
	name = "SMG-25+ & riot shield"
	desc = "Equipped with a mag harness, recoil compensator and gyroscopic stabilizer, and comes with a TL-172 defensive shield. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. \
	The defensive shield provides incredible resilience, allowing the user to soak up tremendous amounts of damage while they or their team mates push the enemy. \
	Generally used with Tyr heavy armor for maximum survivability. Uses standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/m25/ap

/datum/loadout_item/suit_store/main_gun/marine/standard_smg
	name = "SMG-25"
	desc = "Equipped with a mag harness, recoil compensator and gyroscopic stabilizer. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses 10x20mm caseless ammunition."
	ui_icon = "m25"
	item_typepath = /obj/item/weapon/gun/smg/m25/magharness

/datum/loadout_item/suit_store/main_gun/marine/standard_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/standard_smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(istype(wearer.belt, /obj/item/storage/belt))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/smg/m25/extended, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/standard_smg/enhanced
	name = "SMG-25+"
	desc = "Equipped with a mag harness, recoil compensator and gyroscopic stabilizer. SMG-25 submachinegun, is a large capacity smg, able to be be used effectively one or two handed. \
	Like all smgs, it has excellent mobility and handling, but has poor damage application at longer ranges. Uses standard and AP 10x20mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/smg/m25/ap

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle
	name = "BR-8"
	desc ="Equipped with a red dot sight, extended barrel and vertical grip. The BR-8 is a light specialized scout rifle, mostly used by light infantry and scouts. \
	It has great mobility and handling, excellent accuracy and perfect damage application at range. Combined with innate IFF and a variety of high powered ammo types, the BR-8 is a weapon to be feared.  \
	Takes specialized overpressured 10x28mm rounds."
	req_desc = "Requires a light armour suit."
	ui_icon = "tx8"
	item_typepath = /obj/item/weapon/gun/rifle/tx8/scout
	item_whitelist = list(
		/obj/item/clothing/suit/modular/tdf/light/shield = ITEM_SLOT_OCLOTHING,
		/obj/item/clothing/suit/modular/tdf/light/shield_overclocked = ITEM_SLOT_OCLOTHING,
	)
	purchase_cost = 100
	quantity = 2

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(istype(secondary) && !isholster(wearer.belt))
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/scout_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8/impact, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx8/impact, SLOT_IN_BELT)

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/suppressed_carbine
	name = "AR-18-Suppressed"
	desc = "Equipped with red dot sight, suppressor and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. \
	This suppressed variant is typically used for stealth operations, where its quiet firing and lack of tracers can give the user an edge over unsuspecting opponents. Uses 10x24mm caseless ammunition."
	ui_icon = "t18"
	item_typepath = /obj/item/weapon/gun/rifle/standard_carbine/suppressed

/datum/loadout_item/suit_store/main_gun/marine/suppressed_carbine/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/suppressed_carbine/enhanced
	name = "AR-18-Suppressed+"
	desc = "Equipped with red dot sight, suppressor and underbarrel grenade launcher. The AR-18 is the main weapon of the TGMC, offering excellent mobility and impressive close to medium range damage output. \
	Compared to the AR-12, it suffers from a comparatively smaller magazine size, and is less effective at longer range. \
	This suppressed variant is typically used for stealth operations, where its quiet firing and lack of tracers can give the user an edge over unsuspecting opponents. It uses a mix of standard and AP 10x24mm caseless ammunition."
	loadout_item_flags = NONE
	secondary_ammo_type = /obj/item/ammo_magazine/rifle/standard_carbine/ap

/datum/loadout_item/suit_store/main_gun/marine/suppressed_carbine/enhanced/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	return ..()

/datum/loadout_item/suit_store/main_gun/marine/mag_gl
	name = "GL-54"
	desc = "Equipped with a motion sensor. The GL-54 is a magazine fed, semi-automatic grenade launcher designed to shoot airbursting smart grenades. \
	A powerful support weapon, but unwieldy at close range where it can be easily overwhelmed. \
	Comes with a variety of 20mm grenade types."
	ui_icon = "tx54"
	purchase_cost = 75
	quantity = 2
	item_typepath = /obj/item/weapon/gun/rifle/tx54/motion_sensor

/datum/loadout_item/suit_store/main_gun/marine/mag_gl/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return ..()
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(istype(secondary) && !isholster(wearer.belt))
		wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/mirage, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/smoke/dense, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/smoke/acid, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/razor, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/mag_gl/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/smoke/acid, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/tx54/incendiary, SLOT_IN_BELT)

	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/binoculars, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/plasma_smg
	name = "PL-51"
	desc = "Unlocked for free with the Advanced SMG training perk. Equipped with a motion sensor, bayonet and vertical grip. The PL-51 plasma SMG is a powerful close range weapon, with great mobility and handling. \
	Has two firemodes, with a standard reflecting shot, or a more powerful AOE overcharged shot. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/smg/motion_sensor
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/marine/plasma_smg/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/plasma_smg/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/bullet/laser, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/bullet/laser, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/plasma_rifle
	name = "PL-38"
	desc = "Unlocked for free with the Advanced rifle training perk. Equipped with a red dot sight, bayonet and miniflamer. The PL-38 plasma rifle is a powerful heavy rifle, able to unleash significant damage at any range. \
	Has three firemodes, with a standard high ROF mode, a piercing shatter shot, or a melting blast mode. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/rifle/standard
	unlock_cost = 300
	purchase_cost = 90
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/marine/plasma_rifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/bullet/laser, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/bullet/laser, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/plasma_rifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/flamer_tank/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/plasma_cannon
	name = "PL-96"
	desc = "Unlocked for free with the Heavy weapon specialisation perk. Equipped with a magharness. The PL-96 plasma cannon is massive, cumbersome weapon, designed to unleash devastating damage against all targets. \
	Has three firemodes, with a plasma wave mode, that scales in damage against larger targets, a shatter blast mode, or an incendiary blast mode. Like all plasma weapons, it can rapidly build up heat and overheat, rendering it inoperable for a period if used incorrectly."
	ui_icon = "lasergun"
	item_typepath = /obj/item/weapon/gun/energy/lasgun/lasrifle/plasma/cannon/mag_harness
	unlock_cost = 400
	purchase_cost = 80
	quantity = 3
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE

/datum/loadout_item/suit_store/main_gun/marine/plasma_cannon/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/marine/plasma_cannon/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/bullet/laser, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/bullet/laser, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/marine/minigun
	name = "MG-100"
	desc = "A six barreled rotary machine gun, The ultimate in man-portable firepower, capable of laying down high velocity armor piercing rounds this thing will no doubt pack a punch."
	req_desc = "Requires a powerback for power and ammo."
	ui_icon = "minigun"
	item_typepath = LOADOUT_ITEM_TGMC_MINIGUN
	loadout_item_flags = NONE
	purchase_cost = 75
	quantity = 2
	item_whitelist = list(/obj/item/ammo_magazine/minigun_powerpack = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/marine/minigun/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

//notguns
/datum/loadout_item/suit_store/machete_shield
	name = "Machete & shield"
	desc = "A large leather scabbard carrying a M2132 machete. It can be strapped to the back, waist or armor. Extremely dangerous against human opponents - if you can get close enough. \
	The defensive shield provides incredible resilience, allowing the user to soak up tremendous amounts of damage while they or their team mates push the enemy."
	ui_icon = "machete"
	item_typepath = /obj/item/storage/holster/blade/machete/full_alt
	jobs_supported = list(SQUAD_MARINE)
	loadout_item_flags = NONE

/datum/loadout_item/suit_store/machete_shield/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	wearer.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine, SLOT_L_HAND)

	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/synaptizine, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/plastique, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/flashbang/stun, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/emp, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/machete_shield/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb, SLOT_IN_ACCESSORY)
