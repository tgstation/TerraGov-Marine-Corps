/**
 * This datum in charge with selecting wich loadout is currently being edited
 * It also contains a tgui to navigate beetween loadout
 */
/datum/loadout_manager
	/// The loadout currently selected/modified
	var/datum/loadout/current_loadout
	/// A list of all loadouts, categorized by job
	var/list/loadouts_lists = list()

///Copy the loadouts from the client, for easy access
/datum/loadout_manager/proc/load_loadouts(client/c)
	loadouts_lists = create_empty_loadout_list()
	for(var/job_key in c.prefs.loadouts_list)
		var/list/loadout_list_by_job = loadouts_lists[job_key]
		for(var/datum/loadout/loadout AS in loadout_list_by_job)
			loadouts_lists[job_key][loadout.name] = loadout
	if(!length(loadouts_lists[MARINE_LOADOUT]))
		loadouts_lists[MARINE_LOADOUT] += create_empty_loadout("Default")
	current_loadout = loadouts_lists[MARINE_LOADOUT][1]


///Save all the loadouts into the client prefs and then the save file
/datum/loadout_manager/proc/save_loadouts_list(client/c)
	var/list/all_loadouts = list()
	all_loadouts += loadouts_lists[MARINE_LOADOUT]
	all_loadouts += loadouts_lists[ENGIE_LOADOUT]
	all_loadouts += loadouts_lists[MEDIC_LOADOUT]
	all_loadouts += loadouts_lists[SMARTGUNNER_LOADOUT]
	all_loadouts += loadouts_lists[LEADER_LOADOUT]
	c?.prefs.loadouts_list = all_loadouts
	c?.prefs.save_loadouts_list()

/datum/loadout_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutManager")
		ui.open()

/datum/loadout_manager/ui_state(mob/user)
	return GLOB.always_state

/datum/loadout_manager/ui_data(mob/user)
	var/data = list()
	data["loadout_lists"] = loadouts_lists
	return data

/datum/loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("SelectLoadout")
			var/job = params["loadout_job"]
			var/name = params["loadout_name"]
			current_loadout = loadouts_lists[job][name]

/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	save_loadouts_list(user.client)




