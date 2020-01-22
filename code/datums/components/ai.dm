

/*
AI CONTROLLER COMPONENT
The main purpose of the component is to mainly assign the mob to the proper action state with the proper parameters
The parameters are determined by requesting them from the ai mind attached to the component
The ai mind is it's own thing to allow for easy overriding of behaviors, going into more specific routines rather than a very generic one component

AI components are initialized with a param to determine what mind to make
For mobs to start with an ai component, here's an example of it being done with a drone


/mob/living/carbon/xenomorph/drone/ai //A drone that walks around, slashes and uses its weeding abilities

/mob/living/carbon/xenomorph/drone/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind/carbon/xeno/drone)

Any usage of the code above should preferability go into the code/modules/ai/presets holder and in the proper folder

Code interaction restrictions: The component cannot determine what decisions the mob it's attached to makes, it can only request them from the ai mind
*/

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_controller
	var/move_delay = 0 //The next world.time we can do a move at
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
	ai_behavior.register_starting_signals(src)
	RegisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_MOB_DEATH), .proc/clean_up)
	START_PROCESSING(SSprocessing, src)
	parent.AddElement(arglist(ai_behavior.get_new_state(null))) //Initialize it's first action
	ai_behavior.register_state_signals(src)
	register_comp_signals()

/datum/component/ai_controller/process()
	//We don't do . = ..() as . would be a PROCESS_KILL due to /datum/process()
	..()
	var/mob/controlled_mob = parent
	if(controlled_mob.client)
		qdel(src)
		return //No PROCESS_KILL needed here as qdel() will handle that due to clean_up()
	var/result = ai_behavior.do_process()
	if(result) //If this returns something, then there's a REASON for a new action state to be considered
		get_new_state(result)

/*
Requests signals and proc paths to register on a target; mainly for calling procs defined on the component to get new states
Index explination
1: the target to register the signal on
2: COMSIG to intercept
3: proc path to call
*/

/datum/component/ai_controller/proc/register_comp_signals()
	for(var/signal in ai_behavior.get_comp_signals_to_reg())
		RegisterSignal(signal[1], signal[2], signal[3])

/*
Above but unregisters the signals
Index explaination
1: target to unregister the signal
2: COMSIG to unregister
*/

/datum/component/ai_controller/proc/unregister_comp_signals()
	for(var/signal in ai_behavior.get_comp_signals_to_unreg())
		UnregisterSignal(signal[1], signal[2])

/*
We did something that called this proc, let's get a new action state going
force_override determines if the ai mind should or shouldn't override a action state based on the reasoning
Example: if it was damaged while attacking something it wouldn't care unless it was injured
*/
/datum/component/ai_controller/proc/get_new_state(reason_for, force_override = TRUE)
	unregister_comp_signals()
	ai_behavior.unregister_state_signals(src)
	parent.RemoveElement(ai_behavior.cur_action_state)
	parent.AddElement(arglist(ai_behavior.get_new_state(reason_for, parent)))
	register_comp_signals()
	ai_behavior.register_state_signals(src)

//Removes registered signals and action states, useful for scenarios like when the parent is destroyed or a client is taking over
/datum/component/ai_controller/proc/clean_up()
	STOP_PROCESSING(SSprocessing, src) //We do this here and in Destroy() as otherwise we can't remove said src if it's qdel below
	ai_behavior.unregister_state_signals(src)
	parent.RemoveElement(ai_behavior.cur_action_state)

/datum/component/ai_controller/Destroy()
	clean_up()
	return ..()

//Wrappers for signal interception
/datum/component/ai_controller/proc/reason_finished_node_move()
	get_new_state(REASON_FINISHED_NODE_MOVE)

/datum/component/ai_controller/proc/reason_target_killed()
	get_new_state(REASON_TARGET_KILLED)
