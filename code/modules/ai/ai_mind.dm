//A mind that houses a personality and attitudes
//Influences decisions based on node weights and later on, ability activations (xenomorphs and humans)

/datum/ai_mind
	var/datum/component/ai_behavior/parent_component //Used for referencing back to

/datum/ai_mind/New(datum/component_to_hook_to)
	..()
	if(component_to_hook_to)
		parent_component = component_to_hook_to
