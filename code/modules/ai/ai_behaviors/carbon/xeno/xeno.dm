//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/carbon/xeno
	sidestep_prob = 25
	identifier = IDENTIFIER_XENO

/datum/ai_behavior/carbon/xeno/New(loc, parent_to_assign)
	..()
	mob_parent.a_intent = INTENT_HARM //Killing time

//Returns a list of things we can walk to and attack to death
/datum/ai_behavior/carbon/xeno/get_targets()
	var/list/return_result = list()
	for(var/h in cheap_get_humans_near(mob_parent, 8))
		var/mob/nearby_human = h
		if(nearby_human.stat == DEAD)
			continue
		return_result += h
	var/mob/living/carbon/xenomorph/xeno_parent = mob_parent
	for(var/x in cheap_get_xenos_near(mob_parent, 8))
		if(xeno_parent.issamexenohive(x)) //Xenomorphs not in our hive will be attacked as well!
			continue
		var/mob/nearby_xeno = x
		if(nearby_xeno.stat == DEAD)
			continue
		if((nearby_xeno.status_flags & GODMODE) || (nearby_xeno.status_flags & INCORPOREAL)) //No attacking invulnerable/ai's eye!
			continue
		return_result += x
	for(var/turret in GLOB.marine_turrets)
		var/atom/atom_turret = turret
		if(!(get_dist(mob_parent, atom_turret) <= 8))
			continue
		if(mob_parent.z != atom_turret.z)
			continue
		return_result += turret
	return return_result

/datum/ai_behavior/carbon/xeno/process()
	switch(cur_action)
		if(MOVING_TO_NODE)
			if(length(get_targets()))
				change_state(REASON_TARGET_SPOTTED)
		if(MOVING_TO_ATOM)
			change_state(REASON_REFRESH_TARGET) //We'll repick our targets as there could be more better targets to attack
	return ..()

/datum/ai_behavior/carbon/xeno/deal_with_obstacle()
	if(world.time < mob_parent.next_move)
		return

	var/list/things_nearby = range(mob_parent, 1) //Rather than doing multiple range() checks we can just archive it here for just this deal_with_obstacle
	for(var/obj/structure/obstacle in things_nearby)
		if(obstacle.resistance_flags & XENO_DAMAGEABLE)
			var/mob/living/carbon/xenomorph/xeno = mob_parent
			INVOKE_ASYNC(obstacle, /atom.proc/attack_alien, xeno)
			mob_parent.face_atom(obstacle)
			xeno.changeNext_move(xeno.xeno_caste.attack_delay)
			return

	//Cheat mode: insta open airlocks
	for(var/obj/machinery/door/airlock/lock in things_nearby)
		if(!lock.density) //Airlock is already open no need to force it open again
			continue
		if(lock.operating) //Airlock already doing something
			continue
		if(lock.welded) //It's welded, can't force that open
			continue
		lock.open(TRUE)
		return //Don't try going on window frames after opening up airlocks dammit

	//Teleport onto those window frames, we also can't attempt to attack said window frames so this isn't in the obstacles loop
	for(var/obj/structure/window_frame/frame in things_nearby)
		mob_parent.loc = frame.loc
		return

/datum/ai_behavior/carbon/xeno/attack_target()
	if(world.time < mob_parent.next_move)
		return
	if(get_dist(atom_to_walk_to, mob_parent) > attack_range)
		return
	var/mob/living/carbon/xenomorph/xeno = mob_parent
	mob_parent.face_atom(atom_to_walk_to)
	if(ismob(atom_to_walk_to))
		atom_to_walk_to.attack_alien(xeno)
	else if(ismachinery(atom_to_walk_to))
		var/obj/machinery/thing = atom_to_walk_to
		if(!(thing.resistance_flags & XENO_DAMAGEABLE))
			stack_trace("A xenomorph tried to attack a [atom_to_walk_to.name] that isn't considered XENO_DAMAGABLE according to resistance flags.")
		thing.attack_alien(xeno, xeno.xeno_caste.melee_damage * xeno.xeno_melee_damage_modifier)
	xeno.changeNext_move(xeno.xeno_caste.attack_delay)

/datum/ai_behavior/carbon/xeno/change_state(reasoning_for)

	switch(reasoning_for)
		//At time of writing this, these are all the reasons currently implemented, although that will change once I feature bloat the AI again in the future
		if(REASON_FINISHED_NODE_MOVE, REASON_TARGET_KILLED, REASON_TARGET_SPOTTED, REASON_REFRESH_TARGET)
			//We wanna look for targets to kill nearby before considering randomly moving through nearby nodes again
			var/list/potential_targets = get_targets() //Archive results
			if(!length(potential_targets)) //No targets, let's just randomly move to nodes
				reasoning_for = REASON_FINISHED_NODE_MOVE
				return ..()
			//There's targets nearby, kill the closest thing
			var/closest_dist = 999
			var/atom/favorable_target
			for(var/a in potential_targets)
				var/atom/target = a
				if(!(get_dist(mob_parent, target) <= closest_dist))
					continue
				closest_dist = get_dist(mob_parent, target)
				favorable_target = target

			cleanup_current_action()
			atom_to_walk_to = favorable_target
			cur_action = MOVING_TO_ATOM
			mob_parent.AddElement(/datum/element/pathfinder, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			register_action_signals(cur_action)


	return ..() //Random node moving

/datum/ai_behavior/carbon/xeno/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attack_target)
			if(ishuman(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, .proc/reason_target_killed)
				return
			if(ismachinery(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_PARENT_PREQDELETED, .proc/reason_target_killed)
				return

	return ..()

/datum/ai_behavior/carbon/xeno/unregister_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			UnregisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(ishuman(atom_to_walk_to))
				UnregisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH)
				return
			if(ismachinery(atom_to_walk_to))
				UnregisterSignal(atom_to_walk_to, COMSIG_PARENT_PREQDELETED)
				return

	return ..()
