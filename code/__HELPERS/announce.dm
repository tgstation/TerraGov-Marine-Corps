#define ANNOUNCEMENT_REGULAR 1
#define ANNOUNCEMENT_PRIORITY 2
#define ANNOUNCEMENT_COMMAND 3

// these are just spans that furnish the text itself to the appropriate color
#define span_faction_alert_title(str) ("<span class='faction_alert_title'>" + str + "</span>")
#define span_faction_alert_minortitle(str) ("<span class='faction_alert_minortitle'>" + str + "</span>")
#define span_faction_alert_subtitle(str) ("<span class='faction_alert_subtitle'>" + str + "</span>")
#define span_faction_alert_text(str) ("<span class='faction_alert_text'>" + str + "</span>")

// actually giving alerts the striped background
#define faction_alert_default_span(string) ("<div class='faction_alert_default'>" + string + "</div>")
#define faction_alert_colored_span(color, string) ("<div class='faction_alert_" + color + "'>" + string + "</div>")

// colors for faction alert overrides
#define faction_alert_colors list("default", "green", "blue", "pink", "yellow", "orange", "red", "purple", "grey")

/**
 * Make a priority announcement to a target
 *
 * Arguments
 * * message - **required,** this is the announcement message
 * * title - optional, the title of the announcement
 * * subtitle - optional, the subtitle/subheader of the announcement
 * * type - optional, the type of the announcement (see defines in `__HELPERS/announce.dm`)
 * * sound - optional, the sound played accompanying the announcement
 * * color_override - **recommended,** string, use the passed color instead of the default blue (see defines in `__HELPERS/announce.dm`)
 * * receivers - a list of all players to send the message to. defaults to all players, not including those in lobby
 */
/proc/priority_announce(message, title = "", subtitle = "", type = ANNOUNCEMENT_REGULAR, sound = 'sound/misc/notice2.ogg', color_override, list/receivers = (GLOB.alive_human_list + GLOB.ai_list + GLOB.observer_list))
	if(!message)
		return

	/// The strings for this announcement (title/message/etc) to be joined for the final message
	var/list/announcement_strings = list()

	var/header
	switch(type)
		if(ANNOUNCEMENT_REGULAR)
			header = span_faction_alert_title(title)

		if(ANNOUNCEMENT_PRIORITY)
			header = span_faction_alert_title("Priority Announcement")
			if(length(title) > 0)
				header += span_faction_alert_subtitle(title)

		if(ANNOUNCEMENT_COMMAND)
			header = span_faction_alert_title("Command Announcement")

	if(subtitle)
		header += span_faction_alert_subtitle(subtitle)

	announcement_strings += header
	announcement_strings += span_faction_alert_text("[message]")

	var/finalized_announcement
	if(color_override)
		finalized_announcement = faction_alert_colored_span(color_override, jointext(announcement_strings, ""))
	else
		finalized_announcement = faction_alert_default_span(jointext(announcement_strings, ""))

	var/s = sound(sound, channel = CHANNEL_ANNOUNCEMENTS)
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
/proc/minor_announce(message, title = "Attention:", alert, list/receivers = GLOB.alive_human_list)
	if(!message)
		return

	var/sound/S = alert ? sound('sound/misc/notice1.ogg') : sound('sound/misc/notice2.ogg')
	S.channel = CHANNEL_ANNOUNCEMENTS
	for(var/mob/M AS in receivers)
		if(!isnewplayer(M) && !isdeaf(M))
			to_chat(M, "[faction_alert_default_span("[span_faction_alert_minortitle("[title]")][span_faction_alert_text("[message]")]")]")
			SEND_SOUND(M, S)
