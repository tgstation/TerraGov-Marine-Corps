/*
AI CONTROLLER COMPONENT

Really just here to exist as a way to hold the ai behavior while being an easy way of applying ai to atom/movables
The main purpose of this is to handle cleanup and setting up the initial ai behavior
*/

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_controller
	var/datum/ai_behavior/ai_behavior //Calculates the action states to take and the parameters it gets; literally the brain

/datum/component/ai_controller/Initialize(behavior_type)
	. = ..()
	if(!ismob(parent)) //Requires a mob as the element action states needed to be apply depend on several mob defines like cached_multiplicative_slowdown or action_busy
		stack_trace("An AI controller was initialized on a parent that isn't compatible with the ai component. Parent type: [parent.type]")
		return COMPONENT_INCOMPATIBLE
	if(isnull(behavior_type))
		stack_trace("An AI controller was initialized without a mind to initialize parameter; component removed")
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/movable_parent = parent
	var/node_to_spawn_at //Temp storage holder for the node we will want to spawn at
	for(var/obj/effect/ai_node/node in range(7))
		node_to_spawn_at = node
		movable_parent.forceMove(node.loc)
		break
	if(isnull(node_to_spawn_at))
		stack_trace("An AI controller was being attached to a parent however it was unable to locate a node nearby to attach itself to; component removed.")
		message_admins("Notice: An AI controller was initialized but wasn't close enough to a node; if you were spawning AI component users, then do it closer to a node.")
		return COMPONENT_INCOMPATIBLE
	//This is here so we only make a mind if there's a node nearby for the parent to go onto
	ai_behavior = new behavior_type(src, parent)
	ai_behavior.current_node = node_to_spawn_at
	ai_behavior.late_initialize() //We gotta give the ai behavior things like what node to spawn at before it wants to start an action
	RegisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_MOB_DEATH), .proc/clean_up)

//Removes registered signals and action states, useful for scenarios like when the parent is destroyed or a client is taking over
/datum/component/ai_controller/proc/clean_up()
	STOP_PROCESSING(SSprocessing, ai_behavior)
	ai_behavior.unregister_action_signals(ai_behavior.cur_action)
	parent.RemoveElement(/datum/element/pathfinder)

/datum/component/ai_controller/Destroy()
	clean_up()
	return ..()
