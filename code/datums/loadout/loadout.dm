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
	///The version of this loadout. This will can allow in the future to erase loadouts that are too old to work with the loadout saver system
	var/version = 1

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
		var/datum/item_representation/item_representation = item_list[slot_key]
		item = item_representation.instantiate_object()
		if(!user.equip_to_slot_if_possible(item, GLOB.slot_str_to_slot[slot_key], warning = FALSE))
			item.forceMove(source)

/**
 * This will read all items on the mob, and if the item is supported by the loadout maker, will save it in the corresponding slot
 * An item is supported if it's path
 */
/datum/loadout/proc/save_mob_loadout(mob/living/carbon/human/user)
	var/obj/item/item_in_slot
	var/item_representation_type
	for(var/slot_key in GLOB.visible_item_slot_list)
		item_in_slot = user.get_item_by_slot(GLOB.slot_str_to_slot[slot_key])
		if(!item_in_slot || !is_savable_in_loadout(item_in_slot.type))
			continue
		item_representation_type = item_representation_type(item_in_slot.type)
		item_list[slot_key] = new item_representation_type(item_in_slot)

/datum/loadout/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutViewer", name)
		ui.open()

/datum/loadout/ui_state(mob/user)
	return GLOB.always_state

/datum/loadout/ui_static_data(mob/user)
	var/data = list()
	data["items"] = prepare_items_data()
	var/list/loadout_data = list()
	loadout_data["job"] = job
	loadout_data["name"] = name
	data["loadout"] = list(loadout_data)
	return data

/datum/loadout/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("equipLoadout")
			if(TIMER_COOLDOWN_CHECK(ui.user, COOLDOWN_LOADOUT_EQUIPPED))
				to_chat(ui.user, "<span class='warning'>You already equipped a loadout recently!</span>")
				return
			TIMER_COOLDOWN_START(ui.user, COOLDOWN_LOADOUT_EQUIPPED, LOADOUT_COOLDOWN)
			equip_mob(ui.user, ui.user.loc)
			ui.close()
		if("deleteLoadout")
			ui.user.client.prefs.loadout_manager.delete_loadout(src)
			ui.close()


/datum/loadout/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/inventory),
	)

/datum/loadout/proc/prepare_items_data(mob/user)
	var/items_data = list()
	for (var/item_slot_key in GLOB.visible_item_slot_list)
		var/list/result = list()

		var/datum/item_representation/item_representation = item_list[item_slot_key]
		if (isnull(item_representation))
			result["icon"] = icon2base64(icon("icons/misc/empty.dmi", "empty"))
			items_data[item_slot_key] = result
			continue
		//This is costly, but this allows to have a pretty an accurate visualisation
		var/obj/item/item = item_representation.instantiate_object()
		var/image/standing = image(item.icon, item.icon_state)
		item.apply_custom(standing)
		item.apply_accessories(standing)
		var/icon/flat_icon = getFlatIcon(standing)
		result["icon"] = icon2base64(flat_icon)
		result["name"] = item.name
		qdel(item)

		items_data[item_slot_key] = result
	return items_data
