//List of all visible and accessible slot on loadouts
GLOBAL_LIST_INIT(visible_item_slot_list, list(
	slot_head_str,
	slot_back_str,
	slot_wear_mask_str,
	slot_glasses_str,
	slot_w_uniform_str,
	slot_wear_suit_str,
	slot_gloves_str,
	slot_shoes_str,
	slot_s_store_str,
	slot_belt_str,
	slot_l_store_str,
	slot_r_store_str,
))

/datum/loadout
	///Name of the loadout
	var/name = ""
	/** 
	 * Assoc list of all items composing this loadout
	 * the key of each item is a slot key 
	 * each item of the list is a obj/item
	 */
	var/list/item_list

/**
 * Add an item to this loadout, will return TRUE if everything went ok
 * item_added the item to add
 * item_slot where the item should be added
 */
/datum/loadout/proc/add_item(obj/item/item_added, slot)
	if(can_equip_to_slot(item_added, slot))
		item_list[slot] = item_added
		return TRUE

///Empty a slot of the loadout
/datum/loadout/proc/empty_slot(slot)
	item_list[slot] = null

///Check if the item can go to the specified slot
/datum/loadout/proc/can_equip_to_slot(obj/item/item_added, slot)
	switch(slot)
		if(slot_wear_mask_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_MASK))
				return FALSE
			return TRUE
		if(slot_back_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_BACK))
				return FALSE
			return TRUE
		if(slot_wear_suit_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_OCLOTHING))
				return FALSE
			return TRUE
		if(slot_gloves_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_GLOVES))
				return FALSE
			return TRUE
		if(slot_shoes_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_FEET))
				return FALSE
			return TRUE
		if(slot_belt_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_BELT))
				return FALSE
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			return TRUE
		if(slot_glasses_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_EYES))
				return FALSE
			return TRUE
		if(slot_head_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_HEAD))
				return FALSE
			return TRUE
		if(slot_w_uniform_str)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_ICLOTHING))
				return FALSE
			return TRUE
		if(slot_l_store_str)
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			if(item_added.flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(item_added.w_class <= 2 || (item_added.flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
		if(slot_r_store_str)
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			if(item_added.flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(item_added.w_class <= 2 || (item_added.flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
		if(slot_s_store_str)
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			var/obj/item/jumpsuit = item_list[SLOT_W_UNIFORM]
			if(!jumpsuit.allowed)
				return FALSE
			if(is_type_in_list(item_added, jumpsuit.allowed) )
				return TRUE
			return FALSE
	return FALSE //Unsupported slot

///Return a new empty loayout
/proc/create_empty_loadout(name = "Default")
	var/datum/loadout/empty = new
	empty.name = name
	empty.item_list = list()
	empty.item_list[slot_w_uniform_str] = new /obj/item/clothing/under/marine/standard
	empty.item_list[slot_shoes_str] = new /obj/item/clothing/shoes/marine
	return empty
