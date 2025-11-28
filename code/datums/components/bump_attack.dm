/datum/component/bump_attack
	///Whether the component is active
	var/active = FALSE
	///The proc to register with COMSIG_MOVABLE_BUMP, based on what kind of mob the component is on
	var/bump_action_path

/datum/component/bump_attack/Initialize(enabled = TRUE, has_button = TRUE, silent_activation = FALSE)
	. = ..()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	if(ishuman(parent))
		RegisterSignal(parent, COMSIG_ITEM_TOGGLE_BUMP_ATTACK, PROC_REF(living_activation_toggle))
		bump_action_path = PROC_REF(human_bump_action)
	else if(isxeno(parent))
		bump_action_path = PROC_REF(xeno_bump_action)
	else
		bump_action_path = PROC_REF(living_bump_action)
	living_activation_toggle(should_enable = enabled, silent_activation = silent_activation)

/datum/component/bump_attack/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_BUMP)

/// Handles the activation and deactivation of the bump attack component on living mobs.
/datum/component/bump_attack/proc/living_activation_toggle(datum/source, should_enable = !active, silent_activation)
	if(should_enable == active)
		return
	var/mob/living/bumper = parent
	if(!silent_activation)
		bumper.balloon_alert(bumper, "[should_enable ? "attacking" : "pushing"] enemies in your way")
	if(should_enable)
		active = TRUE
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, bump_action_path)
		return
	var/obj/item/held_item = bumper.get_inactive_held_item()
	if(held_item?.item_flags & CAN_BUMP_ATTACK)
		return
	active = FALSE
	UnregisterSignal(bumper, COMSIG_MOVABLE_BUMP)

///Handles living bump action checks before actually doing the attack checks.
/datum/component/bump_attack/proc/living_bump_action_checks(atom/target)
	var/mob/living/bumper = parent
	if(!bumper.client?.prefs?.toggle_bump_attacking)
		return NONE
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_BUMP_ATTACK))
		return NONE
	if(!(target.atom_flags & BUMP_ATTACKABLE) || bumper.throwing || bumper.incapacitated())
		return NONE

///Handles carbon bump action checks before actually doing the attack checks.
/datum/component/bump_attack/proc/carbon_bump_action_checks(atom/target)
	var/mob/living/carbon/bumper = parent
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	switch(bumper.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return NONE

///Handles living pre-bump attack checks.
/datum/component/bump_attack/proc/living_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	. = living_bump_action_checks(target)
	if(!isnull(.))
		return
	return living_do_bump_action(target)

///Handles human pre-bump attack checks.
/datum/component/bump_attack/proc/human_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/bumper = parent
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	var/mob/living/living_target = target
	if(bumper.faction == living_target.faction)
		return //FF
	if(ishuman(target) && (bumper.wear_id))
		var/mob/living/carbon/human/human_target = target
		if(bumper.wear_id?.iff_signal == human_target.wear_id?.iff_signal)
			return //FF
	if(isxeno(target))
		var/mob/living/carbon/xenomorph/xeno = target
		if(bumper.wear_id && CHECK_BITFIELD(xeno.xeno_iff_check(), bumper.wear_id.iff_signal))
			return //Do not hit friend with tag!
	INVOKE_ASYNC(src, PROC_REF(human_do_bump_action), target)

///Handles xeno pre-bump attack checks.
/datum/component/bump_attack/proc/xeno_bump_action(datum/source, atom/target)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/bumper = parent
	. = carbon_bump_action_checks(target)
	if(!isnull(.))
		return
	if(bumper.issamexenohive(target))
		return //No more nibbling.
	return xeno_do_bump_action(target)

///Handles living bump attacks.
/datum/component/bump_attack/proc/living_do_bump_action(atom/target)
	var/mob/living/bumper = parent
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	bumper.UnarmedAttack(target, TRUE)
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, CLICK_CD_MELEE)
	return COMPONENT_BUMP_RESOLVED

///Handles human bump attacks.
/datum/component/bump_attack/proc/human_do_bump_action(atom/target)
	var/mob/living/bumper = parent
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	var/obj/item/held_item = bumper.get_active_held_item()
	if(!held_item)
		bumper.UnarmedAttack(target, TRUE)
	else if(held_item.item_flags & CAN_BUMP_ATTACK)
		held_item.melee_attack_chain(bumper, target)
	else //disables pushing if you have bump attacks on, so you don't accidentally misplace your enemy when switching to an item that can't bump attack
		return COMPONENT_BUMP_RESOLVED
	GLOB.round_statistics.human_bump_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "human_bump_attacks")
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, held_item ? held_item.attack_speed : CLICK_CD_MELEE)
	return COMPONENT_BUMP_RESOLVED

///Handles xeno bump attacks.
/datum/component/bump_attack/proc/xeno_do_bump_action(atom/target)
	var/mob/living/carbon/xenomorph/bumper = parent
	if(bumper.next_move > world.time)
		return COMPONENT_BUMP_RESOLVED //We don't want to push people while on attack cooldown.
	bumper.UnarmedAttack(target, TRUE)
	GLOB.round_statistics.xeno_bump_attacks++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "xeno_bump_attacks")
	TIMER_COOLDOWN_START(src, COOLDOWN_BUMP_ATTACK, bumper.xeno_caste.attack_delay)
	return COMPONENT_BUMP_RESOLVED
