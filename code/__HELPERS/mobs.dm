/proc/random_ethnicity()
	return pick(GLOB.ethnicities_list)


/proc/random_body_type()
	return pick(GLOB.body_types_list)


/proc/random_hair_style(gender, species = "Human")
	var/list/valid_hairstyles = list()
	for(var/hairstyle in GLOB.hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.hair_styles_list[hairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if(!(species in S.species_allowed))
			continue
		valid_hairstyles[hairstyle] = GLOB.hair_styles_list[hairstyle]

	if(!length(valid_hairstyles))
		return "Crewcut"
		
	return pick(valid_hairstyles)


/proc/random_facial_hair_style(gender, species = "Human")
	var/list/valid_facialhairstyles = list()
	for(var/facialhairstyle in GLOB.facial_hair_styles_list)
		var/datum/sprite_accessory/S = GLOB.facial_hair_styles_list[facialhairstyle]
		if(gender == MALE && S.gender == FEMALE)
			continue
		if(gender == FEMALE && S.gender == MALE)
			continue
		if(!(species in S.species_allowed))
			continue

		valid_facialhairstyles[facialhairstyle] = GLOB.facial_hair_styles_list[facialhairstyle]

	if(!length(valid_facialhairstyles))
		return "Shaved"

	return pick(valid_facialhairstyles)


/proc/get_playable_species()
	var/list/playable_species = list(GLOB.all_species[DEFAULT_SPECIES])
	return playable_species


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


/proc/random_unique_name(gender, attempts_to_find_unique_name = 10)
	for(var/i in 1 to attempts_to_find_unique_name)
		if(gender == FEMALE)
			. = capitalize(pick(GLOB.first_names_female)) + " " + capitalize(pick(GLOB.last_names))
		else
			. = capitalize(pick(GLOB.first_names_male)) + " " + capitalize(pick(GLOB.last_names))

		if(!findname(.))
			break


/proc/get_mob_by_ckey(key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M