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
	RegisterSignal(parent_component.parent, COMSIG_MOB_TARGET_REACHED, .proc/target_reached) //Target was reached; could be a enemy or a node

/datum/ai_mind/proc/target_reached() //We reached a node, let's pick another node to go to
	if(istype(parent_component.atom_to_walk_to, /obj/effect/AINode))
		parent_component.parent.RemoveElement(/datum/element/action_state/move_to_atom)
		parent_component.current_node = parent_component.atom_to_walk_to
		parent_component.atom_to_walk_to = pick(parent_component.current_node.datumnode.adjacent_nodes)
		parent_component.parent.AddElement(/datum/element/action_state/move_to_atom, parent_component.atom_to_walk_to, 1)

/datum/ai_mind/proc/Process() //Processes every AI subsystem tick
