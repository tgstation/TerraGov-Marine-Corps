//This proc is the most basic of the procs. All it does is make a new mob on the same tile and transfer over a few variables.
//Returns the new mob
//Note that this proc does NOT do MMI related stuff!
/mob/proc/change_mob_type(var/new_type = null, var/turf/location = null, var/new_name = null as text, var/delete_old_mob = 0 as num, var/subspecies)
	if(istype(src,/mob/new_player))
		to_chat(usr, "<span class='warning'>Cannot convert players who have not entered yet.</span>")
		return

	if(!new_type)
		new_type = input("Mob type path:", "Mob type") as text|null

	if(istext(new_type))
		new_type = text2path(new_type)

	if(!ispath(new_type))
		to_chat(usr, "Invalid type path (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		return

	if(new_type == /mob/new_player)
		to_chat(usr, "<span class='warning'>Cannot convert into a new_player mob type.</span>")
		return

	var/mob/M
	if(isturf(location))
		M = new new_type(location)
	else
		M = new new_type(loc)

	if(!M || !ismob(M))
		to_chat(usr, "Type path is not a mob (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		qdel(M)
		return

	if(istext(new_name))
		M.name = new_name
		M.real_name = new_name
	else
		M.name = name
		M.real_name = real_name

	if(dna)
		M.dna = dna.Clone()

	if(mind && isliving(M))
		mind.name = M.real_name
		mind.transfer_to(M, TRUE) // second argument to force key move to new mob)
	else
		M.key = key
		if(M.client) 
			M.client.change_view(world.view)


	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
		if(subspecies)
			H.set_species(subspecies)
		if(M.client)
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
		
	if(delete_old_mob)
		spawn(1)
			qdel(src)

	return M