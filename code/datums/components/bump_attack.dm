/datum/component/bump_attack
	var/active = FALSE
	var/bump_action_path
	var/datum/action/bump_attack_toggle/toggle_action


/datum/component/bump_attack/Initialize()
	. = ..()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	toggle_action = new()
	var/toggle_path
	if(isliving(parent))
		if(ishuman(parent))
			bump_action_path = .proc/human_bump_action
		else if(isxeno(parent))
			bump_action_path = .proc/xeno_bump_action
		else
			bump_action_path = .proc/living_bump_action
		toggle_path = .proc/living_activation_toggle
		toggle_action.give_action(parent)
	else
		return COMPONENT_INCOMPATIBLE
	toggle_action.update_button_icon(active)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, toggle_path)


/datum/component/bump_attack/Destroy(force, silent)
	QDEL_NULL(toggle_action)
	return ..()


/datum/component/bump_attack/proc/living_activation_toggle(datum/source, atom/target)
	var/mob/living/bumper = parent
	active = !active
	to_chat(bumper, "<span class='notice'>You will now [active ? "attack" : "push"] enemies who are in your way.</span>")
	if(active)
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, bump_action_path)
	else
		UnregisterSignal(bumper, COMSIG_MOVABLE_BUMP)
	toggle_action.update_button_icon(active)


/datum/component/bump_attack/proc/living_bump_action(datum/source, atom/target)
	var/mob/living/bumper = parent
	if(!isliving(target) || bumper.throwing || bumper.incapacitated())
		return
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	bumper.UnarmedAttack(target, TRUE)
	return COMPONENT_BUMP_RESOLVED


/datum/component/bump_attack/proc/human_bump_action(datum/source, atom/target)
	var/mob/living/carbon/human/bumper = parent
	if(!isliving(target) || bumper.throwing || bumper.incapacitated())
		return
	switch(bumper.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return
	var/mob/living/living_target = target
	if(bumper.faction == living_target.faction)
		return //FF
	if(bumper.get_active_held_item())
		return //We have something in our hand.
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED
	bumper.UnarmedAttack(target, TRUE)
	return COMPONENT_BUMP_RESOLVED


/datum/component/bump_attack/proc/xeno_bump_action(datum/source, atom/target)
	var/mob/living/carbon/xenomorph/bumper = parent
	if(!isliving(target) || bumper.throwing || bumper.incapacitated())
		return
	switch(bumper.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return
	if(bumper.issamexenohive(target))
		return //No more nibbling.
	if(bumper.get_active_held_item())
		return
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED
	bumper.UnarmedAttack(target, TRUE)
	return COMPONENT_BUMP_RESOLVED
