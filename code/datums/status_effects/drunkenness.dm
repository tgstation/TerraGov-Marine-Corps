//drunkenness
/datum/status_effect/stacking/drunkenness
	id = "drunkenness"
	tick_interval = 2 SECONDS
	consumed_on_threshold = FALSE

/datum/status_effect/stacking/drunkenness/on_creation(mob/living/new_owner, stacks_to_apply)
	if(!iscarbon(new_owner))
		qdel(src)
		return
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_DEATH, TYPE_PROC_REF(/datum/status_effect, on_owner_death))

/datum/status_effect/stacking/drunkenness/add_stacks(stacks_added)
	. = ..()
	if(!owner)
		return
	stack_decay = max(stacks * 0.03, 0.3)

/datum/status_effect/stacking/drunkenness/stack_decay_effect()
	if(stacks <= 5)
		return

	if(stacks >= 6)
		if(prob(25))
			owner.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk)
		owner.adjust_jitter(-3)

	if(stacks >= 11)
		owner.adjust_timed_status_effect(2 SECONDS, /datum/status_effect/speech/slurring/drunk, 10 SECONDS)

	if(stacks >= 41)
		if(prob(25))
			owner.AdjustConfused(4 SECONDS)
		if(owner.amount_dizzied() < 450) // To avoid giving the player overly dizzy too
			owner.adjust_dizziness(8)

	if(stacks >= 51)
		if(prob(5))
			owner.AdjustConfused(10 SECONDS)
			owner.vomit()
		if(owner.amount_dizzied() < 600)
			owner.adjust_dizziness(12)

	if(stacks >= 61 && prob(25))
		owner.blur_eyes(3)

	if(stacks >= 71)
		owner.blur_eyes(4)

	if(stacks >= 81)
		owner.adjustToxLoss(0.2)
		if(prob(10) && !owner.stat)
			to_chat(owner, span_warning("Maybe you should lie down for a bit..."))
			owner.adjust_drowziness(5)

	if(stacks >= 91)
		owner.adjustBrainLoss(0.2, TRUE)
		if(prob(15 && !owner.stat))
			to_chat(owner, span_warning("Just a quick nap..."))
			owner.Sleeping(80 SECONDS)

	if(stacks >=101) //Let's be honest, you should be dead by now
		owner.adjustToxLoss(4)

///Level of pain relief provided by being drunk
/datum/status_effect/stacking/drunkenness/proc/get_shock_modifier()
	if(stacks > 80)
		return PAIN_REDUCTION_HEAVY
	if(stacks > 40)
		return PAIN_REDUCTION_MEDIUM
	if(stacks > 5)
		return PAIN_REDUCTION_LIGHT
	return 0

//status procs for drunkenness

///Returns if drunk
/mob/living/proc/is_drunk()
	return has_status_effect(STATUS_EFFECT_DRUNKENNESS)

///Returns remaining drunkenness stacks
/mob/living/proc/amount_drunkenness()
	var/datum/status_effect/stacking/drunkenness/current_drunkenness = is_drunk()
	return current_drunkenness ? current_drunkenness.stacks : 0

///Applies drunkenness unless existing stacks is higher
/mob/living/proc/drunken(amount)
	if(amount <= 0)
		return //wrong proc
	if(status_flags & GODMODE)
		return

	var/datum/status_effect/stacking/drunkenness/current_drunkenness = is_drunk()
	if(!current_drunkenness)
		return apply_status_effect(STATUS_EFFECT_DRUNKENNESS, amount)

	if(current_drunkenness.stacks >= amount)
		return current_drunkenness

	current_drunkenness.add_stacks(amount - current_drunkenness.stacks)
	return current_drunkenness

///Used to set drunkenness to a set amount, commonly to remove it
/mob/living/proc/set_drunkenness(amount)
	var/datum/status_effect/stacking/drunkenness/current_drunkenness = is_drunk()
	if(amount <= 0)
		if(current_drunkenness)
			qdel(current_drunkenness)
		return

	if(status_flags & GODMODE)
		return current_drunkenness

	if(!current_drunkenness)
		return apply_status_effect(STATUS_EFFECT_DRUNKENNESS, amount)

	current_drunkenness.add_stacks(amount - current_drunkenness.stacks)
	return current_drunkenness

///Applies drunkenness or adds to existing stacks
/mob/living/proc/adjust_drunkenness(amount)
	if(amount > 0 && (status_flags & GODMODE))
		return

	var/datum/status_effect/stacking/drunkenness/current_drunkenness = is_drunk()
	if(current_drunkenness)
		current_drunkenness.add_stacks(amount)
	else if(amount > 0)
		current_drunkenness = apply_status_effect(STATUS_EFFECT_DRUNKENNESS, amount)

	return current_drunkenness
