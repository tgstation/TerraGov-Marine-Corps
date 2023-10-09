#define TGS_STATUS_THROTTLE 7

/datum/tgs_chat_command/tgscheck
	name = "check"
	help_text = "Gets the playercount, gamemode, and address of the server"
	var/last_tgs_check = 0


/datum/tgs_chat_command/tgscheck/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_tgs_check < TGS_STATUS_THROTTLE)
		return
	last_tgs_check = rtod
	var/server = CONFIG_GET(string/server)
	return "Round ID: [GLOB.round_id] | Round Time: [gameTimestamp("hh:mm")] | Players: [length(GLOB.clients)] | Ground Map: [length(SSmapping.configs) ? SSmapping.configs[GROUND_MAP].map_name : "Loading..."] | Ship Map: [length(SSmapping.configs) ? SSmapping.configs[SHIP_MAP].map_name : "Loading..."] | Mode: [GLOB.master_mode] | Round Status: [SSticker.HasRoundStarted() ? (SSticker.IsRoundInProgress() ? "Active" : "Finishing") : "Starting"] | Link: [server ? server : "<byond://[world.internet_address]:[world.port]>"]"


/datum/tgs_chat_command/ahelp
	name = "ahelp"
	help_text = "<ckey|ticket #> <message|ticket <close|resolve|icissue|reject|reopen|tier <ticket #>|list>>"
	admin_only = TRUE


/datum/tgs_chat_command/ahelp/Run(datum/tgs_chat_user/sender, params)
	var/list/all_params = splittext(params, " ")
	if(length(all_params) < 2)
		return "Insufficient parameters"
	var/target = all_params[1]
	all_params.Cut(1, 2)
	var/id = text2num(target)
	if(id != null)
		var/datum/admin_help/AH = GLOB.ahelp_tickets.TicketByID(id)
		if(AH)
			target = AH.initiator_ckey
		else
			return "Ticket #[id] not found!"
	var/res = TgsPm(target, all_params.Join(" "), sender.friendly_name)
	return res


/datum/tgs_chat_command/namecheck
	name = "namecheck"
	help_text = "Returns info on the specified target"
	admin_only = TRUE


/datum/tgs_chat_command/namecheck/Run(datum/tgs_chat_user/sender, params)
	params = trim(params)
	if(!params)
		return "Insufficient parameters"
	log_admin("Chat Name Check: [sender.friendly_name] on [params]")
	message_admins("Name checking [params] from [sender.friendly_name]")
	return keywords_lookup(params, TRUE)


/datum/tgs_chat_command/adminwho
	name = "adminwho"
	help_text = "Lists administrators currently on the server"
	admin_only = TRUE


/datum/tgs_chat_command/adminwho/Run(datum/tgs_chat_user/sender, params)
	return tgsadminwho()


/datum/tgs_chat_command/sdql
	name = "sdql"
	help_text = "Runs an SDQL query"
	admin_only = TRUE


/datum/tgs_chat_command/sdql/Run(datum/tgs_chat_user/sender, params)
	var/list/results = HandleUserlessSDQL(sender.friendly_name, params)
	if(!results)
		return "Query produced no output"
	var/list/text_res = results.Copy(1, 3)
	var/list/refs = results[4]
	var/list/names = results[5]
	. = "[text_res.Join("\n")][length(refs) ? "\nRefs: [refs.Join(" ")]" : ""][length(names) ? "\nText: [replacetext(names.Join(" "), "<br>", "")]" : ""]"


/datum/tgs_chat_command/reload_admins
	name = "reload_admins"
	help_text = "Forces the server to reload admins."
	admin_only = TRUE


/datum/tgs_chat_command/reload_admins/Run(datum/tgs_chat_user/sender, params)
	ReloadAsync()
	log_admin("[sender.friendly_name] reloaded admins via chat command.")
	message_admins("[sender.friendly_name] reloaded admins via chat command.")
	return "Admins reloaded."


/datum/tgs_chat_command/reload_admins/proc/ReloadAsync()
	set waitfor = FALSE
	load_admins()

/datum/tgs_chat_command/lagcheck
	name = "lagcheck"
	help_text = "Checks current time dilation on the server"
	var/last_tgs_check = 0


/datum/tgs_chat_command/lagcheck/Run(datum/tgs_chat_user/sender, params)
	var/rtod = REALTIMEOFDAY
	if(rtod - last_tgs_check < TGS_STATUS_THROTTLE)
		return
	last_tgs_check = rtod
	return "Time Dilation: [round(SStime_track.time_dilation_current,1)]% AVG:([round(SStime_track.time_dilation_avg_fast,1)]%, [round(SStime_track.time_dilation_avg,1)]%, [round(SStime_track.time_dilation_avg_slow,1)]%)"
