//A mind that houses a personality and attitudes
//Influences decisions based on node weights and later on, ability activations (xenomorphs and humans)

/datum/ai_mind
	//While the below variables could be stored on the component, it's stored here instead as we use them for calculating the parameters
	//and what action states to give to the component so it can then apply it on the parent/mob
	var/atom/atom_to_walk_to //An atom for the overall AI to walk to
	var/distance_to_maintain = 1 //Default distance to maintain from a target while in combat usually
	var/obj/effect/ai_node/current_node //Current node to use for calculating action states: this is the mob's node
	var/datum/element/action_state/cur_action_state //Current TYPE of the action state we're using; used for calculating next action state

/datum/ai_mind/proc/set_cur_node(the_node)
	current_node = the_node

//reason_for is a reason for why the last action state got changed, whenever because it accomplished its mission or something interrupted it
//Parent is for say checking on the overall status of the mob and evalulating action states off of that alongside parameter generation
//This will also deregister any signals related to the old action state
/datum/ai_mind/proc/get_new_state(reason_for, mob/living/parent)
	if(!reason_for || reason_for == FINISHED_MOVE) //AI mind got initialized or something messed up
		atom_to_walk_to = pick(current_node.datumnode.adjacent_nodes)
		cur_action_state = /datum/element/action_state/move_to_atom
		return list(cur_action_state, atom_to_walk_to, distance_to_maintain)

//Gets the signals needed to register for the current action state
/datum/ai_mind/proc/get_signals_to_reg()
	if(istype(atom_to_walk_to, /obj/effect/ai_node)) //We're walking to a node, register a signal for getting a new state after reaching it
		return list(COMSIG_MOB_TARGET_REACHED = /datum/component/ai_behavior/proc/target_reached)

//Returns a list of signals to unregister related to the current action state/atom walking to
/datum/ai_mind/proc/get_signals_to_unreg()
	if(atom_to_walk_to) //We're walking to a node, remove that signal related to it
		if(istype(atom_to_walk_to, /obj/effect/ai_node))
			return list(COMSIG_MOB_TARGET_REACHED)
