/datum/loadout
	///Name of the loadout
	var/name = ""
	///The job associated with the loadout
	var/job = MARINE_LOADOUT
	/**
	 * Assoc list of all items composing this loadout
	 * the key of each item is a slot key
	 * each item of the list is a datum/item_representation
	 */
	var/list/item_list

/**
 * Add an item to this loadout, will return TRUE if everything went ok
 * item_type the type of the item we want to add
 * item_slot where the item should be added
 */
/datum/loadout/proc/add_item(item_type, slot)
	if(!can_equip_to_slot(item_type, slot))
		return FALSE
	var/item_representation_type = item_representation_type(item_type)
	var/datum/item_representation/item_representation = new item_representation_type
	item_representation.copy_vars_from_item_type(item_type)
	item_list[slot] = item_representation
	return TRUE

///Empty a slot of the loadout
/datum/loadout/proc/empty_slot(slot)
	item_list[slot] = null

///Check if the item can go to the specified slot
/datum/loadout/proc/can_equip_to_slot(item_type, slot)
	var/obj/item/item = item_type
	var/flags_equip_slot = initial(item.flags_equip_slot)
	var/w_class = initial(item.w_class)
	switch(slot)
		if(slot_wear_mask_str)
			if(!(flags_equip_slot & ITEM_SLOT_MASK))
				return FALSE
			return TRUE
		if(slot_back_str)
			if(!(flags_equip_slot & ITEM_SLOT_BACK))
				return FALSE
			return TRUE
		if(slot_wear_suit_str)
			if(!(flags_equip_slot & ITEM_SLOT_OCLOTHING))
				return FALSE
			return TRUE
		if(slot_gloves_str)
			if(!(flags_equip_slot & ITEM_SLOT_GLOVES))
				return FALSE
			return TRUE
		if(slot_shoes_str)
			if(!(flags_equip_slot & ITEM_SLOT_FEET))
				return FALSE
			return TRUE
		if(slot_belt_str)
			if(!(flags_equip_slot & ITEM_SLOT_BELT))
				return FALSE
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			return TRUE
		if(slot_glasses_str)
			if(!(flags_equip_slot & ITEM_SLOT_EYES))
				return FALSE
			return TRUE
		if(slot_head_str)
			if(!(flags_equip_slot & ITEM_SLOT_HEAD))
				return FALSE
			return TRUE
		if(slot_w_uniform_str)
			if(!(flags_equip_slot & ITEM_SLOT_ICLOTHING))
				return FALSE
			return TRUE
		if(slot_l_store_str)
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			if(flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(w_class <= 2 || (flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
		if(slot_r_store_str)
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			if(flags_equip_slot & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if(w_class <= 2 || (flags_equip_slot & ITEM_SLOT_POCKET))
				return TRUE
		if(slot_s_store_str)
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			var/obj/item/jumpsuit = item_list[SLOT_W_UNIFORM]
			if(!jumpsuit.allowed)
				return FALSE
			if(jumpsuit.allowed.Find(item_type))
				return TRUE
			return FALSE
	return FALSE //Unsupported slot

/**
 * This will equipe the mob with all items of the loadout.
 * If a slot is already full, or an item doesn't fit the slot, the item will fall on the ground
 * user : the mob to dress
 * source : The turf where all rejected items will fall
 */
/datum/loadout/proc/equip_mob(mob/user, turf/source)
	var/obj/item/item
	for(var/slot_key in GLOB.visible_item_slot_list)
		if(!item_list[slot_key])
			continue
		item = get_item_from_item_representation(item_list[slot_key])
		if(!user.equip_to_slot_if_possible(item, GLOB.slot_str_to_slot[slot_key], warning = FALSE))
			item.forceMove(source)

/**
 * This will read all items on the mob, and if the item is supported by the loadout maker, will save it in the corresponding slot
 * An item is supported if it's path
 */
///datum/loadout/proc/save_mob_loadout(mob/user)

/datum/loadout/ui_interact(mob/user, datum/tgui/ui)
	prepare_items_data(user)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "LoadoutMaker", name)
		ui.open()

/datum/loadout/ui_static_data(mob/user)
	var/data = list()
	data["items"] = prepare_items_data()
	return data

/datum/loadout/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("equipLoadout")
			equip_mob(ui.user, ui.user.loc)

/datum/loadout/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inventory),
	)

/datum/loadout/proc/prepare_items_data(mob/user)
	var/items_data = list()
	for (var/item_slot_key in GLOB.visible_item_slot_list)
		var/list/result = list()

		var/datum/item_representation/item = item_list[item_slot_key]
		if (isnull(item))
			result["icon"] = icon2base64(icon("icons/misc/empty.dmi", "empty"))
			items_data[item_slot_key] = result
			continue

		var/obj/item/item_type = item.item_type
		result["icon"] = icon2base64(icon(initial(item_type.icon), initial(item_type.icon_state)))
		result["name"] = initial(item_type.name)

		items_data[item_slot_key] = result
	return items_data


///Return a new empty loayout
/proc/create_empty_loadout(name = "Default", job = MARINE_LOADOUT)
	var/datum/loadout/default = new
	default.name = name
	default.job = job
	default.item_list = list()
	default.add_item(/obj/item/clothing/under/marine/standard ,slot_w_uniform_str)
	default.add_item(/obj/item/clothing/shoes/marine ,slot_shoes_str)
	return default
