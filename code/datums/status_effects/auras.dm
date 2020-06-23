/datum/status_effect/aura
	id = "effect_aura"
	tick_interval = 0
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null

	/// Display name of the aura
	var/display_name = "SHOULD NOT SHOW - CONTACT DEV"

	/// How strong of an effect (1 being 100%)
	var/strength = 1

/datum/status_effect/aura/on_creation(mob/living/new_owner, set_duration, set_strength)
	if(isnum(set_duration))
		duration = set_duration

	if(isnum(set_strength))
		strength = set_strength

	return ..()

/datum/status_effect/aura/refresh(mob/living/owner, set_duration, set_strength)
	to_chat(world, "Refreshing owner: [owner], set_duration: [set_duration], set_strength: [set_strength]")
	if(!isnum(set_strength) || set_strength < strength)
		return FALSE

	// Reapply effects when changing strength
	if(strength != set_strength)
		on_remove()
		on_apply()

	strength = set_strength

	if(isnum(set_duration))
		duration = set_duration + world.time

/datum/status_effect/aura/frenzy
	id = "effect_aura_frenzy"
	display_name = "frenzy"

/datum/status_effect/aura/frenzy/on_apply()
	. = ..()
	owner.add_movespeed_modifier(MOVESPEED_ID_FRENZY_AURA, TRUE, 0, NONE, TRUE, -strength * 0.06)

/datum/status_effect/aura/frenzy/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(MOVESPEED_ID_FRENZY_AURA)

/datum/status_effect/aura/warding
	id = "effect_aura_warding"
	display_name = "warding"

/datum/status_effect/aura/warding/on_apply()
	. = ..()
	if(!isxeno(owner))
		return
	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.armor_pheromone_bonus = strength * 2.5

/datum/status_effect/aura/warding/on_remove()
	. = ..()
	if(!isxeno(owner))
		return
	var/mob/living/carbon/xenomorph/xeno = owner
	xeno.armor_pheromone_bonus = 0

/datum/status_effect/aura/recovery
	id = "effect_aura_recovery"
	display_name = "recovery"
