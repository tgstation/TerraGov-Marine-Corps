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
	if(X.caste_flags & CAN_BE_GIVEN_PLASMA)
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
	var/mob/living/carbon/xenomorph/owner_xeno = owner
	owner_xeno.blood_bank += min(5, 100 - owner_xeno.blood_bank)
	to_chat(owner_xeno, span_notice("Blood bank: [owner_xeno.blood_bank]%"))
	owner_xeno.adjustBruteLoss(-damage)
	owner_xeno.adjustFireLoss(-damage)
	if(owner_xeno.has_status_effect(STATUS_EFFECT_XENO_FEAST))
		for(var/mob/living/carbon/xenomorph/target_xeno AS in cheap_get_xenos_near(owner_xeno, 4))
			if(target_xeno != owner_xeno)
				target_xeno.adjustBruteLoss(-damage*0.7)
				target_xeno.adjustFireLoss(-damage*0.7)
				to_chat(target_xeno, span_notice("You feel your wounds being restored by [owner_xeno]'s pheromones."))

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
