/mob/living/carbon/xenomorph/pyrogen
	caste_base_type = /datum/xeno_caste/pyrogen
	name = "Pyrogen"
	desc = "A skittish alien, it burns with fury."
	icon = 'icons/Xeno/castes/pyrogen.dmi'
	icon_state = "pyrogen Walking"
	health = 325
	maxHealth = 325
	plasma_stored = 300
	mob_size = MOB_SIZE_XENO
	drag_delay = 3
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16
	bubble_icon = "alienroyal"
	/// The percentage of brute/burn healing that will be negated for all Melting Fire status effects that this xenomorph caused.
	var/melting_fire_healing_reduction = 0

/mob/living/carbon/xenomorph/pyrogen/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_XENOMORPH_POSTATTACK_LIVING, PROC_REF(on_postattack))

/// Applies a single stack of melting fire to those that they attack.
/mob/living/carbon/xenomorph/pyrogen/proc/on_postattack(mob/living/source, mob/living/target, damage)
	SIGNAL_HANDLER
	var/datum/status_effect/stacking/melting_fire/debuff = target.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
	if(debuff)
		debuff.add_stacks(1, src)
		return
	target.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, 1, src)

/mob/living/carbon/xenomorph/pyrogen/on_floored_trait_loss(datum/source)
	. = ..()
	flick("stunned_comeback",src)

/mob/living/carbon/xenomorph/pyrogen/set_resting()
	. = ..()
	if(resting)
		flick("demanifest", src)
	else
		flick("manifest", src)

/mob/living/carbon/xenomorph/pyrogen/primordial
	upgrade = XENO_UPGRADE_PRIMO
