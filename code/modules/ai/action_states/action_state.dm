
/datum/action_state
	var/datum/component/ai_behavior/parent_ai

/datum/action_state/New(parent_to_hook_to)
	..()
	if(parent_to_hook_to)
		parent_ai = parent_to_hook_to
		return TRUE
	else
		stack_trace("A action state was initialized without a parent to hook onto, VERY BAD!!!")
		qdel(src)
		return FALSE

//Called from AI process, this is NOT for assigning new states or removing and choosing next state, that's the AI behavior job
//This is for updating things like random_move's next_node

/datum/action_state/proc/Complete(reason) //What we do once completing the the task, also inform the parent ai we finished it
	parent_ai.action_completed(reason)
	qdel(src)

/datum/action_state/proc/GetTargetDir(smart_pathfind) //This supplements the direction we will be walking in for pathfinding
