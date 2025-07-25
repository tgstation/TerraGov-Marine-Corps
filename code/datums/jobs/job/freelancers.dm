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
	paygrade = "CBT"
	outfit = /datum/outfit/job/freelancer/standard
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/standard,
		/datum/outfit/job/freelancer/standard/pump,
		/datum/outfit/job/freelancer/standard/tx11,
	)


//Freelancer Medic
/datum/job/freelancer/medic
	title = "Freelancer Medic"
	paygrade = "MED"
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/freelancer/medic
	multiple_outfits = TRUE
	outfits = list(
	/datum/outfit/job/freelancer/medic,
	/datum/outfit/job/freelancer/medic/marksman,
	)

//Freelancer Veteran. Generic term for 'better equipped dude'
/datum/job/freelancer/grenadier
	title = "Freelancer Veteran"
	paygrade = "CBT"
	skills_type = /datum/skills/freelancer_veteran
	outfit = /datum/outfit/job/freelancer/grenadier
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/grenadier,
		/datum/outfit/job/freelancer/grenadier/tx55,
		/datum/outfit/job/freelancer/grenadier/hpr,
	)

//Freelancer specialist
/datum/job/freelancer/specialist

	title = "Freelancer Specialist"
	paygrade = "SPEC"
	skills_type = /datum/skills/freelancer_veteran
	outfit = /datum/outfit/job/freelancer/specialist
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/specialist,
		/datum/outfit/job/freelancer/specialist/flamer,
	)

//Freelancer Leader
/datum/job/freelancer/leader
	title = "Freelancer Leader"
	paygrade = "CMD"
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/freelancer/leader
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/freelancer/leader,
		/datum/outfit/job/freelancer/leader/tx55,
	)
