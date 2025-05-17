/datum/job/special_forces
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/special_forces_standard
	faction = FACTION_SPECFORCE

//Special forces Standard
/datum/job/special_forces/standard
	title = "Special Force Standard"
	outfit = /datum/outfit/job/special_forces/standard


//Special Force breacher
/datum/job/special_forces/breacher
	title = "Special Force Breacher"
	outfit = /datum/outfit/job/special_forces/breacher


/datum/job/special_forces/drone_operator
	title = "Special Force Drone Operator"
	outfit = /datum/outfit/job/special_forces/drone_operator


//Special forces Medic
/datum/job/special_forces/medic
	title = "Special Force Medic"
	outfit = /datum/outfit/job/special_forces/medic
	skills_type = /datum/skills/combat_medic/special_forces

//Special forces Leader
/datum/job/special_forces/leader
	title = "Special Force Leader"
	skills_type = /datum/skills/sl/pmc/special_forces
	outfit = /datum/outfit/job/special_forces/leader
