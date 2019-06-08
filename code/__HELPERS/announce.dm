#define ANNOUNCEMENT_REGULAR 1
#define ANNOUNCEMENT_PRIORITY 2
#define ANNOUNCEMENT_COMMAND 3


/proc/priority_announce(message, title = "Announcement", type = ANNOUNCEMENT_REGULAR, sound = 'sound/misc/notice2.ogg', list/receivers = (GLOB.alive_human_list + GLOB.silicon_mobs + GLOB.observer_list))
	if(!message)
		return

	var/announcement

	switch(type)
		if(ANNOUNCEMENT_REGULAR)
			announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"

		if(ANNOUNCEMENT_PRIORITY)
			announcement += "<h1 class='alert'>Priority Announcement</h1>"
			if(title && title != "Announcement")
				announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
		
		if(ANNOUNCEMENT_COMMAND)
			announcement += "<h1 class='alert'>Command Announcement</h1>"


	announcement += "<br><span class='alert'>[html_encode(message)]</span><br>"
	announcement += "<br>"

	var/s = sound(sound)
	for(var/i in receivers)
		var/mob/M = i
		if(!isnewplayer(M) && !isdeaf(M))
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

	for(var/i in receivers)
		var/mob/M = i
		if(!isnewplayer(M) && !isdeaf(M))
			to_chat(M, "<span class='big bold'><font color = red>[html_encode(title)]</font color><BR>[html_encode(message)]</span><BR>")
			if(alert)
				SEND_SOUND(M, sound('sound/misc/notice1.ogg'))
			else
				SEND_SOUND(M, sound('sound/misc/notice2.ogg'))