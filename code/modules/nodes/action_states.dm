/datum/action_state
	var/datum/ai_behavior/parent_ai

/datum/action_state/New(parent_to_hook_to)
	..()
	if(parent_to_hook_to)
		parent_ai = parent_to_hook_to

//Called from AI process, this is NOT for assigning new states or removing and choosing next state, that's the AI behavior job
//This is for updating things like random_move's next_node

/datum/action_state/proc/Process()

/datum/action_state/proc/CanComplete() //If we can complete the task

/datum/action_state/proc/OnComplete() //What we do once completing the the task, also inform the parent ai we finished it
	qdel(src)

/datum/action_state/proc/GetTargetDir(smart_pathfind) //This supplements the direction we will be walking in for pathfinding

/datum/action_state/random_move //We randomly move to a randomly picked node using simplistic node pathfinding VIA get_dir(start, end)
	var/obj/effect/AINode/next_node //The node we're going to for going to the destination, this is what we walk to
	var/list/weights //Want to make the random moving account for weights? here ya go then

/datum/action_state/random_move/New(parent_to_hook_to)
	..()
	if(SSai.is_pacifist || (!SSai.is_suicidal && (parent_ai.parentmob.health < (parent_ai.parentmob.maxHealth * SSai.retreat_health_threshold))))
		weights = list(ENEMY_PRESENCE = -200, DANGER_SCALE = -1)
	if(length(weights))
		next_node = parent_ai.current_node.GetBestAdjNode(weights)
	else
		next_node = pick(shuffle(parent_ai.current_node.datumnode.adjacent_nodes)) //Pick some random nodes

/datum/action_state/random_move/Process()
	if(CanComplete())
		node_reached()
		parent_ai.action_completed(FINISHED_MOVE)
		OnComplete()

/datum/action_state/random_move/proc/node_reached() //What we do upon reaching the node
	parent_ai.current_node = next_node

/datum/action_state/random_move/GetTargetDir(smart_pathfind) //We give it a direction to the target
	if(smart_pathfind)
		return get_dir(parent_ai.parentmob, get_step_to(parent_ai.parentmob, next_node))
	return get_dir(parent_ai.parentmob, next_node)

/datum/action_state/random_move/CanComplete()
	return get_dist(parent_ai.parentmob, next_node) < 2 ? TRUE : FALSE

/datum/action_state/random_move/scout //The scouting version, we look for humans nearby and do things if we find em

/datum/action_state/random_move/scout/node_reached()
	//Looks for enemies nearby if not pacifist, if there are, we gonna go do some hunt and destroy otherwise more scouting
	if(SSai.is_pacifist)
		..()
		parent_ai.action_completed(FINISHED_MOVE)
		qdel(src)
		return

	var/list/potential_enemies = cheap_get_humans_near(parent_ai.parentmob, 10)
	if(length(potential_enemies))
		if(get_dist(parent_ai.parentmob, parent_ai.current_node) < get_dist(parent_ai.parentmob, next_node))
			parent_ai.current_node.add_to_notable_nodes(ENEMY_PRESENCE)
			parent_ai.current_node.datumnode.set_weight(ENEMY_PRESENCE, potential_enemies.len)
		else
			next_node.add_to_notable_nodes(ENEMY_PRESENCE)
			next_node.datumnode.set_weight(ENEMY_PRESENCE, potential_enemies.len)
		..()
		parent_ai.action_completed(ENEMY_CONTACT) //Enemy contact, lets get hunt and destroy up
		qdel(src)
		return

	//No enemies located
	..()
	parent_ai.action_completed(FINISHED_MOVE)

/datum/action_state/move_to_node //Move to a specific node
	var/obj/effect/AINode/next_node //The node we're going to for going to the destination, this is what we walk to
	var/obj/effect/AINode/destination_node //The overall node we're going to

/datum/action_state/move_to_node/Process()
	if(!next_node)
		next_node = get_node_towards(parent_ai.current_node, destination_node)

	if(get_dist(parent_ai.parentmob, next_node) < 2)
		parent_ai.current_node = next_node
		next_node = get_node_towards(parent_ai.current_node, destination_node)

	if(CanComplete())
		OnComplete()

/datum/action_state/move_to_node/OnComplete() //What we do once completing the the task, also inform the parent ai we finished it
	parent_ai.action_completed(FINISHED_MOVE)
	qdel(src)

/datum/action_state/move_to_node/CanComplete()
	return parent_ai.current_node == destination_node

/datum/action_state/move_to_node/GetTargetDir(smart_pathfind) //We give it a direction to the target
	if(smart_pathfind)
		return get_dir(parent_ai.parentmob, get_step_to(parent_ai.parentmob, next_node))
	return get_dir(parent_ai.parentmob, next_node)

/datum/action_state/move_to_node/proc/next_node_reached() //If we want to do something once hitting the next node, we do it here
	parent_ai.current_node = next_node
	next_node = get_node_towards(parent_ai.current_node, destination_node)
	if(!next_node) //If get_node_towards doesn't have a valid path, then let's tell ma44 because he still doesn't have dijkstra
		stack_trace("[parent_ai.parentmob.name] failed to get a new path at node [AREACOORD(parent_ai.current_node)] moving to [AREACOORD(destination_node)]")
		OnComplete()

/datum/action_state/hunt_and_destroy //We look for nearby humans and hunt, if it died, look for more
	var/atomtowalkto
	var/distance_to_maintain = 1 //Keep a distance to the atomtowalkto at this or lower, higher numbers mean kiting

/datum/action_state/hunt_and_destroy/New(parent_to_hook_to)
	..()
	distance_to_maintain = parent_ai.distance_to_maintain
	Process()

/datum/action_state/hunt_and_destroy/GetTargetDir(smart_pathfind)
	//Move to that target
	if(get_dist(parent_ai.parentmob, atomtowalkto) > distance_to_maintain) //Too far away, close in
		if(smart_pathfind)
			return get_dir(parent_ai.parentmob, get_step_to(parent_ai.parentmob, atomtowalkto, distance_to_maintain))
		return get_dir(parent_ai.parentmob, atomtowalkto)

	if(get_dist(parent_ai.parentmob, atomtowalkto) < distance_to_maintain) //Too close, get out
		if(smart_pathfind)
			return get_dir(parent_ai.parentmob, get_step_away(parent_ai.parentmob, atomtowalkto, distance_to_maintain))
		return get_dir(atomtowalkto, parent_ai.parentmob)

	//We're at the edge of our range, let's go left or right if it's enabled
	if(prob(SSai.prob_sidestep_melee))
		if(get_dir(parent_ai.parentmob, atomtowalkto)) //If we're on top of a human IE pounced, get_dir returns null
			return(pick(shuffle(LeftAndRightOfDir(get_dir(parent_ai.parentmob, atomtowalkto)))))
		else //We'll step in a random direction instead
			return(pick(shuffle(CARDINAL_ALL_DIRS)))

/datum/action_state/hunt_and_destroy/Process()
	var/datum/ai_behavior/xeno/parent_ai2 = parent_ai
	if(!SSai.is_suicidal) //If xenos aren't suicidal, check for low health and if on fire
		if(parent_ai.parentmob.health < (parent_ai.parentmob.maxHealth * SSai.retreat_health_threshold)) //Abort attack let's run!
			parent_ai.action_completed(DISENGAGE)
			qdel(src)
			return

		//We're on fire, let's get a move on out of here like true loreful xenos (unless its a ravager then screw you)
		var/mob/living/carbon/xenomorph/parentmob2 = parent_ai.parentmob
		if(!(parentmob2.xeno_caste.caste_flags && CASTE_FIRE_IMMUNE) && prob(2 * parentmob2.fire_stacks * (parentmob2.xeno_caste.fire_resist)))
			parent_ai.action_completed(DISENGAGE)
			qdel(src)
			return

	if(!atomtowalkto)
		var/list/potential_enemies = cheap_get_humans_near(parent_ai.parentmob, 10)
		if(length(potential_enemies))
			atomtowalkto = pick(shuffle(potential_enemies))
		else
			parent_ai.action_completed(NO_ENEMIES_FOUND) //No enemies located, back to scouting
			return
	if(get_dist(parent_ai.parentmob, atomtowalkto) <= 1)
		if(istype(parent_ai2))
			parent_ai2.attack_target(atomtowalkto)
	if(CanComplete())
		OnComplete()

/datum/action_state/hunt_and_destroy/CanComplete() //Returns true if the atom we're walking to is in range, otherwise false
	var/mob/living/carbon/target = atomtowalkto
	return target.stat == DEAD ? TRUE : FALSE

/datum/action_state/hunt_and_destroy/OnComplete() //See if we have any more targets to kill, otherwise delet
	var/list/potential_enemies = cheap_get_humans_near(parent_ai.parentmob, 10)
	if(potential_enemies.len)
		atomtowalkto = pick(shuffle(potential_enemies))
		return
	else
		parent_ai.action_completed(NO_ENEMIES_FOUND)
		..()
