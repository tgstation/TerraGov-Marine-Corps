/mob/proc/change_mob_type(new_type, turf/location, new_name, delete_old_mob, subspecies)
	if(!ispath(new_type))
		return

	if(new_type == /mob/new_player)
		to_chat(usr, "<span class='warning'>Cannot convert into a new_player.</span>")
		return

	var/mob/M
	if(isturf(location))
		M = new new_type(location)
	else
		M = new new_type(loc)

	if(!istype(M))
		to_chat(usr, "<span class='warning'>Invalid typepath.</span>")
		qdel(M)
		return

	if(mind)
		mind.transfer_to(M, TRUE)
	else
		M.key = key
		if(M.client) 
			M.client.change_view(world.view)

	if(istext(new_name))
		M.name = new_name
		M.real_name = new_name
		if(M.mind)
			M.mind.name = new_name

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(subspecies)
			H.set_species(subspecies)
		if(H.client)
			H.name = H.client.prefs.real_name
			H.real_name = H.client.prefs.real_name
			H.voice_name = H.client.prefs.real_name
			H.gender = H.client.prefs.gender
			H.h_style = H.client.prefs.h_style
			H.f_style = H.client.prefs.f_style
			H.r_hair = H.client.prefs.r_hair
			H.g_hair = H.client.prefs.g_hair
			H.b_hair = H.client.prefs.b_hair
			H.r_facial = H.client.prefs.r_facial
			H.g_facial = H.client.prefs.g_facial
			H.b_facial = H.client.prefs.b_facial
			H.r_eyes = H.client.prefs.r_eyes
			H.g_eyes = H.client.prefs.g_eyes
			H.b_eyes = H.client.prefs.b_eyes
			H.age = H.client.prefs.age
			H.ethnicity = H.client.prefs.ethnicity
			H.body_type = H.client.prefs.body_type
			H.flavor_text = H.client.prefs.flavor_text
		if(H.mind)
			H.mind.name = H.real_name
		
	if(delete_old_mob)
		QDEL_IN(src, 1)

	return M


/mob/new_player/change_mob_type(new_type, turf/location, new_name, delete_old_mob, subspecies)
	return