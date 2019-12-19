/*
Datums that represent an AI mind and it's way of doing various things like movement or handling a gun
Base datums for stuff like humans or xenos have possible actions to do as well as attitudes
*/

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_behavior
	var/turf/lastturf //If this is the same as parentmob turf at HandleMovement() then we made no progress in moving, do HandleObstruction from there
	var/move_delay = 0 //The next world.time we can do a move at
	var/datum/ai_mind/mind //Calculates the action states to take and the parameters it gets; literally the brain

/datum/component/ai_behavior/Initialize(datum/ai_mind/mind_to_make)
	. = ..()
	if(!iscarbon(parent))
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
	if(!temp_node)
		stack_trace("An AI component was being attached to a parent however there's no nodes nearby; component removed.")
		return COMPONENT_INCOMPATIBLE
	//This is here so we only make a mind if there's a node nearby for the parent to go onto
	mind = new mind_to_make(src)
	mind.set_cur_node(temp_node)
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, .proc/qdel_self)
	RegisterSignal(parent, COMSIG_AI_DO_ACTION, .proc/do_action)
	var/list/sig_to_reg = mind.starting_signals
	for(var/signal in sig_to_reg)
		RegisterSignal(parent, sig_to_reg[signal], sig_to_reg[sig_to_reg[signal]])
	START_PROCESSING(SSprocessing, src)
	parent.AddElement(arglist(mind.get_new_state(null, parent))) //Null in this case means it just appeared and needs a starting action state
	register_signals()

//Contacts the ai mind if we should be doing a thing; triggered by say getting close to a human and needing to attack it
/datum/component/ai_behavior/proc/do_action()
	var/list/temp_list = mind.request_action(parent)
	//1st index: target to call proc on
	//2nd index: proc path
	//3rd index: proc parameters
	if(length(temp_list)) //Incase this gets called on minds with nothing coded for request_action like base ai mind
		call(temp_list[1], temp_list[2])(arglist(temp_list[3]))

/datum/component/ai_behavior/proc/target_reached() //We reached something, let's ask the mind and see what we do next
	unregister_signals()
	parent.RemoveElement(mind.cur_action_state)
	mind.set_cur_node(mind.atom_to_walk_to)
	parent.AddElement(arglist(mind.get_new_state(COMSIG_FINISHED_NODE_MOVE, parent)))
	register_signals()

//Requests a list of signals from the AI mind to register
/datum/component/ai_behavior/proc/register_signals()
	var/list/sig_to_reg = mind.get_signals_to_reg() //Saved here to index through down below
	for(var/signal in sig_to_reg)
		RegisterSignal(parent, sig_to_reg[signal], sig_to_reg[sig_to_reg[signal]])

//Above but unregisters signals
/datum/component/ai_behavior/proc/unregister_signals()
	var/list/sig_to_unreg = mind.get_signals_to_unreg() //Saved here to index through down below
	for(var/signal in sig_to_unreg)
		UnregisterSignal(parent, sig_to_unreg[signal], sig_to_unreg[sig_to_unreg[signal]])

/datum/component/ai_behavior/proc/qdel_self() //Wrapper for COSMIG_MOB_DEATH signal
	STOP_PROCESSING(SSprocessing, src) //We do this here and in Destroy() as otherwise we can't remove said src if it's qdel below
	unregister_signals()
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
