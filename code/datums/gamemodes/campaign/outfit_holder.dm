//holds a record of loadout_item datums, and the actual loadout itself
/datum/outfit_holder
	var/role
	///Assoc list of loadout_items by slot
	var/list/datum/loadout_item/equipped_things = list()
	///The actual loadout to be equipped
	var/datum/outfit/quick/loadout
	///Cost of the loadout to equip
	var/loadout_cost = 0
	///Items available to be equipped
	var/list/list/datum/loadout_item/available_list = list() //only used for ui data purposes
	///Items available to be purchased
	var/list/list/datum/loadout_item/purchasable_list = list() //only used for ui data purposes

/datum/outfit_holder/New(new_role)
	. = ..()
	role = new_role
	loadout = new /datum/outfit/quick
	for(var/slot in GLOB.campaign_loadout_slots)
		available_list["[slot]"] = list()
		for(var/datum/loadout_item/loadout_item AS in GLOB.campaign_loadout_items_by_role[role])
			if(loadout_item.item_slot != slot)
				continue
			if(loadout_item.loadout_item_flags & LOADOUT_ITEM_DEFAULT_CHOICE)
				equipped_things["[slot]"] = loadout_item
			if(loadout_item.loadout_item_flags & LOADOUT_ITEM_ROUNDSTART_OPTION)
				available_list["[loadout_item.item_slot]"] += loadout_item
				continue
			if(loadout_item.loadout_item_flags & LOADOUT_ITEM_ROUNDSTART_UNLOCKABLE)
				purchasable_list["[loadout_item.item_slot]"] += loadout_item

/datum/outfit_holder/Destroy(force, ...)
	equipped_things = null
	available_list = null
	purchasable_list = null
	QDEL_NULL(loadout)
	return ..()

///Equips the loadout to a mob
/datum/outfit_holder/proc/equip_loadout(mob/living/carbon/human/owner)
	for(var/slot in equipped_things)
		var/datum/loadout_item/thing_to_check = equipped_things["[slot]"]
		if(!thing_to_check)
			continue
		if(thing_to_check.quantity > 0)
			thing_to_check.quantity --
	loadout.equip(owner)
	//insert post equip magic here

///Adds a new loadout_item to the available list
/datum/outfit_holder/proc/unlock_new_option(datum/loadout_item/new_item)
	if(new_item in available_list["[new_item.item_slot]"])
		return
	available_list["[new_item.item_slot]"] += new_item
	purchasable_list["[new_item.item_slot]"] -= new_item

///Adds a new loadout_item to the purchasable list
/datum/outfit_holder/proc/allow_new_option(datum/loadout_item/new_item)
	if(new_item in purchasable_list["[new_item.item_slot]"])
		return
	if(new_item in available_list["[new_item.item_slot]"])
		return
	purchasable_list["[new_item.item_slot]"] += new_item

///Tries to add a datum if valid
/datum/outfit_holder/proc/attempt_equip_loadout_item(datum/loadout_item/new_item)
	if(!new_item.item_checks(src))
		return FALSE
	return equip_loadout_item(new_item)

///Actually adds an item to a loadout
/datum/outfit_holder/proc/equip_loadout_item(datum/loadout_item/new_item)
	var/slot_bit = "[new_item.item_slot]"
	loadout_cost -= equipped_things[slot_bit].purchase_cost
	equipped_things[slot_bit] = new_item //adds the datum
	loadout_cost += equipped_things[slot_bit].purchase_cost
	//currently the below doesn't give any feedback, so unneeded here
	//check_full_loadout() //checks all datums to see if this makes anything invalid

	switch(new_item.item_slot) //adds it to the loadout itself
		if(ITEM_SLOT_OCLOTHING)
			loadout.wear_suit = new_item.item_typepath
		if(ITEM_SLOT_ICLOTHING)
			loadout.w_uniform = new_item.item_typepath
		if(ITEM_SLOT_GLOVES)
			loadout.gloves = new_item.item_typepath
		if(ITEM_SLOT_EYES)
			loadout.glasses = new_item.item_typepath
		if(ITEM_SLOT_EARS)
			loadout.ears = new_item.item_typepath
		if(ITEM_SLOT_MASK)
			loadout.mask = new_item.item_typepath
		if(ITEM_SLOT_HEAD)
			loadout.head = new_item.item_typepath
		if(ITEM_SLOT_FEET)
			loadout.shoes = new_item.item_typepath
		if(ITEM_SLOT_ID)
			loadout.id = new_item.item_typepath
		if(ITEM_SLOT_BELT)
			loadout.belt = new_item.item_typepath
		if(ITEM_SLOT_BACK)
			loadout.back = new_item.item_typepath
		if(ITEM_SLOT_R_POCKET)
			loadout.r_store = new_item.item_typepath
		if(ITEM_SLOT_L_POCKET)
			loadout.l_store = new_item.item_typepath
		if(ITEM_SLOT_SUITSTORE)
			loadout.suit_store = new_item.item_typepath
		else
			CRASH("Invalid item slot specified [slot_bit]")
	return TRUE

///scans the entire loadout for validity
/datum/outfit_holder/proc/check_full_loadout()
	. = TRUE
	for(var/slot in equipped_things)
		var/datum/loadout_item/thing_to_check = equipped_things["[slot]"]
		if(!thing_to_check)
			continue
		if(thing_to_check.quantity == 0)
			return FALSE
			//mark visually/early return here
		if(length(thing_to_check.item_whitelist) && !thing_to_check.whitelist_check(src))
			//mark visually here
			return FALSE
		if(length(thing_to_check.item_blacklist) && !thing_to_check.blacklist_check(src))
			//mark visually here
			return FALSE

//2 procs below may be unneeded

//returns ther datum, not the item. Currently unused
///Returns an item type in a particular loadout slot
/datum/outfit_holder/proc/find_item(slot)
	return equipped_things["[slot]"]

///Fully populates the loadout
/datum/outfit_holder/proc/populate_loadout() //this might be redundant, maybe just use it for the initial default since we don't need the checks in that case
	loadout.wear_suit = equipped_things["[ITEM_SLOT_OCLOTHING]"]
	loadout.w_uniform = equipped_things["[ITEM_SLOT_ICLOTHING]"]
	loadout.gloves = equipped_things["[ITEM_SLOT_GLOVES]"]
	loadout.glasses = equipped_things["[ITEM_SLOT_EYES]"]
	loadout.ears = equipped_things["[ITEM_SLOT_EARS]"]
	loadout.mask = equipped_things["[ITEM_SLOT_MASK]"]
	loadout.head = equipped_things["[ITEM_SLOT_HEAD]"]
	loadout.shoes = equipped_things["[ITEM_SLOT_FEET]"]
	loadout.id = equipped_things["[ITEM_SLOT_ID]"]
	loadout.belt = equipped_things["[ITEM_SLOT_BELT]"]
	loadout.back = equipped_things["[ITEM_SLOT_BACK]"]
	loadout.r_store = equipped_things["[ITEM_SLOT_R_POCKET]"]
	loadout.l_store = equipped_things["[ITEM_SLOT_L_POCKET]"]
	loadout.suit_store = equipped_things["[ITEM_SLOT_SUITSTORE]"]

////////////////////////////LOADOUT ITSELF////////////////

/*
we can just have a single loadout per person (per role probably) and load the relevant vars from the loadout_item datum
no safety check on the outfit itself, we'll let that all get handled externally
WILL need a 'validate entire outfit' proc somewhere though
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
