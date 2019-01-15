//print an error message to world.log


// On Linux/Unix systems the line endings are LF, on windows it's CRLF, admins that don't use notepad++
// will get logs that are one big line if the system is Linux and they are using notepad.  This solves it by adding CR to every line ending
// in the logs.  ascii character 13 = CR

/var/global/log_end= world.system_type == UNIX ? ascii2text(13) : ""


/proc/error(msg)
	log_world("## ERROR: [msg]")

#define WARNING(MSG) warning("[MSG] in [__FILE__] at line [__LINE__] src: [src] usr: [usr].")
//print a warning message to world.log
/proc/warning(msg)
	log_world("## WARNING: [msg]")

//print a testing-mode debug message to world.log
/proc/testing(msg)
	log_world("## TESTING: [msg]")

/proc/log_admin(text)
	admin_log.Add(text)
	if (config.log_admin)
		world_game_log << html_decode("\[[time_stamp()]]ADMIN: [text]")

/proc/log_admin_private(text)
	admin_log.Add(text)
	if (config.log_admin)
		world_game_log << html_decode("\[[time_stamp()]]ADMINPRIVATE: [text]")

/proc/log_adminsay(text)
	admin_log.Add(text)
	if (config.log_adminchat)
		world_game_log << html_decode("\[[time_stamp()]]ADMINPRIVATE: ASAY: [text]")

/proc/log_dsay(text)
	if (config.log_adminchat)
		world_game_log << html_decode("\[[time_stamp()]]ADMIN: DSAY: [text]")

/proc/log_topic(text)
	if (config.log_world_topic)
		world_game_log << html_decode("\[[time_stamp()]]TOPIC: [text]")

/proc/log_href(text)
	if (config.log_hrefs)
		world_href_log << html_decode("\[[time_stamp()]]HREF: [text]")

/proc/log_debug(text)
	if (config.log_debug)
		world_game_log << html_decode("\[[time_stamp()]]DEBUG: [text]")

	for(var/client/C in admins)
		if(C.prefs.toggles_chat & CHAT_DEBUGLOGS)
			to_chat(C, "DEBUG: [text]")

/proc/log_game(text)
	if (config.log_game)
		world_game_log << html_decode("\[[time_stamp()]]GAME: [text]")

/proc/log_vote(text)
	if (config.log_vote)
		world_game_log << html_decode("\[[time_stamp()]]VOTE: [text]")

/proc/log_access(text)
	if (config.log_access)
		world_game_log << html_decode("\[[time_stamp()]]ACCESS: [text]")

/proc/log_say(text)
	if (config.log_say)
		world_game_log << html_decode("\[[time_stamp()]]SAY: [text]")

/proc/log_hivemind(text)
	if (config.log_hivemind)
		world_game_log << html_decode("\[[time_stamp()]]HIVEMIND: [text]")

/proc/log_ooc(text)
	if (config.log_ooc)
		world_game_log << html_decode("\[[time_stamp()]]OOC: [text]")

/proc/log_whisper(text)
	if (config.log_whisper)
		world_game_log << html_decode("\[[time_stamp()]]WHISPER: [text]")

/proc/log_emote(text)
	if (config.log_emote)
		world_game_log << html_decode("\[[time_stamp()]]EMOTE: [text]")

/proc/log_attack(text)
	if (config.log_attack)
		world_attack_log << html_decode("\[[time_stamp()]]ATTACK: [text]")

/proc/log_adminwarn(text)
	if (config.log_adminwarn)
		world_game_log << html_decode("\[[time_stamp()]]ADMINWARN: [text]")

/proc/log_pda(text)
	if (config.log_pda)
		world_pda_log << html_decode("\[[time_stamp()]]PDA: [text]")

/proc/log_misc(text)
	world_game_log << html_decode("\[[time_stamp()]]MISC: [text]")

/proc/log_sql(text)
	sql_error_log << html_decode("\[[time_stamp()]]SQL: [text]")

/proc/log_world(text)
//	world_runtime_log << text
	world.log << text

/proc/loc_name(atom/A)
	if(!istype(A))
		return "(INVALID LOCATION)"

	var/turf/T = A
	if (!istype(T))
		T = get_turf(A)

	if(istype(T))
		return "([AREACOORD(T)])"
	else if(A.loc)
		return "(UNKNOWN (?, ?, ?))"
