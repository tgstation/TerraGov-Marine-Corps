//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/element/ai_behavior/carbon/xeno

/datum/element/ai_behavior/Attach(datum/target, distance_to_maintain = 1, sidestep_prob = 0, attack_range = 1)
	. = ..()
	var/mob/mob_target = target
	mob_target.a_intent = INTENT_HARM //Killing time

//Returns a list of things we can walk to and attack to death
/datum/element/ai_behavior/carbon/xeno/get_targets(atom/source)
	var/list/return_result = list()
	for(var/h in cheap_get_humans_near(source, 8))
		var/mob/nearby_human = h
		if(nearby_human.stat == DEAD)
			continue
		return_result += h
	var/mob/living/carbon/xenomorph/xeno_source = source
	for(var/x in GLOB.alive_xeno_list)
		if(!xeno_source.issamexenohive(x)) //Xenomorphs not in our hive will attack as well!
			return_result += x
	for(var/turret in GLOB.marine_turrets)
		var/atom/atom_turret = turret
		if(QDELETED(atom_turret))
			continue
		if(!get_dist(source, atom_turret) <= 8)
			continue
		if(source.z != atom_turret.z)
			continue
		return_result += turret
	return return_result

/datum/element/ai_behavior/carbon/xeno/process()

	for(var/attached_mob in attached_to_mobs)
		switch(cur_actions[attached_mob])
			if(MOVING_TO_NODE)
				if(length(get_targets(attached_mob)))
					change_state(attached_mob, REASON_TARGET_SPOTTED)
			if(MOVING_TO_ATOM)
				change_state(attached_mob, REASON_REFRESH_TARGET) //We'll repick our targets as there could be more better targets to attack

	..()

/datum/element/ai_behavior/carbon/xeno/deal_with_obstacle(mob/mob)
	if(world.time < mob.next_move)
		return

	var/list/things_nearby = range(mob, 1) //Rather than doing multiple range() checks we can just archive it here for just this deal_with_obstacle
	for(var/obj/structure/obstacle in things_nearby)
		if(!(obstacle.resistance_flags & XENO_DAMAGEABLE))
			var/mob/living/carbon/xenomorph/xeno = mob
			obstacle.attack_alien(xeno)
			mob.face_atom(obstacle)
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
		lock.open(TRUE) //Force it open
		return //Don't try going on window frames after opening up airlocks dammit

	//Teleport onto those window frames, we also can't attempt to attack said window frames so this isn't in the obstacles loop
	for(var/obj/structure/window_frame/frame in things_nearby)
		mob.loc = frame.loc
		return

/datum/element/ai_behavior/carbon/xeno/attack_target(mob/mob)
	if(world.time < mob.next_move)
		return
	if(get_dist(atoms_to_walk_to[mob], mob) > attack_ranges[mob])
		return
	var/mob/living/carbon/xenomorph/xeno = mob
	mob.face_atom(atoms_to_walk_to[mob])
	if(ismob(atoms_to_walk_to[mob]))
		atoms_to_walk_to[mob].attack_alien(xeno)
	else if(ismachinery(atoms_to_walk_to[mob]))
		var/obj/machinery/thing = atoms_to_walk_to[mob]
		if(!(thing.resistance_flags & XENO_DAMAGEABLE))
			stack_trace("A xenomorph tried to attack a [atoms_to_walk_to[mob].name] that isn't considered XENO_DAMAGABLE according to resistance flags.")
		thing.attack_alien(xeno)
	xeno.changeNext_move(xeno.xeno_caste.attack_delay)

/datum/element/ai_behavior/carbon/xeno/change_state(mob/mob, reasoning_for)

	switch(reasoning_for)
		//At time of writing this, these are all the reasons currently implemented, although that will change once I feature bloat the AI again in the future
		if(REASON_FINISHED_NODE_MOVE, REASON_TARGET_KILLED, REASON_TARGET_SPOTTED, REASON_REFRESH_TARGET)
			//We wanna look for targets to kill nearby before considering randomly moving through nearby nodes again
			var/list/potential_targets = get_targets(mob) //Archive results
			if(!length(potential_targets)) //No targets, let's just randomly move to nodes
				reasoning_for = REASON_FINISHED_NODE_MOVE
				return ..()
			//There's targets nearby, kill the closest thing
			var/closest_dist = 999
			var/atom/favorable_target
			for(var/a in potential_targets)
				var/atom/target = a
				if(!(get_dist(mob, target) <= closest_dist))
					continue
				closest_dist = get_dist(mob, target)
				favorable_target = target

			clean_up(mob)
			atoms_to_walk_to[mob] = favorable_target
			cur_actions[mob] = MOVING_TO_ATOM
			mob.AddElement(/datum/element/pathfinder, atoms_to_walk_to[mob], distance_to_maintains[mob], sidestep_probs[mob])
			register_action_signals(mob, cur_actions[mob])

	return ..() //Random node moving

/datum/element/ai_behavior/carbon/xeno/register_action_signals(mob, action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attack_target, override = TRUE)
			if(ishuman(atoms_to_walk_to[mob]))
				RegisterSignal(atoms_to_walk_to[mob], COMSIG_MOB_DEATH, .proc/reason_target_killed, override = TRUE)
				return
			if(ismachinery(atoms_to_walk_to[mob]))
				RegisterSignal(atoms_to_walk_to[mob], COMSIG_PARENT_QDELETING, .proc/reason_target_killed, override = TRUE)
				return

	return ..()

/datum/element/ai_behavior/carbon/xeno/unregister_action_signals(mob, action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			UnregisterSignal(mob, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(ishuman(atoms_to_walk_to[mob]))
				UnregisterSignal(atoms_to_walk_to[mob], COMSIG_MOB_DEATH)
				return
			if(ismachinery(atoms_to_walk_to[mob]))
				UnregisterSignal(atoms_to_walk_to[mob], COMSIG_PARENT_QDELETING)
				return

	return ..()
