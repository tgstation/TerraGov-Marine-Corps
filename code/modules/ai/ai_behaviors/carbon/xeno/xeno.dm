//Generic template for application to a xeno/ mob, contains specific obstacle dealing alongside targeting only humans, xenos of a different hive and sentry turrets

/datum/ai_behavior/carbon/xeno
	sidestep_prob = 25
	identifier = IDENTIFIER_XENO

/datum/ai_behavior/carbon/xeno/New(loc, parent_to_assign, escorted_atom)
	..()
	mob_parent.a_intent = INTENT_HARM //Killing time

/datum/ai_behavior/carbon/xeno/look_for_new_state()
	switch(cur_action)
		if(ESCORTING_ATOM, MOVING_TO_NODE)
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_ALL, null, mob_parent.get_xeno_hivenumber())
			if(!next_target)
				return
			change_action(MOVING_TO_ATOM, next_target)
		if(MOVING_TO_ATOM)
			if(escorted_atom && get_dist(escorted_atom, mob_parent) > target_distance)
				change_action(ESCORTING_ATOM, escorted_atom)
				return
			var/atom/next_target = get_nearest_target(escorted_atom, target_distance, TARGET_ALL, null, mob_parent.get_xeno_hivenumber())
			if(!next_target)//We didn't find a target
				cleanup_current_action()
				late_initialize()
				return
			if(next_target == atom_to_walk_to)//We didn't find a better target
				return
			change_action(null, next_target)//We found a better target, change course!

/datum/ai_behavior/carbon/xeno/proc/attack_atom(atom/attacked)
	var/mob/living/carbon/xenomorph/xeno = mob_parent
	attacked.attack_alien(xeno, xeno.xeno_caste.melee_damage * xeno.xeno_melee_damage_modifier)
	xeno.changeNext_move(xeno.xeno_caste.attack_delay)

/datum/ai_behavior/carbon/xeno/deal_with_obstacle()
	if(world.time < mob_parent.next_move)
		return

	var/list/things_nearby = range(mob_parent, 1) //Rather than doing multiple range() checks we can just archive it here for just this deal_with_obstacle
	for(var/obj/structure/obstacle in things_nearby)
		if(obstacle.resistance_flags & XENO_DAMAGEABLE)
			mob_parent.face_atom(obstacle)
			INVOKE_ASYNC(src, .proc/attack_atom, obstacle)
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
	mob_parent.face_atom(atom_to_walk_to)
	if(ismob(atom_to_walk_to))
		attack_atom(atom_to_walk_to)
	else if(ismachinery(atom_to_walk_to))
		var/obj/machinery/thing = atom_to_walk_to
		if(!(thing.resistance_flags & XENO_DAMAGEABLE))
			stack_trace("A xenomorph tried to attack a [atom_to_walk_to.name] that isn't considered XENO_DAMAGABLE according to resistance flags.")
		attack_atom(atom_to_walk_to)

/datum/ai_behavior/carbon/xeno/register_action_signals(action_type)
	switch(action_type)
		if(MOVING_TO_ATOM)
			RegisterSignal(mob_parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attack_target)
			if(ishuman(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/ai_behavior.proc/look_for_new_state)
				return
			if(ismachinery(atom_to_walk_to))
				RegisterSignal(atom_to_walk_to, COMSIG_PARENT_PREQDELETED, /datum/ai_behavior.proc/look_for_new_state)
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
