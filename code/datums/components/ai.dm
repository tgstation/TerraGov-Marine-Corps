/*
AI BEHAVIOR COMPONENT
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
/datum/component/ai_behavior
	var/move_delay = 0 //The next world.time we can do a move at
	var/datum/ai_mind/mind //Calculates the action states to take and the parameters it gets; literally the brain

/datum/component/ai_behavior/Initialize(datum/ai_mind/mind_to_make)
	. = ..()
	if(!iscarbon(parent))
		stack_trace("AI component was initialized on a parent that isn't a non carbon mob")
		return COMPONENT_INCOMPATIBLE
	if(isnull(mind_to_make))
		stack_trace("AI component was initialized without a mind to initialize parameter; component removed")
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/parent2 = parent
	var/temp_node
	for(var/obj/effect/ai_node/node in range(7))
		if(node)
			temp_node = node
			parent2.forceMove(node.loc)
			break
	if(isnull(temp_node))
		stack_trace("An AI component was being attached to a parent however there's no nodes nearby; component removed.")
		return COMPONENT_INCOMPATIBLE
	//This is here so we only make a mind if there's a node nearby for the parent to go onto
	mind = new mind_to_make(src, parent)
	mind.current_node = temp_node
	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, .proc/clean_up)
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/clean_up)
	for(var/signal in mind.starting_signals)
		RegisterSignal(parent, signal[1], signal[2])
	START_PROCESSING(SSprocessing, src)
	parent.AddElement(arglist(mind.get_new_state(null))) //Initialize it's first action
	register_signals()

/datum/component/ai_behavior/process()
	//We don't do . = ..() as . would be a PROCESS_KILL due to /datum/process()
	..()
	//Client detection
	if(istype(parent, /mob/living/carbon))
		var/mob/living/carbon/parent2 = parent
		if(parent2.client)
			qdel(src)
			return //No PROCESS_KILL needed here as qdel() will handle that due to clean_up()
	var/result = mind.do_process()
	if(result) //If this returns something, then it's a REASON for a new action state to be considered
		get_new_state(result)

//We did something that called this proc, let's get a new action state going
//force_override determines if the ai mind should or shouldn't override a action state based on the reasoning
//Example: if it was damaged while attacking something it wouldn't care unless it was injured
/datum/component/ai_behavior/proc/get_new_state(reason_for, force_override = TRUE)
	unregister_signals()
	parent.RemoveElement(mind.cur_action_state)
	parent.AddElement(arglist(mind.get_new_state(reason_for, parent)))
	register_signals()

//Removes registered signals and action states, useful for scenarios like when the parent is destroyed or a client is taking over
/datum/component/ai_behavior/proc/clean_up()
	STOP_PROCESSING(SSprocessing, src) //We do this here and in Destroy() as otherwise we can't remove said src if it's qdel below
	unregister_signals()
	parent.RemoveElement(mind.cur_action_state)

/datum/component/ai_behavior/Destroy()
	clean_up()
	..()

//Requests a list of signals from the AI mind to register
//get_signals_to_reg() returns a list consisting of lists that consist of a target to reg, a COMSIG and for registering a proc path
//Index explaination
//1: the target to register the signal on
//2: COMSIG to intercept
//3: proc path to call
/datum/component/ai_behavior/proc/register_signals()
	for(var/signal in mind.get_signals_to_reg())
		RegisterSignal(signal[1], signal[2], signal[3])

//Above but unregisters signals
//get_signals_to_unreg() returns a list consisting of lists that consist of a target to unreg, a COMSIG
//Index explaination
//1: target to unregister the signal
//2: COMSIG to unregister
/datum/component/ai_behavior/proc/unregister_signals()
	for(var/signal in mind.get_signals_to_unreg())
		UnregisterSignal(signal[1], signal[2])

//Wrappers for signal interception
/datum/component/ai_behavior/proc/reason_finished_node_move()
	get_new_state(REASON_FINISHED_NODE_MOVE)

/datum/component/ai_behavior/proc/reason_target_killed()
	get_new_state(REASON_TARGET_KILLED)

/datum/component/ai_behavior/proc/mind_attack_target()
	var/datum/ai_mind/carbon/mind2 = mind
	if(!istype(mind2))
		stack_trace("An attack order was given to a mind that is considered for non carbon mobs")
		return
	mind2.attack_target()

/datum/component/ai_behavior/proc/deal_with_obstacle()
	var/datum/ai_mind/carbon/mind2 = mind
	mind2.deal_with_obstacle()
