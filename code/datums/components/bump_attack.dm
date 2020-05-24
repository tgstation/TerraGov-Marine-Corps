/datum/component/bump_attack
	var/active = TRUE
	var/bump_action_path
	var/cross_action_path
	var/datum/action/bump_attack_toggle/toggle_action


/datum/component/bump_attack/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	toggle_action = new()
	var/toggle_path
	if(ishuman(parent))
		bump_action_path = .proc/human_bump_action
		cross_action_path = .proc/human_bump_action
	else if(isxeno(parent))
		bump_action_path = .proc/xeno_bump_action
		cross_action_path = .proc/xeno_bump_action
	else
		bump_action_path = .proc/living_bump_action
		cross_action_path = .proc/living_bump_action
	toggle_path = .proc/living_activation_toggle
	toggle_action.give_action(parent)
	toggle_action.update_button_icon(active)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, toggle_path)
	if(active)
		RegisterSignal(parent, COMSIG_MOVABLE_BUMP, bump_action_path)
		RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, cross_action_path)

/datum/component/bump_attack/Destroy(force, silent)
	QDEL_NULL(toggle_action)
	return ..()


/datum/component/bump_attack/proc/living_activation_toggle(datum/source)
	var/mob/living/bumper = parent
	active = !active
	to_chat(bumper, "<span class='notice'>You will now [active ? "attack" : "push"] enemies who are in your way.</span>")
	if(active)
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, bump_action_path)
		RegisterSignal(bumper, COMSIG_MOVABLE_CROSSED, cross_action_path)
	else
		UnregisterSignal(bumper, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_CROSSED))
	toggle_action.update_button_icon(active)


/datum/component/bump_attack/proc/living_bump_action_checks(atom/target)
	if(COOLDOWN_CHECK(src, COOLDOWN_BUMP_ATTACK))
		return NONE
	var/mob/living/bumper = parent
	if(!isliving(target) || bumper.throwing || bumper.incapacitated())
		return NONE


/datum/component/bump_attack/proc/carbon_bump_action_checks(atom/target)
	var/mob/living/carbon/bumper = parent
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	switch(bumper.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return NONE
	if(bumper.get_active_held_item())
		return NONE //We have something in our hand.


/datum/component/bump_attack/proc/living_bump_action(datum/source, atom/target)
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	return living_do_bump_action(target)


/datum/component/bump_attack/proc/human_bump_action(datum/source, atom/target)
	var/mob/living/carbon/human/bumper = parent
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	var/mob/living/living_target = target
	if(bumper.faction == living_target.faction)
		return //FF
	return living_do_bump_action(target)


/datum/component/bump_attack/proc/xeno_bump_action(datum/source, atom/target)
	var/mob/living/carbon/xenomorph/bumper = parent
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	if(bumper.issamexenohive(target))
		return //No more nibbling.
	return living_do_bump_action(target)


/datum/component/bump_attack/proc/living_do_bump_action(atom/target)
	var/mob/living/bumper = parent
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	bumper.UnarmedAttack(target, TRUE)
	COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, CLICK_CD_MELEE)
	return COMPONENT_BUMP_RESOLVED
