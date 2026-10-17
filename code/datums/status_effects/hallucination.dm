//hallucinations
/datum/status_effect/stacking/hallucination
	id = "hallucination"
	tick_interval = 2 SECONDS
	stack_decay = 2
	consumed_on_threshold = FALSE
	max_stacks = 1000
	///fake health hud
	var/screwyhud = SCREWYHUD_NONE
	///Time when the next hallucination can occur
	var/next_hallucination = 0

/datum/status_effect/stacking/hallucination/on_creation(mob/living/new_owner, stacks_to_apply)
	if(!iscarbon(new_owner))
		qdel(src)
		return
	. = ..()
	if(!.)
		return
	RegisterSignal(owner, COMSIG_MOB_DEATH, TYPE_PROC_REF(/datum/status_effect, on_owner_death))

/datum/status_effect/stacking/hallucination/stack_decay_effect()
	if(stacks < 20)
		return
	if(world.time < next_hallucination)
		return

	var/halpick = pickweight(GLOB.hallucination_list)
	new halpick(owner, FALSE)

	next_hallucination = world.time + rand(10 SECONDS, 60 SECONDS)

///Sets the fake hud status
/datum/status_effect/stacking/hallucination/proc/set_screwyhud(hud_type)
	screwyhud = hud_type
	var/mob/living/carbon/carbon_owner = owner
	carbon_owner.handle_healths_hud_updates()

//status procs for hallucination

///Returns if hallucination
/mob/living/proc/is_hallucinating()
	return has_status_effect(STATUS_EFFECT_HALLUCINATION)

///Returns remaining hallucination stacks
/mob/living/proc/amount_hallucinating()
	var/datum/status_effect/stacking/hallucination/current_hallucination = is_hallucinating()
	return current_hallucination ? current_hallucination.stacks : 0

///Applies hallucination unless existing stacks is higher
/mob/living/proc/hallucinate(amount)
	if(amount <= 0)
		return //wrong proc
	if(status_flags & GODMODE)
		return

	var/datum/status_effect/stacking/hallucination/current_hallucination = is_hallucinating()
	if(!current_hallucination)
		return apply_status_effect(STATUS_EFFECT_HALLUCINATION, amount)

	if(current_hallucination.stacks >= amount)
		return current_hallucination

	current_hallucination.add_stacks(amount - current_hallucination.stacks)
	return current_hallucination

///Used to set hallucination to a set amount, commonly to remove it
/mob/living/proc/set_hallucination(amount)
	var/datum/status_effect/stacking/hallucination/current_hallucination = is_hallucinating()
	if(amount <= 0)
		if(current_hallucination)
			qdel(current_hallucination)
		return

	if(status_flags & GODMODE)
		return current_hallucination

	if(!current_hallucination)
		return apply_status_effect(STATUS_EFFECT_HALLUCINATION, amount)

	current_hallucination.add_stacks(amount - current_hallucination.stacks)
	return current_hallucination

///Applies hallucination or adds to existing stacks
/mob/living/proc/adjust_hallucination(amount)
	if(amount > 0)
		if(status_flags & GODMODE)
			return

	var/datum/status_effect/stacking/hallucination/current_hallucination = is_hallucinating()
	if(current_hallucination)
		current_hallucination.add_stacks(amount)
	else if(amount > 0)
		current_hallucination = apply_status_effect(STATUS_EFFECT_HALLUCINATION, amount)

	return current_hallucination
