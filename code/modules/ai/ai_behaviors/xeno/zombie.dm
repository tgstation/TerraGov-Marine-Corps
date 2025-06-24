/datum/ai_behavior/xeno/zombie
	identifier = IDENTIFIER_ZOMBIE
	base_action = ESCORTING_ATOM
	sidestep_prob = 10

/datum/ai_behavior/xeno/zombie/process()
	. = ..()
	var/mob/living/living_parent = mob_parent
	if(living_parent.resting)
		living_parent.get_up()

/datum/ai_behavior/xeno/zombie/melee_interact(datum/source, atom/interactee, melee_tool)
	melee_tool = mob_parent.r_hand ? mob_parent.r_hand : mob_parent.l_hand
	return ..()

/datum/ai_behavior/xeno/zombie/try_to_heal()
	return //Zombies don't need to do anything to heal

/datum/ai_behavior/xeno/zombie/patrolling
	base_action = MOVING_TO_NODE

/datum/ai_behavior/xeno/zombie/idle
	base_action = IDLE
