/mob/living/carbon/xenomorph/queen
	caste_base_type = /mob/living/carbon/xenomorph/queen
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Queen Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	wall_smash = 0
	health = 300
	maxHealth = 300
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_FOUR //Queen doesn't count towards population limit.
	upgrade = XENO_UPGRADE_ZERO

	var/breathing_counter = 0
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/queen/Initialize()
	RegisterSignal(src, COMSIG_HIVE_BECOME_RULER, .proc/on_becoming_ruler)
	. = ..()
	hive.RegisterSignal(src, COMSIG_HIVE_XENO_DEATH, /datum/hive_status.proc/on_queen_death)
	playsound(loc, 'sound/voice/alien_queen_command.ogg', 75, 0)


// ***************************************
// *********** Life overrides
// ***************************************
/mob/living/carbon/xenomorph/queen/handle_decay()
	if(prob(20+abs(3*upgrade_as_number())))
		use_plasma(min(rand(1,2), plasma_stored))


// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/queen/handle_special_state()
	if(is_charging >= CHARGE_ON)
		icon_state = "Queen Charging"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/reset_perspective(atom/A)
	if (!client)
		return

	if(observed_xeno && !stat)
		client.perspective = EYE_PERSPECTIVE
		client.eye = observed_xeno
		return

	if (ismovableatom(A))
		client.perspective = EYE_PERSPECTIVE
		client.eye = A
		return

	if (isturf(loc))
		client.eye = client.mob
		client.perspective = MOB_PERSPECTIVE
		return

	client.perspective = EYE_PERSPECTIVE
	client.eye = loc

// ***************************************
// *********** Name
// ***************************************
/mob/living/carbon/xenomorph/queen/generate_name()
	switch(upgrade)
		if(XENO_UPGRADE_ZERO)
			name = "[hive.prefix]Queen ([nicknumber])"			 //Young
		if(XENO_UPGRADE_ONE)
			name = "[hive.prefix]Elder Queen ([nicknumber])"	 //Mature
		if(XENO_UPGRADE_TWO)
			name = "[hive.prefix]Elder Empress ([nicknumber])"	 //Elder
		if(XENO_UPGRADE_THREE)
			name = "[hive.prefix]Ancient Empress ([nicknumber])" //Ancient
		if(XENO_UPGRADE_FOUR)
			name = "[hive.prefix]Primordial Empress ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name


// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/queen/death_cry()
	playsound(loc, 'sound/voice/alien_queen_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/queen/xeno_death_alert()
	return


// ***************************************
// *********** Larva Mother
// ***************************************

/mob/living/carbon/xenomorph/queen/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	if(!incapacitated(TRUE))
		mothers += src //Adding us to the list.
