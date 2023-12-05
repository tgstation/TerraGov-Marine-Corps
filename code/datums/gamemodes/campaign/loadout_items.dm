#define campaign_loadout_slots list(ITEM_SLOT_OCLOTHING, ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_EYES, ITEM_SLOT_EARS, \
ITEM_SLOT_MASK, ITEM_SLOT_HEAD, ITEM_SLOT_FEET, ITEM_SLOT_ID, ITEM_SLOT_BELT, ITEM_SLOT_BACK, ITEM_SLOT_R_POCKET, ITEM_SLOT_L_POCKET, ITEM_SLOT_SUITSTORE)

//represents an equipable item
//Are singletons
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
/datum/loadout_item/proc/attempt_add_loadout_item(datum/outfit_holder/outfit_holder)
	if(length(item_whitelist) && !whitelist_check(outfit_holder))
		return FALSE
	if(length(item_blacklist) && !blacklist_check(outfit_holder))
		return FALSE
	return TRUE

///checks if a loadout has required whitelist items
/datum/loadout_item/proc/whitelist_check(datum/outfit_holder/outfit_holder)
	for(var/slot in item_whitelist)
		var/type_to_check = outfit_holder.equipped_things[slot].item_typepath
		if(!type_to_check || type_to_check != item_whitelist[slot])
			return FALSE
	return TRUE

///Checks if a loadout has any blacklisted items
/datum/loadout_item/proc/blacklist_check(datum/outfit_holder/outfit_holder)
	for(var/slot in item_blacklist)
		var/type_to_check = outfit_holder.equipped_things[slot].item_typepath
		if(type_to_check == item_blacklist[slot])
			return FALSE
	return TRUE

//example use
/datum/loadout_item/suit_slot
	item_slot = ITEM_SLOT_OCLOTHING

/datum/loadout_item/suit_slot/heavy_surt
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	jobs_supported = list(SQUAD_MARINE)

/datum/loadout_item/helmet
	item_slot = ITEM_SLOT_HEAD

/datum/loadout_item/helmet/heavy_surt
	name = "item name here"
	desc = "item desc here"
	item_typepath = /obj/item/clothing/head/modular/m10x/surt
	jobs_supported = list(SQUAD_MARINE)
	item_whitelist = list(
		ITEM_SLOT_OCLOTHING = /obj/item/clothing/suit/modular/xenonauten/heavy/surt
	)

//holds a record of loadout_item datums, and the actual loadout itself
/datum/outfit_holder
	///Assoc list of loadout_items by slot
	var/list/datum/loadout_item/equipped_things = list()
	///The actual loadout to be equipped
	var/datum/outfit/quick/loadout
	///Cost of the loadout to equip
	var/loadout_cost = 0

/datum/outfit_holder/New()
	. = ..()
	loadout = new /datum/outfit/quick
	for(var/slot in campaign_loadout_slots)
		equipped_things[slot] = null

/datum/outfit_holder/Destroy(force, ...)
	equipped_things = null
	QDEL_NULL(loadout)
	return ..()

///Equips the loadout to a mob
/datum/outfit_holder/proc/equip_loadout(mob/living/carbon/human/owner)
	loadout.equip(owner)
	//insert post equip magic here

///Tries to add a datum if valid
/datum/outfit_holder/proc/attempt_add_loadout_item(datum/loadout_item/new_item)
	if(!new_item.attempt_add_loadout_item())
		return FALSE
	return add_loadout_item(new_item)

///Actually adds an item to a loadout
/datum/outfit_holder/proc/add_loadout_item(datum/loadout_item/new_item)
	var/slot_bit = new_item.item_slot
	loadout_cost -= equipped_things[slot_bit].purchase_cost
	equipped_things[slot_bit] = new_item //adds the datum
	loadout_cost += equipped_things[slot_bit].purchase_cost
	check_full_loadout() //checks all datums to see if this makes anything invalid

	switch(slot_bit) //adds it to the loadout itself
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
		var/datum/loadout_item/thing_to_check = equipped_things[slot]
		if(!thing_to_check)
			continue
		if(length(thing_to_check.item_whitelist) && !thing_to_check.whitelist_check(src))
			//mark visually here
			. = FALSE
		if(length(thing_to_check.item_blacklist) && !thing_to_check.blacklist_check(src))
			//mark visually here
			. = FALSE

//2 procs below may be unneeded

//returns ther datum, not the item. Currently unused
///Returns an item type in a particular loadout slot
/datum/outfit_holder/proc/find_item(slot)
	return equipped_things[slot]

///Fully populates the loadout
/datum/outfit_holder/proc/populate_loadout() //this might be redundant, maybe just use it for the initial default since we don't need the checks in that case
	loadout.wear_suit = equipped_things[ITEM_SLOT_OCLOTHING]
	loadout.w_uniform = equipped_things[ITEM_SLOT_ICLOTHING]
	loadout.gloves = equipped_things[ITEM_SLOT_GLOVES]
	loadout.glasses = equipped_things[ITEM_SLOT_EYES]
	loadout.ears = equipped_things[ITEM_SLOT_EARS]
	loadout.mask = equipped_things[ITEM_SLOT_MASK]
	loadout.head = equipped_things[ITEM_SLOT_HEAD]
	loadout.shoes = equipped_things[ITEM_SLOT_FEET]
	loadout.id = equipped_things[ITEM_SLOT_ID]
	loadout.belt = equipped_things[ITEM_SLOT_BELT]
	loadout.back = equipped_things[ITEM_SLOT_BACK]
	loadout.r_store = equipped_things[ITEM_SLOT_R_POCKET]
	loadout.l_store = equipped_things[ITEM_SLOT_L_POCKET]
	loadout.suit_store = equipped_things[ITEM_SLOT_SUITSTORE]

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
