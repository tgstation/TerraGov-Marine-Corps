//dizzy
/datum/status_effect/stacking/dizzy
	id = "dizzy"
	tick_interval = 2 SECONDS
	stack_decay = 1
	consumed_on_threshold = FALSE
	max_stacks = 1000
	stack_threshold = 100

/datum/status_effect/stacking/dizzy/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_DEATH, TYPE_PROC_REF(/datum/status_effect, on_owner_death))

/datum/status_effect/stacking/dizzy/add_stacks(stacks_added)
	. = ..()
	if(!owner)
		return
	var/restingpwr = 3
	if(owner.stat || owner.resting)
		restingpwr += 12
	stack_decay = restingpwr

/datum/status_effect/stacking/dizzy/threshold_cross_effect()
	INVOKE_ASYNC(src, PROC_REF(dizzy_process))

///does the shakey
/datum/status_effect/stacking/dizzy/proc/dizzy_process()
	while(threshold_crossed)
		if(owner.client)
			var/amplitude = stacks*(sin(stacks * 0.044 * world.time) + 1) / 70
			owner.client.pixel_x = amplitude * sin(0.008 * stacks * world.time)
			owner.client.pixel_y = amplitude * cos(0.008 * stacks * world.time)
		sleep(0.1 SECONDS)

	if(!owner.client)
		return
	owner.client.pixel_x = 0
	owner.client.pixel_y = 0

//status procs for dizzy

///Returns if dizzy
/mob/living/proc/is_dizzy()
	return has_status_effect(STATUS_EFFECT_DIZZY)

///Returns remaining dizzy stacks
/mob/living/proc/amount_dizzied()
	var/datum/status_effect/stacking/dizzy/current_dizziness = is_dizzy()
	return current_dizziness ? current_dizziness.stacks : 0

///Applies dizzy unless existing stacks is higher
/mob/living/proc/dizzy(amount)
	if(amount <= 0)
		return //wrong proc
	if(status_flags & GODMODE)
		return

	var/datum/status_effect/stacking/dizzy/current_dizziness = is_dizzy()
	if(!current_dizziness)
		return apply_status_effect(STATUS_EFFECT_DIZZY, amount)

	if(current_dizziness.stacks >= amount)
		return current_dizziness

	current_dizziness.add_stacks(amount - current_dizziness.stacks)
	return current_dizziness

///Used to set dizzy to a set amount, commonly to remove it
/mob/living/proc/set_dizziness(amount)
	var/datum/status_effect/stacking/dizzy/current_dizziness = is_dizzy()
	if(amount <= 0)
		if(current_dizziness)
			qdel(current_dizziness)
		return

	if(status_flags & GODMODE)
		return current_dizziness

	if(!current_dizziness)
		return apply_status_effect(STATUS_EFFECT_DIZZY, amount)

	current_dizziness.add_stacks(amount - current_dizziness.stacks)
	return current_dizziness

///Applies dizzy or adds to existing duration
/mob/living/proc/adjust_dizziness(amount)
	if(amount > 0)
		if(status_flags & GODMODE)
			return

	var/datum/status_effect/stacking/dizzy/current_dizziness = is_dizzy()
	if(current_dizziness)
		current_dizziness.add_stacks(amount)
	else if(amount > 0)
		current_dizziness = apply_status_effect(STATUS_EFFECT_DIZZY, amount)

	return current_dizziness
