/mob/living/carbon/xenomorph/ravager
	caste_base_type = /mob/living/carbon/xenomorph/ravager
	name = "Ravager"
	desc = "A huge, nasty red alien with enormous scythed claws."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Ravager Walking"
	health = 250
	maxHealth = 250
	plasma_stored = 50
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_THREE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16
	old_x = -16

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/ravager/Bump(atom/A)
	if(!throwing || !usedPounce || !throw_source || !thrower) //Must currently be charging to knock aside and slice marines in it's path
		return ..() //It's not pouncing; do regular Bump() IE body block but not throw_impact() because ravager isn't being thrown
	if(!isliving(A)) //Must also be living; regular Bump() will default to throw_impact() which means ravager will plow through tables but get stopped by cades and walls
		return ..()
	var/mob/living/living_target = A
	if(isxeno(living_target))
		var/mob/living/carbon/xenomorph/xeno_target = A
		if(xeno_target.issamexenohive(src)) //No friendly fire
			return ..()

	living_target.attack_alien(src,  xeno_caste.melee_damage * 0.25, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, living_target, 2) //This is where we blast our target
	target_turf =  get_step_rand(target_turf) //Scatter
	living_target.throw_at(get_turf(target_turf), RAVAGER_CHARGEDISTANCE, RAVAGER_CHARGESPEED, living_target)
	living_target.Paralyze(2 SECONDS)
	shake_camera(living_target, 2, 1)


// ***************************************
// *********** Ability related
// ***************************************
/mob/living/carbon/xenomorph/ravager/get_crit_threshold()
	. = ..()
	if(!endure)
		return
	return RAVAGER_ENDURE_HP_LIMIT

/mob/living/carbon/xenomorph/ravager/get_death_threshold()
	. = ..()
	if(!endure)
		return
	return RAVAGER_ENDURE_HP_LIMIT
