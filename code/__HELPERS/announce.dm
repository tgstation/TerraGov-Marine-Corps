#define ANNOUNCEMENT_REGULAR 1
#define ANNOUNCEMENT_PRIORITY 2
#define ANNOUNCEMENT_COMMAND 3

/proc/priority_announce(message, title = "Announcement", type = ANNOUNCEMENT_REGULAR, sound = 'sound/misc/notice2.ogg', list/receivers = (GLOB.alive_human_list + GLOB.ai_list + GLOB.observer_list))
	if(!message)
		return

	var/announcement
	var/header

	switch(type)
		if(ANNOUNCEMENT_REGULAR)
			header += "[html_encode(title)]"

		if(ANNOUNCEMENT_PRIORITY)
			header += "Priority Announcement"
			if(title && title != "Announcement")
				header += "[html_encode(title)]"

		if(ANNOUNCEMENT_COMMAND)
			header += "Command Announcement"


	announcement += "<meta charset='UTF-8'>[span_faction_alert("[span_faction_alert_title("[header]")]<br>[span_faction_alert_text("[html_encode(message)]")]")]"

	var/s = sound(sound, channel = CHANNEL_ANNOUNCEMENTS)
	for(var/i in receivers)
		var/mob/M = i
		if(!isnewplayer(M))
			to_chat(M, announcement)
			SEND_SOUND(M, s)


/proc/print_command_report(papermessage, papertitle = "paper", announcemessage = "A report has been downloaded and printed out at all communications consoles.", announcetitle = "Incoming Classified Message", announce = TRUE)
	if(announce)
		priority_announce(announcemessage, announcetitle, sound = 'sound/AI/commandreport.ogg')

	for(var/obj/machinery/computer/communications/C in GLOB.machines)
		if(C.machine_stat & (BROKEN|NOPOWER))
			continue

		var/obj/item/paper/P = new(get_turf(C))
		P.name = papertitle
		P.info = papermessage
		P.update_icon()


/proc/minor_announce(message, title = "Attention:", alert, list/receivers = GLOB.alive_human_list)
	if(!message)
		return

	var/sound/S = alert ? sound('sound/misc/notice1.ogg') : sound('sound/misc/notice2.ogg')
	S.channel = CHANNEL_ANNOUNCEMENTS
	for(var/mob/M AS in receivers)
		if(!isnewplayer(M) && !isdeaf(M))
			to_chat(M, "[span_faction_alert("[span_faction_alert_minortitle("[html_encode(title)]")][span_faction_alert_text("[html_encode(message)]")]")]")
			SEND_SOUND(M, S)
