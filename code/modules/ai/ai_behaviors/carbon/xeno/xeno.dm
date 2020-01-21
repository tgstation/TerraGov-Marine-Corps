//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/carbon/xeno
	sidestep_prob = 100 //Kill everything

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
	for(var/x in GLOB.alive_xeno_list)
		if(!xeno_parent.issamexenohive(x)) //Xenomorphs not in our hive will attack as well!
			return_result += x
	for(var/turret in GLOB.marine_turrets)
		var/atom/atom_turret = turret
		if(QDELETED(atom_turret))
			continue
		if(!get_dist(mob_parent, atom_turret) <= 8)
			continue
		if(mob_parent.z != atom_turret.z)
			continue
		return_result += turret
	return return_result

/datum/ai_behavior/carbon/xeno/do_process()
	if(isainode(atom_to_walk_to) && length(get_targets()))
		return REASON_TARGET_SPOTTED
	if(istype(atom_to_walk_to, /mob/living/carbon/human) || istype(atom_to_walk_to, /obj/machinery/marine_turret))
		return REASON_REFRESH_TARGET //We'll repick our targets as there could be more better targets to attack
	return ..()

/datum/ai_behavior/carbon/xeno/deal_with_obstacle()
	if(!world.time > mob_parent.next_move)
		return

	var/list/things_nearby = range(mob_parent, 1) //Rather than doing multiple range() checks we can just archive it here for just this deal_with_obstacle
	for(var/obj/structure/obstacle in things_nearby)
		if(!(obstacle.resistance_flags & XENO_DAMAGEABLE))
			var/mob/living/carbon/xenomorph/xeno = mob_parent
			obstacle.attack_alien(xeno)
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
		lock.open()
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
		thing.attack_alien(xeno)
	xeno.changeNext_move(xeno.xeno_caste.attack_delay)

/datum/ai_behavior/carbon/xeno/get_new_state(reason_for)
	switch(reason_for) //Lets look for targets when we're recently done doing an action, gotta find enemies to kill
		if(REASON_FINISHED_NODE_MOVE, REASON_TARGET_KILLED, REASON_TARGET_SPOTTED, REASON_REFRESH_TARGET)
			var/list/potential_targets = get_targets() //Define here as if there's targets we don't need to redundently call the get targets
			if(!length(potential_targets))
				//No targets, let's just randomly move to nodes
				reason_for = REASON_FINISHED_NODE_MOVE
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
			if(!favorable_target)
				reason_for = REASON_FINISHED_NODE_MOVE
				return ..()
			atom_to_walk_to = favorable_target
			cur_action_state = /datum/element/action_state/move_to_atom
			return list(cur_action_state, atom_to_walk_to, distance_to_maintain, sidestep_prob)

	//If we get here reason_for is null or some other odd reason, let parent handle that
	return ..()

/datum/ai_behavior/carbon/xeno/get_signals_to_reg()
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		return list(
				list(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, /datum/component/ai_controller/.proc/mind_attack_target),
				list(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/component/ai_controller/.proc/reason_target_killed)
				)

	if(istype(atom_to_walk_to, /obj/machinery)) //Machine targets are usually destroyed rather than having a static health pool til dead (but not qdel) like humans are
		return list(
				list(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, /datum/component/ai_controller/.proc/mind_attack_target),
				list(atom_to_walk_to, COMSIG_PARENT_QDELETING, /datum/component/ai_controller/.proc/reason_target_killed)
				)

	return ..() //Walking to a node

/datum/ai_behavior/carbon/xeno/get_signals_to_unreg()
	if(atom_to_walk_to)

		if(istype(atom_to_walk_to, /mob/living/carbon/human))
			return list(
					list(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE),
					list(atom_to_walk_to, COMSIG_MOB_DEATH)
					)

		if(istype(atom_to_walk_to, /obj/machinery))
			return list(
					list(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE),
					list(atom_to_walk_to, COMSIG_PARENT_QDELETING)
					)
	return ..() //Walking to a node
