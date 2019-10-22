/datum/component/bump_attack
    var/active = FALSE
    var/datum/action/bump_attack_toggle/toggle_action

/datum/component/bump_attack/Initialize()
	. = ..()
	if(!ismovableatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(isliving(parent))
		toggle_action = new()
		RegisterSignal(toggle_action, COMSIG_ACTION_TRIGGER, .proc/bump_attack_toggle)
		toggle_action.give_action(parent)
		toggle_action.update_button_icon(active)
	else
		return COMPONENT_INCOMPATIBLE

/datum/component/bump_attack/proc/bump_attack_toggle(datum/source, atom/target)
	var/mob/living/bumper = parent

	active = !active
	to_chat(bumper, "<span class='notice'>You will now [active ? "attack" : "push"] enemies who are in your way.</span>")

	if(active)
		RegisterSignal(bumper, COMSIG_MOVABLE_BUMP, .proc/bump_action)
	else
		UnregisterSignal(bumper, COMSIG_MOVABLE_BUMP)
	toggle_action.update_button_icon(active)

/datum/component/bump_attack/proc/bump_action(datum/source, atom/target)
    if(isliving(parent))
        var/mob/living/bumper = parent
        bumper.bump_attack(target)

/mob/living/proc/bump_attack(atom/target)
	if(!isliving(target) || a_intent == INTENT_HELP || a_intent == INTENT_GRAB || throwing || incapacitated())
		return
	if(next_move > world.time)
		return COMPONENT_BUMP_RESOLVED//we don't want to push people while on attack cooldown
	do_bump_attack(target)
	return COMPONENT_BUMP_RESOLVED

/mob/living/proc/do_bump_attack(atom/target)
	UnarmedAttack(target, TRUE)

/mob/living/carbon/human/do_bump_attack(atom/target)//this isn't currently used anywhere, just here for the future
	if(isliving(target))
		var/mob/living/living_target = target
		if(faction == living_target.faction)
			return //FF
	if(get_active_held_item())
		return //We have something in our hand.
	return ..()

/mob/living/carbon/xenomorph/do_bump_attack(atom/target)
	if(issamexenohive(target))
		return //No more nibbling.
	return ..()
