//This proc allows download of past server logs saved within the data/logs/ folder.
/client/proc/getserverlogs()
	set name = "Get Server Logs"
	set desc = "View/retrieve logfiles."
	set category = "Admin"

	browseserverlogs()

/client/proc/getcurrentlogs()
	set name = "Get Current Logs"
	set desc = "View/retrieve logfiles for the current round."
	set category = "Admin"

	browseserverlogs("[GLOB.log_directory]/")

/client/proc/browseserverlogs(path = "data/logs/")
	path = browse_files(path)
	if(!path)
		return

	if(file_spam_check())
		return

	message_admins("[key_name_admin(src)] accessed file: [path]")
	switch(alert("View (in game), Open (in your system's text editor), or Download?", path, "View", "Open", "Download"))
		if ("View")
			src << browse("<pre style='word-wrap: break-word;'>[html_encode(file2text(file(path)))]</pre>", list2params(list("window" = "viewfile.[path]")))
		if ("Open")
			src << run(file(path))
		if ("Download")
			src << ftp(file(path))
		else
			return
	to_chat(src, "Attempting to send [path], this may take a fair few minutes if the file is very large.")
	return


/client/proc/getfolderlogs()
	set name = "Get Server Logs Folder"
	set desc = "Please use responsibly."
	set category = "Admin"

	var/choice = alert(src, "Due to the way BYOND handles files, you WILL need a click macro. This function is also recurive and prone to fucking up, especially if you select the wrong folder. Are you absolutely sure you want to proceed?", "WARNING", "Yes", "No")
	if(choice != "Yes")
		return

	var/path = "data/logs/"
	path = browse_folders(path)

	if(path)
		recursive_download(path)



/client/proc/recursive_download(var/folder)
	var/files = flist(folder)
	for(var/next in files)
		if(copytext(next, -1, 0) == "/")
			to_chat(src, "Going deeper [folder][next]")
			recursive_download(folder + next)
		else
			to_chat(src, "Downloading [folder][next]")
			var/fil = replacetext("[folder][next]", "/", "_")
			sleep(5)
			src << ftp(file(folder + next), fil)



/client/proc/browse_folders(root = "data/logs/", max_iterations = 100)
	var/path = root

	for(var/i = 0, i < max_iterations, i++)
		var/list/choices = flist(path)
		if(path != root)
			choices.Insert(1, "/")

		var/choice = input(src, "Choose a folder to access:", "Download", null) as null|anything in choices
		switch(choice)
			if(null)
				return FALSE
			if("/")
				path = root
				continue

		path += choice


		if(copytext(path, -1, 0) != "/")		//didn't choose a directory, no need to iterate again
			continue
		else
			var/choice2 = alert(src, "Is this the folder you want to download?:",, "Yes", "No")
			switch(choice2)
				if("Yes")
					break
				if("No")
					continue

	return path


/proc/show_individual_logging_panel(mob/M, source = LOGSRC_CLIENT, type = INDIVIDUAL_ATTACK_LOG)
	if(!M || !ismob(M))
		return

	var/ntype = text2num(type)

	//Add client links
	var/dat = ""
	if(M.client)
		dat += "<center><p>Client</p></center>"
		dat += "<center>"
		dat += individual_logging_panel_link(M, INDIVIDUAL_ATTACK_LOG, LOGSRC_CLIENT, "Attack Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_SAY_LOG, LOGSRC_CLIENT, "Say Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_EMOTE_LOG, LOGSRC_CLIENT, "Emote Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_COMMS_LOG, LOGSRC_CLIENT, "Comms Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_OOC_LOG, LOGSRC_CLIENT, "OOC Log", source, ntype)
		dat += " | "
		dat += individual_logging_panel_link(M, INDIVIDUAL_SHOW_ALL_LOG, LOGSRC_CLIENT, "Show All", source, ntype)
		dat += "</center>"
	else
		dat += "<p> No client attached to mob </p>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"
	dat += "<center><p>Mob</p></center>"
	//Add the links for the mob specific log
	dat += "<center>"
	dat += individual_logging_panel_link(M, INDIVIDUAL_ATTACK_LOG, LOGSRC_MOB, "Attack Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_SAY_LOG, LOGSRC_MOB, "Say Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_EMOTE_LOG, LOGSRC_MOB, "Emote Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_COMMS_LOG, LOGSRC_MOB, "Comms Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_OOC_LOG, LOGSRC_MOB, "OOC Log", source, ntype)
	dat += " | "
	dat += individual_logging_panel_link(M, INDIVIDUAL_SHOW_ALL_LOG, LOGSRC_MOB, "Show All", source, ntype)
	dat += "</center>"

	dat += "<hr style='background:#000000; border:0; height:1px'>"

	var/log_source = M.logging;
	if(source == LOGSRC_CLIENT && M.client) //if client doesn't exist just fall back to the mob log
		log_source = M.client.player_details.logging //should exist, if it doesn't that's a bug, don't check for it not existing

	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & ntype)
			var/list/reversed = log_source[log_type]
			if(islist(reversed))
				reversed = reverseRange(reversed.Copy())
				for(var/entry in reversed)
					dat += "<font size=2px><b>[entry]</b><br>[reversed[entry]]</font><br>"
			dat += "<hr>"

	usr << browse(dat, "window=invidual_logging_[key_name(M)];size=600x480")

/proc/individual_logging_panel_link(mob/M, log_type, log_src, label, selected_src, selected_type)
	var/slabel = label
	if(selected_type == log_type && selected_src == log_src)
		slabel = "<b>\[[label]\]</b>"

	return "<a href='?_src_=holder;individuallog=\ref[M];log_type=[log_type];log_src=[log_src]'>[slabel]</a>"