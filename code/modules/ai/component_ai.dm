/*
Datums that represent an AI mind and it's way of doing various things like movement or handling a gun
Base datums for stuff like humans or xenos have possible actions to do as well as attitudes
*/

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_behavior

	var/turf/destinationturf //Turf that we want to get to
	var/turf/lastturf //If this is the same as parentmob turf at HandleMovement() then we made no progress in moving, do HandleObstruction from there
	var/obj/effect/AINode/current_node //Current node the parentmob is at
	var/move_delay = 0 //The next world.time we can do a move at
	//var/datum/action_state/action_state //If we have an action state we feed it info and see what it tells us what to do
	var/distance_to_maintain = 1 //Default distance to maintain from a target while in combat
	var/datum/ai_mind/mind //Controls bsaic things like what to do once a action is completed or ability activations
	var/atom/atom_to_walk_to //An atom for the overall AI to walk to

/datum/component/ai_behavior/Initialize(datum/ai_mind/mind_to_make)
	. = ..()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	if(!mind_to_make)
		stack_trace("AI component was initialized without a mind to initialize parameter, stopping component creation.")
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/parent2 = parent
	for(var/obj/effect/AINode/node in range(7))
		if(node)
			current_node = node
			parent2.forceMove(current_node.loc)
		break
	if(!current_node)
		stack_trace("An AI component was being attached to a movable atom however there's no nodes nearby; component removed.")
		qdel(src)
		return
	mind = new mind_to_make(src)
	mind.late_init()
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/qdel_self)
	START_PROCESSING(SSprocessing, src)
	parent.AddElement(/datum/element/action_state/move_to_atom/node, pick(current_node.datumnode.adjacent_nodes), 1)

/datum/component/ai_behavior/proc/qdel_self() //Wrapper for COSMIG_MOB_DEATH signal
	STOP_PROCESSING(SSprocessing, src) //We do this here and in Destroy() as otherwise we can't remove said src if it's qdel below
	qdel(src)

/datum/component/ai_behavior/Destroy()
	qdel(mind)
	if(!QDELETED(src))
		STOP_PROCESSING(SSprocessing, src)
	..()

/datum/component/ai_behavior/process() //Processes and updates things
	if(QDELETED(parent))
		return FALSE
	var/mob/living/parent2 = parent
	lastturf = parent2.loc
	return TRUE

/*
//Tile by tile movement electro boogaloo
/datum/component/ai_behavior/proc/ProcessMove()
	if(!QDELETED(action_state))
		var/mob/living/carbon/parent2 = parent
		if(!parent2.canmove)
			addtimer(CALLBACK(src, .proc/ProcessMove), 2)
			return
		var/totalmovedelay = 0
		switch(parent2.m_intent)
			if(MOVE_INTENT_RUN)
				totalmovedelay += 2 + CONFIG_GET(number/movedelay/run_delay)
			if(MOVE_INTENT_WALK)
				totalmovedelay += 7 + CONFIG_GET(number/movedelay/walk_delay)
		totalmovedelay += parent2.movement_delay()

		var/doubledelay = FALSE //If we add on additional delay due to it being a diagonal move
		var/dumb_direction = action_state.GetTargetDir(smart_pathfind = TRUE)
		if(!step(parent2, dumb_direction)) //If this doesn't work, we're stuck, go figure
			addtimer(CALLBACK(src, .proc/ProcessMove), 5) //Try moving again in half a second
			return

		if(dumb_direction in GLOB.diagonals)
			doubledelay = TRUE

		if(doubledelay)
			move_delay = world.time + (totalmovedelay * SQRTWO)
			addtimer(CALLBACK(src, .proc/ProcessMove), totalmovedelay * SQRTWO)
			return
		else
			move_delay = world.time + totalmovedelay
			addtimer(CALLBACK(src, .proc/ProcessMove), totalmovedelay)
			return
*/
