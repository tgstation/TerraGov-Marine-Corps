/mob/living/carbon/xenomorph/king
	caste_base_type = /mob/living/carbon/xenomorph/king
	name = "King"
	desc = "A primordial creature, evolved to smash the hardiest of defences and hunt the hardiest of prey."
	icon = 'icons/Xeno/castes/king.dmi'
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
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)

/mob/living/carbon/xenomorph/king/Initialize(mapload)
	. = ..()
	SSmonitor.stats.king++
	playsound(loc, 'sound/voice/xenos_roaring.ogg', 75, 0)

/mob/living/carbon/xenomorph/king/generate_name()
	switch(upgrade)
		if(XENO_UPGRADE_NORMAL)
			name = "[hive.prefix]Emperor ([nicknumber])"	 //Normal
		if(XENO_UPGRADE_PRIMO)
			name = "[hive.prefix]Primordial Emperor ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/on_death()
	. = ..()
	SSmonitor.stats.king--

/mob/living/carbon/xenomorph/king/death_cry()
	playsound(loc, 'sound/voice/alien_king_died.ogg', 75, 0)
