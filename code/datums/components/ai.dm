/*
A component that is basically just a holder and facilitator for action state assignment alongside signal registration
The ai mind is the main brains and handles proc calls on targets/component's parent
*/

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_behavior
	var/turf/lastturf //If this is the same as parentmob turf at HandleMovement() then we made no progress in moving, do HandleObstruction from there
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
	mind = new mind_to_make(src)
	mind.current_node = temp_node
	mind.mob_parent = parent
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/qdel_self)
	START_PROCESSING(SSprocessing, src)
	parent.AddElement(arglist(mind.get_new_state(null))) //Initialize it's first action
	register_signals()

//We did something that called this proc, let's get a new action state going
//force_override determines if the ai mind should or shouldn't override a action state based on the reasoning
//Example: if it was damaged while attacking something it wouldn't care unless it was injured
/datum/component/ai_behavior/proc/get_new_state(reason_for, force_override = TRUE)
	unregister_signals()
	parent.RemoveElement(mind.cur_action_state)
	parent.AddElement(arglist(mind.get_new_state(reason_for, parent)))
	register_signals()

/datum/component/ai_behavior/proc/qdel_self() //Wrapper for COSMIG_MOB_DEATH signal
	STOP_PROCESSING(SSprocessing, src) //We do this here and in Destroy() as otherwise we can't remove said src if it's qdel below
	qdel(src)

/datum/component/ai_behavior/Destroy()
	qdel(mind)
	if(!QDELETED(src))
		STOP_PROCESSING(SSprocessing, src)
	..()

/datum/component/ai_behavior/process() //Processes and updates things
	var/atom/movable/parent2 = parent
	lastturf = parent2.loc
	return TRUE

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
