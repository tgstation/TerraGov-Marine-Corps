#define BASE_HEAL_RATE -0.0125


//Largely negative status effects go here, even if they have small benificial effects
//STUN EFFECTS
/datum/status_effect/incapacitating
	tick_interval = 0
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null

/datum/status_effect/incapacitating/on_creation(mob/living/new_owner, set_duration)
	if(new_owner.status_flags & GODMODE)
		qdel(src)
		return
	if(isnum(set_duration))
		duration = set_duration
	return ..()

//STUN
/datum/status_effect/incapacitating/stun
	id = "stun"

/datum/status_effect/incapacitating/stun/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/stun/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	return ..()

//KNOCKDOWN
/datum/status_effect/incapacitating/knockdown
	id = "knockdown"

/datum/status_effect/incapacitating/knockdown/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/knockdown/on_remove()
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	return ..()

//IMMOBILIZED
/datum/status_effect/incapacitating/immobilized
	id = "immobilized"

/datum/status_effect/incapacitating/immobilized/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/immobilized/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	return ..()

//PARALYZED
/datum/status_effect/incapacitating/paralyzed
	id = "paralyzed"

/datum/status_effect/incapacitating/paralyzed/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/paralyzed/on_remove()
	REMOVE_TRAIT(owner, TRAIT_INCAPACITATED, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_IMMOBILE, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_FLOORED, TRAIT_STATUS_EFFECT(id))
	return ..()

//UNCONSCIOUS
/datum/status_effect/incapacitating/unconscious
	id = "unconscious"

/datum/status_effect/incapacitating/unconscious/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/unconscious/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/incapacitating/unconscious/tick()
	if(owner.getStaminaLoss())
		owner.adjustStaminaLoss(-0.3) //reduce stamina loss by 0.3 per tick, 6 per 2 seconds

//SLEEPING
/datum/status_effect/incapacitating/sleeping
	id = "sleeping"
	alert_type = /atom/movable/screen/alert/status_effect/asleep
	var/mob/living/carbon/carbon_owner
	var/mob/living/carbon/human/human_owner

/datum/status_effect/incapacitating/sleeping/on_creation(mob/living/new_owner)
	. = ..()
	if(.)
		if(iscarbon(owner)) //to avoid repeated istypes
			carbon_owner = owner
		if(ishuman(owner))
			human_owner = owner

/datum/status_effect/incapacitating/sleeping/Destroy()
	carbon_owner = null
	human_owner = null
	return ..()

/datum/status_effect/incapacitating/sleeping/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/sleeping/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/incapacitating/sleeping/tick()
	if(owner.maxHealth)
		var/health_ratio = owner.health / owner.maxHealth
		var/healing = BASE_HEAL_RATE //set for a base of 0.25 healed per 2-second interval asleep in a bed with covers.
		if((locate(/obj/structure/bed) in owner.loc))
			healing += (2 * BASE_HEAL_RATE)
		else if((locate(/obj/structure/table) in owner.loc))
			healing += BASE_HEAL_RATE
		for(var/obj/item/bedsheet/bedsheet in range(owner.loc,0))
			if(bedsheet.loc != owner.loc) //bedsheets in your backpack/neck don't give you comfort
				continue
			healing += BASE_HEAL_RATE
			break //Only count the first bedsheet
		if(health_ratio > -0.5)
			owner.adjustBruteLoss(healing)
			owner.adjustFireLoss(healing)
			owner.adjustToxLoss(healing * 0.5, TRUE, TRUE)
			owner.adjustStaminaLoss(healing * 100)
			owner.adjustCloneLoss(healing * health_ratio * 0.8)
	if(human_owner && human_owner.drunkenness)
		human_owner.drunkenness *= 0.997 //reduce drunkenness by 0.3% per tick, 6% per 2 seconds
	if(prob(20))
		if(carbon_owner)
			carbon_owner.handle_dreams()
		if(prob(10) && owner.health > owner.health_threshold_crit)
			owner.emote("snore")



/**
 * Adjusts a timed status effect on the mob,taking into account any existing timed status effects.
 * This can be any status effect that takes into account "duration" with their initialize arguments.
 *
 * Positive durations will add deciseconds to the duration of existing status effects
 * or apply a new status effect of that duration to the mob.
 *
 * Negative durations will remove deciseconds from the duration of an existing version of the status effect,
 * removing the status effect entirely if the duration becomes less than zero (less than the current world time).
 *
 * duration - the duration, in deciseconds, to add or remove from the effect
 * effect - the type of status effect being adjusted on the mob
 * max_duration - optional - if set, positive durations will only be added UP TO the passed max duration
 */
/mob/living/proc/adjust_timed_status_effect(duration, effect, max_duration)
	if(!isnum(duration))
		CRASH("adjust_timed_status_effect: called with an invalid duration. (Got: [duration])")

	if(!ispath(effect, /datum/status_effect))
		CRASH("adjust_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	// If we have a max duration set, we need to check our duration does not exceed it
	if(isnum(max_duration))
		if(max_duration <= 0)
			CRASH("adjust_timed_status_effect: Called with an invalid max_duration. (Got: [max_duration])")

		if(duration >= max_duration)
			duration = max_duration

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		if(isnum(max_duration) && duration > 0)
			// Check the duration remaining on the existing status effect
			// If it's greater than / equal to our passed max duration, we don't need to do anything
			var/remaining_duration = existing.duration - world.time
			if(remaining_duration >= max_duration)
				return

			// Otherwise, add duration up to the max (max_duration - remaining_duration),
			// or just add duration if it doesn't exceed our max at all
			existing.duration += min(max_duration - remaining_duration, duration)

		else
			existing.duration += duration

		// If the duration was decreased and is now less 0 seconds,
		// qdel it / clean up the status effect immediately
		// (rather than waiting for the process tick to handle it)
		if(existing.duration <= world.time)
			qdel(existing)

	else if(duration > 0)
		apply_status_effect(effect, duration)

/**
 * Sets a timed status effect of some kind on a mob to a specific value.
 * If only_if_higher is TRUE, it will only set the value up to the passed duration,
 * so any pre-existing status effects of the same type won't be reduced down
 *
 * duration - the duration, in deciseconds, of the effect. 0 or lower will either remove the current effect or do nothing if none are present
 * effect - the type of status effect given to the mob
 * only_if_higher - if TRUE, we will only set the effect to the new duration if the new duration is longer than any existing duration
 */
/mob/living/proc/set_timed_status_effect(duration, effect, only_if_higher = FALSE)
	if(!isnum(duration))
		CRASH("set_timed_status_effect: called with an invalid duration. (Got: [duration])")

	if(!ispath(effect, /datum/status_effect))
		CRASH("set_timed_status_effect: called with an invalid effect type. (Got: [effect])")

	var/datum/status_effect/existing = has_status_effect(effect)
	if(existing)
		// set_timed_status_effect to 0 technically acts as a way to clear effects,
		// though remove_status_effect would achieve the same goal more explicitly.
		if(duration <= 0)
			qdel(existing)
			return

		if(only_if_higher)
			// If the existing status effect has a higher remaining duration
			// than what we aim to set it to, don't downgrade it - do nothing (return)
			var/remaining_duration = existing.duration - world.time
			if(remaining_duration >= duration)
				return

		// Set the duration accordingly
		existing.duration = world.time + duration

	else if(duration > 0)
		apply_status_effect(effect, duration)

/atom/movable/screen/alert/status_effect/asleep
	name = "Asleep"
	desc = "You've fallen asleep. Wait a bit and you should wake up. Unless you don't, considering how helpless you are."
	icon_state = "asleep"

//ADMIN SLEEP
/datum/status_effect/incapacitating/adminsleep
	id = "adminsleep"
	alert_type = /atom/movable/screen/alert/status_effect/adminsleep
	duration = -1

/datum/status_effect/incapacitating/adminsleep/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/incapacitating/adminsleep/on_remove()
	REMOVE_TRAIT(owner, TRAIT_KNOCKEDOUT, TRAIT_STATUS_EFFECT(id))
	return ..()

/atom/movable/screen/alert/status_effect/adminsleep
	name = "Admin Slept"
	desc = "You've been slept by an Admin."
	icon_state = "asleep"

//CONFUSED
/datum/status_effect/incapacitating/confused
	id = "confused"
	alert_type = /atom/movable/screen/alert/status_effect/confused

/atom/movable/screen/alert/status_effect/confused
	name = "Confused"
	desc = "You're dazed and confused."
	icon_state = "asleep"

/datum/status_effect/plasmadrain
	id = "plasmadrain"

/datum/status_effect/plasmadrain/on_creation(mob/living/new_owner, set_duration)
	if(isxeno(new_owner))
		owner = new_owner
		duration = set_duration
		return ..()
	else
		CRASH("something applied plasmadrain on a nonxeno, dont do that")

/datum/status_effect/plasmadrain/tick()
	var/mob/living/carbon/xenomorph/xenoowner = owner
	if(xenoowner.plasma_stored >= 0)
		var/remove_plasma_amount = xenoowner.xeno_caste.plasma_max / 10
		xenoowner.plasma_stored -= remove_plasma_amount
		if(xenoowner.plasma_stored <= 0)
			xenoowner.plasma_stored = 0

/datum/status_effect/noplasmaregen
	id = "noplasmaregen"
	tick_interval = 2 SECONDS

/datum/status_effect/noplasmaregen/on_creation(mob/living/new_owner, set_duration)
	if(isxeno(new_owner))
		owner = new_owner
		duration = set_duration
		return ..()
	else
		CRASH("something applied noplasmaregen on a nonxeno, dont do that")

/datum/status_effect/noplasmaregen/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_NOPLASMAREGEN, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/noplasmaregen/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOPLASMAREGEN, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/noplasmaregen/tick()
	to_chat(owner, span_warning("You feel too weak to summon new plasma..."))

/datum/status_effect/incapacitating/harvester_slowdown
	id = "harvest_slow"
	tick_interval = 1 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	var/debuff_slowdown = 2

/datum/status_effect/incapacitating/harvester_slowdown/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_movespeed_modifier(MOVESPEED_ID_HARVEST_TRAM_SLOWDOWN, TRUE, 0, NONE, TRUE, debuff_slowdown)

/datum/status_effect/incapacitating/harvester_slowdown/on_remove()
	owner.remove_movespeed_modifier(MOVESPEED_ID_HARVEST_TRAM_SLOWDOWN)
	return ..()

//MUTE
/datum/status_effect/mute
	id = "mute"
	alert_type = /atom/movable/screen/alert/status_effect/mute

/atom/movable/screen/alert/status_effect/mute
	name = "Muted"
	desc = "You can't speak!"
	icon_state = "mute"

/datum/status_effect/mute/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	if(set_duration) //If the duration is limited, set it
		duration = set_duration
	return ..()

/datum/status_effect/mute/on_apply()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(owner, TRAIT_MUTED, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/mute/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MUTED, TRAIT_STATUS_EFFECT(id))
	return ..()

/datum/status_effect/spacefreeze
	id = "spacefreeze"

/datum/status_effect/spacefreeze/on_creation(mob/living/new_owner)
	. = ..()
	to_chat(new_owner, span_danger("The cold vacuum instantly freezes you, maybe this was a bad idea?"))

/datum/status_effect/spacefreeze/tick()
	owner.adjustFireLoss(40)

///irradiated mob
/datum/status_effect/incapacitating/irradiated
	id = "irradiated"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 20
	alert_type = /atom/movable/screen/alert/status_effect/irradiated
	///Some effects only apply to carbons
	var/mob/living/carbon/carbon_owner

/datum/status_effect/incapacitating/irradiated/on_creation(mob/living/new_owner, set_duration)
	. = ..()
	if(.)
		if(iscarbon(owner))
			carbon_owner = owner

/datum/status_effect/incapacitating/irradiated/Destroy()
	carbon_owner = null
	return ..()

/datum/status_effect/incapacitating/irradiated/tick()
	var/mob/living/living_owner = owner
	//Roulette of bad things
	if(prob(15))
		living_owner.adjustCloneLoss(2)
		to_chat(living_owner, span_warning("You feel like you're burning from the inside!"))
	else
		living_owner.adjustToxLoss(3)
	if(prob(15))
		living_owner.adjust_Losebreath(5)
	if(prob(15))
		living_owner.vomit()
	if(carbon_owner && prob(15))
		var/datum/internal_organ/organ = pick(carbon_owner.internal_organs)
		if(organ)
			organ.take_damage(5)

/atom/movable/screen/alert/status_effect/irradiated
	name = "Irradiated"
	desc = "You've been irradiated! The effects of the radiation will continue to harm you until purged from your system."
	icon_state = "radiation"

// ***************************************
// *********** Intoxicated
// ***************************************
/datum/status_effect/stacking/intoxicated
	id = "intoxicated"
	tick_interval = 2 SECONDS
	stacks = 1
	max_stacks = 30
	consumed_on_threshold = FALSE
	/// Owner of the debuff is limited to carbons.
	var/mob/living/carbon/debuff_owner
	/// Used for particles. Holds the particles instead of the mob. See particle_holder for documentation.
	var/obj/effect/abstract/particle_holder/particle_holder

/datum/status_effect/stacking/intoxicated/can_gain_stacks()
	if(owner.status_flags & GODMODE)
		return FALSE
	return ..()

/datum/status_effect/stacking/intoxicated/on_creation(mob/living/new_owner, stacks_to_apply)
	if(new_owner.status_flags & GODMODE)
		qdel(src)
		return
	. = ..()
	debuff_owner = new_owner
	RegisterSignal(debuff_owner, COMSIG_LIVING_DO_RESIST, .proc/call_resist_debuff)
	debuff_owner.balloon_alert(debuff_owner, "Intoxicated")
	playsound(debuff_owner.loc, "sound/bullets/acid_impact1.ogg", 30)
	particle_holder = new(debuff_owner, /particles/toxic_slash)
	particle_holder.particles.spawning = 1 + round(stacks / 2)
	particle_holder.pixel_x = -2
	particle_holder.pixel_y = 0
	if(HAS_TRAIT(debuff_owner, TRAIT_INTOXICATION_RESISTANT) || (debuff_owner.get_soft_armor(BIO) >= 65))
		stack_decay = 2

/datum/status_effect/stacking/intoxicated/on_remove()
	UnregisterSignal(debuff_owner, COMSIG_LIVING_DO_RESIST)
	debuff_owner = null
	QDEL_NULL(particle_holder)
	return ..()

/datum/status_effect/stacking/intoxicated/tick()
	. = ..()
	if(!debuff_owner)
		return
	if(HAS_TRAIT(debuff_owner, TRAIT_INTOXICATION_RESISTANT) || (debuff_owner.get_soft_armor(BIO) > 65))
		stack_decay = 2
	var/debuff_damage = SENTINEL_INTOXICATED_BASE_DAMAGE + round(stacks / 10)
	debuff_owner.adjustFireLoss(debuff_damage)
	playsound(debuff_owner.loc, "sound/bullets/acid_impact1.ogg", 4)
	particle_holder.particles.spawning = 1 + round(stacks / 2)
	if(stacks >= 20)
		debuff_owner.adjust_slowdown(1)
		debuff_owner.adjust_stagger(1)

/// Called when the debuff's owner uses the Resist action for this debuff.
/datum/status_effect/stacking/intoxicated/proc/call_resist_debuff()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/resist_debuff) // grilled cheese sandwich

/// Resisting the debuff will allow the debuff's owner to remove some stacks from themselves.
/datum/status_effect/stacking/intoxicated/proc/resist_debuff()
	if(!do_after(debuff_owner, 3 SECONDS, TRUE, debuff_owner, BUSY_ICON_GENERIC))
		debuff_owner.balloon_alert("Interrupted")
		return
	playsound(debuff_owner.loc, 'sound/effects/slosh.ogg', 30)
	debuff_owner.balloon_alert("Succeeded")
	stacks -= SENTINEL_INTOXICATED_RESIST_REDUCTION
