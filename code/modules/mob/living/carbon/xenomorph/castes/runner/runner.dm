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
/mob/living/carbon/xenomorph/runner/proc/hit_and_run_bonus(datum/source, mob/living/H, damage, list/damage_mod)
	var/last_move = last_move_intent - 10
	var/bonus
	if(last_move && last_move < world.time - 5) //If we haven't moved in the last 500 ms, we lose our bonus
		hit_and_run = 0
		return
	bonus = min(hit_and_run, 1)//Runner deals +5% damage per tile moved in rapid succession to a maximum of +100%. Damage bonus is lost on attacking.
	switch(bonus)
		if(1)
			visible_message("<span class='danger'>\The [src] strikes with lethal speed!</span>", \
			"<span class='danger'>We strike with lethal speed!</span>")
		if(0.5 to 0.99)
			visible_message("<span class='danger'>\The [src] strikes with deadly speed!</span>", \
			"<span class='danger'>We strike with deadly speed!</span>")
		if(0.25 to 0.45)
			visible_message("<span class='danger'>\The [src] strikes with vicious speed!</span>", \
			"<span class='danger'>We strike with vicious speed!</span>")
	
	damage_mod += (damage * bonus)
	hit_and_run = 0 //reset the hit and run bonus
	return COMSIG_XENOMORPH_BONUS_APPLIED // dont stack our attack with bonus_dam
	
/mob/living/carbon/xenomorph/runner/handle_status_effects()
	if(hit_and_run)
		var/last_move = last_move_intent - 10
		if(last_move && last_move < world.time - 5) //If we haven't moved in the last 500 ms, we lose our bonus
			hit_and_run = 0
	return ..()

/mob/living/carbon/xenomorph/runner/update_stat()
	. = ..()
	if(stat != CONSCIOUS && layer != initial(layer))
		layer = MOB_LAYER
