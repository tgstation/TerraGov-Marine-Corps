#define RESTART_COUNTER_PATH "data/round_counter.txt"


GLOBAL_VAR(restart_counter)
//TODO: Replace INFINITY with the version that fixes http://www.byond.com/forum/?post=2407430
GLOBAL_VAR_INIT(bypass_tgs_reboot, world.system_type == UNIX && world.byond_build < INFINITY)


//This happens after the Master subsystem new(s) (it's a global datum)
//So subsystems globals exist, but are not initialised
/world/New()
	hub_password = "kMZy3U5jJHSiBQjr"

	log_world("World loaded at [time_stamp()]!")

	GLOB.config_error_log = GLOB.world_qdel_log = GLOB.world_manifest_log = GLOB.sql_error_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = "data/logs/config_error.[GUID()].log" //temporary file used to record errors with loading config, moved to log directory once logging is set

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	SetupExternalRSC()

	//make_datum_references_lists()	//Port this from /tg/
	makeDatumRefLists() //Legacy

	TgsNew(new /datum/tgs_event_handler/tg, minimum_required_security_level = TGS_SECURITY_TRUSTED)

	GLOB.revdata = new

	//SetupLogs depends on the RoundID, so lets check
	//DB schema and set RoundID if we can
	SSdbcore.CheckSchemaVersion()
	SSdbcore.SetRoundID()
	SetupLogs()

	world.log = file("[GLOB.log_directory]/runtime.log")

	load_admins()

	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	initialize_marine_armor()

	callHook("startup")

	if(CONFIG_GET(flag/usewhitelist))
		load_whitelist()

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	update_status()

	// Set up roundstart seed list. This is here because vendors were
	// bugging out and not populating with the correct packet names
	// due to this list not being instantiated.
	populate_seed_list()

	if(!RoleAuthority)
		RoleAuthority = new /datum/authority/branch/role()
		to_chat(world, "<span class='danger'>Job setup complete</span>")

	if(!EvacuationAuthority)
		EvacuationAuthority = new

	world.tick_lag = CONFIG_GET(number/ticklag)

	spawn(3000)
		if(CONFIG_GET(flag/kick_inactive))
			KickInactiveClients()

	return ..()


/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		var/realtime = world.realtime
		var/texttime = time2text(realtime, "YYYY/MM/DD")
		GLOB.log_directory = "data/logs/[texttime]/round-"
		if(GLOB.round_id)
			GLOB.log_directory += "[GLOB.round_id]"
		else
			var/timestamp = replacetext(time_stamp(), ":", ".")
			GLOB.log_directory += "[timestamp]"
	else
		GLOB.log_directory = "data/logs/[override_dir]"

	GLOB.world_game_log = "[GLOB.log_directory]/game.log"
	GLOB.world_attack_log = "[GLOB.log_directory]/attack.log"
	GLOB.world_manifest_log = "[GLOB.log_directory]/manifest.log"
	GLOB.world_href_log = "[GLOB.log_directory]/hrefs.log"
	GLOB.sql_error_log = "[GLOB.log_directory]/sql.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"

	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.sql_error_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)

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


var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday


/world/Topic(T, addr, master, key)
	TGS_TOPIC

	if(CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in GLOB.player_list)
			if(M.client)
				n++
		return n

	else if(T == "status")
		var/list/s = list()
		s["version"] = game_version
		s["mode"] = master_mode
		s["respawn"] = config ? GLOB.respawn_allowed : 0
		s["enter"] = GLOB.enter_allowed
		s["vote"] = CONFIG_GET(flag/allow_vote_mode)
		s["host"] = host ? host : null
		s["players"] = list()
		s["stationtime"] = duration2text()
		var/n = 0
		var/admins = 0

		for(var/client/C in GLOB.clients)
			if(C.holder)
				if(C.holder.fakekey)
					continue	//so stealthmins aren't revealed by the hub
				admins++
			s["player[n]"] = C.key
			n++
		s["players"] = n

		s["admins"] = admins

		return list2params(s)


/world/Reboot(var/reason)
	TgsReboot()
	for(var/client/C in GLOB.clients)
		if(CONFIG_GET(string/server))
			C << link("byond://[CONFIG_GET(string/server)]")
	return ..()


#define INACTIVITY_KICK	6000	//10 minutes in ticks (approx.)
/world/proc/KickInactiveClients()
	spawn(-1)
		set background = TRUE
		while(1)
			sleep(INACTIVITY_KICK)
			for(var/client/C in GLOB.clients)
				if(check_other_rights(C, R_ADMIN, FALSE)).
					continue
				if(C.is_afk(INACTIVITY_KICK))
					if(!istype(C.mob, /mob/dead))
						log_access("AFK: [key_name(C)].")
						to_chat(C, "<span class='warning'>You have been inactive for more than 10 minutes and have been disconnected.</span>")
						qdel(C)
#undef INACTIVITY_KICK


/hook/startup/proc/loadMode()
	world.load_mode()
	return TRUE


/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			master_mode = Lines[1]
			log_config("Saved mode is '[master_mode]'")


/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)


/world/proc/update_status()
	//Note: Hub content is limited to 254 characters, including HTML/CSS. Image width is limited to 450 pixels.
	var/s = ""

	if(CONFIG_GET(string/server_name))
		if(CONFIG_GET(string/discordurl))
			s += "<a href=\"[CONFIG_GET(string/discordurl)]\"><b>[CONFIG_GET(string/server_name)] &#8212; [MAIN_SHIP_NAME]</a></b>"
		else
			s += "<b>[CONFIG_GET(string/server_name)] &#8212; [MAIN_SHIP_NAME]</b>"
		if(ticker && master_mode)
			switch(GLOB.map_tag)
				if("Ice Colony")
					s += "<br>Map: <a href='[CONFIG_GET(string/icecolonyurl)]'><b>[GLOB.map_tag]</a></b>"
				if("LV-624")
					s += "<br>Map: <a href='[CONFIG_GET(string/lv624url)]'><b>[GLOB.map_tag]</a></b>"
				if("Solaris Ridge")
					s += "<br>Map: <a href='[CONFIG_GET(string/bigredurl)]'><b>[GLOB.map_tag]</a></b>"
				if("Prison Station")
					s += "<br>Map: <a href='[CONFIG_GET(string/prisonstationurl)]'><b>[GLOB.map_tag]</a></b>"
				if("Whiskey Outpost")
					s += "<br>Map: <a href='[CONFIG_GET(string/whiskeyoutposturl)]'><b>[GLOB.map_tag]</a></b>"
				else
					s += "<br>Map: <b>[GLOB.map_tag]</b>"
			s += "<br>Mode: <b>[ticker.mode ? ticker.mode.name : "Lobby"]</b>"
			s += "<br>Round time: <b>[duration2text()]</b>"
		else
			s += "<br>Map: <b>[GLOB.map_tag]</b>"

		status = s


#define FAILED_DB_CONNECTION_CUTOFF 1
var/failed_db_connections = 0
var/failed_old_db_connections = 0


/proc/setup_database_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return FALSE
	if(!dbcon)
		dbcon = new()

	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]", "[user]", "[pass]")
	. = dbcon.IsConnected()
	if(.)
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_sql(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return FALSE
	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return TRUE


/world/proc/SetupExternalRSC()
	if(!CONFIG_GET(string/resource_url))
		return
	GLOB.external_rsc_url = CONFIG_GET(string/resource_url)