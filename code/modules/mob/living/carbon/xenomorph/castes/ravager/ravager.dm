/mob/living/carbon/xenomorph/ravager
	caste_base_type = /mob/living/carbon/xenomorph/ravager
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
	old_x = -16
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/ravager/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_LIGHT_STEP, XENO_TRAIT)

// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/ravager/Bump(atom/A)
	if(!throwing || !usedPounce || !throw_source || !thrower) //Must currently be charging to knock aside and slice marines in it's path
		return ..() //It's not pouncing; do regular Bump() IE body block but not throw_impact() because ravager isn't being thrown
	if(!ishuman(A)) //Must also be a human; regular Bump() will default to throw_impact() which means ravager will plow through tables but get stopped by cades and walls
		return ..()
	var/mob/living/carbon/human/human_victim = A
	human_victim.attack_alien_harm(src, xeno_caste.melee_damage * xeno_melee_damage_modifier * 0.25, FALSE, TRUE, FALSE, TRUE, INTENT_HARM) //Location is always random, cannot crit, harm only
	var/target_turf = get_ranged_target_turf(human_victim, get_dir(src, human_victim), rand(1, 3)) //we blast our victim behind us
	target_turf = get_step_rand(target_turf) //Scatter
	human_victim.throw_at(get_turf(target_turf), RAV_CHARGEDISTANCE, RAV_CHARGESPEED, src)
	human_victim.Paralyze(2 SECONDS)

/mob/living/carbon/xenomorph/ravager/flamer_fire_act(burnlevel)
	. = ..()
	if(stat)
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_RAVAGER_FLAMER_ACT))
		return FALSE
	gain_plasma(50)
	TIMER_COOLDOWN_START(src, COOLDOWN_RAVAGER_FLAMER_ACT, 1 SECONDS)
	if(prob(30))
		emote("roar")
		to_chat(src, span_xenodanger("The heat of the fire roars in our veins! KILL! CHARGE! DESTROY!"))

// ***************************************
// *********** Ability related
// ***************************************
/mob/living/carbon/xenomorph/ravager/get_crit_threshold()
	. = ..()
	if(!endure)
		return
	var/datum/action/ability/xeno_action/endure/endure_ability = actions_by_path[/datum/action/ability/xeno_action/endure]
	return endure_ability.endure_threshold

/mob/living/carbon/xenomorph/ravager/get_death_threshold()
	. = ..()
	if(!endure)
		return
	var/datum/action/ability/xeno_action/endure/endure_ability = actions_by_path[/datum/action/ability/xeno_action/endure]
	return endure_ability.endure_threshold

