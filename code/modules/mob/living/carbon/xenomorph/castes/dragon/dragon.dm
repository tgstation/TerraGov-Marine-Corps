/mob/living/carbon/xenomorph/dragon
	caste_base_type = /datum/xeno_caste/dragon
	name = "Dragon"
	desc = "A massive, ancient beast with scales that shimmer like polished armor. The fiercest and most formidable creature."
	icon = 'icons/Xeno/castes/dragon.dmi'
	icon_state = "Dragon Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	health = 850
	maxHealth = 850
	plasma_stored = 0
	pixel_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	initial_language_holder = /datum/language_holder/xeno/dragon
	tier = XENO_TIER_FOUR
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)
	xeno_flags = XENO_ROUNY // TODO: Get real sprites to use.

/mob/living/carbon/xenomorph/dragon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/xenos_roaring.ogg', 75, 0)
	RegisterSignals(src, list(COMSIG_XENOMORPH_BRUTE_DAMAGE, COMSIG_XENOMORPH_BURN_DAMAGE), PROC_REF(taking_damage))

/mob/living/carbon/xenomorph/dragon/death_cry()
	playsound(loc, 'sound/voice/alien/king_died.ogg', 75, 0)

/// Reduces damage (after-armor) taken by half as long they have plasma. Will always consume at least 1 plasma if any damage is taken.
// TODO: This needs to be BEFORE-ARMOR. Look at overriding `apply_damage` to do this!
/mob/living/carbon/xenomorph/dragon/proc/taking_damage(datum/source, amount, list/amount_mod)
	SIGNAL_HANDLER
	if(amount <= 0 || !plasma_stored || stat == DEAD || lying_angle)
		return
	var/damage_reduction = min(amount/2, plasma_stored)
	use_plasma(ROUND_UP(damage_reduction))
	amount_mod += damage_reduction
