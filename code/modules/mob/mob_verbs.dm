/mob/verb/mode()
	set name = "Activate Held Object"
	set category = "Object"
	set src = usr

	if(istype(loc,/obj/mecha)) return

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

/mob/verb/point_to(atom/A in view(client.view + client.get_offset(), loc))
	set name = "Point To"
	set category = "Object"

	if(!isturf(loc))
		return FALSE

	if(!(A in view(client.view + client.get_offset(), loc))) //Target is no longer visible to us.
		return FALSE

	if(!A.mouse_opacity) //Can't click it? can't point at it.
		return FALSE

	if(is_mob_incapacitated() || (status_flags & FAKEDEATH)) //Incapacitated, can't point.
		return FALSE

	var/tile = get_turf(A)
	if(!tile)
		return FALSE

	if(next_move > world.time)
		return FALSE

	if(recently_pointed_to > world.time)
		return FALSE

	next_move = world.time + 2

	point_to_atom(A, tile)
	return TRUE


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





/mob/verb/abandon_mob()
	set name = "Respawn"
	set category = "OOC"

	if(!GLOB.respawn_allowed && !check_rights(R_ADMIN, FALSE))
		to_chat(usr, "<span class='notice'>Respawn is disabled.</span>")
		return
	if(stat != DEAD)
		to_chat(usr, "<span class='boldnotice'>You must be dead to use this!</span>")
		return
	if(!ticker?.mode || ticker.mode.name == "meteor" || ticker.mode.name == "epidemic") //BS12 EDIT
		to_chat(usr, "<span class='notice'>Respawn is disabled for this roundtype.</span>")
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

		if(deathtime < (respawntime * 600) && !check_rights(R_ADMIN, FALSE))
			to_chat(usr, "You must wait [respawntime] minutes to respawn!")
			return
		else
			to_chat(usr, "You can respawn now, enjoy your new life!")

	log_game("[usr.name]/[usr.key] used abandon mob.")

	to_chat(usr, "<span class='boldnotice'>Make sure to play a different character, and please roleplay correctly!</span>")

	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return
	client.screen.Cut()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		return

	var/mob/new_player/M = new /mob/new_player()
	if(!client)
		log_game("[usr.key] AM failed due to disconnect.")
		qdel(M)
		return

	M.key = key
	if(M.client)
		M.client.change_view(world.view)
	return


/mob/verb/cancel_camera()
	set name = "Cancel Camera View"
	set category = "Object"
	reset_view(null)
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


/mob/verb/stop_pulling()
	set name = "Stop Pulling"
	set category = "IC"

	if(pulling)
		var/mob/M = pulling
		pulling.pulledby = null
		pulling = null
		grab_level = 0
		if(hud_used && hud_used.pull_icon)
			hud_used.pull_icon.icon_state = "pull0"
		if(istype(r_hand, /obj/item/grab))
			temporarilyRemoveItemFromInventory(r_hand)
		else if(istype(l_hand, /obj/item/grab))
			temporarilyRemoveItemFromInventory(l_hand)
		if(istype(M))
			if(M.client)
				//resist_grab uses long movement cooldown durations to prevent message spam
				//so we must undo it here so the victim can move right away
				M.client.next_movement = world.time
			M.update_canmove()


/mob/verb/view_notes()
	set name = "View Admin Remarks"
	set category = "OOC"

	var/key = usr.key

	var/dat = "<html><head><title>Info on [key]</title></head>"
	dat += "<body>"

	key = ckey(key)

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/update_file = 0
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
				update_file = 1
			if(!I.rank)
				I.rank = "N/A"
				update_file = 1
			if(!(I.hidden))
				dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
				dat += "<br><br>"
		if(update_file) to_chat(info, infos)

	dat += "</body></html>"
	usr << browse(dat, "window=adminplayerinfo;size=480x480")