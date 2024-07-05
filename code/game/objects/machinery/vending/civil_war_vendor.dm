//Civilwar vendors

GLOBAL_LIST_INIT(civilwar_loadouts, init_civilwar_loadouts())

/proc/init_civilwar_loadouts() //List of all loadouts in civil_war_loadouts.dm
	. = list()
	var/list/loadout_list = list(
		/datum/outfit/quick/civilwar/bluecoat,
		/datum/outfit/quick/civilwar/redcoat,
	)

	for(var/X in loadout_list)
		.[X] = new X

/obj/machinery/quick_vendor/civilwar
	categories = list(
		"Bluecoat"
	)

/obj/machinery/quick_vendor/civilwar/redcoat
	categories = list(
		"Redcoat",
	)

/obj/machinery/quick_vendor/civilwar/set_stock_list()
	global_list_to_use = GLOB.civilwar_loadouts
