//A mind that determines things to be done
//Decisions can be influenced by node weights, surrounding objects in the world and whatever else is happening toit
//This part handles all the proc calls on things like the parent being provided and atom being walked to
//This allow gives the ai component signals to register and the proc to be called on the component (which will usually be redirected to the mind)

//Code interaction restrictions: AI mind can only interact with the ai comp whenever the ai comp requests signals
//It can never interact with the action state as it's a element

/datum/ai_behavior
	//While the below variables could be stored on the component, it's stored here instead as we use them for calculating the parameters
	//and what action states to give to the component so it can then apply it on the parent/mob
	var/atom/atom_to_walk_to //An atom for the overall AI to walk to; this is a cache
	var/distance_to_maintain = 1 //Default distance to maintain from a target while in combat usually
	var/sidestep_prob = 0 //Prob chance of sidestepping (left or right) when distance maintained with target
	var/obj/effect/ai_node/current_node //Current node to use for calculating action states: this is the mob's node
	var/datum/element/action_state/cur_action_state //Current TYPE of the action state we're using; used for calculating next action state
	var/mob/mob_parent //Ref to the parent associated with this mind
	var/starting_signals = list() //All signals to be registered on parent mob upon being made

/datum/ai_behavior/New(loc, parent_to_assign)
	..()
	if(isnull(parent_to_assign))
		stack_trace("An ai behavior was initialized without a parent to assign it to; destroying mind. Mind type: [type]")
		qdel(src)
		return
	mob_parent = parent_to_assign

//reason_for is a reason for why the last action state got changed, whenever because it accomplished its mission or something interrupted it
//Parent is for say checking on the overall status of the mob and evalulating action states off of that alongside parameter generation
//This will also deregister any signals related to the old action state
/datum/ai_behavior/proc/get_new_state(reason_for)
	if(!reason_for || reason_for == REASON_FINISHED_NODE_MOVE || reason_for == REASON_TARGET_KILLED)
		if(isainode(atom_to_walk_to))
			current_node = atom_to_walk_to
		atom_to_walk_to = pick(current_node.datumnode.adjacent_nodes)
		cur_action_state = /datum/element/action_state/move_to_atom
		return list(cur_action_state, atom_to_walk_to, distance_to_maintain, sidestep_prob)
	stack_trace("An ai mind didn't give parameters back for a new action state, VERY BAD!! Mind type: [src.type], Reasoning: [reason_for]")

//This is called by the component every process, this doesn't have a process() defined as the component will decide based off of the return value of this if it should apply a particular action state
/datum/ai_behavior/proc/do_process()
	return

//Gets the signals needed to register for the current action state
/datum/ai_behavior/proc/get_signals_to_reg()
	if(isainode(atom_to_walk_to)) //We're walking to a node, register a signal for getting a new state after reaching it
		return list(
				list(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, /datum/component/ai_controller/.proc/reason_finished_node_move)
					)

//Returns a list of signals to unregister related to the current action state/atom walking to
/datum/ai_behavior/proc/get_signals_to_unreg()
	if(atom_to_walk_to) //We're walking to a node, remove that signal related to it
		if(isainode(atom_to_walk_to))
			return list(
					list(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
					)
