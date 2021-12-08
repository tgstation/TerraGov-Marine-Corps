/datum/job/fallen
	title = "PFC ghost"
	outfit = /datum/outfit/job/marine/standard

/datum/job/fallen/return_spawn_turf()
    return pick(GLOB.spawns_by_job[/datum/job/fallen])

/datum/job/fallen/engineer
	title = "Engineer ghost"
	outfit = /datum/outfit/job/marine/engineer

/datum/job/fallen/corpsman
	title = "Corpsman ghost"
	outfit = /datum/outfit/job/marine/corpsman

/datum/job/fallen/smartgunner
	title = "Smartgunner ghost"
	outfit = /datum/outfit/job/marine/smartgunner

/datum/job/fallen/leader
	title = "Leader ghost"
	outfit = /datum/outfit/job/marine/leader