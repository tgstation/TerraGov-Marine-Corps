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
	if(!ishuman(A)) //Must also be a human; regular Bump() will default to throw_impact() which means ravager will plow through tables but get stopped by cades and walls
		return ..()
	var/mob/living/carbon/human/H = A
	H.attack_alien_harm(src, xeno_caste.melee_damage * xeno_melee_damage_modifier * 0.25, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, H, rand(1, 3)) //This is where we blast our target
	target_turf =  get_step_rand(target_turf) //Scatter
	H.throw_at(get_turf(target_turf), RAV_CHARGEDISTANCE, RAV_CHARGESPEED, H)
	H.Paralyze(2 SECONDS)


// ***************************************
// *********** Ability related
// ***************************************
/mob/living/carbon/xenomorph/ravager/get_crit_threshold()
	. = ..()
	if(!endure)
		return
	var/datum/action/xeno_action/endure/endure_ability = actions_by_path[/datum/action/xeno_action/endure]
	return endure_ability.endure_threshold

/mob/living/carbon/xenomorph/ravager/get_death_threshold()
	. = ..()
	if(!endure)
		return
	var/datum/action/xeno_action/endure/endure_ability = actions_by_path[/datum/action/xeno_action/endure]
	return endure_ability.endure_threshold

