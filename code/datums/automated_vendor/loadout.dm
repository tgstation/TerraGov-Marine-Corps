/datum/loadout
	///Name of the loadout
	var/name = ""
	/** 
	 * Assoc list of all items composing this loadout
	 * the key of each item is a datum/item_slot 
	 * each item of the list is a obj/item
	 */
	var/list/item_list

/**
 * Add an item to this loadout, will return TRUE if everything went ok
 * item_added the item to add
 * item_slot where the item should be added
 */
/datum/loadout/proc/add_item(obj/item/item_added, datum/item_slot/slot)
	if(can_equip_to_slot(item_added, slot))
		item_list[slot] = item_added
		return TRUE

///Empty a slot of the loadout
/datum/loadout/proc/empty_slot(datum/item_slot/slot)
	item_list[slot] = null

///Check if the item can go to the specified slot
/datum/loadout/proc/can_equip_to_slot(obj/item/item_added, datum/item_slot/slot)
	switch(slot.item_slot)
		if(SLOT_WEAR_MASK)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_MASK))
				return FALSE
			return TRUE
		if(SLOT_BACK)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_BACK))
				return FALSE
			return TRUE
		if(SLOT_WEAR_SUIT)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_OCLOTHING))
				return FALSE
			return TRUE
		if(SLOT_GLOVES)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_GLOVES))
				return FALSE
			return TRUE
		if(SLOT_SHOES)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_FEET))
				return FALSE
			return TRUE
		if(SLOT_BELT)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_BELT))
				return FALSE
			if(!item_list[/datum/item_slot/jumpsuit])
				return FALSE
			return TRUE
		if(SLOT_GLASSES)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_EYES))
				return FALSE
			return TRUE
		if(SLOT_HEAD)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_HEAD))
				return FALSE
			return TRUE
		if(SLOT_W_UNIFORM)
			if(!(item_added.flags_equip_slot & ITEM_SLOT_ICLOTHING))
				return FALSE
			return TRUE
		if(SLOT_L_STORE)
			if(!item_list[/datum/item_slot/jumpsuit])
				return FALSE
			if(item_added.flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(item_added.w_class <= 2 || (item_added.flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
		if(SLOT_R_STORE)
			if(!item_list[/datum/item_slot/jumpsuit])
				return FALSE
			if(item_added.flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(item_added.w_class <= 2 || (item_added.flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
		if(SLOT_S_STORE)
			if(!item_list[/datum/item_slot/jumpsuit])
				return FALSE
			var/obj/item/jumpsuit = item_list[/datum/item_slot/jumpsuit]
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
	empty.item_list[ITEM_SLOT_KEY_JUMPSUIT] = new /obj/item/clothing/under/marine/standard
	empty.item_list[ITEM_SLOT_KEY_FEET] = new /obj/item/clothing/shoes/marine
	return empty
