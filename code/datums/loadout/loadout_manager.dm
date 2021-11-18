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
	RegisterSignal(loadout_vendor, COMSIG_PARENT_QDELETING, .proc/close_ui)

/// Wrapper proc to handle loadout vendor being qdeleted while we have loadout manager opened
/datum/loadout_manager/proc/close_ui()
	SIGNAL_HANDLER
	ui_close()

/datum/loadout_manager/ui_data(mob/living/user)
	. = ..()
	var/data = list()
	var/list/loadouts_data_tgui = list()
	for(var/list/loadout_data in loadouts_data)
		var/next_loadout_data = list()
		next_loadout_data["job"] = loadout_data[1]
		next_loadout_data["name"] = loadout_data[2]
		loadouts_data_tgui += list(next_loadout_data)
	data["loadout_list"] = loadouts_data_tgui
	return data

/datum/loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(TIMER_COOLDOWN_CHECK(ui.user, COOLDOWN_LOADOUT_VISUALIZATION))
		return
	TIMER_COOLDOWN_START(ui.user, COOLDOWN_LOADOUT_VISUALIZATION, 1 SECONDS) //Anti spam cooldown
	switch(action)
		if("saveLoadout")
			if(length(loadouts_data) >= MAXIMUM_LOADOUT * 2)
				to_chat(ui.user, span_warning("You've reached the maximum number of loadouts saved, please delete some before saving new ones"))
				return
			var/loadout_name = params["loadout_name"]
			if(isnull(loadout_name))
				return
			var/loadout_job = params["loadout_job"]
			var/datum/loadout/loadout = create_empty_loadout(loadout_name, loadout_job)
			loadout.save_mob_loadout(ui.user)
			ui.user.client.prefs.save_loadout(loadout)
			add_loadout(loadout)
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)
		if("importLoadout")
			var/loadout_id = params["loadout_id"]
			if(isnull(loadout_id))
				return
			var/list/items = splittext_char(loadout_id, "//")
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
				var/datum/item_representation/modular_helmet/helmet = loadout.item_list[slot_head_str]
				if(istype(helmet, /datum/item_representation/modular_helmet))
					if(loadout.version < 7)
						loadout.empty_slot(slot_head_str)
					if(loadout.version < 8)
						if("[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/tech" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/corpsman" ||  "[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/standard")
							helmet.item_type = /obj/item/clothing/head/modular/marine/m10x
					if(loadout.version < 10)
						helmet.greyscale_colors = initial(helmet.item_type.greyscale_colors)
						for(var/datum/item_representation/armor_module/colored/module AS in helmet.attachments)
							if(!istype(module, /datum/item_representation/armor_module/colored))
								continue
							module.greyscale_colors = initial(module.item_type.greyscale_colors)
				var/datum/item_representation/modular_armor/armor = loadout.item_list[slot_wear_suit_str]
				if(istype(armor, /datum/item_representation/modular_armor))
					if(loadout.version < 7)
						loadout.empty_slot(slot_wear_suit_str)
					if(loadout.version < 8)
						if("[armor.item_type]" == "/obj/item/clothing/suit/modular/pas11x")
							armor.item_type = /obj/item/clothing/suit/modular/xenonauten
					if(loadout.version < 10)
						for(var/datum/item_representation/armor_module/colored/module AS in armor.attachments)
							if(!istype(module, /datum/item_representation/armor_module/colored))
								continue
							module.greyscale_colors = initial(module.item_type.greyscale_colors)
				var/datum/item_representation/uniform_representation/uniform = loadout.item_list[slot_w_uniform_str]
				if(istype(uniform, /datum/item_representation/uniform_representation))
					if(loadout.version < 9)
						uniform.current_variant = null
						uniform.attachments = list()
				var/message_to_send = "Please note: The loadout code has been updated and due to that:"
				if(loadout.version < 7)
					message_to_send += "<br>any modular helmet/suit has been removed from it due to the transitioning of loadout version 6 to 7."
				if(loadout.version < 8)
					message_to_send += "<br>any PAS11 armor/M10x helmet has been removed from it due to the transitioning of loadout version 7 to 8(Xenonauten Addition)."
				if(loadout.version < 9)
					message_to_send += "<br>any uniforms have had their webbings/accessory removed due to the transitioning of loadout version 8 to 9."
				if(loadout.version < 10)
					message_to_send += "<br>any modular armor pieces and jaeger helmets have had their colors reset due to the new color/greyscale system. (version 9 to 10)"
				loadout.version = CURRENT_LOADOUT_VERSION
				message_to_send += "<br>This loadout is now on version [loadout.version]"
				to_chat(ui.user, span_warning(message_to_send))
				var/job = params["loadout_job"]
				var/name = params["loadout_name"]
				delete_loadout(ui.user, name, job)
				ui.user.client.prefs.save_loadout(loadout)
				add_loadout(loadout)
			ui.user.client.prefs.save_loadout(loadout)
			add_loadout(loadout)
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)
		if("selectLoadout")
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
				var/datum/item_representation/modular_helmet/helmet = loadout.item_list[slot_head_str]
				if(istype(helmet, /datum/item_representation/modular_helmet))
					if(loadout.version < 7)
						loadout.empty_slot(slot_head_str)
					if(loadout.version < 8)
						if("[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/tech" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/corpsman" || "[helmet.item_type]" == "/obj/item/clothing/head/modular/marine/m10x/standard")
							helmet.item_type = /obj/item/clothing/head/modular/marine/m10x
					if(loadout.version < 10)
						helmet.greyscale_colors = initial(helmet.item_type.greyscale_colors)
						for(var/datum/item_representation/armor_module/colored/module AS in helmet.attachments)
							if(!istype(module, /datum/item_representation/armor_module/colored))
								continue
							module.greyscale_colors = initial(module.item_type.greyscale_colors)
				var/datum/item_representation/modular_armor/armor = loadout.item_list[slot_wear_suit_str]
				if(istype(armor, /datum/item_representation/modular_armor))
					if(loadout.version < 7)
						loadout.empty_slot(slot_wear_suit_str)
					if(loadout.version < 8)
						if("[armor.item_type]" == "/obj/item/clothing/suit/modular/pas11x")
							armor.item_type = /obj/item/clothing/suit/modular/xenonauten
					if(loadout.version < 10)
						for(var/datum/item_representation/armor_module/colored/module AS in armor.attachments)
							if(!istype(module, /datum/item_representation/armor_module/colored))
								continue
							module.greyscale_colors = initial(module.item_type.greyscale_colors)
				var/datum/item_representation/uniform_representation/uniform = loadout.item_list[slot_w_uniform_str]
				if(istype(uniform, /datum/item_representation/uniform_representation))
					if(loadout.version < 9)
						uniform.current_variant = null
						uniform.attachments = list()
				var/message_to_send = "Please note: The loadout code has been updated and due to that:"
				if(loadout.version < 7)
					message_to_send += "<br>any modular helmet/suit has been removed from it due to the transitioning of loadout version 6 to 7."
				if(loadout.version < 8)
					message_to_send += "<br>any PAS11 armor/M10x helmet has been removed from it due to the transitioning of loadout version 7 to 8(Xenonauten Addition)."
				if(loadout.version < 9)
					message_to_send += "<br>any uniforms have had their webbings/accessory removed due to the transitioning of loadout version 8 to 9."
				if(loadout.version < 10)
					message_to_send += "<br>any modular armor pieces and jaeger helmets have had their colors reset due to the new color/greyscale system. (version 9 to 10)"
				loadout.version = CURRENT_LOADOUT_VERSION
				message_to_send += "<br>This loadout is now on version [loadout.version]"
				to_chat(ui.user, span_warning(message_to_send))
				delete_loadout(ui.user, name, job)
				ui.user.client.prefs.save_loadout(loadout)
				add_loadout(loadout)
				to_chat(ui.user, span_warning("Please note: The loadout code has been updated and as such any modular helmet/suit has been removed from it due to the transitioning of loadout versions. Any future modular helmet/suit saves should have no problem being saved."))
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)


/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	user.client?.prefs.save_loadout_list(loadouts_data, CURRENT_LOADOUT_VERSION)
