/mob/living/carbon/xenomorph/runner
	caste_base_type = /mob/living/carbon/xenomorph/runner
	name = "Runner"
	desc = "A small red alien that looks like it could run fairly quickly..."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x1 or something
	icon_state = "Runner Walking"
	health = 100
	maxHealth = 100
	plasma_stored = 50
	speed = -1.7
	flags_pass = PASSTABLE
	tier = XENO_TIER_ONE
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16  //Needed for 2x2
	old_x = -16
	hit_and_run = 0
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
		)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/runner/Initialize(mapload, can_spawn_in_centcomm)
	. = ..()
	RegisterSignal(src, list(
		COMSIG_XENOMORPH_DISARM_HUMAN,
		COMSIG_XENOMORPH_ATTACK_LIVING),
		.proc/hit_and_run_bonus)

// ***************************************
// *********** Life overrides
// ***************************************

/mob/living/carbon/xenomorph/runner/update_stat()
	. = ..()
	if(stat != CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER
