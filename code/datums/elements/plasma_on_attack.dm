/datum/element/plasma_on_attack
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	var/damage_plasma_multiplier = 1

/datum/element/plasma_on_attack/Attach(datum/target, damage_plasma_multiplier)
	. = ..()
	if(!isxeno(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/damage_dealt)
	src.damage_plasma_multiplier = damage_plasma_multiplier

/datum/element/plasma_on_attack/proc/damage_dealt(datum/source, mob/living/attacked, damage)
	var/mob/living/carbon/xenomorph/furious = source
	furious.gain_plasma(damage * damage_plasma_multiplier)

