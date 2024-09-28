/datum/job/imperial
	job_category = JOB_CAT_MARINE
	comm_title = "IMP"
	faction = FACTION_IMP
	skills_type = /datum/skills/imperial
	supervisors = "the sergeant"
	access = ALL_ANTAGONIST_ACCESS
	minimal_access = ALL_ANTAGONIST_ACCESS

/datum/job/imperial/guardsman
	title = "Guardsman"
	comm_title = "Guard"
	paygrade = "Guard"
	outfit = /datum/outfit/job/imperial/guardsman


/datum/job/imperial/guardsman/sergeant
	title = "Guardsman Sergeant"
	comm_title = "Sergeant"
	skills_type = /datum/skills/imperial/sl
	paygrade = "Sergeant"
	outfit = /datum/outfit/job/imperial/guardsman/sergeant


/datum/job/imperial/guardsman/medicae
	title = "Guardsman Medicae"
	comm_title = "Medicae"
	skills_type = /datum/skills/imperial/medicae
	paygrade = "Medicae"
	outfit = /datum/outfit/job/imperial/guardsman/medicae


/datum/job/imperial/commissar
	title = "Imperial Commissar"
	comm_title = "Commissar"
	skills_type = /datum/skills/imperial/sl
	paygrade = "Commissar"
	outfit = /datum/outfit/job/imperial/commissar

