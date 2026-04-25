/**
 * This datum in charge with selecting wich loadout is currently being edited
 * It also contains a tgui to navigate beetween loadouts
 */
/datum/loadout_manager
	/**
	 * List of all loadouts. Format is list(list(loadout_job, loadout_name))
	 */
	var/list/loadouts_data = list()
	/// The host of the loadout_manager, aka from which loadout vendor are you managing loadouts
	var/loadout_vendor
	/// The version of the loadout manager
	var/version = CURRENT_LOADOUT_VERSION

///Remove the data of a loadout from the loadouts list
/datum/loadout_manager/proc/delete_loadout(mob/user, loadout_name, loadout_job)
	var/list/new_loadouts_data = list()
	for(var/loadout_data in loadouts_data)
		if(loadout_data[1] != loadout_job || loadout_data[2] != loadout_name)
			new_loadouts_data += list(loadout_data)
	loadouts_data = new_loadouts_data
	user.client?.prefs.save_loadout_list(loadouts_data, CURRENT_LOADOUT_VERSION)

///Add the name and the job of a datum/loadout into the list of all loadout data
/datum/loadout_manager/proc/add_loadout(datum/loadout/next_loadout)
	loadouts_data += list(list(next_loadout.job, next_loadout.name))

/datum/loadout_manager/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutManager")
		ui.open()

/datum/loadout_manager/ui_state(mob/user)
	return GLOB.human_adjacent_state

/datum/loadout_manager/ui_host()
	return loadout_vendor

/// Wrapper proc to set the host of our ui datum, aka the loadout vendor that's showing us the loadouts
/datum/loadout_manager/proc/set_host(_loadout_vendor)
	loadout_vendor = _loadout_vendor
	RegisterSignal(loadout_vendor, COMSIG_QDELETING, PROC_REF(close_ui))

/// Wrapper proc to handle loadout vendor being qdeleted while we have loadout manager opened
/datum/loadout_manager/proc/close_ui()
	SIGNAL_HANDLER
	ui_close()

/datum/loadout_manager/ui_data(mob/living/user)
	var/list/data = list()
	data["loadout_list"] = list()

	for(var/list/loadout_data as anything in loadouts_data)
		data["loadout_list"] += list(list(
			"job" = loadout_data[1],
			"name" = loadout_data[2],
		))
	return data

/datum/loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("saveLoadout")
			if(length(loadouts_data) >= MAXIMUM_LOADOUT * 2)
				to_chat(ui.user, span_warning("You've reached the maximum number of loadouts saved, please delete some before saving new ones"))
				return
			var/loadout_name = params["loadout_name"]
			if(isnull(loadout_name))
				return
			var/loadout_job = params["loadout_job"]
			for(var/loadout_data in loadouts_data)
				if(loadout_data[1] == loadout_job && loadout_data[2] == loadout_name)
					to_chat(ui.user, span_warning("Loadout [loadout_name] for [loadout_job] already exists. Try another name"))
					return
			var/datum/loadout/loadout = create_empty_loadout(loadout_name, loadout_job)
			loadout.save_mob_loadout(ui.user)
			ui.user.client.prefs.save_loadout(loadout)
			add_loadout(loadout)
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)
		if("edit_loadout_position")
			var/loadout_name = params["loadout_name"]
			var/loadout_job = params["loadout_job"]
			if(isnull(loadout_name) || isnull(loadout_job))
				return
			var/list/located_loadout
			for(var/list/loadout_data as anything in loadouts_data)
				if(loadout_data[1] == loadout_job && loadout_data[2] == loadout_name)
					located_loadout = loadout_data
					break
			if(isnull(located_loadout))
				return
			var/loadout_location = loadouts_data.Find(located_loadout)
			var/direction = params["direction"]
			if(!direction)
				return
			switch(direction)
				if("down")
					//return if it's going above the limit
					if(loadout_location == length(loadouts_data))
						return
					loadouts_data.Swap(loadout_location++, loadout_location)
				if("up")
					//return if it's the very bottom already
					if(loadout_location == 1)
						return
					loadouts_data.Swap(loadout_location--, loadout_location)
			return TRUE
		if("importLoadout")
			var/loadout_id = params["loadout_id"]
			if(isnull(loadout_id))
				return
			var/list/items = splittext(loadout_id, "//")
			if(length(items) != 3)
				to_chat(ui.user, span_warning("Wrong format!"))
				return
			var/datum/loadout/loadout = load_player_loadout(items[1], items[2], items[3])
			if(!istype(loadout))
				to_chat(ui.user, span_warning("Loadout not found!"))
				return
			if(!(loadout.version in GLOB.accepted_loadout_versions))
				to_chat(ui.user, span_warning("The loadouts was found but is from a past version, and cannot be imported."))
				return
			if(loadout.version != CURRENT_LOADOUT_VERSION)
				legacy_version_fix(loadout, params["loadout_name"], params["loadout_job"], ui)

			ui.user.client.prefs.save_loadout(loadout)
			add_loadout(loadout)
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)

		if("selectLoadout")
			if(TIMER_COOLDOWN_RUNNING(ui.user, COOLDOWN_LOADOUT_VISUALIZATION))
				return
			TIMER_COOLDOWN_START(ui.user, COOLDOWN_LOADOUT_VISUALIZATION, 1 SECONDS) //Anti spam cooldown
			var/job = params["loadout_job"]
			var/name = params["loadout_name"]
			if(isnull(name))
				return
			var/datum/loadout/loadout = ui.user.client.prefs.load_loadout(name, job)
			if(!loadout)
				to_chat(ui.user, span_warning("Error when loading this loadout"))
				delete_loadout(ui.user, name, job)
				CRASH("Fail to load loadouts")
			if(loadout.version != CURRENT_LOADOUT_VERSION)
				legacy_version_fix(loadout, name, job, ui)

			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)


/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	user.client?.prefs.save_loadout_list(loadouts_data, CURRENT_LOADOUT_VERSION)

///Recursive function to update attachment lists.
/datum/loadout_manager/proc/update_attachments(list/datum/item_representation/armor_module/attachments, version)
	for(var/datum/item_representation/armor_module/module AS in attachments)
		if(version < 13)
			if(ispath(module.item_type, /obj/item/armor_module/greyscale))
				module.item_type = text2path(splicetext("[module.item_type]", 24, 33, "armor"))
			module.colors = initial(module.item_type.greyscale_colors)
			if(!istype(module, /datum/item_representation/armor_module/armor) && !istype(module, /datum/item_representation/armor_module/colored))
				continue
			var/datum/item_representation/armor_module/new_module = new
			new_module.attachments = module.attachments
			new_module.item_type = module.item_type
			new_module.colors = module.colors
			attachments.Remove(module)
			attachments.Add(new_module)
		if(version < 14)
			if(ispath(module.item_type, /obj/item/armor_module/armor/cape))
				module.variant = NORMAL
				if(module.item_type == /obj/item/armor_module/armor/cape/kama)
					module.variant = CAPE_KAMA
				else if(module.item_type != /obj/item/armor_module/armor/cape)
					var/datum/item_representation/armor_module/new_cape = new
					new_cape.item_type = /obj/item/armor_module/armor/cape
					new_cape.attachments = module.attachments
					new_cape.colors = module.colors
					switch(module.item_type)
						if(/obj/item/armor_module/armor/cape/half)
							new_cape.variant = CAPE_HALF
						if(/obj/item/armor_module/armor/cape/scarf)
							new_cape.variant = CAPE_SCARF
						if(/obj/item/armor_module/armor/cape/short)
							new_cape.variant = CAPE_SHORT
						if(/obj/item/armor_module/armor/cape/short/classic)
							new_cape.variant = CAPE_SHORT_OLD
					attachments.Remove(module)
					attachments.Add(new_cape)
			if(ispath(module.item_type, /obj/item/armor_module/armor/cape_highlight))
				module.variant = CAPE_HIGHLIGHT_NONE
				if(module.item_type == /obj/item/armor_module/armor/cape_highlight/kama)
					module.variant = CAPE_KAMA
				else if(module.item_type != /obj/item/armor_module/armor/cape_highlight)
					var/datum/item_representation/armor_module/armor/new_highlight = new
					new_highlight.item_type = /obj/item/armor_module/armor/cape_highlight
					new_highlight.attachments = module.attachments
					new_highlight.colors = module.colors
					new_highlight.variant = CAPE_HIGHLIGHT_NONE
					switch(module.item_type)
						if(/obj/item/armor_module/armor/cape_highlight/half)
							new_highlight.variant = CAPE_HALF
						if(/obj/item/armor_module/armor/cape_highlight/scarf)
							new_highlight.variant = CAPE_SCARF
					attachments.Remove(module)
					attachments.Add(new_highlight)
			if(ispath(module.item_type, /obj/item/armor_module/armor/visor/marine/eva/skull))
				var/datum/item_representation/armor_module/armor/new_glyph = new
				new_glyph.item_type = /obj/item/armor_module/armor/visor_glyph
				module.attachments.Add(new_glyph)
			if(ispath(module.item_type, /obj/item/armor_module/armor/visor/marine/old/eva/skull))
				var/datum/item_representation/armor_module/armor/new_glyph = new
				new_glyph.item_type = /obj/item/armor_module/armor/visor_glyph/old
				module.attachments.Add(new_glyph)
/*
//REENABLE WHEN CONVERSION TIME
		if(version < 16)
			var/static/list/conversion_list = LEGACY_PALETTES_TO_NEW
			var/lookup_colors = conversion_list[module.colors]
			if(lookup_colors)
				module.colors = lookup_colors
*/

		update_attachments(module.attachments, version)

///Modifies a legacy loadout to make it valid for the current loadout version
/datum/loadout_manager/proc/legacy_version_fix(datum/loadout/loadout, loadout_name, loadout_job, datum/tgui/ui)
	var/datum/item_representation/hat/modular_helmet/helmet = loadout.item_list[slot_head_str]
	if(istype(helmet, /datum/item_representation/modular_helmet))
		if(loadout.version < 7)
			loadout.empty_slot(slot_head_str)
		if(loadout.version < 8)
			if("[helmet.item_type]" == "/obj/item/clothing/head/modular/m10x/tech" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/m10x/corpsman" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/m10x/standard")
				helmet.item_type = /obj/item/clothing/head/modular/m10x
		if(loadout.version < 10)
			helmet.colors = initial(helmet.item_type.greyscale_colors)
			for(var/datum/item_representation/armor_module/module AS in helmet.attachments)
				if(!istype(module, /datum/item_representation/armor_module))
					continue
				module.colors = initial(module.item_type.greyscale_colors)
		if(loadout.version < 11)
			var/datum/item_representation/modular_helmet/old_helmet = loadout.item_list[slot_head_str]
			var/datum/item_representation/hat/modular_helmet/new_helmet = new
			new_helmet.item_type = old_helmet.item_type
			new_helmet.bypass_vendor_check = old_helmet.bypass_vendor_check
			new_helmet.colors = old_helmet.greyscale_colors
			new_helmet.current_variant = old_helmet.current_variant
			new_helmet.attachments = old_helmet.attachments
			loadout.item_list[slot_head_str] = new_helmet
		if(loadout.version < 13)
			helmet.colors = initial(helmet.item_type.greyscale_colors)
		update_attachments(helmet.attachments, loadout.version)

	else if(helmet) //there used to be no specific representation for generic hats
		if(loadout.version < 11)
			var/datum/item_representation/old_hat = loadout.item_list[slot_head_str]
			var/datum/item_representation/hat/modular_helmet/new_hat = new
			if("[old_hat.item_type]" == "/obj/item/clothing/head/helmet/marine/robot")
				new_hat.item_type = /obj/item/clothing/head/modular/robot
			if("[old_hat.item_type]" == "/obj/item/clothing/head/helmet/marine/robot/light")
				new_hat.item_type = /obj/item/clothing/head/modular/robot/light
			if("[old_hat.item_type]" == "/obj/item/clothing/head/helmet/marine/robot/heavy")
				new_hat.item_type = /obj/item/clothing/head/modular/robot/heavy
			new_hat.bypass_vendor_check = old_hat.bypass_vendor_check
			new_hat.current_variant = "black"
			loadout.item_list[slot_head_str] = new_hat
		if(loadout.version < 13)
			helmet.colors = initial(helmet.item_type.greyscale_colors)
		update_attachments(helmet.attachments, loadout.version)
	var/datum/item_representation/armor_suit/modular_armor/armor = loadout.item_list[slot_wear_suit_str]
	if(istype(armor, /datum/item_representation/modular_armor))
		if(loadout.version < 7)
			loadout.empty_slot(slot_wear_suit_str)
		if(loadout.version < 8)
			if("[armor.item_type]" == "/obj/item/clothing/suit/modular/pas11x")
				armor.item_type = /obj/item/clothing/suit/modular/xenonauten
		if(loadout.version < 10)
			for(var/datum/item_representation/armor_module/module AS in armor.attachments)
				if(!istype(module, /datum/item_representation/armor_module))
					continue
				module.colors = initial(module.item_type.greyscale_colors)
		if(loadout.version < 11)
			var/datum/item_representation/modular_armor/old_armor = loadout.item_list[slot_wear_suit_str]
			var/datum/item_representation/armor_suit/modular_armor/new_armor = new
			new_armor.item_type = old_armor.item_type
			new_armor.bypass_vendor_check = old_armor.bypass_vendor_check
			new_armor.current_variant = old_armor.current_variant
			new_armor.attachments = old_armor.attachments
			loadout.item_list[slot_wear_suit_str] = new_armor
		if(loadout.version < 13)
			armor.colors = initial(armor.item_type.greyscale_colors)
		update_attachments(armor.attachments, loadout.version)
	else if(istype(armor, /datum/item_representation/suit_with_storage))
		if(loadout.version < 11)
			var/datum/item_representation/suit_with_storage/old_armor = loadout.item_list[slot_wear_suit_str]
			var/datum/item_representation/armor_suit/modular_armor/new_armor = new
			if("[old_armor.item_type]" == "/obj/item/clothing/suit/storage/marine/robot")
				new_armor.item_type = /obj/item/clothing/suit/modular/robot
			if("[old_armor.item_type]" == "/obj/item/clothing/suit/storage/marine/robot/light")
				new_armor.item_type = /obj/item/clothing/suit/modular/robot/light
			if("[old_armor.item_type]" == "/obj/item/clothing/suit/storage/marine/robot/heavy")
				new_armor.item_type = /obj/item/clothing/suit/modular/robot/heavy
			new_armor.bypass_vendor_check = old_armor.bypass_vendor_check
			new_armor.current_variant = "black"
			loadout.item_list[slot_wear_suit_str] = new_armor
		update_attachments(armor.attachments, loadout.version)
	else if(armor)
		update_attachments(armor.attachments, loadout.version)

	var/datum/item_representation/uniform_representation/uniform = loadout.item_list[slot_w_uniform_str]
	if(istype(uniform, /datum/item_representation/uniform_representation))
		if(loadout.version < 9)
			uniform.current_variant = null
			uniform.attachments = list()
		update_attachments(uniform.attachments, loadout.version)

	var/datum/item_representation/boot/footwear = loadout.item_list[slot_shoes_str]
	if(footwear)
		if(loadout.version < 11)
			if("[footwear.item_type]" == "/obj/item/clothing/shoes/marine/full")
				var/obj/item/clothing/shoes/marine/full/new_boots = new (loadout_vendor)
				loadout.item_list[slot_shoes_str] = new /datum/item_representation/boot(new_boots)
				qdel(new_boots)

/*
//REENABLE WHEN CONVERSION TIME
	if(loadout.version < 16)
		var/static/list/conversion_list = LEGACY_PALETTES_TO_NEW
		for(var/key in loadout.item_list)
			var/datum/item_representation/item = loadout.item_list[key]
			if(!item.colors)
				continue
			var/lookup_colors = conversion_list[item.colors]
			if(lookup_colors)
				item.colors = lookup_colors
			if(istype(item, /datum/item_representation/modular_armor))
				var/datum/item_representation/modular_armor/mod = item
				update_attachments(mod.attachments, loadout.version)
			else if(istype(item, /datum/item_representation/modular_helmet))
				var/datum/item_representation/modular_helmet/mod = item
				update_attachments(mod.attachments, loadout.version)
			else if(istype(item, /datum/item_representation/boot))
				var/datum/item_representation/boot/mod = item
				update_attachments(mod.attachments, loadout.version)
			else if(istype(item, /datum/item_representation/armor_suit))
				var/datum/item_representation/armor_suit/mod = item
				update_attachments(mod.attachments, loadout.version)
			else if(istype(item, /datum/item_representation/armor_module))
				var/datum/item_representation/armor_module/mod = item
				update_attachments(mod.attachments, loadout.version)
			else if(istype(item, /datum/item_representation/hat))
				var/datum/item_representation/hat/mod = item
				update_attachments(mod.attachments, loadout.version)
			else if(istype(item, /datum/item_representation/uniform_representation))
				var/datum/item_representation/uniform_representation/mod = item
				update_attachments(mod.attachments, loadout.version)
*/
	var/message_to_send = "Please note: The loadout code has been updated and due to that:"
	if(loadout.version < 7)
		message_to_send += "<br>any modular helmet/suit has been removed from it due to the transitioning of loadout version 6 to 7."
	if(loadout.version < 8)
		message_to_send += "<br>any PAS11 armor/M10x helmet has been removed from it due to the transitioning of loadout version 7 to 8(Xenonauten Addition)."
	if(loadout.version < 9)
		message_to_send += "<br>any uniforms have had their webbings/accessory removed due to the transitioning of loadout version 8 to 9."
	if(loadout.version < 10)
		message_to_send += "<br>any modular armor pieces and jaeger helmets have had their colors reset due to the new color/greyscale system. (version 19 to 10)"
	if(loadout.version < 11)
		message_to_send += "<br>Some boots, helmets and armour have had their internal storage refactored and some items may be removed from your loadout. (version 10 to 11)"
	if(loadout.version < 13)
		message_to_send += "<br>Due to hyperscaling armor, any colorable armor have had their colors set to default. (Version 11 to 13)"
/*
//REENABLE WHEN CONVERSION TIME
	if(loadout.version < 16)
		message_to_send += "<br>Armor Palettes have been completely overhauled. Legacy palette colors replaced with corresponding updated palette. (Version 16)"
*/
	loadout.version = CURRENT_LOADOUT_VERSION
	message_to_send += "<br>This loadout is now on version [loadout.version]"
	to_chat(ui.user, span_warning(message_to_send))

	delete_loadout(ui.user, loadout_name, loadout_job)
	ui.user.client.prefs.save_loadout(loadout)
	add_loadout(loadout)
