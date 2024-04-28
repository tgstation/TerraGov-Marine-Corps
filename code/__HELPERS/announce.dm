// the types of priority announcements
#define ANNOUNCEMENT_REGULAR 1
#define ANNOUNCEMENT_PRIORITY 2
#define ANNOUNCEMENT_COMMAND 3

// don't use any of these macros outside of here to keep the appearance of alerts consistent (unless you need to make them global for some reason)
// if you want to design a faction alert to use in a message or something, use assemble_alert()

// a style for extra padding on alert titles
#define span_alert_header(str) ("<span class='alert_header'>" + str + "</span>")

// these are spans that just furnish themselves to the appropriate color
#define span_faction_alert_title(str) ("<span class='faction_alert_title'>" + str + "</span>")
#define span_faction_alert_minortitle(str) ("<span class='faction_alert_minortitle'>" + str + "</span>")
#define span_faction_alert_subtitle(str) ("<span class='faction_alert_subtitle'>" + str + "</span>")
#define span_faction_alert_text(str) ("<span class='faction_alert_text'>" + str + "</span>")

// the actual striped background of faction alerts, the spans above will color themselves to match these
#define faction_alert_default_span(string) ("<div class='faction_alert_default'>" + string + "</div>")
#define faction_alert_colored_span(color, string) ("<div class='faction_alert_" + color + "'>" + string + "</div>")

// colors for faction alert overrides, used for admin menus
#define faction_alert_colors list("default", "green", "blue", "pink", "yellow", "orange", "red", "purple", "grey")

/**
 * Design a faction alert. Returns a string.
 *
 * Arguments
 * * title - required, the title to use for this alert
 * * subtitle - optional, the subtitle/subheader to use for this alert
 * * message - required, the message to use for this alert
 * * color_override - optional, the color to use for this alert instead of blue
 * * minor - is this a minor alert?
 */
/proc/assemble_alert(title, subtitle, message, color_override, minor = FALSE)
	if(!title || !message)
		return

	var/list/alert_strings = list()
	var/header
	var/finalized_alert
	header = minor ? span_faction_alert_minortitle(title) : span_faction_alert_title(title)

	if(subtitle)
		header += span_faction_alert_subtitle(subtitle)

	alert_strings += span_alert_header(header)
	alert_strings += span_faction_alert_text(message)

	if(color_override)
		finalized_alert = faction_alert_colored_span(color_override, jointext(alert_strings, ""))
	else
		finalized_alert = faction_alert_default_span(jointext(alert_strings, ""))

	return finalized_alert

/**
 * Make a priority announcement to a target
 *
 * Arguments
 * * message - **required,** the content of the announcement
 * * title - optional, the title of the announcement
 * * subtitle - optional, the subtitle/subheader of the announcement
 * * type - optional, the type of the announcement (see defines in `__HELPERS/announce.dm`)
 * * sound - optional, the sound played accompanying the announcement
 * * channel_override - optional, what channel is this sound going to be played on?
 * * color_override - **recommended,** string, use the passed color instead of the default blue (see defines in `__HELPERS/announce.dm`)
 * * receivers - a list of all players to send the message to. defaults to all players, not including those in lobby
 */
/proc/priority_announce(message, title = "Announcement", subtitle = "", type = ANNOUNCEMENT_REGULAR, sound = 'sound/misc/notice2.ogg', channel_override = CHANNEL_ANNOUNCEMENTS, color_override, list/receivers = (GLOB.alive_human_list + GLOB.ai_list + GLOB.observer_list))
	if(!message)
		return


	// header/subtitle to use when using assemble_alert()
	var/assembly_header
	var/assembly_subtitle
	switch(type)
		if(ANNOUNCEMENT_REGULAR)
			assembly_header = title

		if(ANNOUNCEMENT_PRIORITY)
			assembly_header = "Priority Announcement"
			if(length(title) > 0)
				assembly_subtitle = title

		if(ANNOUNCEMENT_COMMAND)
			assembly_header = "Command Announcement"

	if(subtitle && type != ANNOUNCEMENT_PRIORITY)
		assembly_subtitle = subtitle

	var/finalized_announcement
	if(color_override)
		finalized_announcement = assemble_alert(
			title = assembly_header,
			subtitle = assembly_subtitle,
			message = message,
			color_override = color_override
		)
	else
		finalized_announcement = assemble_alert(
			title = assembly_header,
			subtitle = assembly_subtitle,
			message = message
		)

	var/s = sound(sound, channel = channel_override)
	for(var/i in receivers)
		var/mob/M = i
		if(!isnewplayer(M))
			to_chat(M, finalized_announcement)
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

/**
 * Make a minor announcement to a target
 *
 * Arguments
 * * message - required, this is the announcement message
 * * title - optional, the title of the announcement
 * * alert - optional, alert or notice?
 * * receivers - a list of all players to send the message to
 */
/proc/minor_announce(message, title = "Attention:", alert, list/receivers = GLOB.alive_human_list, should_play_sound = FALSE)
	if(!message)
		return

	var/sound/S = alert ? sound('sound/misc/notice1.ogg') : sound('sound/misc/notice2.ogg')
	S.channel = CHANNEL_ANNOUNCEMENTS
	for(var/mob/M AS in receivers)
		if(!isnewplayer(M) && !isdeaf(M))
			to_chat(M, assemble_alert(
				title = title,
				message = message,
				minor = TRUE
			))
			if(should_play_sound)
				SEND_SOUND(M, S)

#undef span_alert_header
#undef span_faction_alert_title
#undef span_faction_alert_minortitle
#undef span_faction_alert_subtitle
#undef span_faction_alert_text
#undef faction_alert_default_span
#undef faction_alert_colored_span
