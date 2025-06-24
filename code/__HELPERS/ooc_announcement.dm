// These are local since they don't really need to be used anywhere else
#define span_ooc_announcement_text(str) ("<span class='ooc_announcement_text'>" + str + "</span>")
#define span_ooc_alert_subtitle(str) ("<span class='faction_alert_subtitle'>" + str + "</span>")
#define span_major_announcement_title(str) ("<span class='faction_alert_title'>" + str + "</span>")
/**
 * Sends a div formatted chat box announcement
 *
 * Formatted like:
 *
 * " Server Announcement " (or sender_override)
 *
 * " Title "
 *
 * " Text "
 *
 * Arguments
 * * text - required, the text to announce
 * * title - optional, the title of the announcement.
 * * players - optional, a list of all players to send the message to. defaults to the entire world
 * * play_sound - if TRUE, play a sound with the announcement
 * * sound_override - optional, override the default announcement sound
 * * sender_override - optional, modifies the sender of the announcement
 * * style - optional, is this an `ooc` (blue, used for admin announcements) or `game` (red, used for round-related announcements) announcement
 * * encode_title - if TRUE, the title will be HTML encoded (escaped)
 * * encode_text - if TRUE, the text will be HTML encoded (escaped)
 */
/proc/send_ooc_announcement(
	text,
	title = "",
	players,
	play_sound = TRUE,
	sound_override = 'sound/misc/adm_announce.ogg',
	sender_override = "Server Admin Announcement",
	style = OOC_ALERT_ADMIN,
	encode_title = TRUE,
	encode_text = FALSE,
)
	if(isnull(text))
		return

	var/list/announcement_strings = list()

	if(encode_title && title && length(title) > 0)
		title = html_encode(title)
		if(encode_text)
			text = html_encode(text)
			if(!length(text))
				return

	announcement_strings += span_major_announcement_title(sender_override)
	announcement_strings += span_ooc_alert_subtitle(title)
	announcement_strings += span_ooc_announcement_text(text)
	var/finalized_announcement = create_ooc_announcement_div(jointext(announcement_strings, ""), style)

	if(islist(players))
		for(var/mob/target in players)
			to_chat(target, finalized_announcement)
			if(play_sound)
				SEND_SOUND(target, sound(sound_override))
	else
		to_chat(world, finalized_announcement)

		if(!play_sound)
			return

		for(var/mob/player in GLOB.player_list)
			SEND_SOUND(player, sound(sound_override))

/**
 * Inserts a span styled message into an OOC alert style div
 *
 *
 * Arguments
 * * message - required, the message contents
 * * style_override - required, set the div style
 */
/proc/create_ooc_announcement_div(message, style_override)
	return "<div class='ooc_alert_[style_override]'>[message]</div>"

#undef span_ooc_announcement_text
#undef span_ooc_alert_subtitle
#undef span_major_announcement_title
