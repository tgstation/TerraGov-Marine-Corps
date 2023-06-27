/datum/job/fallen/after_spawn(mob/living/new_mob, mob/M, latejoin)
	RegisterSignal(new_mob, list(COMSIG_MOB_DEATH, COMSIG_MOB_LOGOUT), PROC_REF(delete_mob))
	to_chat(new_mob, span_danger("This is a place for everyone to experiment and RP. Standard rules applies here. Do not blow up the vendors, do not grief,\
	do not try to lag the server with explosions. Alternatively, don't fill the xeno asteroid with walls or other structures."))

/datum/job/fallen/return_spawn_type(datum/preferences/prefs)
	switch(prefs?.species)
		if("Combat Robot")
			switch(prefs?.robot_type)
				if("Basic")
					return /mob/living/carbon/human/species/robot
				if("Hammerhead")
					return /mob/living/carbon/human/species/robot/alpharii
				if("Chilvaris")
					return /mob/living/carbon/human/species/robot/charlit
				if("Ratcher")
					return /mob/living/carbon/human/species/robot/deltad
				if("Sterling")
					return /mob/living/carbon/human/species/robot/bravada
		if("Vatborn")
			return /mob/living/carbon/human/species/vatborn
		else
			return /mob/living/carbon/human

///Delete the mob when you log out or when it's dead
/datum/job/fallen/proc/delete_mob(mob/living/source)
	SIGNAL_HANDLER
	source.visible_message(span_danger("[source] suddenly disappears!"))
	qdel(source)

/datum/job/fallen/marine
	title = SQUAD_MARINE
	outfit = /datum/outfit/job/marine/standard

/datum/job/fallen/marine/engineer
	title = SQUAD_ENGINEER
	skills_type = /datum/skills/combat_engineer
	outfit = /datum/outfit/job/marine/engineer

/datum/job/fallen/marine/corpsman
	title = SQUAD_CORPSMAN
	skills_type = /datum/skills/combat_medic
	outfit = /datum/outfit/job/marine/corpsman

/datum/job/fallen/marine/smartgunner
	title = SQUAD_SMARTGUNNER
	skills_type = /datum/skills/smartgunner
	outfit = /datum/outfit/job/marine/smartgunner

/datum/job/fallen/marine/leader
	title = SQUAD_LEADER
	skills_type = /datum/skills/sl
	outfit = /datum/outfit/job/marine/leader

/datum/job/fallen/marine/mechpilot
	title = MECH_PILOT
	skills_type = /datum/skills/mech_pilot
	outfit = /datum/outfit/job/command/mech_pilot

/datum/job/fallen/xenomorph
	title = ROLE_XENOMORPH
