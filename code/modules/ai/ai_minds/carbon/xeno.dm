//Generic ai mind, goes around attacking but with the alien attack proc instead of carbon fist
/datum/ai_mind/carbon/xeno

//Returns a list of things we can walk to and attack to death
/datum/ai_mind/carbon/xeno/get_targets()
	var/list/return_result = list()
	for(var/mob/living/carbon/human/h in cheap_get_humans_near(mob_parent, 7))
		if(h && h.stat != DEAD)
			return_result += h
	return return_result

/datum/ai_mind/carbon/xeno/get_new_state(reason_for)
	if(reason_for == REASON_TARGET_KILLED || reason_for == REASON_FINISHED_NODE_MOVE)
		var/list/potential_targets = get_targets() //Define here as if there's targets we don't need to redundently call the get targets
		if(length(potential_targets)) //There's alive humans nearby, time to kill
			atom_to_walk_to = pick(potential_targets)
			cur_action_state = /datum/element/action_state/move_to_atom
			return list(cur_action_state, atom_to_walk_to, distance_to_maintain, 75)
		else //No targets, let's just randomly move to nodes
			return ..()
	else //We didn't arrive to a node and we didn't recently kill a target, chances are reason_for is null so let parent handle it
		return ..()

/datum/ai_mind/carbon/xeno/get_signals_to_reg()
	if(istype(atom_to_walk_to, /mob/living/carbon/human))
		return list(
				list(mob_parent, COMSIG_CLOSE_TO_MOB, /datum/component/ai_behavior/.proc/mind_attack_target),
				list(atom_to_walk_to, COMSIG_MOB_DEATH, /datum/component/ai_behavior/.proc/reason_target_killed)
				)
	return ..() //Walking to a node

/datum/ai_mind/carbon/xeno/get_signals_to_unreg()
	if(atom_to_walk_to)
		if(istype(atom_to_walk_to, /mob/living/carbon/human))
			return list(
					list(mob_parent, COMSIG_CLOSE_TO_NODE),
					list(atom_to_walk_to, COMSIG_MOB_DEATH)
					)
	return ..() //Walking to a node

/datum/ai_mind/carbon/xeno/attack_target()
	if(world.time < mob_parent.next_move)
		var/mob/living/carbon/xenomorph/xeno = mob_parent
		atom_to_walk_to.attack_alien(xeno, force_intent = INTENT_HARM)
		xeno.changeNext_move(xeno.xeno_caste.attack_delay)
