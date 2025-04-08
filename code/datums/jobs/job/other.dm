//Colonist
/datum/job/colonist
	title = "Colonist"
	paygrade = "C"
	outfit = /datum/outfit/job/other/colonist

//Passenger
/datum/job/passenger
	title = "Passenger"
	paygrade = "C"


//Pizza Deliverer
/datum/job/pizza
	title = "Pizza Deliverer"
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	outfit = /datum/outfit/job/other/pizza

//Spatial Agent
/datum/job/spatial_agent
	title = "Spatial Agent"
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	skills_type = /datum/skills/spatial_agent
	outfit = /datum/outfit/job/other/spatial_agent

/datum/job/spatial_agent/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	H.grant_language(/datum/language/xenocommon)

/datum/job/spatial_agent/galaxy_red
	outfit = /datum/outfit/job/other/spatial_agent/galaxy_red

/datum/job/spatial_agent/galaxy_blue
	outfit = /datum/outfit/job/other/spatial_agent/galaxy_blue

/datum/job/spatial_agent/xeno_suit
	outfit = /datum/outfit/job/other/spatial_agent/xeno_suit

/datum/job/spatial_agent/marine_officer
	outfit = /datum/outfit/job/other/spatial_agent/marine_officer


/datum/job/zombie
	title = "Oh god run"
