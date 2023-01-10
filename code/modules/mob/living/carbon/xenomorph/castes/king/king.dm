/mob/living/carbon/xenomorph/king
	caste_base_type = /mob/living/carbon/xenomorph/king
	name = "King"
	desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "King Walking"
	attacktext = "bites"
	attack_sound = null
	friendly = "nuzzles"
	health = 500
	maxHealth = 500
	plasma_stored = 300
	pixel_x = -16
	old_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6
	tier = XENO_TIER_FOUR //King, like queen, doesn't count towards population limit.
	upgrade = XENO_UPGRADE_ZERO
	bubble_icon = "alienroyal"

/mob/living/carbon/xenomorph/king/Initialize(mapload)
	. = ..()
	hive.RegisterSignal(src, COMSIG_HIVE_XENO_DEATH, /datum/hive_status.proc/on_king_death)
	SSmonitor.stats.king++

/mob/living/carbon/xenomorph/king/generate_name()
	switch(upgrade)
		if(XENO_UPGRADE_ZERO)
			name = "[hive.prefix]King ([nicknumber])"	 //Young
		if(XENO_UPGRADE_ONE)
			name = "[hive.prefix]Elder King ([nicknumber])"	 //Mature
		if(XENO_UPGRADE_TWO)
			name = "[hive.prefix]Elder Emperor ([nicknumber])"	 //Elder
		if(XENO_UPGRADE_THREE)
			name = "[hive.prefix]Ancient Emperor ([nicknumber])" //Ancient
		if(XENO_UPGRADE_FOUR)
			name = "[hive.prefix]Primordial Emperor ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/on_death()
	. = ..()
	SSmonitor.stats.king--
