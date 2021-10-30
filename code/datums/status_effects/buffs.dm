/datum/status_effect/xeno_rejuvenate
	id = "xeno_rejuvenate"

/datum/status_effect/xeno_rejuvenate/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	duration = set_duration
	return ..()

/datum/status_effect/xeno_rejuvenate/tick()
	var/mob/living/carbon/xenomorph/X = owner
	new /obj/effect/temp_visual/telekinesis(get_turf(owner))
	to_chat(owner, span_notice("We feel our wounds close up and plasma reserves refilling."))
	X.adjustBruteLoss(-X.maxHealth*0.1)
	X.adjustFireLoss(-X.maxHealth*0.1)
	X.gain_plasma(X.xeno_caste.plasma_max*0.25)

/datum/status_effect/xeno_carnage
	id = "xeno_carnage"

/datum/status_effect/xeno_carnage/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	duration = set_duration
	to_chat(owner, span_notice("We give into our thirst!"))
	RegisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)
	return ..()

/datum/status_effect/xeno_carnage/on_remove()
	. = ..()
	to_chat(owner, span_notice("Our bloodlust subsides..."))
	UnregisterSignal(owner, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/carnage_slash)

/datum/status_effect/xeno_carnage/proc/carnage_slash(datum/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/mob/living/carbon/xenomorph/X = owner
	X.blood_bank += min(5, 100 - X.blood_bank)
	to_chat(X, span_notice("Blood bank: [X.blood_bank]%"))
	X.adjustBruteLoss(-damage)
	X.adjustFireLoss(-damage)
	if(X.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		for(var/mob/living/carbon/xenomorph/H in range(4, owner))
			if(H != X)
				H.adjustBruteLoss(-damage*0.7)
				H.adjustFireLoss(-damage*0.7)
				to_chat(H, span_notice("You feel your wounds being restored by [X]'s pheromones."))

/datum/status_effect/xeno_feast
	id = "xeno_feast"

/datum/status_effect/xeno_feast/on_creation(mob/living/new_owner, set_duration)
	owner = new_owner
	duration = set_duration
	return ..()

/datum/status_effect/xeno_feast/tick()
	var/mob/living/carbon/xenomorph/X = owner
	if(X.blood_bank < 5)
		to_chat(X, span_notice("Our feast blood reserve runs dry..."))
		X.remove_status_effect(/datum/status_effect/xeno_feast)
		return
	X.adjustBruteLoss(-X.maxHealth*0.1)
	X.adjustFireLoss(-X.maxHealth*0.1)
	X.blood_bank -= 5
	to_chat(X, span_notice("Blood bank: [X.blood_bank]%"))
