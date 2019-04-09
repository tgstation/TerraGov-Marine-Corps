/var/datum/announcement/priority/priority_announcement = new(do_log = 0)
/var/datum/announcement/priority/command/command_announcement = new(do_log = 0, do_newscast = 1)
/var/datum/announcement/priority/command/warning/ai_system = new()


/datum/announcement
	var/title = "Attention"
	var/announcer = ""
	var/log = 0
	var/sound
	var/newscast = 0
	var/channel_name = "Public Station Announcements"
	var/announcement_type = "Announcement"

/datum/announcement/New(var/do_log = 0, var/new_sound = null, var/do_newscast = 0)
	sound = new_sound
	log = do_log
	newscast = do_newscast

/datum/announcement/priority/New(var/do_log = 1, var/new_sound = sound('sound/misc/notice2.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Priority Announcement"
	announcement_type = "Priority Announcement"

/datum/announcement/priority/command/New(var/do_log = 1, var/new_sound = sound('sound/misc/notice2.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Command Announcement"
	announcement_type = "Command Announcement"

/datum/announcement/priority/command/warning/New() //This is so stupid.
	..(0, sound('sound/misc/notice2.ogg'), 0)
	title = MAIN_AI_SYSTEM
	announcement_type = "Automated Announcement"

/datum/announcement/priority/command/warning/Announce(message, new_sound)
	for(var/mob/living/silicon/decoy/ship_ai/AI in GLOB.silicon_mobs)
		return AI.say(message, new_sound)

/datum/announcement/priority/security/New(var/do_log = 1, var/new_sound = sound('sound/misc/notice2.ogg'), var/do_newscast = 0)
	..(do_log, new_sound, do_newscast)
	title = "Security Announcement"
	announcement_type = "Security Announcement"

/datum/announcement/proc/Announce(message as text, new_title = "", new_sound = null, do_newscast = newscast, to_xenos = FALSE, admin = FALSE)
	if(!message)
		return
	var/message_title = new_title ? new_title : title
	var/message_sound = new_sound ? sound(new_sound) : sound

	if(admin)
		message = noscript(message)
		message_title = noscript(message_title)
	else
		message = html_encode(message)
		message_title = html_encode(message_title)

	Message(message, message_title, to_xenos)
	if(do_newscast)
		NewsCast(message, message_title)
	Sound(message_sound, to_xenos)
	Log(message, message_title)

/datum/announcement/proc/Message(message as text, message_title as text, var/to_xenos = 0)
	for(var/mob/M in GLOB.player_list)
		if(!to_xenos)
			if(isxeno(M) || iszombie(M)) //we reuse to_xenos arg for zombies
				continue
			if(ishuman(M)) //what xenos can't hear, the survivors on the ground can't either.
				var/mob/living/carbon/human/H = M
				if(issurvivor(H) && !is_mainship_level(H.z))
					continue
		if(!isnewplayer(M) && !isdeaf(M))
			to_chat(M, "<h2 class='alert'>[title]</h2>")
			to_chat(M, "<span class='alert'>[message]</span>")
			if (announcer)
				to_chat(M, "<span class='alert'> -[html_encode(announcer)]</span>")

/datum/announcement/minor/Message(message as text, message_title as text, var/to_xenos = 0)
	for(var/mob/M in GLOB.player_list)
		if(!to_xenos)
			if(isxeno(M) || iszombie(M)) //we reuse to_xenos arg for zombies
				continue
			if(ishuman(M)) //what xenos can't hear, the survivors on the ground can't either.
				var/mob/living/carbon/human/H = M
				if(issurvivor(H) && !is_mainship_level(H.z))
					continue
		if(!istype(M,/mob/new_player) && !isdeaf(M))
			to_chat(M, "<b>[message]</b>")

/datum/announcement/priority/Message(message as text, message_title as text, var/to_xenos = 0)
	to_chat(world, "<h1 class='alert'>[message_title]</h1>")
	to_chat(world, "<span class='alert'>[message]</span>")
	if(announcer)
		to_chat(world, "<span class='alert'> -[html_encode(announcer)]</span>")
	to_chat(world, "<br>")

/datum/announcement/priority/command/Message(message as text, message_title as text, var/to_xenos = 0)
	var/command
//	command += "<h1 class='alert'>[message_title]</h1>"
	if (message_title)
		command += "<br><h2 class='alert'>[message_title]</h2>"

	command += "<br><span class='alert'>[message]</span><br>"
	command += "<br>"
	for(var/mob/M in GLOB.player_list)
		if(istype(M,/mob/living/carbon/Xenomorph))
			continue
		if(!istype(M,/mob/new_player) && !isdeaf(M))
			to_chat(M, command)

/datum/announcement/priority/security/Message(message as text, message_title as text, var/to_xenos = 0)
	to_chat(world, "<font size=4 color='red'>[message_title]</font>")
	to_chat(world, "<font color='red'>[message]</font>")

/datum/announcement/proc/NewsCast(message as text, message_title as text, var/to_xenos = 0)
	if(!newscast)
		return

	var/datum/news_announcement/news = new
	news.channel_name = channel_name
	news.author = announcer
	news.message = message
	news.message_type = announcement_type
	news.can_be_redacted = 0
	news.announce_newscaster_news()

/datum/announcement/proc/PlaySound(var/message_sound, var/to_xenos = 0)
	if(!message_sound)
		return
	for(var/mob/M in GLOB.player_list)
		if(isxeno(M) && !to_xenos)
			continue
		if(!isnewplayer(M) && !isdeaf(M))
			M << message_sound

/datum/announcement/proc/Sound(var/message_sound)
	PlaySound(message_sound)

/datum/announcement/priority/Sound(var/message_sound)
	if(sound)
		world << sound

/datum/announcement/priority/command/Sound(var/message_sound, var/to_xenos = 0)
	PlaySound(message_sound, to_xenos)


/datum/announcement/proc/Log(message as text, message_title as text)
	if(log)
		usr.log_talk("[message_title] - [message] - [announcer]", LOG_SAY, "[announcement_type]")
		message_admins("[ADMIN_TPMONTY(usr)] has made \a [announcement_type].")


/proc/GetNameAndAssignmentFromId(var/obj/item/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name

/datum/news_announcement
	var/round_time // time of the round at which this should be announced, in seconds
	var/message // body of the message
	var/author = "NanoTrasen Editor"
	var/channel_name = "Nyx Daily"
	var/can_be_redacted = 0
	var/message_type = "Story"

/datum/news_announcement/proc/announce_newscaster_news()
	var/datum/feed_channel/sendto
	for(var/datum/feed_channel/FC in news_network.network_channels)
		if(FC.channel_name == channel_name)
			sendto = FC
			break

	if(!sendto)
		sendto = new /datum/feed_channel
		sendto.channel_name = channel_name
		sendto.author = author
		sendto.locked = 1
		sendto.is_admin_channel = 1
		news_network.network_channels += sendto

	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = author ? author : sendto.author
	newMsg.is_admin_message = !can_be_redacted
	newMsg.body = message
	newMsg.message_type = message_type

	sendto.messages += newMsg

	for(var/obj/machinery/newscaster/NEWSCASTER in allCasters)
		NEWSCASTER.newsAlert(channel_name)
