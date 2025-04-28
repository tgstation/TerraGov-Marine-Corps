/proc/GetExp(minutes as num)
	var/exp = minutes - (world.realtime / 10) / 60
	if(exp <= 0)
		return 0
	else
		var/timeleftstring
		if(exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if(exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring


/proc/notes_add(key, note, mob/usr)
	if(!check_rights(R_BAN))
		return

	if(!key || !note)
		return

	key = ckey(key)

	//Loading list of notes for this key
	var/savefile/info = new("data/player_saves/[key[1]]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos) infos = list()

	//Overly complex timestamp creation
	var/modifier = "th"
	switch(time2text(world.timeofday, "DD"))
		if("01","21","31")
			modifier = "st"
		if("02","22")
			modifier = "nd"
		if("03","23")
			modifier = "rd"
	var/day_string = "[time2text(world.timeofday, "DD")][modifier]"
	if(copytext(day_string, 1, 2) == "0")
		day_string = copytext(day_string,2)
	var/full_date = time2text(world.timeofday, "Day, Month DD of YYYY")
	var/day_loc = findtext(full_date, time2text(world.timeofday, "DD"))
	var/hourminute_string = time2text(world.timeofday, "hh:mm")

	var/datum/player_info/P = new
	if(usr)
		P.author = usr.key
		P.rank = usr.client.holder.rank
	else
		P.author = CONFIG_GET(string/server_name) ? "[CONFIG_GET(string/server_name)] Bot" : "Adminbot"
		P.rank = "Silicon"
	P.content = note
	P.timestamp = "[hourminute_string] [copytext(full_date, 1, day_loc)][day_string][copytext(full_date, day_loc + 2)]"
	P.hidden = FALSE

	infos += P
	to_chat(info, infos)

	log_admin_private("[key_name(usr)] has edited [key]'s notes: [note]")
	message_admins("[ADMIN_TPMONTY(usr)] has edited [key]'s notes: [note]")

	qdel(info)

	//Updating list of keys with notes on them
	var/savefile/note_list = new("data/player_notes.sav")
	var/list/note_keys
	note_list >> note_keys
	if(!note_keys)
		note_keys = list()
	if(!note_keys.Find(key))
		note_keys += key
	to_chat(note_list, note_keys)
	qdel(note_list)


/proc/notes_del(key, index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[key[1]]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]
	infos.Remove(item)

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has deleted [key]'s note: [item.content]")
	message_admins("[ADMIN_TPMONTY(usr)] has deleted [key]'s note: [item.content]")


/proc/notes_hide(key, index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[key[1]]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]
	item.hidden = TRUE

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has hidden [key]'s note: [item.content]")
	message_admins("[ADMIN_TPMONTY(usr)] has hidden [key]'s note: [item.content]")


/proc/notes_unhide(key, index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[key[1]]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]
	item.hidden = FALSE

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has made visible [key]'s note: [item.content]")
	message_admins("[ADMIN_TPMONTY(usr)] has made visible [key]'s note: [item.content]")


/proc/notes_edit(key, index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[key[1]]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos || length(infos) < index)
		return

	var/datum/player_info/item = infos[index]

	var/note = input(usr, "What do you want the note to say?", "Edit Note", item.content) as message|null
	if(!note)
		return

	item.content = note

	to_chat(info, infos)
	qdel(info)

	log_admin_private("[key_name(usr)] has edited [key]'s note: [note]")
	message_admins("[ADMIN_TPMONTY(usr)] has edited [key]'s note: [note]")



/datum/player_info/var/author // admin who authored the information
/datum/player_info/var/rank //rank of admin who made the notes
/datum/player_info/var/content // text content of the information
/datum/player_info/var/timestamp // Because this is bloody annoying
/datum/player_info/var/hidden


#define PLAYER_NOTES_ENTRIES_PER_PAGE 50

/mob/verb/view_notes()
	set name = "View Notes"
	set category = "OOC"
	set hidden = TRUE

	var/key = usr.key

	var/dat = "<html><head><title>Info on [key]</title></head>"
	dat += "<body>"

	key = ckey(key)

	var/savefile/info = new("data/player_saves/[key[1]]/[key]/info.sav")
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
