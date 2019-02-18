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
	var/list/playable_species = list()
	for(var/species in GLOB.all_species)
		if(is_alien_whitelisted(species))
			playable_species += species
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

/proc/dsfasfbdf(mob/user, delay, needhand = TRUE, numticks = 5, show_busy_icon, selected_zone_check, busy_check = FALSE)

/proc/do_after(mob/user, delay, needhand = TRUE, atom/target = null, progress = TRUE, show_busy_icon = FALSE, busy_check = FALSE, datum/callback/extra_checks = null)
	if(!user)
		return FALSE

	if(busy_check && user.action_busy)
		to_chat(user, "<span class='warning'>You're already busy doing something!</span>")
		return FALSE

	var/atom/Tloc = null
	if(target && !isturf(target))
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/holding = user.get_active_held_item()

	var/holdingnull = TRUE //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = FALSE //Users hand started holding something, check to see if it's still holding that

	delay *= user.do_after_coefficent()

	var/image/busy_icon
	if(show_busy_icon)
		busy_icon = get_busy_icon(show_busy_icon)
		if(busy_icon)
			user.overlays += busy_icon

	var/datum/progressbar/progbar
	if (progress)
		progbar = new(user, delay, target)

	user.action_busy = TRUE
	var/endtime = world.time + delay
	var/starttime = world.time
	. = TRUE
	while (world.time < endtime)
		stoplag(1)
		if (progress)
			progbar.update(world.time - starttime)

		if(QDELETED(user) || user.stat || user.loc != Uloc || (extra_checks && !extra_checks.Invoke()))
			. = FALSE
			break

		if(user.is_mob_incapacitated())
			. = FALSE
			break

		if(!QDELETED(Tloc) && (QDELETED(target) || Tloc != target.loc))
			if(Uloc != Tloc || Tloc != user)
				. = FALSE
				break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = FALSE
					break
			if(user.get_active_held_item() != holding)
				. = FALSE
				break
	if (progress)
		qdel(progbar)
	if(show_busy_icon)
		user.overlays -= busy_icon
		qdel(busy_icon)
	user.action_busy = FALSE

/mob/proc/do_after_coefficent() // This gets added to the delay on a do_after, default 1
	. = 1