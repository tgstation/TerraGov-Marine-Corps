/mob/living/carbon/xenomorph/queen
	caste_base_type = /datum/xeno_caste/queen
	name = "Queen"
	desc = "A huge, looming alien creature. The biggest and the baddest."
	icon = 'icons/Xeno/castes/queen.dmi'
	icon_state = "Queen Walking"
	health = 300
	maxHealth = 300
	plasma_stored = 300
	pixel_x = -16
	mob_size = MOB_SIZE_BIG
	drag_delay = 6 //pulling a big dead xeno is hard
	tier = XENO_TIER_FOUR //Queen doesn't count towards population limit.
	upgrade = XENO_UPGRADE_NORMAL
	bubble_icon = "alienroyal"
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/hijack,
	)

// ***************************************
// *********** Init
// ***************************************
/mob/living/carbon/xenomorph/queen/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/voice/alien/queen_command.ogg', 75, 0)

// ***************************************
// *********** Mob overrides
// ***************************************

/mob/living/carbon/xenomorph/queen/handle_special_state()
	if(is_charging >= CHARGE_ON)
		icon_state = "[xeno_caste.caste_name][(xeno_flags & XENO_ROUNY) ? " rouny" : ""] Charging"
		return TRUE
	return FALSE

/mob/living/carbon/xenomorph/queen/upgrade_xeno(newlevel, silent = FALSE)
	. = ..()
	hive?.update_leader_pheromones()

// ***************************************
// *********** Name
// ***************************************
/mob/living/carbon/xenomorph/queen/generate_name()
	var/playtime_mins = client?.get_exp(xeno_caste.caste_name)
	var/prefix = (hive.prefix || xeno_caste.upgrade_name) ? "[hive.prefix][xeno_caste.upgrade_name] " : ""
	if(!client?.prefs.show_xeno_rank || !client)
		name = prefix + "Queen ([nicknumber])"
		real_name = name
		if(mind)
			mind.name = name
		return
	switch(playtime_mins)
		if(0 to 600)
			name = prefix + "Young Queen ([nicknumber])"
		if(601 to 1500)
			name = prefix + "Mature Queen ([nicknumber])"
		if(1501 to 4200)
			name = prefix + "Elder Empress ([nicknumber])"
		if(4201 to 10500)
			name = prefix + "Ancient Empress ([nicknumber])"
		if(10501 to INFINITY)
			name = prefix + "Prime Empress ([nicknumber])"
		else
			name = prefix + "Young Queen ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name


// ***************************************
// *********** Death
// ***************************************
/mob/living/carbon/xenomorph/queen/death_cry()
	playsound(loc, 'sound/voice/alien/queen_died.ogg', 75, 0)

/mob/living/carbon/xenomorph/queen/xeno_death_alert()
	return


// ***************************************
// *********** Larva Mother
// ***************************************

/mob/living/carbon/xenomorph/queen/proc/is_burrowed_larva_host(datum/source, list/mothers, list/silos)
	if(!incapacitated(TRUE))
		mothers += src //Adding us to the list.
