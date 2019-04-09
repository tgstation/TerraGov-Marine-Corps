/datum/faction/nanotrasen
	name = "Nanotrasen"
	shortname = "NT"

	friendly_factions = list(
		/datum/faction/tgmc,
		/datum/faction/pmc)

/datum/faction/pmc
	name = "Paramilitary Company"
	shortname = "PMCs"

	friendly_factions = list(
		/datum/faction/nanotrasen)

/datum/faction/xenomorph/corrupted
	name = "Corrupted Xenomorphs"
	shortname = "Corrupted Xenos"

	initial_hives = list(/datum/hive_status/corrupted)

	friendly_factions = list(
		/datum/faction/nanotrasen)
