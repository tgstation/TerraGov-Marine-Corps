//A generic mind for a carbon; handles mainly attack cooldowns and soon ability activations
/datum/ai_mind/carbon
	var/attack_range = 1 //How far away we gotta be before considering an attack
	starting_signals = list(list(COMSIG_OBSTRUCTED_MOVE, .proc/deal_with_obstacle)
							)

//Returns a list of things we can walk to and attack to death
/datum/ai_mind/carbon/proc/get_targets()

//Generic attack proc, unique procs to call for xenos, humans and other species
/datum/ai_mind/carbon/proc/attack_target()

//Attempt to deal with a obstacle
/datum/ai_mind/carbon/proc/deal_with_obstacle()
