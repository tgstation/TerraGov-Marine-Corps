//jitter
/datum/status_effect/stacking/jitter
	id = "jitter"
	tick_interval = 2 SECONDS
	stack_decay = 1
	consumed_on_threshold = FALSE
	max_stacks = 1000

/datum/status_effect/stacking/jitter/add_stacks(stacks_added)
	. = ..()
	if(!owner)
		return
	var/restingpwr = 3
	if(owner.stat || owner.resting)
		restingpwr += 12
	stack_decay = restingpwr
	owner.do_jitter_animation(stacks)

//status procs for jitter

///Returns if jitter
/mob/living/proc/is_jittered()
	return has_status_effect(STATUS_EFFECT_JITTER)

///Returns remaining jitter stacks
/mob/living/proc/amount_jittered()
	var/datum/status_effect/stacking/jitter/current_jitter = is_jittered()
	return current_jitter ? current_jitter.stacks : 0

///Applies jitter unless existing stacks is higher
/mob/living/proc/jitter(amount)
	if(amount <= 0)
		return //wrong proc
	if(status_flags & GODMODE)
		return

	var/datum/status_effect/stacking/jitter/current_jitter = is_jittered()
	if(!current_jitter)
		return apply_status_effect(STATUS_EFFECT_JITTER, amount)

	if(current_jitter.stacks >= amount)
		return current_jitter

	current_jitter.add_stacks(amount - current_jitter.stacks)
	return current_jitter

///Used to set jitter to a set amount, commonly to remove it
/mob/living/proc/set_jitter(amount)
	var/datum/status_effect/stacking/jitter/current_jitter = is_jittered()
	if(amount <= 0)
		if(current_jitter)
			qdel(current_jitter)
		return

	if(status_flags & GODMODE)
		return current_jitter

	if(!current_jitter)
		return apply_status_effect(STATUS_EFFECT_JITTER, amount)

	current_jitter.add_stacks(amount - current_jitter.stacks)
	return current_jitter

///Applies jitter or adds to existing duration
/mob/living/proc/adjust_jitter(amount)
	if(amount > 0)
		if(status_flags & GODMODE)
			return

	var/datum/status_effect/stacking/jitter/current_jitter = is_jittered()
	if(current_jitter)
		current_jitter.add_stacks(amount)
	else if(amount > 0)
		current_jitter = apply_status_effect(STATUS_EFFECT_JITTER, amount)

	return current_jitter
