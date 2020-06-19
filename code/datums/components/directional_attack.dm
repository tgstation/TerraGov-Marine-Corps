/datum/component/directional_attack
    var/active = TRUE
    var/directional_action_path
    var/datum/action/directional_attack_toggle/toggle_action
/datum/component/directional_attack/Initialize()
    . = ..()
    if(!isliving(parent))
        return COMPONENT_INCOMPATIBLE
    toggle_action = new()
    var/toggle_path
    if(ishuman(parent))
        directional_action_path = .proc/human_directional_action
    if(isxeno(parent))
        directional_action_path = .proc/xeno_directional_action
    toggle_path = .proc/living_activation_toggle
    toggle_action.give_action(parent)
    toggle_action.update_button_icon(active)
    RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, toggle_path)

/datum/component/directional_attack/Destroy(force, silent)
    QDEL_NULL(toggle_action)
    return ..()

/datum/component/directional_attack/proc/living_activation_toggle(datum/source)
    var/mob/living/attacker = parent
    active = !active
    to_chat(attacker, "<span class='notice'>You will now [active ? "attack" : "not attack"] enemies upon clicking in their directional.</span>")
    toggle_action.update_button_icon(active)

/datum/component/directional_attack/proc/living_directional_action_checks(atom/target)
	if(COOLDOWN_CHECK(src, COOLDOWN_DIRECTIONAL_ATTACK))
		return NONE
	var/mob/living/attacker = parent
	if(!isliving(target) || attacker.throwing || attacker.incapacitated())
		return NONE
	if(get_dir(src, target) && target.dir)
		return NONE //Not facing the correct way

/datum/component/directional_attack/proc/carbon_directional_action_checks(atom/target)
	var/mob/living/carbon/attacker = parent
	. = living_directional_action_checks(target)
	if(!isnull(.))
		return
	switch(attacker.a_intent)
		if(INTENT_HELP, INTENT_GRAB)
			return NONE
	if(attacker.get_active_held_item())
		return NONE //We have something in our hand.
    
/datum/component/directional_attack/proc/living_directional_action(datum/source, atom/target)
	. = living_directional_action_checks(target)
	if(!isnull(.))
		return
	return living_do_directional_action(target)

/datum/component/directional_attack/proc/human_directional_action(datum/source, atom/target)
	var/mob/living/carbon/human/attacker = parent
	. = carbon_directional_action_checks(target)
	if(!isnull(.))
		return
	var/mob/living/living_target = target
	if(attacker.faction == living_target.faction)
		return //FF
	return living_do_directional_action(target)

/datum/component/directional_attack/proc/xeno_directional_action(datum/source, atom/target)
	var/mob/living/carbon/xenomorph/attacker = parent
	. = carbon_directional_action_checks(target)
	if(!isnull(.))
		return
	if(attacker.issamexenohive(target))
		return //No more nibbling.
	return living_do_directional_action(target)


/datum/component/directional_attack/proc/living_do_directional_action(atom/target)
    var/mob/living/attacker = parent
	if(attacker.next_move > world.time)
		return COMPONENT_DIRECTIONAL_RESOLVED //We don't want to push people while on attack cooldown.
    attacker.UnarmedAttack(target, TRUE)
    COOLDOWN_START(src, COOLDOWN_DIRECTIONAL_ATTACK, CLICK_CD_MELEE)
    return COMPONENT_DIRECTIONAL_RESOLVED