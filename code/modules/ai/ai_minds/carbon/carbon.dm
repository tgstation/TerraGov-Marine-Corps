//A generic mind for a carbon; handles mainly attack cooldowns and soon ability activations
/datum/ai_mind/carbon

//Returns a list of things we can walk to and attack to death
/datum/ai_mind/carbon/proc/get_targets()

//Generic attack proc, unique procs to call for xenos, humans and other species
/datum/ai_mind/carbon/proc/attack_target()