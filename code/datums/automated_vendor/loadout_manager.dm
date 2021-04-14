/**
 * This datum in charge with selecting wich loadout is currently being edited
 * It also contains a tgui to navigate beetween loadout
 */
/datum/loadout_manager
	/// The loadout currently selected/modified
	var/datum/loadout/current_loadout
	/// A list of all standard marine loadouts
	var/list/marine_loadouts_list = list()
	/// A list of all engie loadouts
	var/list/engie_loadouts_list = list()
	/// A list of all medic loadouts
	var/list/medic_loadouts_list = list()
	/// A list of all squad leader loadouts
	var/list/leader_loadouts_list = list()

///Copy the loadouts from the client, for easy access
/datum/loadout_manager/proc/load_loadouts(client/c)
	for(var/datum/loadout/loadout AS in c.prefs.loadouts_list)
		switch(loadout.job)
			if(MARINE_LOADOUT)
				marine_loadouts_list[loadout.name] = loadout
			if(ENGIE_LOADOUT)
				engie_loadouts_list[loadout.name] = loadout
			if(MEDIC_LOADOUT)
				medic_loadouts_list[loadout.name] = loadout
			if(LEADER_LOADOUT)
				leader_loadouts_list[loadout.name] = loadout

///Save all the loadouts into the client prefs and then the save file
/datum/loadout_manage/proc/save_loadouts_list(client/c)
	var/list/all_loadouts = list()
	all_loadouts += marine_loadouts_list
	all_loadouts += engie_loadouts_list
	all_loadouts += medic_loadouts_list
	all_loadouts += leader_loadouts_list
	c.prefs.loadouts_list = all_loadouts
	c.prefs.save_loadouts_list()




