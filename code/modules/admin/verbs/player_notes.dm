/datum/admins/proc/player_notes_show(var/key as text)
	set category = "Admin"
	set name = "Player Notes Show"

	if(!check_rights(R_BAN))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
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
			dat += "<font color=#008800>[I.content]</font> <i>by [I.author] ([I.rank])</i> on <i><font color=blue>[I.timestamp]</i></font> "
			var/bot = CONFIG_GET(string/server_name) ? "[CONFIG_GET(string/server_name)] Bot" : "Adminbot"
			if(I.author == usr.key || I.author == bot || check_rights(R_PERMISSIONS))
				dat += "<A href='?src=[ref];notes_remove=[key];remove_index=[i]'>Remove</A> "
				dat += "<A href='?src=[ref];notes_edit=[key];edit_index=[i]'>Edit</A> "
			if(I.hidden)
				dat += "<A href='?src=[ref];notes_unhide=[key];unhide_index=[i]'>Unhide</A>"
			else
				dat += "<A href='?src=[ref];notes_hide=[key];hide_index=[i]'>Hide</A>"
			dat += "<br><br>"
		if(update_file) to_chat(info, infos)

	dat += "<br>"
	dat += "<A href='?src=[ref];notes_add=[key]'>Add Comment</A><br>"
	dat += "<A href='?src=[ref];notes_copy=[key]'>Copy Player Notes</A><br>"

	dat += "</body></html>"
	usr << browse(dat, "window=adminplayerinfo;size=480x480")


/datum/admins/proc/player_notes_copy(var/key as text)
	set category = null
	set name = "Player Notes Copy"

	if(!check_rights(R_BAN))
		return

	var/dat = "<html><head><title>Copying notes for [key]</title></head>"
	dat += "<body>"
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos)
		dat += "No information found on the given key.<br>"
	else
		var/i = 0
		for(var/datum/player_info/I in infos)
			i += 1
			if(!I.timestamp)
				I.timestamp = "Pre-4/3/2012"
			if(I.hidden)
				continue
			dat += "<font color=#008800>[I.content]</font> | <i><font color=blue>[I.timestamp]</i></font>"
			dat += "<br><br>"
	dat += "</body></html>"
	// Using regex to remove the note author for bans done in admin/topic.dm
	var/regex/remove_author = new("(?=Banned by).*?(?=\\|)", "g")
	dat = remove_author.Replace(dat, "Banned ")

	usr << browse(dat, "window=notescopy;size=480x480")


/datum/admins/proc/player_notes_list()
	set category = "Admin"
	set name = "Player Notes List"

	if(!check_rights(R_BAN))
		return

	usr.client.holder.PlayerNotesPage(1)


/proc/notes_add(var/key, var/note, var/mob/usr)
	if(!check_rights(R_BAN))
		return

	if(!key || !note)
		return

	key = ckey(key)

	//Loading list of notes for this key
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!infos) infos = list()

	//Overly complex timestamp creation
	var/modifyer = "th"
	switch(time2text(world.timeofday, "DD"))
		if("01","21","31")
			modifyer = "st"
		if("02","22",)
			modifyer = "nd"
		if("03","23")
			modifyer = "rd"
	var/day_string = "[time2text(world.timeofday, "DD")][modifyer]"
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


/proc/notes_del(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
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


/proc/notes_hide(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
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


/proc/notes_unhide(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
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


/proc/notes_edit(var/key, var/index)
	if(!check_rights(R_BAN))
		return

	key = ckey(key)
	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
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


/datum/admins/proc/PlayerNotesPage(page)
	if(!check_rights(R_BAN))
		return

	var/ref = "[REF(usr.client.holder)];[HrefToken()]"
	var/dat = "<B>Player notes</B><HR>"
	var/savefile/S = new("data/player_notes.sav")
	var/list/note_keys
	S >> note_keys
	if(!note_keys)
		dat += "No notes found."
	else
		dat += "<table>"
		note_keys = sortList(note_keys)

		// Display the notes on the current page
		var/number_pages = length(note_keys) / PLAYER_NOTES_ENTRIES_PER_PAGE
		// Emulate ceil(why does BYOND not have ceil)
		if(number_pages != round(number_pages))
			number_pages = round(number_pages) + 1
		var/page_index = page - 1
		if(page_index < 0 || page_index >= number_pages)
			return

		var/lower_bound = page_index * PLAYER_NOTES_ENTRIES_PER_PAGE + 1
		var/upper_bound = (page_index + 1) * PLAYER_NOTES_ENTRIES_PER_PAGE
		upper_bound = min(upper_bound, length(note_keys))
		for(var/index = lower_bound, index <= upper_bound, index++)
			var/t = note_keys[index]
			dat += "<tr><td><a href='?src=[ref];notes=show;ckey=[t]'>[t]</a></td></tr>"

		dat += "</table><br>"

		// Display a footer to select different pages
		for(var/index = 1, index <= number_pages, index++)
			if(index == page)
				dat += "<b>"
			dat += "<a href='?src=[ref];notes=list;index=[index]'>[index]</a> "
			if(index == page)
				dat += "</b>"

	usr << browse(dat, "window=player_notes;size=400x400")


/datum/admins/proc/player_has_info(var/key as text)
	if(!check_rights(R_BAN))
		return

	var/savefile/info = new("data/player_saves/[copytext(key, 1, 2)]/[key]/info.sav")
	var/list/infos
	info >> infos
	if(!length(infos))
		return FALSE
	else
		return TRUE