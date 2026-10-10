//slowdown
/datum/status_effect/stacking/slowdown
	id = "slowdown"
	tick_interval = 2 SECONDS
	stack_decay = 1
	consumed_on_threshold = FALSE

/datum/status_effect/stacking/slowdown/on_apply()
	. = ..()
	if(!.)
		return
	stack_decay = owner.get_slowdown_regen()

/datum/status_effect/stacking/slowdown/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_STAGGERSTUN)
	return ..()

/datum/status_effect/stacking/slowdown/add_stacks(stacks_added)
	. = ..()
	if(!owner)
		return
	owner.add_movespeed_modifier(MOVESPEED_ID_STAGGERSTUN, TRUE, 0, NONE, TRUE, stacks) //updates modifier


///Returns the slowdown mult for this mob type
/mob/living/proc/get_slowdown_regen()
	return STANDARD_SLOWDOWN_REGEN

/mob/living/carbon/xenomorph/get_slowdown_regen()
	return XENO_SLOWDOWN_REGEN

//status procs for slowdown

///Returns if slowed
/mob/living/proc/is_slowed()
	return has_status_effect(STATUS_EFFECT_SLOWDOWN)

///Returns remaining slow stacks
/mob/living/proc/amount_slowed()
	var/datum/status_effect/stacking/slowdown/current_slow = is_slowed()
	return current_slow ? current_slow.stacks : 0

///Applies slow unless existing stacks is higher
/mob/living/proc/slowdown(amount)
	if(amount <= 0)
		return //wrong proc
	if(status_flags & GODMODE)
		return
	if(HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE))
		return

	amount *= get_slowdown_regen()

	var/datum/status_effect/stacking/slowdown/current_slow = is_slowed()
	if(!current_slow)
		return apply_status_effect(STATUS_EFFECT_SLOWDOWN, amount)

	if(current_slow.stacks >= amount)
		return current_slow

	current_slow.add_stacks(amount - current_slow.stacks)
	return current_slow

///Used to set slow to a set amount, commonly to remove it
/mob/living/proc/set_slowdown(amount)
	var/datum/status_effect/stacking/slowdown/current_slow = is_slowed()
	if(amount <= 0)
		if(current_slow)
			qdel(current_slow)
		return

	if(status_flags & GODMODE)
		return current_slow
	if(HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE))
		return current_slow

	amount *= get_slowdown_regen()

	if(!current_slow)
		return apply_status_effect(STATUS_EFFECT_SLOWDOWN, amount)

	current_slow.add_stacks(amount - current_slow.stacks)
	return current_slow

///Applies slow or adds to existing duration
/mob/living/proc/adjust_slowdown(amount)
	if(amount > 0)
		if(status_flags & GODMODE)
			return
		if(HAS_TRAIT(src, TRAIT_SLOWDOWNIMMUNE))
			return

	amount *= get_slowdown_regen()

	var/datum/status_effect/stacking/slowdown/current_slow = is_slowed()
	if(current_slow)
		current_slow.add_stacks(amount)
	else if(amount > 0)
		current_slow = apply_status_effect(STATUS_EFFECT_SLOWDOWN, amount)

	return current_slow

/mob/living/carbon/xenomorph/adjust_slowdown(amount)
	if(is_charging >= CHARGE_ON)
		return
	return ..()
