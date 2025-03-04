
/datum/tgs_chat_command/tgscheck
	name = "check"
	help_text = "Gets the playercount, gamemode, and address of the server"

/datum/tgs_chat_command/tgscheck/Run(datum/tgs_chat_user/sender, params)
	var/server = CONFIG_GET(string/public_address) || CONFIG_GET(string/server)
	return "Round ID: [GLOB.round_id] | Round Time: [gameTimestamp("hh:mm")] | Players: [length(GLOB.clients)] | Ground Map: [length(SSmapping.configs) ? SSmapping.configs[GROUND_MAP].map_name : "Loading..."] | Ship Map: [length(SSmapping.configs) ? SSmapping.configs[SHIP_MAP].map_name : "Loading..."] | Mode: [GLOB.master_mode] | Round Status: [SSticker.HasRoundStarted() ? (SSticker.IsRoundInProgress() ? "Active" : "Finishing") : "Starting"] | Link: [server ? server : "<byond://[world.internet_address]:[world.port]>"]"

/datum/tgs_chat_command/lagcheck
	name = "lagcheck"
	help_text = "Checks current time dilation on the server"

/datum/tgs_chat_command/lagcheck/Run(datum/tgs_chat_user/sender, params)
	return "Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)"

/datum/tgs_chat_command/gameversion
	name = "gameversion"
	help_text = "Gets the version details from the show-server-revision verb, basically"

/datum/tgs_chat_command/gameversion/Run(datum/tgs_chat_user/sender, params)
	var/list/msg = list("")
	msg += "BYOND Server Version: [world.byond_version].[world.byond_build] (Compiled with: [DM_VERSION].[DM_BUILD])\n"

	if (!GLOB.revdata)
		msg += "No revision information found."
	else
		msg += "Revision [copytext_char(GLOB.revdata.commit, 1, 9)]"
		if (GLOB.revdata.date)
			msg += " compiled on '[GLOB.revdata.date]'"

		if(GLOB.revdata.originmastercommit)
			msg += ", from origin commit: <[CONFIG_GET(string/githuburl)]/commit/[GLOB.revdata.originmastercommit]>"

		if(GLOB.revdata.testmerge.len)
			msg += "\n"
			for(var/datum/tgs_revision_information/test_merge/PR as anything in GLOB.revdata.testmerge)
				msg += "PR #[PR.number] at [copytext_char(PR.head_commit, 1, 9)] [PR.title].\n"
				if (PR.url)
					msg += "<[PR.url]>\n"
	return new /datum/tgs_message_content(msg.Join(""))

// Notify
/datum/tgs_chat_command/notify
	name = "notify"
	help_text = "Pings the invoker when the round ends"

/datum/tgs_chat_command/notify/Run(datum/tgs_chat_user/sender, params)
	if(!CONFIG_GET(str_list/channel_announce_new_game))
		return new /datum/tgs_message_content("Notifcations are currently disabled")

	for(var/member in SSdiscord.notify_members) // If they are in the list, take them out
		if(member == sender.mention)
			SSdiscord.notify_members -= sender.mention
			return new /datum/tgs_message_content("You will no longer be notified when the server restarts")

	// If we got here, they arent in the list. Chuck 'em in!
	SSdiscord.notify_members += sender.mention
	return new /datum/tgs_message_content("You will now be notified when the server restarts")

/datum/tgs_chat_command/seasonals
	name = "seasonals"
	help_text = "Checks current seasonals active in the round."

/datum/tgs_chat_command/seasonals/Run(datum/tgs_chat_user/sender, params)
	var/list/messages = list()
	if(!length(SSpersistence.season_progress))
		return new /datum/tgs_message_content("No seasonals found")
	for(var/season_entry in SSpersistence.season_progress)
		var/season_name = jointext(splittext("[season_entry]", "_"), " ")
		var/season_name_first_letter = uppertext(copytext(season_name, 1, 2))
		var/season_name_remainder = copytext(season_name, 2, length(season_name) + 1)
		season_name = season_name_first_letter + season_name_remainder
		messages += "[season_name]: [SSpersistence.season_progress[season_entry][CURRENT_SEASON_NAME]]"
	return new /datum/tgs_message_content(messages.Join("\n"))
