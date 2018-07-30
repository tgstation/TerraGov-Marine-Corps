/datum/job/mercenaries
	special_role = "Mercenary"
	comm_title = "Merc"
	faction = "Unknown Mercenary Group"
	total_positions = 0
	spawn_positions = 0
	access = list(ACCESS_IFF_PMC, ACCESS_WY_PMC_GREEN, ACCESS_WY_PMC_ORANGE, ACCESS_WY_PMC_RED, ACCESS_WY_PMC_BLACK, ACCESS_WY_CORPORATE)
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT
	skills_type = /datum/skills/mercenary

//Mercenary Heavy
/datum/job/mercenaries/heavy
	title = "Mercenary Enforcer"

//Mercenary Engineer
/datum/job/mercenaries/engineer
	title = "Mercenary Engineer"

//Mercenary Worker
/datum/job/mercenaries/worker
	title = "Mercenary Worker"
