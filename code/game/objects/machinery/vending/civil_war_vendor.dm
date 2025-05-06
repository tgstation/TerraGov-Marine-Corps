//Civilwar vendors

GLOBAL_LIST_INIT(civil_war_loadouts, init_civil_war_loadouts())

/proc/init_civil_war_loadouts() //List of all loadouts in civil_war_loadouts
	. = list()
	var/list/loadout_list = list(
		/datum/outfit/quick/civil_war/bluecoat,
		/datum/outfit/quick/civil_war/redcoat,
	)

	for(var/X in loadout_list)
		.[X] = new X

/obj/machinery/quick_vendor/civil_war
	categories = list(
		"Bluecoat"
	)

/obj/machinery/quick_vendor/civil_war/redcoat
	categories = list(
		"Redcoat",
	)

/obj/machinery/quick_vendor/civil_war/set_stock_list()
	global_list_to_use = GLOB.civil_war_loadouts
