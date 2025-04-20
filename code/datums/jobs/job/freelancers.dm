/datum/job/freelancer
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_FREELANCERS
	minimap_icon = "freelancer"
	outfit = /datum/outfit/job/freelancer


//Freelancer Standard
/datum/job/freelancer/standard
	title = "Freelancer Standard"
	paygrade = "FRE1"
	outfit = /datum/outfit/job/freelancer/standard
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/standard/one,
		/datum/outfit/job/freelancer/standard/two,
		/datum/outfit/job/freelancer/standard/three,
	)


//Freelancer Medic
/datum/job/freelancer/medic
	title = "Freelancer Medic"
	paygrade = "FRE2"
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/freelancer/medic


//Freelancer Veteran. Generic term for 'better equipped dude'
/datum/job/freelancer/grenadier
	title = "Freelancer Veteran"
	paygrade = "FRE3"
	outfit = /datum/outfit/job/freelancer/grenadier
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/grenadier/one,
		/datum/outfit/job/freelancer/grenadier/two,
		/datum/outfit/job/freelancer/grenadier/three,
	)


//Freelancer Leader
/datum/job/freelancer/leader
	title = "Freelancer Leader"
	paygrade = "FRE4"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/freelancer/leader
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/leader/one,
		/datum/outfit/job/freelancer/leader/two,
		/datum/outfit/job/freelancer/leader/three,
	)
