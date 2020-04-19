/mob/living/carbon/xenomorph/defender
	caste_base_type = /mob/living/carbon/xenomorph/defender
	name = "Defender"
	desc = "A alien with an armored head crest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Defender Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pull_speed = -2


// ***************************************
// *********** Icon
// ***************************************
/mob/living/carbon/xenomorph/defender/handle_special_state()
	if(fortify)
		icon_state = "Defender Fortify"
		return TRUE
	if(crest_defense)
		icon_state = "Defender Crest"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/defender/handle_special_wound_states()
	. = ..()
	if(fortify)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_fortify", "layer"=-X_WOUND_LAYER)
	if(crest_defense)
		return image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="defender_wounded_crest", "layer"=-X_WOUND_LAYER)

// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/defender/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && fortify) //No longer conscious.
		set_fortify(FALSE) //Fortify prevents dragging due to the anchor component.


// ***************************************
// *********** Mob overrides
// ***************************************
/mob/living/carbon/xenomorph/defender/Bump(atom/A)
	if(!throwing || !throw_source || !thrower)
		return ..()
	if(!ishuman(A))
		return ..()
	var/mob/living/carbon/human/H = A
	var/extra_dmg = xeno_caste.melee_damage * 0.5 // 50% dmg reduction
	H.attack_alien(src, extra_dmg, FALSE, TRUE, FALSE, TRUE) //Location is always random, cannot crit, harm only
	var/target_turf = get_step_away(src, H, rand(1, 2)) //This is where we blast our target
	target_turf = get_step_rand(target_turf) //Scatter
	H.throw_at(get_turf(target_turf), 4, 70, H)
	H.Paralyze(40)
	return
