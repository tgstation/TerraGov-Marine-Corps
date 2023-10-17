/mob/living/carbon/xenomorph/king
	icon = 'modular_RUtgmc/icons/Xeno/castes/king.dmi'
	footsteps = FOOTSTEP_XENO_STOMPY

/mob/living/carbon/xenomorph/king/generate_name()
	var/playtime_mins = client?.get_exp(xeno_caste.caste_name)
	var/prefix = (hive.prefix || xeno_caste.upgrade_name) ? "[hive.prefix][xeno_caste.upgrade_name] " : ""
	switch(playtime_mins)
		if(0 to 600)
			name = prefix + "Young King ([nicknumber])"
		if(601 to 3000)
			name = prefix + "Mature King ([nicknumber])"
		if(3001 to 9000)
			name = prefix + "Elder Emperor ([nicknumber])"
		if(9001 to 18000)
			name = prefix + "Ancient Emperor ([nicknumber])"
		if(18001 to INFINITY)
			name = prefix + "Prime Emperor ([nicknumber])"
		else
			name = prefix + "Young King ([nicknumber])"

	real_name = name
	if(mind)
		mind.name = name
