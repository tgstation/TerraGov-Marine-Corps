//A mind that houses a personality and attitudes
//Influences decisions based on node weights and later on, ability activations (xenomorphs and humans)

/datum/ai_mind
	var/datum/component/ai_behavior/parent_component //Used for referencing back to

/datum/ai_mind/New(datum/component_to_hook_to)
	..()
	if(component_to_hook_to)
		parent_component = component_to_hook_to

/datum/ai_mind/proc/late_init() //Used for checking if there's a parent component and initial action states/decisions
	if(QDELETED(parent_component))
		stack_trace("AI mind had a qdel'd component after being late initialized. Removing it.")
		qdel(src)
		return
	RegisterSignal(parent_component.parent, COMSIG_DISTANCE_MAINTAINED, .proc/distance_maintained) //Distance was maintained
	RegisterSignal(parent_component.parent, COMSIG_NODE_REACHED, .proc/node_reached) //A Node was maintained
	//parent_component.action_state = new/datum/action_state/move_to_atom/node(parent_component, parent_component.current_node.GetBestAdjNode())

/datum/ai_mind/proc/distance_maintained() //What we do when distance is maintained

/datum/ai_mind/proc/node_reached() //We reached a node, let's pick another node to go to
	parent_component.parent.DetachElement(/datum/element/action_state/move_to_atom/node)
	parent_component.parent.AddElement(/datum/element/action_state/move_to_atom/node, pick(parent_component.current_node.datumnode.adjacent_nodes), 1)

/datum/ai_mind/proc/Process() //Processes every AI subsystem tick
