/obj/machinery/computer/telecomms/server
	name = "telecommunications server monitoring console"
	desc = "Has full access to all details and record of the telecommunications network it's monitoring."

	icon_state = "computer"
	screen_overlay = "comm_logs"

	var/screen = 0				// the screen number:
	var/list/servers = list()	// the servers located by the computer
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe
	var/temp = ""				// temporary feedback messages

	var/universal_translate = FALSE // set to 1 if it can translate nonhuman speech

	circuit = /obj/item/circuitboard/computer/comm_server

/obj/machinery/computer/telecomms/server/preset
	network = "tcommsat"

/obj/machinery/computer/telecomms/server/interact(mob/user)
	var/dat

	switch(screen)
		if(0) // --- Main Menu ---
			dat += "<br>[temp]<br>"
			dat += "<br>Current Network: <a href='?src=[REF(src)];network=1'>[network]</a><br>"
			if(length(servers))
				dat += "<br>Detected Telecommunication Servers:<ul>"
				for(var/obj/machinery/telecomms/T in servers)
					dat += "<li><a href='?src=[REF(src)];viewserver=[T.id]'>[REF(T)] [T.name]</a> ([T.id])</li>"
				dat += "</ul>"
				dat += "<br><a href='?src=[REF(src)];operation=release'>\[Flush Buffer\]</a>"

			else
				dat += "<br>No servers detected. Scan for servers: <a href='?src=[REF(src)];operation=scan'>\[Scan\]</a>"
		if(1) // --- Viewing Server ---
			dat += "<br>[temp]<br>"
			dat += "<center><a href='?src=[REF(src)];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=[REF(src)];operation=refresh'>\[Refresh\]</a></center>"
			dat += "<br>Current Network: [network]"
			dat += "<br>Selected Server: [SelectedServer.id]"

			if(SelectedServer.totaltraffic >= 1024)
				dat += "<br>Total recorded traffic: [round(SelectedServer.totaltraffic / 1024)] Terrabytes<br><br>"
			else
				dat += "<br>Total recorded traffic: [SelectedServer.totaltraffic] Gigabytes<br><br>"

			dat += "Stored Logs: <ol>"

			var/i = 0
			for(var/datum/comm_log_entry/C in SelectedServer.log_entries)
				i++
				// If the log is a speech file
				if(C.input_type == "Speech File")
					dat += "<li><font color = #6ff76f>[C.name]</font>  <font color = #f75454><a href='?src=[REF(src)];delete=[i]'>\[X\]</a></font><br>"

					// -- Determine race of orator --

					var/mobtype = C.parameters["mobtype"]
					var/race			   // The actual race of the mob

					if(ispath(mobtype, /mob/living/carbon/human) || ispath(mobtype, /mob/living/brain))
						race = "Humanoid"
					else if(ispath(mobtype, /mob/living/carbon/human/species/monkey))
						race = "Monkey"
					// sometimes M gets deleted prematurely for AIs... just check the job
					else if(ispath(mobtype, /mob/living/silicon) || C.parameters["job"] == "AI")
						race = "Artificial Life"
					else if(isobj(mobtype))
						race = "Machinery"
					else if(ispath(mobtype, /mob/living/simple_animal))
						race = "Domestic Animal"
					else
						race = "<i>Unidentifiable</i>"

					dat += "<u><font color = #58f498>Data type</font></u>: [C.input_type]<br>"
					dat += "<u><font color = #58f498>Source</font></u>: [C.parameters["name"]] (Job: [C.parameters["job"]])<br>"
					dat += "<u><font color = #58f498>Class</font></u>: [race]<br>"
					var/message = C.parameters["message"]
					var/language = C.parameters["language"]

					// based on [/atom/movable/proc/lang_treat]
					if(universal_translate || user.has_language(language))
						message = "\"[message]\""
					else if(!user.has_language(language))
						var/datum/language/D = GLOB.language_datum_instances[language]
						message = "\"[D.scramble(message)]\""
					else if(language)
						message = "<i>(unintelligible)</i>"

					dat += "<u><font color = #58f498>Contents</font></u>: [message]<br>"
					dat += "</li><br>"

				else if(C.input_type == "Execution Error")
					dat += "<li><font color = #ff6363>[C.name]</font>  <a href='?src=[REF(src)];delete=[i]'>\[X\]</a><br>"
					dat += "<u><font color = #e8e784>Error</font></u>: \"[C.parameters["message"]]\"<br>"
					dat += "</li><br>"
				else
					dat += "<li><font color = #8e8ef9>[C.name]</font>  <a href='?src=[REF(src)];delete=[i]'>\[X\]</a><br>"
					dat += "<u><font color = #58f498>Data type</font></u>: [C.input_type]<br>"
					dat += "<u><font color = #58f498>Contents</font></u>: <i>(unintelligible)</i><br>"
					dat += "</li><br>"
			dat += "</ol>"

	var/datum/browser/browser = new(user, "comm_monitor", "<div align='center'>Telecommunication Server Monitor</div>", 575, 400)
	browser.set_content(dat)
	browser.open(TRUE)

	temp = ""


/obj/machinery/computer/telecomms/server/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				break

	else if(href_list["operation"])
		switch(href_list["operation"])
			if("release")
				servers = list()
				screen = 0
			if("mainmenu")
				screen = 0
			if("scan")
				if(length(servers))
					temp = "<font color = #f97c75>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"
				else
					for(var/obj/machinery/telecomms/server/T in urange(25, src))
						if(T.network == network)
							servers.Add(T)
					if(!length(servers))
						temp = "<font color = #f97c75>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font color>"
					else
						temp = "<font color = #88bff7>- [length(servers)] SERVERS PROBED & BUFFERED -</font color>"
					screen = 0

	else if(href_list["delete"])
		if(!allowed(usr))
			to_chat(usr, span_danger("ACCESS DENIED."))
			return

		if(SelectedServer)
			var/datum/comm_log_entry/D = SelectedServer.log_entries[text2num(href_list["delete"])]
			temp = "<font color = #88bff7>- DELETED ENTRY: [D.name] -</font color>"
			SelectedServer.log_entries.Remove(D)
			qdel(D)

		else
			temp = "<font color = #f97c75>- FAILED: NO SELECTED MACHINE -</font color>"

	else if(href_list["network"])
		var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)
		if(newnet && ((usr in range(1, src)) || issilicon(usr)))
			if(length(newnet) > 15)
				temp = "<font color = #f97c75>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"
			else
				network = newnet
				screen = 0
				servers = list()
				temp = "<font color = #88bff7>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

	updateUsrDialog()
