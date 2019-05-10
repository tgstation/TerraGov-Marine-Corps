proc/random_ethnicity()
	return pick(GLOB.ethnicities_list)

proc/random_body_type()
	return pick(GLOB.body_types_list)

proc/random_hair_style(gender, species = "Human")
	var/h_style = "Crewcut"

	var/list/valid_hairstyles = list()
	for(var/hairstyle in GLOB.hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if( !(species in S.species_allowed))
			continue
		valid_hairstyles[hairstyle] = GLOB.hair_styles_list[hairstyle]

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style


proc/random_facial_hair_style(gender, species = "Human")
	var/f_style = "Shaved"

	var/list/valid_facialhairstyles = list()
	for(var/facialhairstyle in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if( !(species in S.species_allowed))
			continue

		valid_facialhairstyles[facialhairstyle] = GLOB.facial_hair_styles_list[facialhairstyle]

	if(valid_facialhairstyles.len)
		f_style = pick(valid_facialhairstyles)

		return f_style

proc/random_skin_tone()
	switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
		if("caucasian")		. = -10
		if("afroamerican")	. = -115
		if("african")		. = -165
		if("latino")		. = -55
		if("albino")		. = 34
		else				. = rand(-185,34)
	return min(max( .+rand(-25, 25), -185),34)

/proc/get_playable_species()
	var/list/playable_species = list(GLOB.all_species[DEFAULT_SPECIES])
	return playable_species

proc/skintone2racedescription(tone)
	switch (tone)
		if(30 to INFINITY)		return "albino"
		if(20 to 30)			return "pale"
		if(5 to 15)				return "light skinned"
		if(-10 to 5)			return "white"
		if(-25 to -10)			return "tan"
		if(-45 to -25)			return "darker skinned"
		if(-65 to -45)			return "brown"
		if(-INFINITY to -65)	return "black"
		else					return "unknown"

proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"

/proc/do_mob(mob/user, mob/target, delay = 30, user_display, target_display, prog_bar = PROGRESS_GENERIC, uninterruptible = FALSE, datum/callback/extra_checks)
	if(!user || !target)
		return FALSE
	var/user_loc = user.loc

	var/target_loc = target.loc

	var/holding = user.get_active_held_item()
	var/datum/progressbar/P = prog_bar ? new prog_bar(user, delay, target, user_display, target_display) : null

	user.action_busy++
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		P?.update(world.time - starttime)

		if(QDELETED(user) || QDELETED(target) || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break
		if(uninterruptible)
			continue

		if(user.loc != user_loc || target.loc != target_loc || user.get_active_held_item() != holding || user.incapacitated())
			. = FALSE
			break
	if(P)
		qdel(P)
	user.action_busy--


//some additional checks as a callback for for do_afters that want to break on losing health or on the mob taking action
/mob/proc/break_do_after_checks(list/checked_health, check_clicks, selected_zone_check)
	if(check_clicks && next_move > world.time)
		return FALSE
	if(selected_zone_check && zone_selected != selected_zone_check)
		return FALSE
	return TRUE

//pass a list in the format list("health" = mob's health var) to check health during this
/mob/living/break_do_after_checks(list/checked_health, check_clicks, selected_zone_check)
	if(islist(checked_health))
		if(health < checked_health["health"])
			return FALSE
		checked_health["health"] = health
	return ..()

/proc/do_after(mob/user, delay, needhand = TRUE, atom/target, user_display, target_display, prog_bar = PROGRESS_GENERIC, datum/callback/extra_checks)
	if(!user)
		return FALSE

	var/atom/Tloc
	if(target && !isturf(target))
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/holding = user.get_active_held_item()
	delay *= user.do_after_coefficent()

	var/atom/progtarget = target
	if(!target || Tloc == user)
		progtarget = user
	var/datum/progressbar/P = prog_bar ? new prog_bar(user, delay, progtarget, user_display, target_display) : null

	user.action_busy++
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		P?.update(world.time - starttime)

		if(QDELETED(user) || user.incapacitated(TRUE) || user.loc != Uloc || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(!QDELETED(Tloc) && (QDELETED(target) || Tloc != target.loc))
			if(Uloc != Tloc || Tloc != user)
				. = FALSE
				break

		if(needhand && user.get_active_held_item() != holding)
			. = FALSE
			break
	if(P)
		qdel(P)
	user.action_busy--

/mob/proc/do_after_coefficent() // This gets added to the delay on a do_after, default 1
	. = 1