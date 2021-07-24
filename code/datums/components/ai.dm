/*
AI CONTROLLER COMPONENT

Really just here to exist as a way to hold the ai behavior while being an easy way of applying ai to atom/movables
The main purpose of this is to handle cleanup and setting up the initial ai behavior
*/

/**
 * An absolute hardcap on the # of instances of /datum/component/ai_controller that can exist.
 * Should a ai component get initialized while there's already enough instances of said thing, it will deny the initialization of the component but NOT the mob it's being attached to.
 * This is mainly here because admins keep on spamming AI without caring for the server's ability to handle hundreds/thousands of AI.
 */
#define AI_INSTANCE_HARDCAP 100

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_controller
	var/datum/ai_behavior/ai_behavior //Calculates the action states to take and the parameters it gets; literally the brain

/datum/component/ai_controller/Initialize(behavior_type)
	. = ..()

	if((length(GLOB.ai_instances_active) + 1) >= AI_INSTANCE_HARDCAP)
		message_admins("Notice: An AI controller was initialized but because there's already too many AI controllers existing, the initialization was canceled.")
		return COMPONENT_INCOMPATIBLE

	if(!ismob(parent)) //Requires a mob as the element action states needed to be apply depend on several mob defines like cached_multiplicative_slowdown or do_actions
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
	RegisterSignal(parent, COMSIG_COMBAT_LOG, .proc/handle_combat_log)
	GLOB.ai_instances_active += src

//Removes registered signals and action states, useful for scenarios like when the parent is destroyed or a client is taking over
/datum/component/ai_controller/proc/handle_combat_log()
	SIGNAL_HANDLER
	return DONT_LOG

/datum/component/ai_controller/proc/clean_up()
	SIGNAL_HANDLER
	GLOB.ai_instances_active -= src
	parent.RemoveElement(/datum/element/pathfinder)
	UnregisterSignal(parent, COMSIG_COMBAT_LOG)
	if(ai_behavior)
		STOP_PROCESSING(SSprocessing, ai_behavior)
		ai_behavior.unregister_action_signals(ai_behavior.cur_action)
		QDEL_NULL(ai_behavior)

/datum/component/ai_controller/Destroy()
	clean_up()
	return ..()
