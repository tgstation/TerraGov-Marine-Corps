/datum/loadout_item/suit_store
	item_slot = ITEM_SLOT_SUITSTORE

/datum/loadout_item/suit_store/empty
	name = "no suit stored"
	desc = ""
	ui_icon = "empty"
	loadout_item_flags = LOADOUT_ITEM_ROUNDSTART_OPTION|LOADOUT_ITEM_DEFAULT_CHOICE
	jobs_supported = list()


/datum/loadout_item/suit_store/main_gun
	///Ammo type this gun will use
	var/ammo_type
	///alt ammo type for this gun
	var/secondary_ammo_type

/datum/loadout_item/suit_store/main_gun/New()
	. = ..()
	var/obj/item/weapon/gun/weapon_type = item_typepath
	if(!ammo_type)
		ammo_type = weapon_type::default_ammo_type
	if(!secondary_ammo_type)
		secondary_ammo_type = weapon_type::default_ammo_type

/datum/loadout_item/suit_store/main_gun/post_equip(mob/living/carbon/human/wearer, datum/outfit/quick/loadout, datum/outfit_holder/holder)
	. = ..()
	if(!ammo_type)
		return
	if(istype(wearer.belt, /obj/item/storage/belt))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BELT)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_BELT)
	if(istype(wearer.l_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_L_POUCH)
		wearer.equip_to_slot_or_del(new secondary_ammo_type, SLOT_IN_L_POUCH)
	if(istype(wearer.r_store, /obj/item/storage/pouch/magazine))
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
		wearer.equip_to_slot_or_del(new ammo_type, SLOT_IN_R_POUCH)
