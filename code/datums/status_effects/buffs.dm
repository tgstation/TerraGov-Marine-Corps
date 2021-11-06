/datum/status_effect/xeno_rejuvenate
	id = "xeno_rejuvenate"

/datum/status_effect/xeno_rejuvenate/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	duration = set_duration
	new_owner.overlay_fullscreen("xeno_rejuvenate", /obj/screen/fullscreen/bloodlust)
	return ..()

/datum/status_effect/xeno_rejuvenate/on_remove()
	. = ..()
	owner.clear_fullscreen("xeno_rejuvenate", 0.7 SECONDS)

/datum/status_effect/xeno_rejuvenate/tick()
	new /obj/effect/temp_visual/telekinesis(get_turf(owner))
	to_chat(owner, span_notice("We feel our wounds close up and plasma reserves refilling."))

	var/mob/living/carbon/xenomorph/X = owner
	X.adjustBruteLoss(-X.maxHealth*0.1)
	X.adjustFireLoss(-X.maxHealth*0.1)
	if(X.xeno_caste.caste_flags & CASTE_CAN_BE_GIVEN_PLASMA)
		X.gain_plasma(X.xeno_caste.plasma_max*0.25)

/datum/status_effect/xeno_carnage
	id = "xeno_carnage"
	///PLasma gain for each attack
	var/plasma_gain_on_hit

/datum/status_effect/xeno_carnage/on_creation(mob/living/new_owner, set_duration, plasma_gain)
	owner = new_owner
	duration = set_duration
	plasma_gain_on_hit = plasma_gain
	to_chat(owner, span_notice("We give into our thirst!"))
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)
	return ..()

/datum/status_effect/xeno_carnage/on_remove()
	. = ..()
	to_chat(owner, span_notice("Our bloodlust subsides..."))
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)

///Handles logic to be performed for each attack during the duration of the buff
/datum/status_effect/xeno_carnage/proc/carnage_slash(datum/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.gain_plasma(plasma_gain_on_hit)
	owner_xeno.adjustBruteLoss(-damage)
	owner_xeno.adjustFireLoss(-damage)

	if(!owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		return

	for(var/mob/living/carbon/xenomorph/target_xeno AS in cheap_get_xenos_near(owner_xeno, 4))
		if(target_xeno == owner_xeno)
			continue
		target_xeno.adjustBruteLoss(-damage*0.7)
		target_xeno.adjustFireLoss(-damage*0.7)
		to_chat(target_xeno, span_notice("You feel your wounds being restored by [owner_xeno]'s pheromones."))

/datum/status_effect/xeno_feast
	id = "xeno_feast"
	///Amount of plasma drained per tick, removes effect if available plasma is less
	var/plasma_drain

/datum/status_effect/xeno_feast/on_creation(mob/living/new_owner, set_duration, plasma_drain)
	owner = new_owner
	duration = set_duration
	src.plasma_drain = plasma_drain
	new_owner.overlay_fullscreen("xeno_feast", /obj/screen/fullscreen/bloodlust)
	return ..()

/datum/status_effect/xeno_feast/on_remove()
	. = ..()
	owner.clear_fullscreen("xeno_feast", 0.7 SECONDS)

/datum/status_effect/xeno_feast/tick()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.plasma_stored < plasma_drain)
		to_chat(X, span_notice("Our feast has come to an end..."))
		X.remove_status_effect(/datum/status_effect/xeno_feast)
		return
	X.adjustBruteLoss(-X.maxHealth*0.1)
	X.adjustFireLoss(-X.maxHealth*0.1)
	X.use_plasma(plasma_drain)
