/datum/component/bump_attack
	var/active = TRUE
	var/bump_action_path
	var/datum/action/bump_attack_toggle/toggle_action
	var/mob/living/bumper


/datum/component/bump_attack/Initialize()
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	bumper = parent
	if(ishuman(bumper))
		bump_action_path = .proc/human_bump_action
	else if(isxeno(bumper))
		bump_action_path = .proc/xeno_bump_action
	else
		bump_action_path = .proc/living_bump_action
	if(active)
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, bump_action_path)
	var/toggle_path
	toggle_path = .proc/living_activation_toggle
	toggle_action = new()
	toggle_action.give_action(bumper)
	toggle_action.update_button_icon(active)
	RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, toggle_path)

/datum/component/bump_attack/Destroy(force, silent)
	if(active)
		UnregisterSignal(bumper, COMSIG_MOVABLE_BUMP)
	QDEL_NULL(toggle_action)
	bumper = null
	return ..()


/datum/component/bump_attack/proc/living_activation_toggle(datum/source)
	active = !active
	to_chat(bumper, "<span class='notice'>You will now [active ? "attack" : "push"] enemies who are in your way.</span>")
	if(active)
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, bump_action_path)
	else
		UnregisterSignal(bumper, COMSIG_MOVABLE_BUMP)
	toggle_action.update_button_icon(active)


/datum/component/bump_attack/proc/living_bump_action_checks(atom/target)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BUMP_ATTACK))
		return NONE
	if(!isliving(target) || bumper.throwing || bumper.incapacitated())
		return NONE


/datum/component/bump_attack/proc/carbon_bump_action_checks(atom/target)
	var/mob/living/carbon/attacker = bumper
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	switch(attacker.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return NONE

/datum/component/bump_attack/proc/living_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	return living_do_bump_action(target)


/datum/component/bump_attack/proc/human_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/human_bump_action_checks, source, target)

/datum/component/bump_attack/proc/human_bump_action_checks(datum/source, atom/target)
	var/mob/living/carbon/human/attacker = bumper
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	var/mob/living/living_target = target
	if(attacker.faction == living_target.faction)
		return //FF
	return human_do_bump_action(target)

/datum/component/bump_attack/proc/xeno_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/attacker = bumper
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	if(attacker.issamexenohive(target))
		return //No more nibbling.
	return living_do_bump_action(target)


/datum/component/bump_attack/proc/living_do_bump_action(atom/target)
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	bumper.UnarmedAttack(target, TRUE)
	GLOB.round_statistics.xeno_bump_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_bump_attacks")
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, CLICK_CD_MELEE)
	return COMPONENT_BUMP_RESOLVED

/datum/component/bump_attack/proc/human_do_bump_action(atom/target)
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	var/obj/item/held_item = bumper.get_active_held_item()
	if(!held_item)
		bumper.UnarmedAttack(target, TRUE)
	else if(held_item.flags_item & CAN_BUMP_ATTACK)
		held_item.melee_attack_chain(bumper, target)
	else
		return COMPONENT_BUMP_RESOLVED
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, CLICK_CD_MELEE)
	return COMPONENT_BUMP_RESOLVED
