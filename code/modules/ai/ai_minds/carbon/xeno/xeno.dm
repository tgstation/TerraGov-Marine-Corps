//Generic ai mind, goes around attacking but with the alien attack proc instead of carbon fist
/datum/ai_mind/carbon/xeno
	sidestep_prob = 100

//Returns a list of things we can walk to and attack to death
/datum/ai_mind/carbon/xeno/get_targets()
	var/list/return_result = list()
	for(var/mob/living/carbon/human/h in cheap_get_humans_near(mob_parent, 8))
		if(h && h.stat != DEAD)
			return_result += h
	var/mob/living/carbon/xenomorph/mob2 = mob_parent
	for(var/mob/living/carbon/xenomorph/x in GLOB.alive_xeno_list)
		if(x.hivenumber != mob2.hivenumber) //Xenomorphs not in our hive will attack as well!
			return_result += x
	for(var/atom/turret in GLOB.marine_turrets)
		if(!turret.gc_destroyed && get_dist(mob_parent, turret) <= 8 && mob_parent.z == turret.z)
			return_result += turret
	return return_result

/datum/ai_mind/carbon/xeno/do_process()
	if(istype(atom_to_walk_to, /obj/effect/ai_node) && length(get_targets()))
		return REASON_TARGET_SPOTTED
	if(istype(atom_to_walk_to, /mob/living/carbon/human) || istype(atom_to_walk_to, /obj/machinery/marine_turret))
		return REASON_REFRESH_TARGET //We'll repick our targets once we're in combat

/datum/ai_mind/carbon/xeno/deal_with_obstacle()
	if(world.time > mob_parent.next_move)

		for(var/obj/structure/obstacle in range(mob_parent, 1))
			if(obstacle && (obstacle.resistance_flags & XENO_DAMAGEABLE))
				var/mob/living/carbon/xenomorph/xeno = mob_parent
				obstacle.attack_alien(xeno)
				mob_parent.face_atom(obstacle)
				xeno.changeNext_move(xeno.xeno_caste.attack_delay)
				break

		//Cheat mode: insta open airlocks
		for(var/obj/machinery/door/airlock/lock in range(mob_parent, 1))
			if(lock && lock.density && !lock.operating && !lock.welded)
				lock.open()
				return //Don't try going on window frames dammit

		for(var/obj/structure/window in range(mob_parent, 1))
			if(istype(window, /obj/structure/window_frame)) //Teleport onto that window
				mob_parent.loc = window.loc
				break

/datum/ai_mind/carbon/xeno/get_new_state(reason_for)
	if(reason_for == REASON_TARGET_KILLED || reason_for == REASON_FINISHED_NODE_MOVE || reason_for == REASON_TARGET_SPOTTED || reason_for == REASON_REFRESH_TARGET)
		var/list/potential_targets = get_targets() //Define here as if there's targets we don't need to redundently call the get targets
		if(length(potential_targets)) //There's targets nearby, kill the closest thing
			var/closest_dist = 999
			var/atom/favorable_target
			for(var/atom/a in potential_targets)
				if(get_dist(mob_parent, a) <= closest_dist)
					closest_dist = get_dist(mob_parent, a)
					favorable_target = a
			if(favorable_target)
				atom_to_walk_to = favorable_target
				cur_action_state = /datum/element/action_state/move_to_atom
				return list(cur_action_state, atom_to_walk_to, distance_to_maintain, sidestep_prob)
			else
				reason_for = REASON_TARGET_KILLED //Probably no more targets
		else //No targets, let's just randomly move to nodes
			return ..()
	else //If we get here reason_for is null, let parent handle that
		return ..()

/datum/ai_mind/carbon/xeno/get_signals_to_reg()
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		return list(
				list(mob_parent, COMSIG_CLOSE_TO_MOB, /datum/component/ai_behavior/.proc/mind_attack_target),
				list(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/component/ai_behavior/.proc/reason_target_killed)
				)

	if(istype(atom_to_walk_to, /obj/machinery))
		return list(
				list(mob_parent, COMSIG_CLOSE_TO_MACHINERY, /datum/component/ai_behavior/.proc/mind_attack_target),
				list(atom_to_walk_to, COMSIG_PARENT_QDELETING, /datum/component/ai_behavior/.proc/reason_target_killed)
				)

	return ..() //Walking to a node

/datum/ai_mind/carbon/xeno/get_signals_to_unreg()
	if(atom_to_walk_to)

		if(istype(atom_to_walk_to, /mob/living/carbon/human))
			return list(
					list(mob_parent, COMSIG_CLOSE_TO_MOB),
					list(atom_to_walk_to, COMSIG_MOB_DEATH)
					)

		if(istype(atom_to_walk_to, /obj/machinery))
			return list(
					list(mob_parent, COMSIG_CLOSE_TO_MACHINERY),
					list(atom_to_walk_to, COMSIG_PARENT_QDELETING)
					)
	return ..() //Walking to a node

/datum/ai_mind/carbon/xeno/attack_target()
	if(get_dist(atom_to_walk_to, mob_parent) <= attack_range && world.time > mob_parent.next_move)
		var/mob/living/carbon/xenomorph/xeno = mob_parent
		if(istype(atom_to_walk_to, /mob))
			var/mob/target = atom_to_walk_to //Typed for parameter
			target.attack_alien(xeno, force_intent = INTENT_HARM)
		else if(istype(atom_to_walk_to, /obj/machinery))
			var/obj/machinery/thing = atom_to_walk_to
			if(!(thing.resistance_flags & XENO_DAMAGEABLE))
				stack_trace("A xenomorph tried to attack a [atom_to_walk_to.name] that isn't considered XENO_DAMAGABLE according to resistance flags.")
			thing.attack_alien(xeno)
		xeno.changeNext_move(xeno.xeno_caste.attack_delay)
		mob_parent.face_atom(atom_to_walk_to)
