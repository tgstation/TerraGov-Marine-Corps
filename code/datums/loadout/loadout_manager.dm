/**
 * This datum in charge with selecting wich loadout is currently being edited
 * It also contains a tgui to navigate beetween loadouts
 */
/datum/loadout_manager
	/// The data sent to tgui
	var/loadouts_data = list()
	/// The host of the loadout_manager, aka from which loadout vendor are you managing loadouts
	var/loadout_vendor 
	/// The version of the loadout manager
	var/version = 1

///Remove a loadout from the list.
/datum/loadout_manager/proc/delete_loadout(loadout_name, loadout_job)
	for(var/i = 1 ; i <= length(loadouts_data), i += 2)
		if(loadout_job == loadouts_data[i] && loadout_name == loadouts_data[i+1])
			loadouts_data -= loadouts_data[i+1]
			loadouts_data -= loadouts_data[i]
			return

///Add one loadout to the loadout data
/datum/loadout_manager/proc/add_loadout(datum/loadout/next_loadout)
	loadouts_data += next_loadout.job
	loadouts_data += next_loadout.name

/datum/loadout_manager/ui_interact(mob/living/user, datum/tgui/ui)
	if(!(user.job.title in GLOB.loadout_job_supported))
		to_chat(ui.user, "<span class='warning'>Only squad members can use this vendor!</span>")
		return
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

/datum/loadout_manager/ui_static_data(mob/living/user)
	. = ..()
	var/data = list()
	data["job"] = user.job.title
	var/list/loadouts_data_tgui = list()
	for(var/i = 1 ; i <= length(loadouts_data), i += 2)
		var/next_loadout_data = list()
		next_loadout_data["job"] = loadouts_data[i]
		next_loadout_data["name"] = loadouts_data[i+1]
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
	var/mob/living/user = ui.user
	switch(action)
		if("saveLoadout")
			var/loadout_name = params["loadout_name"]
			if(isnull(loadout_name))
				return
			var/datum/loadout/loadout = create_empty_loadout(loadout_name, user.job.title)
			loadout.save_mob_loadout(ui.user)
			ui.user.client.prefs.save_loadout(loadout)
			add_loadout(loadout)
			update_static_data(ui.user, ui)
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)
		if("selectLoadout")
			var/name = params["loadout_name"]
			if(isnull(name))
				return
			var/datum/loadout/loadout = ui.user.client.prefs.load_loadout(name, user.job.title)
			if(!loadout)
				to_chat(ui.user, "<span class='warning'>Error when loading this loadout</span>")
				delete_loadout(name, user.job.title)
				CRASH("Fail to load loadouts")
			loadout.loadout_vendor = loadout_vendor
			loadout.ui_interact(ui.user)
			

/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	user.client?.prefs.save_loadout_manager()
