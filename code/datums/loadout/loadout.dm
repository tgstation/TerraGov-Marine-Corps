/datum/loadout
	///Name of the loadout
	var/name = ""
	///The job associated with the loadout
	var/job = SQUAD_MARINE
	/**
	 * Assoc list of all visible items composing this loadout
	 * the key of each item is a slot key
	 * each item of the list is a datum/item_representation
	 */
	var/list/item_list
	///The host of the loadout_manager, aka from which loadout vendor are you managing loadouts
	var/loadout_vendor
	///The version of this loadout
	var/version = CURRENT_LOADOUT_VERSION

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
			return (flags_equip_slot & ITEM_SLOT_MASK)
		if(slot_back_str)
			return (flags_equip_slot & ITEM_SLOT_BACK)
		if(slot_wear_suit_str)
			return (flags_equip_slot & ITEM_SLOT_OCLOTHING)
		if(slot_gloves_str)
			return (flags_equip_slot & ITEM_SLOT_GLOVES)
		if(slot_shoes_str)
			return (flags_equip_slot & ITEM_SLOT_FEET)
		if(slot_belt_str)
			if(!(flags_equip_slot & ITEM_SLOT_BELT))
				return FALSE
			if(!item_list[SLOT_W_UNIFORM])
				return FALSE
			return TRUE
		if(slot_glasses_str)
			return (flags_equip_slot & ITEM_SLOT_EYES)
		if(slot_head_str)
			return (flags_equip_slot & ITEM_SLOT_HEAD)
		if(slot_w_uniform_str)
			return (flags_equip_slot & ITEM_SLOT_ICLOTHING)
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
		if(slot_ear_str)
			return (flags_equip_slot & ITEM_SLOT_EARS)
		if(slot_wear_id_str)
			return (flags_equip_slot & ITEM_SLOT_ID)
		if(slot_r_hand_str)
			return TRUE
		if(slot_l_hand_str)
			return TRUE
	return FALSE //Unsupported slot

/**
 * This will equip the mob with all items of the loadout.
 * user : the mob to dress
 */
/datum/loadout/proc/equip_mob(mob/user)
	var/obj/item/item
	for(var/slot_key in item_list)
		var/datum/item_representation/item_representation = item_list[slot_key]
		item = item_representation.instantiate_object()
		if(!item)
			continue
		user.equip_to_slot_if_possible(item, GLOB.slot_str_to_slot[slot_key], warning = FALSE)

/**
 * This will read all items on the mob, and if the item is supported by the loadout maker, will save it in the corresponding slot
 * An item is supported if it's path
 */
/datum/loadout/proc/save_mob_loadout(mob/living/carbon/human/user, admin_loadout = FALSE)
	var/obj/item/item_in_slot
	var/item2representation_type
	for(var/slot_key in GLOB.visible_item_slot_list)
		item_in_slot = user.get_item_by_slot(GLOB.slot_str_to_slot[slot_key])
		if(!item_in_slot)
			continue
		item2representation_type = item2representation_type(item_in_slot.type)
		item_list[slot_key] = new item2representation_type(item_in_slot, src)
	if(!admin_loadout)
		return
	for(var/slot_key in GLOB.additional_admin_item_slot_list)
		item_in_slot = user.get_item_by_slot(GLOB.slot_str_to_slot[slot_key])
		if(!item_in_slot)
			continue
		item2representation_type = item2representation_type(item_in_slot.type)
		item_list[slot_key] = new item2representation_type(item_in_slot, src)

/datum/loadout/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutViewer", name)
		ui.open()

/datum/loadout/ui_state(mob/user)
	return GLOB.human_adjacent_state

/datum/loadout/ui_host()
	return loadout_vendor

/datum/loadout/ui_static_data(mob/user)
	var/list/data = list()
	data["items"] = prepare_items_data()
	var/list/loadout_data = list()
	loadout_data["job"] = job
	loadout_data["name"] = name
	data["loadout"] = list(loadout_data)
	return data

/datum/loadout/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("equipLoadout")
			if(TIMER_COOLDOWN_CHECK(ui.user, COOLDOWN_LOADOUT_EQUIPPED))
				to_chat(ui.user, "<span class='warning'>The vendor is still reloading</span>")
				return
			var/datum/loadout_seller/seller = new
			if(seller.try_to_equip_loadout(src, ui.user))
				TIMER_COOLDOWN_START(ui.user, COOLDOWN_LOADOUT_EQUIPPED, 30 SECONDS)
			ui.close()
		if("deleteLoadout")
			ui.user.client.prefs.loadout_manager.delete_loadout(ui.user, name, job)
			ui.close()


/datum/loadout/ui_assets(mob/user)
	. = ..() || list()
	. += get_asset_datum(/datum/asset/simple/inventory)

///Create all the necessary data (icons, name of items) from the loadout, and put them in an assoc list to be used by tgui
/datum/loadout/proc/prepare_items_data(mob/user)
	var/list/items_data = list()
	for (var/item_slot_key in GLOB.visible_item_slot_list)
		var/datum/item_representation/item_representation = item_list[item_slot_key]
		if (item_representation)
			items_data[item_slot_key] = item_representation.get_tgui_data()
			continue
		var/list/result = list()
		result["icons"] = list(list(
			"icon" = icon2base64(icon("icons/misc/empty.dmi", "empty")),
			"translateX" = NO_OFFSET,
			"translateY" = NO_OFFSET,
			"scale" = NO_SCALING,
			))
		items_data[item_slot_key] = result
	return items_data
