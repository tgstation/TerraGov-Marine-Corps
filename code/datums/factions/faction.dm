/datum/faction
	var/name = ""
	var/shortname = ""

	var/list/squads // references to instances of /datum/squad
	var/list/hives // references to instances of /datum/hive_status

	var/list/friendly_factions = list()

	var/list/dynamic_squads = list()

	var/list/initial_squads = list() // list of /datum/squad/ typepaths to make when this faction is created
	var/list/initial_hives = list() // list of /datum/hive_status types that should be pulled from GLOB.hive_datums

/datum/faction/New()
	. = ..()
	for(var/typepath in initial_squads)
		var/datum/squad/S = new typepath(src)
		squads += S
	for(var/hivetype in initial_hives)
		var/datum/hive_status/HS = hivetype
		hives += GLOB.hive_datums[initial(HS.hivenumber)]
	GLOB.factions[type] = src

/datum/faction/proc/initialize_dynamic_squads(faction_count)

