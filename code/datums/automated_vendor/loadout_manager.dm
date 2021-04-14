/**
 * This datum in charge with selecting wich loadout is currently being edited
 * It also contains a tgui to navigate beetween loadout
 */
/datum/loadout_manager
	/// The loadout currently selected/modified
	var/datum/loadout/current_loadout
	/// The currently selected job type
	var/selected_job_type = MARINE_LOADOUT
	/// An assoc list of assoc list of all loadouts, categorized by job
	var/list/loadouts_lists = list()
	/// A simple list of loadout for the selected job, required by tgui to work
	var/list/loadout_simple_list = list()


///Generate a clean default loadout_manager
/datum/loadout_manager/proc/generate_default()
	loadouts_lists = create_default_loadout_list()
	current_loadout = loadouts_lists[MARINE_LOADOUT][loadouts_lists[MARINE_LOADOUT][1]]

/datum/loadout_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutManager")
		prepare_data()
		ui.open()

/datum/loadout_manager/ui_state(mob/user)
	return GLOB.always_state

/datum/loadout_manager/proc/prepare_data()
	loadout_simple_list = list()
	var/length = length(loadouts_lists[selected_job_type])
	var/list/small_list = loadouts_lists[selected_job_type]
	for(var/i in 1 to length)
		loadout_simple_list += small_list[small_list[i]]
		

/datum/loadout_manager/ui_data(mob/user)
	var/data = list()
	data["loadout_list"] = loadout_simple_list
	data["job_type"] = selected_job_type
	return data

/datum/loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("SelectLoadout")
			var/job = params["loadout_job"]
			var/name = params["loadout_name"]
			current_loadout = loadouts_lists[job][name]
		if("SelectJobType")
			selected_job_type = params["job_type"]
			prepare_data()

/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	user.client.prefs.save_loadout_manager()




