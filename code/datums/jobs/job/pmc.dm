/datum/job/pmc
	job_category = JOB_CAT_MARINE
	access = ALL_PMC_ACCESS
	minimal_access = ALL_PMC_ACCESS
	skills_type = /datum/skills/pmc
	faction = FACTION_NANOTRASEN
	minimap_icon = "pmc"


//PMC Standard
/datum/job/pmc/standard
	title = "PMC Standard"
	paygrade = "PMC1"
	outfit = /datum/outfit/job/pmc/standard


//PMC Gunner
/datum/job/pmc/gunner
	title = "PMC Gunner"
	paygrade = "PMC2"
	skills_type = /datum/skills/smartgunner/pmc
	outfit = /datum/outfit/job/pmc/gunner


//PMC Sniper
/datum/job/pmc/sniper
	title = "PMC Sniper"
	paygrade = "PMC3"
	skills_type = /datum/skills/specialist/pmc
	outfit = /datum/outfit/job/pmc/sniper


//PMC Leader
/datum/job/pmc/leader
	job_category = JOB_CAT_COMMAND
	title = "PMC Leader"
	paygrade = "PMC4"
	skills_type = /datum/skills/sl/pmc
	outfit = /datum/outfit/job/pmc/leader
