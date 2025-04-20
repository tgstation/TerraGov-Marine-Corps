/datum/job/icc
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/craftier
	faction = FACTION_ICC
	minimap_icon = "icc"

//ICC Standard
/datum/job/icc/standard
	title = "ICC Standard"
	paygrade = "ICCH"
	multiple_outfits = TRUE
	outfit = /datum/outfit/job/icc/standard/mpi_km
	outfits = list(
		/datum/outfit/job/icc/standard/mpi_km,
		/datum/outfit/job/icc/standard/icc_pdw,
		/datum/outfit/job/icc/standard/icc_battlecarbine,
		/datum/outfit/job/icc/standard/icc_assaultcarbine,
	)


//ICC Guard
/datum/job/icc/guard
	title = "ICC Guardsman"
	paygrade = "ICC3"
	outfit = /datum/outfit/job/icc/guard/coilgun
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/icc/guard/coilgun,
		/datum/outfit/job/icc/guard/icc_autoshotgun,
		/datum/outfit/job/icc/guard/icc_bagmg,
	)


//ICC Medic
/datum/job/icc/medic
	title = "ICC Medic"
	paygrade = "ICC2"
	skills_type = /datum/skills/combat_medic/crafty
	multiple_outfits = TRUE
	outfit = /datum/outfit/job/icc/medic/icc_machinepistol
	outfits = list(
		/datum/outfit/job/icc/medic/icc_machinepistol,
		/datum/outfit/job/icc/medic/icc_sharpshooter,
	)


/datum/job/icc/leader
	title = "ICC Leader"
	paygrade = "ICC2"
	outfit = /datum/outfit/job/icc/leader/icc_heavyshotgun
	skills_type = /datum/skills/sl/icc
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/icc/leader/icc_heavyshotgun,
		/datum/outfit/job/icc/leader/icc_confrontationrifle,
	)
