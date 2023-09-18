// ***************************************
// *********** Psychic Grab
// ***************************************
/datum/action/xeno_action/activable/psychic_grab
	name = "Psychic Grab"
	action_icon_state = "grab"
	desc = "Attracts the target to the owner of the ability."
	cooldown_timer = 12 SECONDS
	plasma_cost = 100
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_PSYCHIC_GRAB,
	)
	target_flags = XABB_MOB_TARGET


/datum/action/xeno_action/activable/psychic_grab/on_cooldown_finish()
	to_chat(owner, span_notice("We gather enough mental strength to grab something again."))
	return ..()


/datum/action/xeno_action/activable/psychic_grab/can_use_ability(atom/target, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(QDELETED(target))
		return FALSE
	if(!isitem(target) && !ishuman(target) && !isdroid(target))	//only items, droids, and mobs can be flung.
		return FALSE
	var/max_dist = 5
	if(!line_of_sight(owner, target, max_dist))
		if(!silent)
			to_chat(owner, span_warning("We must get closer to grab, our mind cannot reach this far."))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(isnestedhost(victim))
			return FALSE
		if(!CHECK_BITFIELD(use_state_flags|override_flags, XACT_IGNORE_DEAD_TARGET) && victim.stat == DEAD)
			return FALSE


/datum/action/xeno_action/activable/psychic_grab/use_ability(atom/target)
	var/mob/living/victim = target

	owner.visible_message(span_xenowarning("A strange and violent psychic aura is suddenly emitted from \the [owner]!"), \
	span_xenowarning("We are rapidly attracting [victim] with the power of our mind!"))
	victim.visible_message(span_xenowarning("[victim] is rapidly attracting away by an unseen force!"), \
	span_xenowarning("You are rapidly attracting to the side by an unseen force!"))
	playsound(owner,'sound/effects/magic.ogg', 75, 1)
	playsound(victim,'sound/weapons/alien_claw_block.ogg', 75, 1)
	succeed_activate()
	add_cooldown()
	if(ishuman(victim))
		victim.apply_effects(0.4, 0.1) 	// The fling stuns you enough to remove your gun, otherwise the marine effectively isn't stunned for long.
		shake_camera(victim, 2, 1)

	var/grab_distance = (isitem(victim)) ? 5 : 4 //Objects get flung further away.

	victim.throw_at(owner, grab_distance, 1, owner, TRUE)

	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/xeno_action/fling = X.actions_by_path[/datum/action/xeno_action/activable/psychic_fling]
	if(fling)
		fling.add_cooldown()

/datum/action/xeno_action/activable/psychic_fling/use_ability(atom/target)
	. = ..()
	var/mob/living/carbon/xenomorph/X = owner
	var/datum/action/xeno_action/grab = X.actions_by_path[/datum/action/xeno_action/activable/psychic_grab]
	if(grab)
		grab.add_cooldown()
