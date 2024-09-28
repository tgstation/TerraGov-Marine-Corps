/datum/job/clf
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_CLF


//CLF Standard
/datum/job/clf/standard
	title = "CLF Standard"
	paygrade = "CLF1"
	outfit = /datum/outfit/job/clf/standard/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/standard/uzi,
		/datum/outfit/job/clf/standard/skorpion,
		/datum/outfit/job/clf/standard/mpi_km,
		/datum/outfit/job/clf/standard/shotgun,
		/datum/outfit/job/clf/standard/garand,
		/datum/outfit/job/clf/standard/fanatic,
		/datum/outfit/job/clf/standard/som_smg,
	)


//CLF Medic
/datum/job/clf/medic
	title = "CLF Medic"
	paygrade = "CLF2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/clf/medic/uzi
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/medic/uzi,
		/datum/outfit/job/clf/medic/skorpion,
		/datum/outfit/job/clf/medic/paladin,
	)


//CLF Specialist
/datum/job/clf/specialist
	title = "CLF Specialist"
	skills_type = /datum/skills/crafty
	outfit = /datum/outfit/job/clf/specialist
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/specialist/dpm,
		/datum/outfit/job/clf/specialist/clf_heavyrifle,
		/datum/outfit/job/clf/specialist/clf_heavymachinegun,
	)



//CLF Leader
/datum/job/clf/leader
	title = "CLF Leader"
	paygrade = "CLF3"
	skills_type = /datum/skills/sl/clf
	outfit = /datum/outfit/job/clf/leader/assault_rifle
	multiple_outfits = TRUE
	outfits = list(
		/datum/outfit/job/clf/leader/assault_rifle,
		/datum/outfit/job/clf/leader/mpi_km,
		/datum/outfit/job/clf/leader/som_rifle,
		/datum/outfit/job/clf/leader/upp_rifle,
		/datum/outfit/job/clf/leader/lmg_d,
	)
