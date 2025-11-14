/mob/living/carbon/xenomorph/ravager
	caste_base_type = /datum/xeno_caste/ravager
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/castes/ravager.dmi'
	icon_state = "Ravager Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 50
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_NORMAL
	pixel_x = -16
	bubble_icon = "alienroyal"
	/// The amount of plasma to be gained for being on fire.
	var/plasma_gain_from_fire = 50

/mob/living/carbon/xenomorph/ravager/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LIGHT_STEP, XENO_TRAIT)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/ravager/fire_act(burn_level)
	. = ..()
	if(stat)
		return
	if(TIMER_COOLDOWN_RUNNING(src, COOLDOWN_RAVAGER_FLAMER_ACT))
		return FALSE
	gain_plasma(plasma_gain_from_fire)
	TIMER_COOLDOWN_START(src, COOLDOWN_RAVAGER_FLAMER_ACT, 1 SECONDS)
	if(prob(30))
		emote("roar")
		to_chat(src, span_xenodanger("The heat of the fire roars in our veins! KILL! CHARGE! DESTROY!"))

/mob/living/carbon/xenomorph/ravager/bloodthirster
	caste_base_type = /datum/xeno_caste/ravager/bloodthirster
