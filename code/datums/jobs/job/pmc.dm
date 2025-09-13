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
	outfit = /datum/outfit/job/pmc/standard/val
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/pmc/standard/val,
		/datum/outfit/job/pmc/standard/val/sarge,
		/datum/outfit/job/pmc/standard/val/sargetwo,
		/datum/outfit/job/pmc/standard/val/sargethree,
		/datum/outfit/job/pmc/standard/val/sargefour,
		/datum/outfit/job/pmc/standard/val/joker,
		/datum/outfit/job/pmc/standard/val/jokertwo,
		/datum/outfit/job/pmc/standard/val/stripes,
		/datum/outfit/job/pmc/standard/val/stripestwo,
		/datum/outfit/job/pmc/standard/val/stripesthree,
		/datum/outfit/job/pmc/standard/m416,
		/datum/outfit/job/pmc/standard/m416/sarge,
		/datum/outfit/job/pmc/standard/m416/sargetwo,
		/datum/outfit/job/pmc/standard/m416/sargethree,
		/datum/outfit/job/pmc/standard/m416/sargefour,
		/datum/outfit/job/pmc/standard/m416/joker,
		/datum/outfit/job/pmc/standard/m416/jokertwo,
		/datum/outfit/job/pmc/standard/m416/stripes,
		/datum/outfit/job/pmc/standard/m416/stripestwo,
		/datum/outfit/job/pmc/standard/m416/stripesthree,
	)

//PMC Gunner
/datum/job/pmc/gunner
	title = "PMC Gunner"
	paygrade = "PMC2"
	skills_type = /datum/skills/smartgunner/pmc
	outfit = /datum/outfit/job/pmc/gunner
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/pmc/gunner,
		/datum/outfit/job/pmc/gunner/sarge,
		/datum/outfit/job/pmc/gunner/sargetwo,
		/datum/outfit/job/pmc/gunner/sargethree,
		/datum/outfit/job/pmc/gunner/sargefour,
		/datum/outfit/job/pmc/gunner/joker,
		/datum/outfit/job/pmc/gunner/jokertwo,
		/datum/outfit/job/pmc/gunner/jokerthree,
		/datum/outfit/job/pmc/gunner/jokerfour,
		/datum/outfit/job/pmc/gunner/stripes,
		/datum/outfit/job/pmc/gunner/stripestwo,
		/datum/outfit/job/pmc/gunner/stripesthree,
		/datum/outfit/job/pmc/gunner/stripes/four,
	)
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
	outfit = /datum/outfit/job/pmc/leader/m416
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/pmc/leader/m416,
		/datum/outfit/job/pmc/leader/gunner,
	)
