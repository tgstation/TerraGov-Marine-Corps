/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc, /obj/vehicle/multitile/root/cm_armored))
		return

	if(hand)
		var/obj/item/W = l_hand
		if (W)
			W.attack_self(src)
			update_inv_l_hand()
	else
		var/obj/item/W = r_hand
		if (W)
			W.attack_self(src)
			update_inv_r_hand()
	if(next_move < world.time)
		next_move = world.time + 2
	return


/mob/verb/memory()
	set name = "Notes"
	set category = "IC"
	if(mind)
		mind.show_memory(src)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")

/mob/verb/add_memory(msg as message)
	set name = "Add Note"
	set category = "IC"

	msg = copytext(msg, 1, MAX_MESSAGE_LEN)
	msg = sanitize(msg)

	if(mind)
		mind.store_memory(msg)
	else
		to_chat(src, "The game appears to have misplaced your mind datum, so we can't show you your notes.")





/mob/verb/respawn()
	set name = "Respawn"
	set category = "OOC"

	if(!GLOB.respawn_allowed && !check_rights(R_ADMIN, FALSE))
		to_chat(usr, "<span class='notice'>Respawn is disabled. This is the default state, you can usually rejoin the round as a human only via ERT.</span>")
		return
	if(stat != DEAD)
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return
	else
		var/deathtime = world.time - src.timeofdeath
		var/deathtimeminutes = round(deathtime / 600)
		var/pluralcheck = "minute"
		if(deathtimeminutes == 0)
			pluralcheck = ""
		else if(deathtimeminutes == 1)
			pluralcheck = " [deathtimeminutes] minute and"
		else if(deathtimeminutes > 1)
			pluralcheck = " [deathtimeminutes] minutes and"
		var/deathtimeseconds = round((deathtime - deathtimeminutes * 600) / 10,1)
		to_chat(usr, "You have been dead for[pluralcheck] [deathtimeseconds] seconds.")

		if(deathtime < (GLOB.respawntime) && !check_rights(R_ADMIN, FALSE))
			to_chat(usr, "You must wait [GLOB.respawntime * 0.1] seconds to respawn!")
			return
		else
			to_chat(usr, "You can respawn now, enjoy your new life!")

	to_chat(usr, "<span class='boldnotice'>Make sure to play a different character, and please roleplay correctly!</span>")

	if(!client)
		return
	client.screen.Cut()
	if(!client)
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		qdel(M)
		return

	M.key = key


/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "Object"
	reset_perspective(null)
	unset_interaction()
	if(isliving(src))
		var/mob/living/M = src
		if(M.cameraFollow)
			M.cameraFollow = null


/mob/verb/eastface()
	set hidden = 1
	return facedir(EAST)


/mob/verb/westface()
	set hidden = 1
	return facedir(WEST)


/mob/verb/northface()
	set hidden = 1
	return facedir(NORTH)


/mob/verb/southface()
	set hidden = 1
	return facedir(SOUTH)


/mob/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"

	stop_pulling()