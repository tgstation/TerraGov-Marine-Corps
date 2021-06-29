/datum/component/plasma_fury

/datum/component/plasma_fury/Initialize(...)
	if(!isxeno(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_XENOMORPH_PLASMA_REGEN, .proc/plasma_regen)
	RegisterSignal(parent, COMSIG_XENOMORPH_ATTACK_LIVING, .proc/damage_dealt)


/datum/component/plasma_fury/proc/damage_dealt(datum/source, mob/living/attacked, damage)
	var/mob/living/carbon/xenomorph/furious = source
	furious.gain_plasma(damage)



/datum/component/plasma_fury/proc/plasma_regen(datum/source, list/plasma_mod)
	var/mob/living/carbon/xenomorph/furious = source
	if(furious.plasma_stored >= furious.xeno_caste.plasma_max * 0.5)
		return COMPONENT_PLASMA_REGEN_HANDLED



