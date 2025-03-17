//ERT roles
/datum/job/som/ert
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty


//SOM Standard
/datum/job/som/ert/standard
	title = "SOM Standard"
	paygrade = "SOM_E3"
	outfit = /datum/outfit/job/som/ert/standard/standard_assaultrifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/standard/standard_assaultrifle,
		/datum/outfit/job/som/ert/standard/standard_smg,
		/datum/outfit/job/som/ert/standard/standard_shotgun,
		/datum/outfit/job/som/ert/standard/charger,
	)


//SOM Medic
/datum/job/som/ert/medic
	title = "SOM Medic"
	paygrade = "SOM_E4"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/som/ert/medic/standard_assaultrifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/medic/standard_assaultrifle,
		/datum/outfit/job/som/ert/medic/standard_smg,
		/datum/outfit/job/som/ert/medic/standard_shotgun,
	)


//SOM Veteran
/datum/job/som/ert/veteran
	title = "SOM Veteran"
	paygrade = "SOM_S1"
	skills_type = /datum/skills/som_veteran
	job_traits = list(TRAIT_AXE_EXPERT, TRAIT_SWORD_EXPERT)
	outfit = /datum/outfit/job/som/ert/veteran/charger
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/veteran/charger,
		/datum/outfit/job/som/ert/veteran/breacher_vet,
		/datum/outfit/job/som/ert/veteran/caliver,
		/datum/outfit/job/som/ert/veteran/caliver_pack,
		/datum/outfit/job/som/ert/veteran/culverin,
	)


//SOM Specialist - special weapon vets
/datum/job/som/ert/specialist
	title = "SOM Specialist"
	paygrade = "SOM_S2"
	skills_type = /datum/skills/som_veteran
	outfit = /datum/outfit/job/som/ert/veteran/culverin
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/veteran/culverin,
		/datum/outfit/job/som/ert/veteran/rpg,
		/datum/outfit/job/som/ert/veteran/pyro,
		/datum/outfit/job/som/ert/veteran/shotgunner,
	)

//SOM Leader
/datum/job/som/ert/leader
	job_category = JOB_CAT_COMMAND
	title = "SOM Leader"
	paygrade = "SOM_S4"
	skills_type = /datum/skills/som_veteran/sl
	job_traits = list(TRAIT_AXE_EXPERT, TRAIT_SWORD_EXPERT)
	outfit = /datum/outfit/job/som/ert/leader/charger
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/leader/standard_assaultrifle,
		/datum/outfit/job/som/ert/leader/charger,
		/datum/outfit/job/som/ert/leader/caliver,
		/datum/outfit/job/som/ert/leader/caliver_pack,
	)


//Breacher ERT

//SOM breacher
/datum/job/som/ert/breacher
	title = "SOM Breacher"
	paygrade = "SOM_S2"
	skills_type = /datum/skills/som_veteran
	job_traits = list(TRAIT_AXE_EXPERT, TRAIT_SWORD_EXPERT)
	outfit = /datum/outfit/job/som/ert/veteran/breacher_melee
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/som/ert/veteran/breacher_melee,
		/datum/outfit/job/som/ert/veteran/breacher_vet,
	)


/datum/job/som/ert/breacher/specialist
	title = "SOM Breacher Specialist"
	paygrade = "SOM_S3"
	outfit = /datum/outfit/job/som/ert/veteran/breacher_rpg
	outfits = list(
		/datum/outfit/job/som/ert/veteran/breacher_rpg,
		/datum/outfit/job/som/ert/veteran/breacher_flamer,
		/datum/outfit/job/som/ert/veteran/breacher_culverin,
	)


//breacher medic
/datum/job/som/ert/medic/breacher
	title = "SOM Breacher Medic"
	paygrade = "SOM_E5"
	skills_type = /datum/skills/som_veteran/medic
	job_traits = list(TRAIT_AXE_EXPERT, TRAIT_SWORD_EXPERT)
	outfit = /datum/outfit/job/som/ert/medic/breacher
	multiple_outfits = FALSE


//SOM Leader
/datum/job/som/ert/leader/breacher
	title = "SOM Breacher Leader"
	paygrade = "SOM_O1"
	outfit = /datum/outfit/job/som/ert/leader/breacher_melee
	outfits = list(
		/datum/outfit/job/som/ert/leader/breacher_melee,
		/datum/outfit/job/som/ert/leader/breacher_ranged,
	)

