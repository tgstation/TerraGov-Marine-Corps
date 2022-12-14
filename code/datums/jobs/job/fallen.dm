/datum/job/fallen
	title = SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard

/datum/job/fallen/after_spawn(mob/living/new_mob, mob/M, latejoin)
	if(!ishuman(new_mob))
		return
	RegisterSignal(new_mob, list(COMSIG_MOB_DEATH, COMSIG_MOB_LOGOUT), .proc/delete_mob)
	to_chat(new_mob, span_danger("This is a place for everyone to experiment and RP. Standard rules applies here. Do not blow the vendors, do not grief,\
	do not try to lag the server with explosions."))

///Delete the mob when you log out or when it's dead
/datum/job/fallen/proc/delete_mob(mob/living/source)
	SIGNAL_HANDLER
	qdel(source)

/datum/job/fallen/engineer
	title = SQUAD_ENGINEER
	skills_type = /datum/skills/combat_engineer
	outfit = /datum/outfit/job/marine/engineer

/datum/job/fallen/corpsman
	title = SQUAD_CORPSMAN
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/marine/corpsman

/datum/job/fallen/smartgunner
	title = SQUAD_SMARTGUNNER
	skills_type = /datum/skills/smartgunner
	outfit = /datum/outfit/job/marine/smartgunner

/datum/job/fallen/leader
	title = SQUAD_LEADER
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/marine/leader

/datum/job/fallen/mechpilot
	title = MECH_PILOT
	skills_type = /datum/skills/mech_pilot
	outfit = /datum/outfit/job/command/mech_pilot
