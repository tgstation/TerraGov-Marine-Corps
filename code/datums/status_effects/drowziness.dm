//drowziness
/datum/status_effect/stacking/drowziness
	id = "drowziness"
	tick_interval = 2 SECONDS
	consumed_on_threshold = FALSE

/datum/status_effect/stacking/drowziness/on_creation(mob/living/new_owner, stacks_to_apply)
	if(!iscarbon(new_owner))
		qdel(src)
		return
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_DEATH, TYPE_PROC_REF(/datum/status_effect, on_owner_death))

/datum/status_effect/stacking/drowziness/on_owner_death(datum/source)
	qdel(src)

/datum/status_effect/stacking/drowziness/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_DROWSINESS)
	return ..()

/datum/status_effect/stacking/drowziness/add_stacks(stacks_added)
	. = ..()
	if(!owner)
		return
	owner.add_movespeed_modifier(MOVESPEED_ID_DROWSINESS, TRUE, 0, NONE, TRUE, stacks)

/datum/status_effect/stacking/drowziness/stack_decay_effect()
	stack_decay = owner.get_resting_power()
	owner.blur_eyes(2)

	if(stacks > 18 && prob(5))
		owner.Sleeping(2 SECONDS)
		owner.Unconscious(10 SECONDS)


//status procs for drowziness

///Returns if drowzy
/mob/living/proc/is_drowzy()
	return has_status_effect(STATUS_EFFECT_DROWZINESS)

///Returns remaining drowziness stacks
/mob/living/proc/amount_drowziness()
	var/datum/status_effect/stacking/drowziness/current_drowziness = is_drowzy()
	return current_drowziness ? current_drowziness.stacks : 0

///Applies drowziness unless existing stacks is higher
/mob/living/proc/drowzy(amount)
	if(amount <= 0)
		return //wrong proc
	if(status_flags & GODMODE)
		return

	var/datum/status_effect/stacking/drowziness/current_drowziness = is_drowzy()
	if(!current_drowziness)
		return apply_status_effect(STATUS_EFFECT_DROWZINESS, amount)

	if(current_drowziness.stacks >= amount)
		return current_drowziness

	current_drowziness.add_stacks(amount - current_drowziness.stacks)
	return current_drowziness

///Used to set drowziness to a set amount, commonly to remove it
/mob/living/proc/set_drowziness(amount)
	var/datum/status_effect/stacking/drowziness/current_drowziness = is_drowzy()
	if(amount <= 0)
		if(current_drowziness)
			qdel(current_drowziness)
		return

	if(status_flags & GODMODE)
		return current_drowziness

	if(!current_drowziness)
		return apply_status_effect(STATUS_EFFECT_DROWZINESS, amount)

	current_drowziness.add_stacks(amount - current_drowziness.stacks)
	return current_drowziness

///Applies drowziness or adds to existing stacks
/mob/living/proc/adjust_drowziness(amount)
	if(amount > 0 && (status_flags & GODMODE))
		return

	var/datum/status_effect/stacking/drowziness/current_drowziness = is_drowzy()
	if(current_drowziness)
		current_drowziness.add_stacks(amount)
	else if(amount > 0)
		current_drowziness = apply_status_effect(STATUS_EFFECT_DROWZINESS, amount)

	return current_drowziness
