/datum/job/fallen
	title = SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard

/datum/job/fallen/after_spawn(mob/living/new_mob, mob/M, latejoin)
	if(!ishuman(new_mob))
		return
	RegisterSignal(new_mob, COMSIG_MOB_DEATH, COMSIG_MOB_LOGOUT, .proc/delete_mob)

///Delete the mob when you log out or when it's dead
/datum/job/fallen/proc/delete_mob(mob/living/source)
	SIGNAL_HANDLER
	qdel(source)

/datum/job/fallen/engineer
	title = SQUAD_ENGINEER
	outfit = /datum/outfit/job/marine/engineer

/datum/job/fallen/corpsman
	title = SQUAD_CORPSMAN
	outfit = /datum/outfit/job/marine/corpsman

/datum/job/fallen/smartgunner
	title = SQUAD_SMARTGUNNER
	outfit = /datum/outfit/job/marine/smartgunner

/datum/job/fallen/leader
	title = SQUAD_LEADER
	outfit = /datum/outfit/job/marine/leader