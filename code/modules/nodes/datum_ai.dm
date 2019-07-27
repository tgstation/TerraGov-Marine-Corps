/*
Datums that represent an AI mind and it's way of doing various things like movement or handling a gun
Base datums for stuff like humans or xenos have possible actions to do as well as attitudes
*/

#define ENEMY_PRESENCE 1
#define DANGER_SCALE 2
#define FINISHED_MOVE "finished moving to node"

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/ai_behavior

	var/mob/living/carbon/parentmob //The mob this is attached to; must be updated for inheritence or else things can break
	var/turf/destinationturf //Turf that we want to get to
	var/turf/lastturf //If this is the same as parentmob turf at HandleMovement() then we made no progress in moving, do HandleObstruction from there
	var/obj/effect/AINode/current_node //Current node the parentmob is at
	var/atom/atomtowalkto //Generic atom we're walking to; action states determine what type
	var/obj/effect/AINode/destination_node
	var/move_delay = 0 //The next world.time we can do a move at
	var/datum/action_state/action_state //If we have an action state we feed it info and see what it tells us what to do
	var/distance_to_maintain = 1 //Default distance to maintain from a target while in combat

/datum/ai_behavior/New()
	..()
	SSai.aidatums += src
	SSai_movement.list_of_lists[1] += src

/datum/ai_behavior/proc/Init() //Bandaid solution for initializing things

	for(var/obj/effect/AINode/node in range(7))
		if(node)
			current_node = node
			parentmob.forceMove(current_node.loc)
			//atomtowalkto = pick(current_node.datumnode.adjacent_nodes)
		break
	if(!current_node)
		qdel(parentmob)
		qdel(src)
		return
	action_state = new/datum/action_state/random_move(src)

/datum/ai_behavior/proc/Process() //Processes and updates things
	if(!parentmob)
		qdel(src)
		return
	lastturf = parentmob.loc
	if(action_state)
		action_state.Process()

/datum/ai_behavior/proc/action_completed(reason) //Action state was completed, let's replace it with something else
	switch(reason)
		if(FINISHED_MOVE)
			action_state = new/datum/action_state/random_move(src)

/datum/ai_behavior/proc/HandleObstruction() //If HandleMovement fails, do some HandleObstruction()

//Tile by tile movement electro boogaloo
/datum/ai_behavior/proc/ProcessMove()

	if(!parentmob.canmove)
		return 2
	var/totalmovedelay = 0
	switch(parentmob.m_intent)
		if(MOVE_INTENT_RUN)
			totalmovedelay += 2 + CONFIG_GET(number/movedelay/run_delay)
		if(MOVE_INTENT_WALK)
			totalmovedelay += 7 + CONFIG_GET(number/movedelay/walk_delay)
	totalmovedelay += parentmob.movement_delay()

	var/doubledelay = FALSE //If we add on additional delay due to it being a diagonal move
	//var/turf/directiontomove = get_dir(parentmob, get_step_towards(parentmob, atomtowalkto)) //We cache the direction so we can adjust move delay on things like diagonal move alongside other things
	var/dumb_direction = action_state.GetTargetDir(TRUE)
	if(!step(parentmob, dumb_direction)) //If this doesn't work, we're stuck
		HandleObstruction()
		return 2

	if(dumb_direction in GLOB.diagonals)
		doubledelay = TRUE

	if(doubledelay)
		move_delay = world.time + (totalmovedelay * SQRTWO)
		return totalmovedelay * SQRTWO
	else
		move_delay = world.time + totalmovedelay
		return totalmovedelay
