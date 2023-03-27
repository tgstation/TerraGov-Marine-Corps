/mob/living/carbon/xenomorph/slime
	caste_base_type = /mob/living/carbon/xenomorph/slime
	name = "Slime"
	desc = "A viscous, squishy and oozy substance. It quivers every now and then, as if it were alive."
	icon = 'icons/Xeno/1x1_Xenos.dmi'
	icon_state = "Slime Walking"
	speak_emote = list("blurbs", "blorbs")
	attacktext = "burns"
	bubble_icon = "alienleft"
	alpha = 200
	health = 225
	maxHealth = 225
	plasma_stored = 125
	pixel_x = 0
	old_x = 0
	pull_speed = -2
	mob_size = MOB_SIZE_HUMAN
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	flags_pass = PASSTABLE
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

// ***************************************
// *********** Overrides
// ***************************************
/mob/living/carbon/xenomorph/slime/set_stat()
	. = ..()
	if(isnull(.))
		return
	if(. == CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER

/mob/living/carbon/xenomorph/slime/throw_impact(atom/hit_atom, speed, bounce)
	return ..(hit_atom, speed, FALSE)
