/datum/job/upp
	job_category = JOB_CAT_MARINE
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS
	skills_type = /datum/skills/crafty
	faction = FACTION_USL

//USL Gunner
/datum/job/upp/standard
	title = "USL Gunner"
	paygrade = "UPP1"
	outfit = /datum/outfit/job/upp/standard

/datum/job/upp/standard/hvh
	outfit = /datum/outfit/job/upp/standard/hvh



//SL Surgeon
/datum/job/upp/medic
	title = "USL Surgeon"
	paygrade = "UPP2"
	skills_type = /datum/skills/combat_medic/crafty
	outfit = /datum/outfit/job/upp/medic

/datum/job/upp/medic/hvh
	outfit = /datum/outfit/job/upp/medic/hvh



//USL Powder Monkey
/datum/job/upp/heavy
	title = "USL Powder Monkey"
	paygrade = "UPP3"
	skills_type = /datum/skills/specialist/upp
	outfit = /datum/outfit/job/upp/heavy

/datum/job/upp/heavy/hvh
	outfit = /datum/outfit/job/upp/heavy/hvh


//USL Captain
/datum/job/upp/leader
	job_category = JOB_CAT_COMMAND
	title = "USL Captain"
	paygrade = "UPP4"
	skills_type = /datum/skills/sl/upp
	outfit = /datum/outfit/job/upp/leader

/datum/job/upp/leader/hvh
	outfit = /datum/outfit/job/upp/leader/hvh
