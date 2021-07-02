/datum/component/plasma_on_attack
	var/damage_plasma_multiplier = 1

/datum/component/plasma_on_attack/Initialize(damage_plasma_multiplier)
	if(!isxeno(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/damage_dealt)
	src.damage_plasma_multiplier = damage_plasma_multiplier

/datum/component/plasma_on_attack/proc/damage_dealt(datum/source, mob/living/attacked, damage)
	var/mob/living/carbon/xenomorph/furious = source
	furious.gain_plasma(damage * damage_plasma_multiplier)




