/client/proc/forcerandomrotate()
	set category = "Server"
	set name = "Trigger Random Map Rotation"

	if(!check_rights(R_SERVER))
		return

	var/rotate = alert("Force a random map rotation to trigger?", "Rotate map?", "Yes", "Cancel")
	if (rotate != "Yes")
		return
	message_admins("[key_name_admin(usr)] is forcing a random map rotation.")
	log_admin("[key_name(usr)] is forcing a random map rotation.")
	maprotatechecked = 1
	maprotate()

/client/proc/adminchangemap()
	set category = "Server"
	set name = "Change Map"

	if(!check_rights(R_SERVER))
		return

	var/list/maprotatechoices = list()
	for (var/map in config.maplist)
		var/datum/votablemap/VM = config.maplist[map]
		var/mapname = VM.friendlyname
		if (VM == config.defaultmap)
			mapname += " (Default)"

		if (VM.minusers > 0 || VM.maxusers > 0)
			mapname += " \["
			if (VM.minusers > 0)
				mapname += "[VM.minusers]"
			else
				mapname += "0"
			mapname += "-"
			if (VM.maxusers > 0)
				mapname += "[VM.maxusers]"
			else
				mapname += "inf"
			mapname += "\]"
		if (VM.voteweight <= 0)
			mapname += "(Disabled)"

		maprotatechoices[mapname] = VM
	var/chosenmap = input("Choose a map to change to", "Change Map")  as null|anything in maprotatechoices
	if (!chosenmap)
		return
	maprotatechecked = TRUE
	var/datum/votablemap/VM = maprotatechoices[chosenmap]
	message_admins("[key_name_admin(usr)] is changing the map to [VM.name]([VM.friendlyname])")
	log_admin("[key_name(usr)] is changing the map to [VM.name]([VM.friendlyname])")
	if (changemap(VM) == 0)
		maprotatechecked = TRUE
		message_admins("[key_name_admin(usr)] has changed the map to [VM.name]([VM.friendlyname])")

