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
			loadouts_list += create_empty_loadout("Much")
			loadouts_list += create_empty_loadout("muhhdf", "engie")
		current_loadout = loadouts_list[1]
	return current_loadout

/datum/loadout_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LoadoutManager")
		ui.open()

/datum/loadout_manager/ui_state(mob/user)
	return GLOB.always_state
		

/datum/loadout_manager/ui_data(mob/user)
	var/data = list()
	data["loadout_list"] = loadouts_list
	return data

/datum/loadout_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

/datum/loadout_manager/ui_close(mob/user)
	. = ..()
	user.client.prefs.save_loadout_manager()




