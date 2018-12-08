/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()
	world.log = config_error_log = world_pda_log = sql_error_log = world_runtime_log = world_attack_log = world_game_log = "data/logs/config_error.log" //temporary file used to record errors with loading config, moved to log directory once logging is set bl
	load_configuration()
	makeDatumRefLists()
	qdel(src)

/world/New()

	hub_password = "[config.hub_password]"
	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	TgsNew(null, TGS_SECURITY_TRUSTED)
	TgsInitializationComplete()

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	initialize_marine_armor()

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	SetupLogs()

	callHook("startup")
	//Emergency Fix
	//end-emergency fix

	src.update_status()

	. = ..()

	//TgsInitializationComplete()
	//sleep_offline = 1

	// Set up roundstart seed list. This is here because vendors were
	// bugging out and not populating with the correct packet names
	// due to this list not being instantiated.
	populate_seed_list()

	if(!RoleAuthority)
		RoleAuthority = new /datum/authority/branch/role()
		to_chat(world, "\red \b Job setup complete")

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!EvacuationAuthority)		EvacuationAuthority = new

	world.tick_lag = config.Ticklag

	Master.Initialize(10, FALSE, TRUE)

	spawn(3000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()
		if(config.kick_inactive)
			KickInactiveClients()

#undef RECOMMENDED_VERSION

	return

/world/proc/SetupLogs()
	var/override_dir = params[OVERRIDE_LOG_DIRECTORY_PARAMETER]
	if(!override_dir)
		log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM/DD")]/round-[replacetext(time_stamp(), ":", ".")]"
	else
		log_directory = "data/logs/[override_dir]"
	world_game_log = file("[log_directory]/game.log")
	world_attack_log = file("[log_directory]/attack.log")
	world_runtime_log = file("[log_directory]/runtime.log")
	world_ra_log = file("[log_directory]/recycle.log")
	world_pda_log = file("[log_directory]/pda.log")
	world_href_log = file("[log_directory]/hrefs.log")
	sql_error_log = file("[log_directory]/sql.log")
	world_game_log << "\n\nStarting up round [time_stamp()]\n---------------------"
	world_attack_log << "\n\nStarting up round [time_stamp()]\n---------------------"
	world_runtime_log << "\n\nStarting up round [time_stamp()]\n---------------------"
	world_pda_log << "\n\nStarting up round [time_stamp()]\n---------------------"
	world_href_log << "\n\nStarting up round [time_stamp()]\n---------------------"
	world.log = world_runtime_log
	if(fexists(config_error_log))
		fcopy(config_error_log, "[log_directory]/config_error.log")
		fdel(config_error_log)


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
	
	if(config.log_world_topic)
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
		s["vote"] = config.allow_vote_mode
		s["ai"] = config.allow_ai
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
		if(input["key"] != config.comms_password)
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
		if(config.server)	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			C << link("byond://[config.server]")

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
						to_chat(C, "\red You have been inactive for more than 10 minutes and have been disconnected.")
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
			log_misc("Saved mode is '[master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	to_chat(F, the_mode)

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")

/proc/load_configuration()
	config = new /datum/configuration()
	config.load("config/config.txt")
	config.load("config/game_options.txt","game_options")
	config.load("config/combat_defines.txt","combat_defines")
	config.loadsql("config/dbconfig.txt")
	config.loadforumsql("config/forumdbconfig.txt")
	// apply some settings from config..
	abandon_allowed = config.respawn


/world/proc/update_status()
	//Note: Hub content is limited to 254 characters, including HTML/CSS. Image width is limited to 450 pixels.
	var/s = ""

	if (config && config.server_name)
		if(config.chaturl)
			s += "<a href=\"[config.chaturl]\"><b>[config.server_name] &#8212; [MAIN_SHIP_NAME]</a></b>"
		else
			s += "<b>[config.server_name] &#8212; [MAIN_SHIP_NAME]</b>"
		if(ticker)
			if(master_mode)
				switch(map_tag)
					if("Ice Colony")
						s += "<br>Map: <a href=\"[config.icecolony_url]\"><b>[map_tag]</a></b>"
					if("LV-624")
						s += "<br>Map: <a href=\"[config.lv624_url]\"><b>[map_tag]</a></b>"
					if("Solaris Ridge")
						s += "<br>Map: <a href=\"[config.bigred_url]\"><b>[map_tag]</a></b>"
					if("Prison Station")
						s += "<br>Map: <a href=\"[config.prisonstation_url]\"><b>[map_tag]</a></b>"
					if("Whiskey Outpost")
						s += "<br>Map: <a href=\"[config.whiskeyoutpost_url]\"><b>[map_tag]</a></b>"
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
