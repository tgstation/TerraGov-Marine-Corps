//represents an equipable item
/datum/loadout_item
	///Item name
	var/name = "item name here"
	///Item desc
	var/desc = "item desc here"
	///Typepath of the actual item this datum represents
	var/item_typepath
	///inventory slot it is intended to go into
	var/item_slot
	///Cost to unlock this option
	var/unlock_cost = 0
	///Cost to use this option
	var/purchase_cost = 0
	///Job types that this perk is available to. no list implies this works for any job
	var/list/jobs_supported
	///assoc list by slot of items required for this to be equipped
	var/list/item_whitelist
	///assoc list by slot of items blacklisted for this to be equipped
	var/list/item_blacklist
	//do we need a post equip gear list?

///Attempts to add an item to a loadout
/datum/loadout_item/proc/attempt_add_loadout_item(datum/outfit/quick/loadout)
	if(length(item_whitelist) && !whitelist_check(loadout))
		return
	if(length(item_blacklist) && !blacklist_check(loadout))
		return
	apply_loadout_item(loadout)

///Actually adds an item to a loadout
/datum/loadout_item/proc/apply_loadout_item(datum/outfit/quick/loadout)
	var/slot_bit = item_slot
	switch(slot_bit) //note, might need to make this new_item, not the item type path, so we can ref cost and other details. Unless we load that somewhere else?
		if(ITEM_SLOT_OCLOTHING)
			loadout.wear_suit = item_typepath
		if(ITEM_SLOT_ICLOTHING)
			loadout.w_uniform = item_typepath
		if(ITEM_SLOT_GLOVES)
			loadout.gloves = item_typepath
		if(ITEM_SLOT_EYES)
			loadout.glasses = item_typepath
		if(ITEM_SLOT_EARS)
			loadout.ears = item_typepath
		if(ITEM_SLOT_MASK)
			loadout.mask = item_typepath
		if(ITEM_SLOT_HEAD)
			loadout.head = item_typepath
		if(ITEM_SLOT_FEET)
			loadout.shoes = item_typepath
		if(ITEM_SLOT_ID)
			loadout.id = item_typepath
		if(ITEM_SLOT_BELT)
			loadout.belt = item_typepath
		if(ITEM_SLOT_BACK)
			loadout.back = item_typepath
		if(ITEM_SLOT_R_POCKET)
			loadout.r_store = item_typepath
		if(ITEM_SLOT_L_POCKET)
			loadout.l_store = item_typepath
		if(ITEM_SLOT_SUITSTORE)
			loadout.suit_store = item_typepath
		else
			CRASH("Invalid item slot specified [item_slot]")
	//do post equip stuff here probs, or when?

///checks if a loadout has required whitelist items
/datum/loadout_item/proc/whitelist_check(datum/outfit/quick/loadout)
	for(var/slot in item_whitelist)
		var/obj/item/thing_to_check = find_item(slot, loadout)
		if(!thing_to_check || thing_to_check.type != item_whitelist[slot])
			return FALSE
	return TRUE

///Checks if a loadout has any blacklisted items
/datum/loadout_item/proc/blacklist_check(datum/outfit/quick/loadout)
	for(var/slot in item_blacklist)
		var/obj/item/thing_to_check = find_item(slot, loadout)
		if(thing_to_check?.type == item_blacklist[slot])
			return FALSE
	return TRUE

///Returns an item type in a particular loadout slot
/datum/loadout_item/proc/find_item(slot_bit, datum/outfit/quick/loadout)
	switch(slot_bit)
		if(ITEM_SLOT_OCLOTHING)
			. = loadout.wear_suit
		if(ITEM_SLOT_ICLOTHING)
			. = loadout.w_uniform
		if(ITEM_SLOT_GLOVES)
			. = loadout.gloves
		if(ITEM_SLOT_EYES)
			. = loadout.glasses
		if(ITEM_SLOT_EARS)
			. = loadout.ears
		if(ITEM_SLOT_MASK)
			. = loadout.mask
		if(ITEM_SLOT_HEAD)
			. = loadout.head
		if(ITEM_SLOT_FEET)
			. = loadout.shoes
		if(ITEM_SLOT_ID)
			. = loadout.id
		if(ITEM_SLOT_BELT)
			. = loadout.belt
		if(ITEM_SLOT_BACK)
			. = loadout.back
		if(ITEM_SLOT_R_POCKET)
			. = loadout.r_store
		if(ITEM_SLOT_L_POCKET)
			. = loadout.l_store
		if(ITEM_SLOT_SUITSTORE)
			. = loadout.suit_store
		else
			CRASH("Invalid item slot specified [item_slot]")

/*
we can just have a single loadout per person (per role probably) and load the relevant vars from the loadout_item datum
no safety check on the outfit itself, we'll let that all get handled externally
Have to devise a way to populate all the post equip shit

//Base TGMC marine outfit
/datum/outfit/quick/test
	jobtype = "Squad Marine"
	ears = /obj/item/radio/headset/mainship/marine
	w_uniform = /obj/item/clothing/under/marine/black_vest
	shoes = /obj/item/clothing/shoes/marine/full
	wear_suit = /obj/item/clothing/suit/modular/xenonauten/heavy/shield
	gloves = /obj/item/clothing/gloves/marine
	mask = /obj/item/clothing/mask/gas
	head = /obj/item/clothing/head/modular/m10x
	r_store = /obj/item/storage/pouch/firstaid/combat_patrol
	l_store = /obj/item/storage/pouch/grenade/combat_patrol
	back = /obj/item/storage/backpack/marine/satchel
	suit_store = /obj/item/weapon/gun/rifle/standard_assaultrifle/rifleman
	belt = /obj/item/storage/belt/marine/t12

/datum/outfit/quick/test/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat, SLOT_IN_HEAD)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/combat_advanced, SLOT_IN_HEAD)

	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/gauze, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/stack/medical/heal_pack/ointment, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/isotonic, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/quickclot, SLOT_IN_SUIT)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/hypospray/autoinjector/dylovene, SLOT_IN_SUIT)

	H.equip_to_slot_or_del(new /obj/item/weapon/shield/riot/marine/deployable, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/packet/p10x24mm, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/ammo_magazine/pistol/standard_heavypistol, SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/weapon/gun/pistol/standard_heavypistol/tactical(H), SLOT_IN_BACKPACK)
	H.equip_to_slot_or_del(new /obj/item/storage/box/MRE, SLOT_IN_BACKPACK)

	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/sticky, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade, SLOT_IN_ACCESSORY)
	H.equip_to_slot_or_del(new /obj/item/explosive/grenade/incendiary, SLOT_IN_ACCESSORY)

**/
