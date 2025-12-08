/datum/ai_behavior/xeno/zombie
	identifier = IDENTIFIER_ZOMBIE
	base_action = ESCORTING_ATOM
	sidestep_prob = 10

/datum/ai_behavior/xeno/zombie/should_start_ai()
	return TRUE

/datum/ai_behavior/xeno/zombie/start_ai()
	RegisterSignal(SSdcs, COMSIG_GLOB_AI_ZOMBIE_RALLY, PROC_REF(rally_zombie))
	return ..()

/datum/ai_behavior/xeno/zombie/cleanup_signals()
	. = ..()
	UnregisterSignal(SSdcs, COMSIG_GLOB_AI_ZOMBIE_RALLY)

/datum/ai_behavior/xeno/zombie/process()
	. = ..()
	if(mob_parent.resting)
		mob_parent.get_up()

/datum/ai_behavior/xeno/zombie/melee_interact(datum/source, atom/interactee, melee_tool)
	melee_tool = mob_parent.r_hand ? mob_parent.r_hand : mob_parent.l_hand
	return ..()

/datum/ai_behavior/xeno/zombie/try_to_heal()
	return //Zombies don't need to do anything to heal

///Rallies the zombie to a target
/datum/ai_behavior/xeno/zombie/proc/rally_zombie(datum/source, atom/atom_to_escort, global_rally = FALSE)
	SIGNAL_HANDLER
	if(QDELETED(atom_to_escort) || mob_parent.ckey || atom_to_escort.z != mob_parent.z)
		return
	if(get_dist(atom_to_escort, mob_parent) <= target_distance)
		set_escorted_atom(source, atom_to_escort)
		return
	if(!global_rally)
		return
	set_goal_node(new_goal_node = find_closest_node(atom_to_escort))
	if(current_action == IDLE) ///Turns on passive zombies also
		look_for_next_node()

/datum/ai_behavior/xeno/zombie/patrolling
	base_action = MOVING_TO_NODE

/datum/ai_behavior/xeno/zombie/idle
	base_action = IDLE
