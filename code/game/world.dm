#define RESTART_COUNTER_PATH "data/round_counter.txt"

GLOBAL_VAR(restart_counter)
//TODO: Replace INFINITY with the version that fixes http://www.byond.com/forum/?post=2407430
GLOBAL_VAR_INIT(bypass_tgs_reboot, world.system_type == UNIX && world.byond_build < INFINITY)

/datum/global_init/New() //Legacy shitcode, leaving this in for the time being as it's out of scope.

//This happens after the Master subsystem new(s) (it's a global datum)
//So subsystems globals exist, but are not initialised
/world/New()

	log_world("World loaded at [time_stamp()]!")

	SetupExternalRSC()

	GLOB.config_error_log = GLOB.world_manifest_log = GLOB.world_pda_log = GLOB.world_job_debug_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = "data/logs/config_error.[GUID()].log" //temporary file used to record errors with loading config, moved to log directory once logging is set

	//make_datum_references_lists()	//initialises global lists for referencing frequently used datums (so that we only ever do it once)
	makeDatumRefLists() //Legacy

	TgsNew(new /datum/tgs_event_handler/tg, minimum_required_security_level = TGS_SECURITY_TRUSTED)

	GLOB.revdata = new

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	//SetupLogs depends on the RoundID, so lets check
	//DB schema and set RoundID if we can
	SSdbcore.CheckSchemaVersion()
	SSdbcore.SetRoundID()
	SetupLogs()

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#endif

	load_admins()
	//LoadVerbs(/datum/verbs/menu)
	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	//GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	//if(TEST_RUN_PARAMETER in params)
		//HandleTestRun()
/*
// EVERYTHING BELOW IS LEGACY
*/
	initialize_marine_armor()

	callHook("startup")

	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	update_status()

	. = ..()

	// Set up roundstart seed list. This is here because vendors were
	// bugging out and not populating with the correct packet names
	// due to this list not being instantiated.
	populate_seed_list()

	if(!RoleAuthority)
		RoleAuthority = new /datum/authority/branch/role()
		to_chat(world, "<span class='danger'>Job setup complete</span>")

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!EvacuationAuthority)		EvacuationAuthority = new

	world.tick_lag = CONFIG_GET(number/ticklag)

	Master.Initialize(10, FALSE, TRUE)

	spawn(3000)		//so we aren't adding to the round-start lag
		if(CONFIG_GET(flag/ToRban))
			ToRban_autoupdate()
		if(CONFIG_GET(flag/kick_inactive))
			KickInactiveClients()

#undef RECOMMENDED_VERSION

	return

/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		GLOB.picture_logging_prefix = "L_[time2text(realtime, "YYYYMMDD")]_"
		GLOB.picture_log_directory = "data/picture_logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
			GLOB.picture_logging_prefix += "R_[GLOB.round_id]_"
			GLOB.picture_log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
			GLOB.picture_log_directory += "[timestamp]"
			GLOB.picture_logging_prefix += "T_[timestamp]_"
	else
		GLOB.log_directory = "data/logs/[override_dir]"
		GLOB.picture_logging_prefix = "O_[override_dir]_"
		GLOB.picture_log_directory = "data/picture_logs/[override_dir]"

	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_mecha_log = "[GLOB.log_directory]/mecha.log"
	GLOB.world_attack_log = "[GLOB.log_directory]/attack.log"
	GLOB.world_pda_log = "[GLOB.log_directory]/pda.log"
	GLOB.world_telecomms_log = "[GLOB.log_directory]/telecomms.log"
	GLOB.world_manifest_log = "[GLOB.log_directory]/manifest.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.sql_error_log = "[GLOB.log_directory]/sql.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.query_debug_log = "[GLOB.log_directory]/query_debug.log"
	GLOB.world_job_debug_log = "[GLOB.log_directory]/job_debug.log"

#ifdef UNIT_TESTS
	GLOB.test_log = file("[GLOB.log_directory]/tests.log")
	start_log(GLOB.test_log)
#endif
	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	start_log(GLOB.world_pda_log)
	start_log(GLOB.world_telecomms_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_job_debug_log)

	GLOB.changelog_hash = md5('html/changelog.html') //for telling if the changelog has changed recently
	if(fexists(GLOB.config_error_log))
		fcopy(GLOB.config_error_log, "[GLOB.log_directory]/config_error.log")
		fdel(GLOB.config_error_log)

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())


//world/Topic(href, href_list[])
//		to_chat(world, "Received a Topic() call!")
//		to_chat(world, "[href]")
//		for(var/a in href_list)
//			to_chat(world, "[a]")
//		if(href_list["hello"])
//			to_chat(world, "Hello world!")
//			return "Hello world!"
//		to_chat(world, "End of Topic() call.")
//		..()

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	TGS_TOPIC

	if(CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? abandon_allowed : 0
		s["enter"] = enter_allowed
		s["vote"] = CONFIG_GET(flag/allow_vote_mode)
		s["ai"] = CONFIG_GET(flag/allow_ai)
		s["host"] = host ? host : null
		s["players"] = list()
		s["stationtime"] = duration2text()
		var/n = 0
		var/admins = 0

		for(var/client/C in clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

		s["admins"] = admins

		return list2params(s)

	else if(copytext(T,1,6) == "notes")
		/*
			We got a request for notes from the IRC Bot
			expected output:
				1. notes = ckey of person the notes lookup is for
				2. validationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
		*/
		var/input[] = params2list(T)
		if(input["key"] != CONFIG_GET(string/comms_password))
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

				spawn(50)
					world_topic_spam_protect_time = world.time
					return "Bad Key (Throttled)"

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr
			return "Bad Key"

		return player_notes_show_irc(input["notes"])


/world/Reboot(var/reason)
	/*spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy
		*/
	TgsReboot()
	for(var/client/C in clients)
		if(CONFIG_GET(string/server))	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[CONFIG_GET(string/server)]")

	..(reason)


#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	spawn(-1)
		set background = 1
		while(1)
			sleep(INACTIVITY_KICK)
			for(var/client/C in clients)
				if(C.holder && C.holder.rights & R_ADMIN) //Skip admins.
					continue
				if(C.is_afk(INACTIVITY_KICK))
					if(!istype(C.mob, /mob/dead))
						log_access("AFK: [key_name(C)]")
						to_chat(C, "<span class='warning'>You have been inactive for more than 10 minutes and have been disconnected.</span>")
						qdel(C)
#undef INACTIVITY_KICK


/hook/startup/proc/loadMode()
	world.load_mode()
	return 1

/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			log_config("Saved mode is '[master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	to_chat(F, the_mode)

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/*
/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.load("config/combat_defines.txt","combat_defines")
	config.loadsql("config/dbconfig.txt")
	config.loadforumsql("config/forumdbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn
*/


/world/proc/update_status()
	//Note: Hub content is limited to 254 characters, including HTML/CSS. Image width is limited to 450 pixels.
	var/s = ""

	if(CONFIG_GET(string/server_name))
		if(CONFIG_GET(string/chaturl))
			s += "<a href=\"[CONFIG_GET(string/chaturl)]\"><b>[CONFIG_GET(string/server_name)] &#8212; [MAIN_SHIP_NAME]</a></b>"
		else
			s += "<b>[CONFIG_GET(string/server_name)] &#8212; [MAIN_SHIP_NAME]</b>"
		if(ticker)
			if(master_mode)
				switch(map_tag)
					if("Ice Colony")
						s += "<br>Map: <a href=\"[CONFIG_GET(string/icecolony_url)]\"><b>[map_tag]</a></b>"
					if("LV-624")
						s += "<br>Map: <a href=\"[CONFIG_GET(string/lv624_url)]\"><b>[map_tag]</a></b>"
					if("Solaris Ridge")
						s += "<br>Map: <a href=\"[CONFIG_GET(string/bigred_url)]\"><b>[map_tag]</a></b>"
					if("Prison Station")
						s += "<br>Map: <a href=\"[CONFIG_GET(string/prisonstation_url)]\"><b>[map_tag]</a></b>"
					if("Whiskey Outpost")
						s += "<br>Map: <a href=\"[CONFIG_GET(string/whiskeyoutpost_url)]\"><b>[map_tag]</a></b>"
					else
						s += "<br>Map: <b>[map_tag]</b>"
				s += "<br>Mode: <b>[ticker.mode.name]</b>"
				s += "<br>Round time: <b>[duration2text()]</b>"
		else
			s += "<br>Map: <b>[map_tag]</b>"
		// s += enter_allowed ? "<br>Entering: <b>Enabled</b>" : "<br>Entering: <b>Disabled</b>"

		status = s

#define FAILED_DB_CONNECTION_CUTOFF 1
var/failed_db_connections = 0
var/failed_old_db_connections = 0

// /hook/startup/proc/connectDB()
// 	if(!setup_database_connection())
// 		log_world("Your server failed to establish a connection with the feedback database.")
// 	else
// 		log_world("Feedback database connection established.")
// 	return 1

proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_sql(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1


// /hook/startup/proc/connectOldDB()
// 	if(!setup_old_database_connection())
// 		log_world("Your server failed to establish a connection with the SQL database.")
// 	else
// 		log_world("SQL database connection established.")
// 	return 1

//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
proc/setup_old_database_connection()

	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!dbcon_old)
		dbcon_old = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_old_db_connections++		//If it failed, increase the failed connections counter.
		log_sql(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_old_db_connection()
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return 1

#undef FAILED_DB_CONNECTION_CUTOFF


/world/proc/SetupExternalRSC()
#ifdef PRELOAD_RSC
	GLOB.external_rsc_urls = world.file2list("[global.config.directory]/external_rsc_urls.txt","\n")
	var/i=1
	while(i<=GLOB.external_rsc_urls.len)
		if(GLOB.external_rsc_urls[i])
			i++
		else
			GLOB.external_rsc_urls.Cut(i,i+1)
#endif