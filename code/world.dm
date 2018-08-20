var/global/datum/global_init/init = new ()

/*
	Pre-map initialization stuff should go here.
*/
/datum/global_init/New()
	load_configuration()
	makeDatumRefLists()
	cdel(src)


/world
	mob = /mob/new_player
	turf = /turf/open/space
	area = /area/space
	view = "15x15"
	cache_lifespan = 0	//stops player uploaded stuff from being kept in the rsc past the current session
	hub = "Exadv1.spacestation13"

#define RECOMMENDED_VERSION 511

/world/New()

	hub_password = "[config.hub_password]"

	//logs
	var/date_string = time2text(world.realtime, "YYYY/MM-Month/DD-Day")
	var/year_string = time2text(world.realtime, "YYYY")
	href_logfile = file("data/logs/[date_string] hrefs.htm")
	diary = file("data/logs/[date_string].log")
	diary << "[log_end]\n[log_end]\nStarting up. [time2text(world.timeofday, "hh:mm.ss")][log_end]\n---------------------[log_end]"
	round_stats = file("data/logs/[year_string]/round_stats.log")
	to_chat(round_stats, "[log_end]\nStarting up - [time2text(world.realtime,"YYYY-MM-DD (hh:mm:ss)")][log_end]\n---------------------[log_end]")
	changelog_hash = md5('html/changelog.html')					//used for telling if the changelog has changed recently

	if(byond_version < RECOMMENDED_VERSION)
		to_chat(world.log, "Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	initialize_marine_armor()

	if(config && config.server_name != null && config.server_suffix && world.port > 0)
		// dumb and hardcoded but I don't care~
		config.server_name += " #[(world.port % 1000) / 100]"

	if(config && config.log_runtime)
		log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	callHook("startup")
	//Emergency Fix
	//end-emergency fix

	src.update_status()

	. = ..()

	sleep_offline = 1

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

	// Process Scheduler
	to_chat(src, "\red \b Scheduler initialized.")
	processScheduler = new

	spawn(0)
		processScheduler.setup()

	to_chat(src, "\red \b Scheduler setup complete.")

	spawn(0)
		processScheduler.start()

//	master_controller = new /datum/controller/game_controller()

	//spawn(1)
		//master_controller.setup()

	spawn(3000)		//so we aren't adding to the round-start lag
		if(config.ToRban)
			ToRban_autoupdate()
		if(config.kick_inactive)
			KickInactiveClients()

#undef RECOMMENDED_VERSION

	return

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
	if(findtext(T, "mapdaemon") == 0) diary << "TOPIC: \"[T]\", from:[addr], master:[master], key:[key][log_end]"

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


	//START: MAPDAEMON PROCESSING
	if(addr == "127.0.0.1") //Verify that instructions are coming from the local machine

		var/list/md_args = splittext(T,"&")
		var/command = md_args[1]
		var/MD_UID = md_args[2]

		if(command == "mapdaemon_get_round_status")

			if(!ticker) return "ERROR" //Yeah yeah wrong data type, but MapDaemon.java can handle it

			if(MapDaemon_UID == -1) MapDaemon_UID = MD_UID //If we haven't seen an instance of MD yet, this is ours now

			if(kill_map_daemon || MD_UID != MapDaemon_UID) return 2 //The super secret killing code that kills it until it's been killed.

			else if(!ticker.mode) return 0 //Before round start

			else if(ticker.mode.round_finished || force_mapdaemon_vote) return 1

			else return 0 //IDK what would cause this but why not, don't really want runtimes

		else if(MD_UID != MapDaemon_UID)
			return 2 //kill the imposter, kill it with fire

		else if(command == "mapdaemon_delay_round")

			if(!ticker) return "ERROR"
			spawn(200) //20 seconds

				var/text = ""
				text += "<hr><br>"
				text += "<span class='centerbold'>"
				text += "<font color='#00CC00'><b>You have 30 seconds to vote for the next map! Use the \"Map Vote\" verb in the OOC tab or click <a href='?src=\ref[src];vote_for_map=1'>here</a> to select an option.</b></font>"
				text += "</span>"
				text += "<hr><br>"

				to_chat(world, text)
				world << 'sound/voice/start_your_voting.ogg'

			ticker.delay_end = 1
			log_admin("World/Topic() call (likely MapDaemon.exe) has delayed the round end.")
			message_admins("World/Topic() call (likely MapDaemon.exe) has delayed the round end.", 1)
			return "SUCCESS"

		else if(command == "mapdaemon_restart_round")

			if(!ticker) return "ERROR"

			ticker.delay_end = 0
			message_admins("World/Topic() call (likely MapDaemon.exe) has resumed the round end.", 1)

			//So admins have a chance to make EORG bans and do whatever
			message_staff("NOTICE: Delay round within 30 seconds in order to prevent auto-restart!", 1)

			MapDaemonHandleRestart() //Doesn't hold

			return "WILL DO" //Yessir!

		else if(command == "mapdaemon_receive_votes")

			var/list/L = list()

			var/i
			for(i in NEXT_MAP_CANDIDATES)
				L[i] = 0 //Initialize it

			var/forced = 0
			var/force_result = ""
			i = null //Sanitize for safety
			var/j
			for(i in player_votes)
				j = player_votes[i]
				if(i == "}}}") //Special invalid ckey for forcing the next map
					forced = 1
					force_result = j
					continue
				L[j] = L[j] + 1 //Just number of votes indexed by map name

			i = null
			var/most_votes = -1
			var/next_map = ""
			for(i in L)
				if(L[i] > most_votes)
					most_votes = L[i]
					next_map = i

			if(!enable_map_vote && ticker && ticker.mode)
				next_map = ticker.mode.name
			else if(enable_map_vote && forced)
				next_map = force_result

			var/text = ""
			text += "<font color='#00CC00'>"

			var/log_text = ""
			log_text += "\[[time2text(world.realtime, "DD Month YYYY")]\] Winner: [next_map] ("

			text += "The voting results were:<br>"
			for(var/name in L)
				text += "[name] - [L[name]]<br>"
				log_text += "[name] - [L[name]],"

			log_text += ")\n"

			if(forced) text += "<b>An admin has forced the next map.</b><br>"
			else
				text2file(log_text, "data/map_votes.txt")

			text += "<b>The next map will be on [forced ? force_result : next_map].</b>"

			text += "</font>"

			to_chat(world, text)

			return next_map



/world/Reboot(var/reason)
	/*spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy
		*/
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
						cdel(C)
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
		s += "<a href=\"[config.forumurl]\"><b>[config.server_name] &#8212; [MAIN_SHIP_NAME]</b>"
		s += "<br><img src=\"[config.forumurl]/byond_hub_logo.jpg\"></a>"
		// s += "<a href=\"http://goo.gl/04C5lP\">Wiki</a>|<a href=\"http://goo.gl/hMmIKu\">Rules</a>"
		if(ticker)
			if(master_mode)
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
// 		to_chat(world.log, "Your server failed to establish a connection with the feedback database.")
// 	else
// 		to_chat(world.log, "Feedback database connection established.")
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
		to_chat(world.log, dbcon.ErrorMsg())

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
// 		to_chat(world.log, "Your server failed to establish a connection with the SQL database.")
// 	else
// 		to_chat(world.log, "SQL database connection established.")
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
		to_chat(world.log, dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
proc/establish_old_db_connection()
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return 1

/proc/MapDaemonHandleRestart()
	set waitfor = 0

	sleep(300)

	if(ticker.delay_end) return

	to_chat(world, "\red <b>Restarting world!</b> \blue Initiated by MapDaemon.exe!")
	log_admin("World/Topic() call (likely MapDaemon.exe) initiated a reboot.")

	if(blackbox)
		blackbox.save_all_data_to_sql() //wtf does this even do?

	sleep(30)
	world.Reboot() //Whatever this is the important part

#undef FAILED_DB_CONNECTION_CUTOFF
