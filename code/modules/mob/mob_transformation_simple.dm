/mob/proc/change_mob_type(new_type, turf/location, new_name, delete_old_mob, subspecies)
	if(!ispath(new_type))
		return

	if(new_type == /mob/new_player)
		to_chat(usr, span_warning("Cannot convert into a new_player."))
		return

	var/mob/M
	if(isturf(location))
		M = new new_type(location)
	else
		M = new new_type(loc)

	if(!istype(M))
		to_chat(usr, span_warning("Invalid typepath."))
		qdel(M)
		return

	if(mind)
		mind.transfer_to(M, TRUE)
	else
		M.key = key

	if(istext(new_name))
		M.name = new_name
		M.real_name = new_name
		if(M.mind)
			M.mind.name = new_name

	on_transformation(subspecies)

	if(delete_old_mob)
		QDEL_IN(src, 1)

	return M


/mob/living/carbon/human/change_mob_type(new_type, turf/location, new_name, delete_old_mob, subspecies)
	if(!ispath(new_type, /mob/living/carbon/human))
		return ..()
	var/mob/living/carbon/carbon_path = new_type
	if(!subspecies)
		subspecies = initial(carbon_path.species)
	on_transformation(subspecies)

/mob/new_player/change_mob_type(new_type, turf/location, new_name, delete_old_mob, subspecies)
	return

/mob/proc/on_transformation(subspecies)
	return

/mob/living/carbon/human/on_transformation(subspecies)
	if(subspecies)
		set_species(subspecies)
	if(client)
		name = client.prefs.real_name
		real_name = client.prefs.real_name
		gender = client.prefs.gender
		h_style = client.prefs.h_style
		f_style = client.prefs.f_style
		r_hair = client.prefs.r_hair
		g_hair = client.prefs.g_hair
		b_hair = client.prefs.b_hair
		grad_style = client.prefs.grad_style
		r_grad = client.prefs.r_grad
		g_grad = client.prefs.g_grad
		b_grad = client.prefs.b_grad
		r_facial = client.prefs.r_facial
		g_facial = client.prefs.g_facial
		b_facial = client.prefs.b_facial
		r_eyes = client.prefs.r_eyes
		g_eyes = client.prefs.g_eyes
		b_eyes = client.prefs.b_eyes
		age = client.prefs.age
		ethnicity = client.prefs.ethnicity
		flavor_text = client.prefs.flavor_text
		update_body()
		update_hair()
		regenerate_icons()
	if(mind)
		mind.name = real_name

/mob/living/silicon/ai/on_transformation(subspecies)
	if(client?.prefs?.ai_name && !is_banned_from(ckey, "Appearance"))
		fully_replace_character_name(real_name, client.prefs.ai_name)
