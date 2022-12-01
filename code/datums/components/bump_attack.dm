/datum/component/bump_attack
	///Whether the component is active
	var/active = FALSE
	///The proc to register with COMSIG_MOVABLE_BUMP, based on what kind of mob the component is on
	var/bump_action_path
	///Action used to turn bump attack on/off manually
	var/datum/action/bump_attack_toggle/toggle_action

/datum/component/bump_attack/Initialize(enabled = TRUE, has_button = TRUE, silent_activation = FALSE)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(ishuman(parent))
		RegisterSignal(parent, COMSIG_ITEM_TOGGLE_BUMP_ATTACK, .proc/living_activation_toggle)
		bump_action_path = .proc/human_bump_action
	else if(isxeno(parent))
		bump_action_path = .proc/xeno_bump_action
	else
		bump_action_path = .proc/living_bump_action
	if(has_button)
		toggle_action = new()
		toggle_action.give_action(parent)
		toggle_action.attacking = active
		toggle_action.update_button_icon()
		RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, .proc/living_activation_toggle)
	living_activation_toggle(should_enable = enabled, silent_activation = silent_activation)

/datum/component/bump_attack/UnregisterFromParent()
	toggle_action?.remove_action(parent)
	UnregisterSignal(parent, COMSIG_MOVABLE_BUMP)

/datum/component/bump_attack/Destroy(force, silent)
	QDEL_NULL(toggle_action)
	return ..()


/datum/component/bump_attack/proc/living_activation_toggle(datum/source, should_enable = !active, silent_activation)
	if(should_enable == active)
		return
	var/mob/living/bumper = parent
	if(!silent_activation)
		bumper.balloon_alert(bumper, "Will now [should_enable ? "attack" : "push"] enemies in your way.")
	toggle_action?.attacking = active
	toggle_action?.update_button_icon()
	if(should_enable)
		active = TRUE
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, bump_action_path)
		return

	var/obj/item/held_item = bumper.get_inactive_held_item()
	if(held_item?.flags_item & CAN_BUMP_ATTACK)
		return
	active = FALSE
	UnregisterSignal(bumper, COMSIG_MOVABLE_BUMP)


/datum/component/bump_attack/proc/living_bump_action_checks(atom/target)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BUMP_ATTACK))
		return NONE
	var/mob/living/bumper = parent
	if(!(target.flags_atom & BUMP_ATTACKABLE) || bumper.throwing || bumper.incapacitated())
		return NONE


/datum/component/bump_attack/proc/carbon_bump_action_checks(atom/target)
	var/mob/living/carbon/bumper = parent
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	switch(bumper.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return NONE

/datum/component/bump_attack/proc/living_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	return living_do_bump_action(target)


///Handles human pre-bump attack checks
/datum/component/bump_attack/proc/human_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/bumper = parent
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	var/mob/living/living_target = target
	if(bumper.faction == living_target.faction)
		return //FF
	INVOKE_ASYNC(src, .proc/human_do_bump_action, target)

/datum/component/bump_attack/proc/xeno_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
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
	GLOB.round_statistics.xeno_bump_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_bump_attacks")
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, CLICK_CD_MELEE)
	return COMPONENT_BUMP_RESOLVED

///Handles human bump attacks
/datum/component/bump_attack/proc/human_do_bump_action(atom/target)
	var/mob/living/bumper = parent
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	var/obj/item/held_item = bumper.get_active_held_item()
	if(!held_item)
		bumper.UnarmedAttack(target, TRUE)
	else if(held_item.flags_item & CAN_BUMP_ATTACK)
		held_item.melee_attack_chain(bumper, target)
	else //disables pushing if you have bump attacks on, so you don't accidentally misplace your enemy when switching to an item that can't bump attack
		return COMPONENT_BUMP_RESOLVED
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, CLICK_CD_MELEE)
	GLOB.round_statistics.human_bump_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "human_bump_attacks")
	return COMPONENT_BUMP_RESOLVED
