/proc/faction_announce(message, title = "Attention:", alert, list/receivers = GLOB.alive_human_list, should_play_sound = FALSE, to_faction = FACTION_TERRAGOV)
	if(!message)
		return

	var/sound/S = alert ? sound('sound/misc/notice1.ogg') : sound('sound/misc/notice2.ogg')
	S.channel = CHANNEL_ANNOUNCEMENTS
	for(var/mob/M AS in receivers)
		if(!isnewplayer(M) && !isdeaf(M) && M.faction == to_faction)
			to_chat(M, assemble_alert(
				title = title,
				message = message,
				minor = TRUE
			))
			if(should_play_sound)
				SEND_SOUND(M, S)
