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
	var/list/list/datum/loadout_item/available_list = list()
	///Items available to be purchased
	var/list/list/datum/loadout_item/purchasable_list = list()

/datum/outfit_holder/New(new_role)
	. = ..()
	role = new_role
	loadout = new /datum/outfit/quick
	for(var/slot in GLOB.campaign_loadout_slots)
		available_list["[slot]"] = list()
		purchasable_list["[slot]"] = list()
		for(var/datum/loadout_item/loadout_item AS in GLOB.campaign_loadout_items_by_role[role])
			if(!loadout_item.name) //various parent types
				continue
			if(loadout_item.item_slot != slot)
				continue
			if(loadout_item.loadout_item_flags & LOADOUT_ITEM_DEFAULT_CHOICE)
				equip_loadout_item(loadout_item)
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
	loadout.equip(owner)
	for(var/slot in equipped_things)
		var/datum/loadout_item/thing_to_check = equipped_things["[slot]"]
		if(!thing_to_check)
			continue
		if(thing_to_check.quantity > 0)
			thing_to_check.quantity --
		thing_to_check.post_equip(owner, loadout, src)

///Adds a new loadout_item to the available list
/datum/outfit_holder/proc/unlock_new_option(datum/loadout_item/new_item)
	available_list["[new_item.item_slot]"] |= new_item
	purchasable_list["[new_item.item_slot]"] -= new_item

///Adds a new loadout_item to the purchasable list
/datum/outfit_holder/proc/allow_new_option(datum/loadout_item/new_item)
	if(!istype(new_item))
		return
	if(new_item in purchasable_list["[new_item.item_slot]"])
		return
	if(new_item in available_list["[new_item.item_slot]"])
		return
	purchasable_list["[new_item.item_slot]"] += new_item

///Removes loadout_item entirely from being equipped
/datum/outfit_holder/proc/remove_option(datum/loadout_item/removed_item)
	if(!istype(removed_item))
		return
	var/removed_item_slot = "[removed_item.item_slot]"
	available_list[removed_item_slot] -= removed_item
	purchasable_list[removed_item_slot] -= removed_item
	if(equipped_things[removed_item_slot] == removed_item)
		equip_loadout_item(available_list[removed_item_slot][1])
		return TRUE

///Tries to add a datum if valid
/datum/outfit_holder/proc/attempt_equip_loadout_item(datum/loadout_item/new_item)
	if(!new_item.item_checks(src))
		return FALSE
	equip_loadout_item(new_item)
	return TRUE

///Actually adds an item to a loadout
/datum/outfit_holder/proc/equip_loadout_item(datum/loadout_item/new_item)
	var/slot_bit = "[new_item.item_slot]"
	loadout_cost -= equipped_things[slot_bit]?.purchase_cost
	equipped_things[slot_bit] = new_item //adds the datum
	loadout_cost += equipped_things[slot_bit]?.purchase_cost

	switch(new_item.item_slot) //adds it to the loadout itself
		if(ITEM_SLOT_OCLOTHING)
			loadout.wear_suit = new_item?.item_typepath
		if(ITEM_SLOT_ICLOTHING)
			loadout.w_uniform = new_item?.item_typepath
		if(ITEM_SLOT_GLOVES)
			loadout.gloves = new_item?.item_typepath
		if(ITEM_SLOT_EYES)
			loadout.glasses = new_item?.item_typepath
		if(ITEM_SLOT_EARS)
			loadout.ears = new_item?.item_typepath
		if(ITEM_SLOT_MASK)
			loadout.mask = new_item?.item_typepath
		if(ITEM_SLOT_HEAD)
			loadout.head = new_item?.item_typepath
		if(ITEM_SLOT_FEET)
			loadout.shoes = new_item?.item_typepath
		if(ITEM_SLOT_ID)
			loadout.id = new_item?.item_typepath
		if(ITEM_SLOT_BELT)
			loadout.belt = new_item?.item_typepath
		if(ITEM_SLOT_BACK)
			loadout.back = new_item?.item_typepath
		if(ITEM_SLOT_R_POCKET)
			loadout.r_pocket = new_item?.item_typepath
		if(ITEM_SLOT_L_POCKET)
			loadout.l_pocket = new_item?.item_typepath
		if(ITEM_SLOT_SUITSTORE)
			loadout.suit_store = new_item?.item_typepath
		if(ITEM_SLOT_SECONDARY)
			loadout.secondary_weapon = new_item?.item_typepath
		else
			CRASH("Invalid item slot specified [slot_bit]")
	new_item.on_holder_equip(src)
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
		if(length(thing_to_check.item_whitelist) && !thing_to_check.whitelist_check(src))
			return FALSE
		if(length(thing_to_check.item_blacklist) && !thing_to_check.blacklist_check(src))
			return FALSE
