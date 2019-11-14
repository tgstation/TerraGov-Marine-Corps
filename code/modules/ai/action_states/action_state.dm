//A singleton action state; AI components are added to the list and a subsystem will periodically call the process() for this
//AI components will also GetTargetDir() from the action_state their connected to so they can have a direction to move in
/datum/element/action_state
	var/list/ai_components = list() //All AI components currently attached to this action state

/datum/element/action_state/proc/attach_component(datum/component/ai_behavior/ai)
	if(!QDELETED(ai))
		ai_components += ai

/datum/element/action_state/proc/detach_component(datum/component/ai_behavior/ai)
	if(!QDELETED(ai))
		ai_components -= ai

//A special process() that doesn't rely on the processing subsystem but rather the action_states subsystem
/datum/element/action_state/proc/state_process(datum/component/ai_behavior/ai)

/datum/element/action_state/move_to_atom

/datum/element/action_state/move_to_atom/attach_component(datum/component/ai_behavior/ai, atom/atom_to_walk_to)
	if(!QDELETED(ai) && atom_to_walk_to)
		ai_components += ai
		ai_components[ai] = atom_to_walk_to

/datum/element/action_state/move_to_atom/detach_component(datum/component/ai_behavior/ai, atom/atom_to_walk_to)
	if(!QDELETED(ai))
		ai_components -= ai

/*
/datum/action_state
	var/datum/component/ai_behavior/parent_ai

/datum/action_state/New(parent_to_hook_to)
	..()
	if(parent_to_hook_to)
		parent_ai = parent_to_hook_to
		START_PROCESSING(SSprocessing, src)
		return TRUE
	else
		stack_trace("A action state was initialized without a parent to hook onto, VERY BAD!!!")
		qdel(src)
		return FALSE

/datum/action_state/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/action_state/process()

/datum/action_state/proc/Complete(reason) //What we do once completing the the task, also inform the parent ai we finished it
	parent_ai.action_completed(reason)
	qdel(src)

//This supplements the direction we will be walking in for pathfinding
/datum/action_state/proc/GetTargetDir(smart_pathfind = FALSE, atom/target, /datum/component/ai_behavior/ai)
*/
