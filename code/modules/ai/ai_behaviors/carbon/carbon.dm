//A generic mind for a carbon; currently has attacking, obstacle dealing and ability activation capabilities

/datum/ai_behavior/carbon
	var/attack_range = 1 //How far away we gotta be before considering an attack
	starting_signals = list(list(COMSIG_OBSTRUCTED_MOVE, .proc/deal_with_obstacle)
							)

//Returns a list of things we preferably want to attack
/datum/ai_behavior/carbon/proc/get_targets()

//Generic attack proc, unique procs to call for xenos, humans and other species as they all have different ways of executing an attack
/datum/ai_behavior/carbon/proc/attack_target()

//Attempt to deal with a obstacle
/datum/ai_behavior/carbon/proc/deal_with_obstacle()
