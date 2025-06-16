/datum/ai_behavior/xeno/illusion
	target_distance = 3 //We attack only nearby
	base_action = ESCORTING_ATOM
	is_offered_on_creation = FALSE
	/// How close a human has to be in order for illusions to react
	var/illusion_react_range = 5

/datum/ai_behavior/xeno/illusion/New(loc, mob/parent_to_assign, atom/escorted_atom)
	if(!escorted_atom)
		base_action = MOVING_TO_NODE
	..()

/// We want a separate look_for_new_state in order to make illusions behave as we wish
/datum/ai_behavior/xeno/illusion/look_for_new_state()
	switch(current_action)
		if(ESCORTING_ATOM)
			for(var/mob/living/carbon/human/victim in view(illusion_react_range, mob_parent))
				if(victim.stat == DEAD)
					continue
				melee_interact(null, victim)
				set_escorted_atom(src, victim)
				return

/datum/ai_behavior/xeno/illusion/melee_interact(datum/source, atom/interactee, melee_tool)
	if(!interactee)
		interactee = atom_to_walk_to
	var/mob/illusion/illusion_parent = mob_parent
	var/mob/living/carbon/xenomorph/original_xeno = illusion_parent.original_mob
	mob_parent.changeNext_move(original_xeno.xeno_caste.attack_delay)
	if(ismob(interactee))
		mob_parent.do_attack_animation(interactee, ATTACK_EFFECT_REDSLASH)
		playsound(mob_parent.loc, SFX_ALIEN_CLAW_FLESH, 25, 1)
		return
	mob_parent.do_attack_animation(interactee, ATTACK_EFFECT_CLAW)

/datum/ai_behavior/xeno/fleeing_illusion
	target_distance = 15 // We will run away forever.
	base_action = ESCORTING_ATOM
	is_offered_on_creation = FALSE

/datum/ai_behavior/xeno/fleeing_illusion/New(loc, mob/parent_to_assign, atom/escorted_atom)
	if(!escorted_atom)
		base_action = MOVING_TO_NODE
	..()

/// We want a separate look_for_new_state in order to make illusions behave as we wish
/datum/ai_behavior/xeno/fleeing_illusion/look_for_new_state()
	switch(current_action)
		if(ESCORTING_ATOM)
			change_action(MOVING_TO_SAFETY, escorted_atom, list(INFINITY))
