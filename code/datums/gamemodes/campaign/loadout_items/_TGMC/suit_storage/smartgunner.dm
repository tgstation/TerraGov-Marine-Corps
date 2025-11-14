/datum/loadout_item/suit_store/main_gun/smartgunner
	jobs_supported = list(SQUAD_SMARTGUNNER)

/datum/loadout_item/suit_store/main_gun/smartgunner/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/smokebomb/cloak, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/explosive/grenade/m15, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

/datum/loadout_item/suit_store/main_gun/smartgunner/smartmachinegun
	name = "SG-29"
	desc = "Equipped with a motion sensor and laser sight. The SG-29 is the TGMC's current standard IFF-capable medium machine gun. \
	It has good mobility for a machinegun, and is extremely effective on the move. Its innate IFF, good damage application and attached motion sensor makes it a powerful support weapon. \
	Has somewhat poor falloff however, and although it has an excellent capacity, has slow reloading. It uses 10x26mm caseless ammunition. \
	Requires special training and it cannot turn off IFF. It uses 10x26mm ammunition."
	ui_icon = "sg29"
	item_typepath = /obj/item/weapon/gun/rifle/standard_smartmachinegun/patrol
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE

/datum/loadout_item/suit_store/main_gun/smartgunner/smartmachinegun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/smartgunner/smart_minigun
	name = "SG-85"
	desc = "Equipped with a motion sensor. The SG-85 is a monstrous IFF minigun, able to unleash an incredible torrent of bullets with a tremendous capacity thanks to its back mounted ammo supply. \
	With excellent armor penetration and minimal falloff, the SG-85 is a supreme support weapon, able to effective apply damage at any range, causing hideous amounts of shrapnel to anyone it doesn't kill."
	req_desc = "Requires a powerback for power and ammo. It uses 10x26mm caseless ammunition"
	ui_icon = "minigun_sg"
	item_typepath = /obj/item/weapon/gun/minigun/smart_minigun/motion_detector
	item_whitelist = list(/obj/item/ammo_magazine/minigun_powerpack/smartgun = ITEM_SLOT_BACK)

/datum/loadout_item/suit_store/main_gun/smartgunner/smart_minigun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(loadout.belt == /obj/item/storage/belt/sparepouch)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/smart_minigun, SLOT_IN_BELT)

/datum/loadout_item/suit_store/main_gun/smartgunner/smarttargetrifle
	name = "SG-62"
	desc = "Equipped with a motio sensor and spotting rifle. The SG-62 is a IFF precision rifle that has accurate, long range stopping power combined with the utility of its attached spotting rifle. \
	The spotting rifle can use a variety of ammo types to suit a variety of situations, but the gun has relatively poor mobility and handling. Good for the smartgunner that favors precision over volume of fire. \
	It uses high velocity 10x27mm caseless ammunition and 12x66mm ammunition for the underslung rifle."
	ui_icon = "smartgun"
	item_typepath = /obj/item/weapon/gun/rifle/standard_smarttargetrifle/motion

/datum/loadout_item/suit_store/main_gun/smartgunner/smarttargetrifle/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!isstorageobj(wearer.back))
		return
	if(isholster(wearer.belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_BACKPACK)
	else
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_BACKPACK)
	if(!istype(wearer.back, /obj/item/storage/backpack/marine/satchel))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)
		wearer.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_BACKPACK)

/datum/loadout_item/suit_store/main_gun/smartgunner/smarttargetrifle/role_post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	wearer.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new /obj/item/tool/extinguisher/mini, SLOT_IN_ACCESSORY)

	var/datum/loadout_item/secondary/gun/secondary = holder.equipped_things["[ITEM_SLOT_SECONDARY]"]
	if(!istype(secondary) || isstorageobj(wearer.back) || (isholster(wearer.belt) && !istype(wearer.belt, /obj/item/storage/holster/m25)))
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/highimpact, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/incendiary, SLOT_IN_ACCESSORY)
		wearer.equip_to_slot_or_del(new /obj/item/ammo_magazine/rifle/standard_spottingrifle/tungsten, SLOT_IN_ACCESSORY)
		return
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)
	wearer.equip_to_slot_or_del(new secondary.secondary_weapon_ammo, SLOT_IN_ACCESSORY)

