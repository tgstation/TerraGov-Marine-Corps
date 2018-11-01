
//This proc is the most basic of the procs. All it does is make a new mob on the same tile and transfer over a few variables.
//Returns the new mob
//Note that this proc does NOT do MMI related stuff!
/mob/proc/change_mob_type(var/new_type = null, var/turf/location = null, var/new_name = null as text, var/delete_old_mob = 0 as num, var/subspecies)

	if(istype(src,/mob/new_player))
		to_chat(usr, "\red cannot convert players who have not entered yet.")
		return

	if(!new_type)
		new_type = input("Mob type path:", "Mob type") as text|null

	if(istext(new_type))
		new_type = text2path(new_type)

	if(!ispath(new_type))
		to_chat(usr, "Invalid type path (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		return

	if(new_type == /mob/new_player)
		to_chat(usr, "\red cannot convert into a new_player mob type.")
		return

	var/mob/M
	if(isturf(location))
		M = new new_type(location)
	else
		M = new new_type(src.loc)

	if(!M || !ismob(M))
		to_chat(usr, "Type path is not a mob (new_type = [new_type]) in change_mob_type(). Contact a coder.")
		cdel(M)
		return

	if(istext(new_name))
		M.name = new_name
		M.real_name = new_name
	else
		M.name = src.name
		M.real_name = src.real_name

	if(src.dna)
		M.dna = src.dna.Clone()

	if(mind && isliving(M))
		mind.transfer_to(M, TRUE) // second argument to force key move to new mob)
	else
		M.key = key
		if(M.client) 
			M.client.change_view(world.view)


	if(istype(M,/mob/living/carbon/human))
		M.client.prefs.load_preferences()
		var/mob/living/carbon/human/H = M
		if(subspecies)
			H.set_species(subspecies)
		H.name = M.client.prefs.real_name
		H.real_name = M.client.prefs.real_name
		H.voice_name = M.client.prefs.real_name
		H.gender = M.client.prefs.gender
		H.h_style = M.client.prefs.h_style
		H.f_style = M.client.prefs.f_style
		H.r_hair = M.client.prefs.r_hair
		H.g_hair = M.client.prefs.g_hair
		H.b_hair = M.client.prefs.b_hair
		H.r_facial = M.client.prefs.r_facial
		H.g_facial = M.client.prefs.g_facial
		H.b_facial = M.client.prefs.b_facial
		H.r_eyes = M.client.prefs.r_eyes
		H.g_eyes = M.client.prefs.g_eyes
		H.b_eyes = M.client.prefs.b_eyes
		H.age = M.client.prefs.age
		H.ethnicity = M.client.prefs.ethnicity
		H.body_type = M.client.prefs.body_type
		
	if(delete_old_mob)
		spawn(1)
			cdel(src)
	return M