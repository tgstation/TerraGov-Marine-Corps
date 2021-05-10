/**
 * This datum in charge with selecting wich loadout is currently being edited
 * It also contains a tgui to navigate beetween loadouts
 */
/datum/loadout_manager
	/// The loadout currently selected/modified
	var/datum/loadout/current_loadout
	/// A list of all loadouts
	var/list/loadouts_list = list()

/datum/loadout_manager/proc/get_current_loadout()
	if(!current_loadout)
		if(!length(loadouts_list))
			loadouts_list += create_empty_loadout()
		current_loadout = loadouts_list[1]
	return current_loadout

/datum/loadout_manager/proc/prepare_loadouts_data()
	var/loadouts_data = list()
	var/next_loadout_data = list()
	for(var/datum/loadout/next_loadout AS in loadouts_list)
		next_loadout_data = list()
		next_loadout_data["job"] = next_loadout.job
		next_loadout_data["name"] = next_loadout.name
		loadouts_data += list(next_loadout_data)
	return loadouts_data

/datum/loadout_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutManager")
		ui.open()

/datum/loadout_manager/ui_state(mob/user)
	return GLOB.always_state

/datum/loadout_manager/ui_data(mob/user)
	var/data = list()
	data["loadout_list"] = prepare_loadouts_data()
	data["items"] = current_loadout?.prepare_items_data()
	return data

/datum/loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("saveLoadout")
			var/job = params["loadout_job"]
			var/loadout_name = params["loadout_name"]
			if(isnull(loadout_name))
				return
			current_loadout = create_empty_loadout(loadout_name, job)
			loadouts_list += current_loadout
			ui.update_static_data()
		if("selectLoadout")
			var/job = params["loadout_job"]
			var/name = params["loadout_name"]
			if(isnull(name))
				return
			for(var/datum/loadout/next_loadout AS in loadouts_list)
				if(next_loadout.name == name && next_loadout.job == job)
					current_loadout = next_loadout
					break
			ui.update_static_data()
				

/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	user.client.prefs.save_loadout_manager()




