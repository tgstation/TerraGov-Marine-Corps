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
	playsound(loc, 'sound/voice/xenos_roaring.ogg', 75, 0)

/mob/living/carbon/xenomorph/king/generate_name()
	var/playtime_mins = client?.get_exp(xeno_caste.caste_name)
	var/prefix = (hive.prefix || xeno_caste.upgrade_name) ? "[hive.prefix][xeno_caste.upgrade_name] " : ""
	switch(playtime_mins)
		if(0 to 600)
			name = prefix + "Hatchling King ([nicknumber])"
		if(601 to 3000)
			name = prefix + "Young King ([nicknumber])"
		if(3001 to 9000)
			name = prefix + "Mature Emperor ([nicknumber])"
		if(9001 to 18000)
			name = prefix + "Elder Emperor ([nicknumber])"
		if(18001 to INFINITY)
			name = prefix + "Ancient Emperor ([nicknumber])"
		else
			name = prefix + "Hatchling King ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name

/mob/living/carbon/xenomorph/king/death_cry()
	playsound(loc, 'sound/voice/alien_king_died.ogg', 75, 0)
