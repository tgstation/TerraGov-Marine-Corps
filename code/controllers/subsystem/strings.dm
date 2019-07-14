SUBSYSTEM_DEF(strings)
	name = "Strings"
	init_order = INIT_ORDER_STRINGS
	flags = SS_NO_FIRE|SS_NO_INIT

	var/list/list/externally_loaded_lists = list()

/datum/controller/subsystem/strings/proc/get_list_from_file(file)
	if(!isnull(externally_loaded_lists[file]))
		return externally_loaded_lists[file]
	return externally_loaded_lists[file] = file2list("strings/[file].txt")
