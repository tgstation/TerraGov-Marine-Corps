/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port
	var/hub_password = null				// hub password

	var/nudge_script_path = "nudge.py"  // where the nudge.py script is located

	var/log_ooc = 0						// log OOC channel
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_hivemind = 0				// log hivemind
	var/log_admin = 0					// log admin actions
	var/log_debug = 1					// log debug output
	var/log_game = 0					// log game events
	var/log_vote = 0					// log voting
	var/log_whisper = 0					// log client whisper
	var/log_emote = 0					// log emotes
	var/log_attack = 0					// log attack messages
	var/log_adminchat = 0				// log admin chat messages
	var/log_adminwarn = 0				// log warnings admins get about bomb construction and such
	var/log_pda = 0						// log pda messages
	var/log_hrefs = 0					// logs all links clicked in-game. Could be used for debugging and tracking down exploits
	var/log_runtime = 0					// logs world.log to a file
	var/sql_enabled = 1					// for sql switching
	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/allow_vote_restart = 0 			// allow votes to restart
	var/ert_admin_call_only = 0
	var/allow_vote_mode = 0				// allow votes to change mode
	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives
	var/vote_delay = 6000				// minimum time between voting sessions (deciseconds, 10 minute default)
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/vote_autotransfer_initial = 108000 // Length of time before the first autotransfer vote is called
	var/vote_autotransfer_interval = 36000 // length of time before next sequential autotransfer vote
	var/vote_autogamemode_timeleft = 100 //Length of time before round start when autogamemode vote is called (in seconds, default 100).
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
//	var/enable_authentication = 0		// goon authentication
	var/del_new_on_log = 1				// del's new players if they log before they spawn in
	var/feature_object_spell_system = 0 //spawns a spellbook which gives object-type spells instead of verb-type spells for the wizard
	var/traitor_scaling = 0 			//if amount of traitors scales based on amount of players
	var/objectives_disabled = 0 			//if objectives are disabled or not
	var/protect_roles_from_antagonist = 0// If security and such can be traitor/cult/other
	var/continous_rounds = 0			// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
	var/allow_Metadata = 0				// Metadata is supported.
	var/popup_admin_pm = 0				//adminPMs to non-admins show in a pop-up 'reply' window when set to 1.
	var/Ticklag = 0.9
	var/Tickcomp = 0
	var/socket_talk	= 0					// use socket_talk to communicate with other processes
	var/list/resource_urls = null
	var/antag_hud_allowed = 0			// Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
	var/antag_hud_restricted = 0                    // Ghosts that turn on Antagovision cannot rejoin the round.
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/humans_need_surnames = 0
	var/allow_random_events = 0			// enables random events mid-round when set to 1
	var/allow_ai = 1					// allow ai job
	var/autooocmute = 0					// allow ai job
	var/hostedby = null
	var/respawn = 1
	var/guest_jobban = 1
	var/usewhitelist = 0
	var/mods_are_mentors = 0
	var/kick_inactive = 0				//force disconnect for inactive players
	var/show_mods = 0
	var/show_mentors = 0
	var/load_jobs_from_txt = 0
	var/ToRban = 0
	var/automute_on = 0					//enables automuting/spam prevention
	var/jobs_have_minimal_access = 0	//determines whether jobs use minimal access or expanded access.

	var/cult_ghostwriter = 1               //Allows ghosts to write in blood in cult rounds...
	var/cult_ghostwriter_req_cultists = 10 //...so long as this many cultists are active.

	var/max_maint_drones = 5				//This many drones can spawn,
	var/allow_drone_spawn = 1				//assuming the admin allow them to.
	var/drone_build_time = 20				//A drone will become available every X ticks since last drone spawn.

	var/disable_player_mice = 0
	var/uneducated_mice = 0 //Set to 1 to prevent newly-spawned mice from understanding human speech

	var/usealienwhitelist = 0
	var/limitalienplayers = 0
	var/alien_to_human_ratio = 0.5

	var/debugparanoid = 0

	var/server
	var/banappeals
	var/wikiurl
	var/forumurl
	var/rulesurl

	//Alert level description
	var/alert_desc_green = "All security alerts have passed."
	var/alert_desc_blue_upto = "Intelligence suggests the presence of a moderate threat in the quadrant. All personnel are to be on alert."
	var/alert_desc_blue_downto = "The current emergency has passed, however all personnel should remain on alert."
	var/alert_desc_red_upto = "Warning: There is an immediate threat onboard. Personnel should secure their departments and await further instructions from command staff."
	var/alert_desc_red_downto = "The self-destruct system has been deactivated. All personnel should remain on high alert."
	var/alert_desc_delta = "Warning: The self-destruct system has been activated. All personnel must obey orders from superior officers under threat of execution."

	var/forbid_singulo_possession = 0

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database

	var/simultaneous_pm_warning_timeout = 100

	var/use_recursive_explosions //Defines whether the server uses recursive or circular explosions.

	var/assistant_maint = 0 //Do assistants get maint access?
	var/gateway_delay = 18000 //How long the gateway takes before it activates. Default is half an hour.
	var/ghost_interaction = 0

	var/comms_password = ""

	var/use_irc_bot = 0
	var/irc_bot_host = ""
	var/main_irc = ""
	var/admin_irc = ""
	var/python_path = "" //Path to the python executable.  Defaults to "python" on windows and "/usr/bin/env python2" on unix
	var/use_lib_nudge = 0 //Use the C library nudge instead of the python nudge.

/datum/configuration/New()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode
	for (var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if (M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				log_misc("Adding game mode [M.name] ([M.config_tag]) to configuration.")
				src.modes += M.config_tag
				src.mode_names[M.config_tag] = M.name
				src.probabilities[M.config_tag] = M.probability
				if (M.votable)
					src.votable_modes += M.config_tag
		cdel(M)
	src.votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

	for(var/t in Lines)
		if(!t)	continue
		t = trim(t)
		if (!length(t)) continue
		else if (copytext(t, 1, 2) == "#") continue

		var/pos = findtext(t, " ")
		var/name
		var/value

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else name = lowertext(t)

		if (!name) continue
		switch(type)
			if("config") initilize_configuration(name,value)
			if("game_options") initialize_game_options(name, value)
			if("combat_defines") initialize_combat_defines(name, value)

/datum/configuration/proc/initilize_configuration(name,value)
	switch (name)
		if ("resource_urls")
			config.resource_urls = text2list(value, " ")

		if ("admin_legacy_system")
			config.admin_legacy_system = 1

		if ("ban_legacy_system")
			config.ban_legacy_system = 1

		if ("use_age_restriction_for_jobs")
			config.use_age_restriction_for_jobs = 1

		if ("jobs_have_minimal_access")
			config.jobs_have_minimal_access = 1

		if ("use_recursive_explosions")
			use_recursive_explosions = 1

		if ("log_ooc")
			config.log_ooc = 1

		if ("log_access")
			config.log_access = 1

		if ("sql_enabled")
			config.sql_enabled = text2num(value)

		if ("log_say")
			config.log_say = 1

		if ("log_hivemind")
			config.log_hivemind = 1

		if ("debug_paranoid")
			config.debugparanoid = 1

		if ("log_admin")
			config.log_admin = 1

		if ("log_debug")
			config.log_debug = text2num(value)

		if ("log_game")
			config.log_game = 1

		if ("log_vote")
			config.log_vote = 1

		if ("log_whisper")
			config.log_whisper = 1

		if ("log_attack")
			config.log_attack = 1

		if ("log_emote")
			config.log_emote = 1

		if ("log_adminchat")
			config.log_adminchat = 1

		if ("log_adminwarn")
			config.log_adminwarn = 1

		if ("log_pda")
			config.log_pda = 1

		if ("log_hrefs")
			config.log_hrefs = 1

		if ("log_runtime")
			config.log_runtime = 1

		if ("mentors")
			config.mods_are_mentors = 1

		if("allow_admin_ooccolor")
			config.allow_admin_ooccolor = 1

		if ("allow_vote_restart")
			config.allow_vote_restart = 1

		if ("allow_vote_mode")
			config.allow_vote_mode = 1

		if ("allow_admin_jump")
			config.allow_admin_jump = 1

		if("allow_admin_rev")
			config.allow_admin_rev = 1

		if ("allow_admin_spawning")
			config.allow_admin_spawning = 1

		if ("no_dead_vote")
			config.vote_no_dead = 1

		if ("default_no_vote")
			config.vote_no_default = 1

		if ("vote_delay")
			config.vote_delay = text2num(value)

		if ("vote_period")
			config.vote_period = text2num(value)

		if ("vote_autotransfer_initial")
			config.vote_autotransfer_initial = text2num(value)

		if ("vote_autotransfer_interval")
			config.vote_autotransfer_interval = text2num(value)

		if ("vote_autogamemode_timeleft")
			config.vote_autogamemode_timeleft = text2num(value)

		if("ert_admin_only")
			config.ert_admin_call_only = 1

		if ("allow_ai")
			config.allow_ai = 1

		if ("autooocmute")
			config.autooocmute = 1

//				if ("authentication")
//					config.enable_authentication = 1

		if ("norespawn")
			config.respawn = 0

		if ("servername")
			config.server_name = value

		if ("serversuffix")
			config.server_suffix = 1

		if ("hubpassword")
			config.hub_password = value

		if ("nudge_script_path")
			config.nudge_script_path = value

		if ("hostedby")
			config.hostedby = value

		if ("server")
			config.server = value

		if ("banappeals")
			config.banappeals = value

		if ("wikiurl")
			config.wikiurl = value

		if ("forumurl")
			config.forumurl = value

		if ("rulesurl")
			config.rulesurl = value

		if ("guest_jobban")
			config.guest_jobban = 1

		if ("guest_ban")
			guests_allowed = 0

		if ("usewhitelist")
			config.usewhitelist = 1

		if ("feature_object_spell_system")
			config.feature_object_spell_system = 1

		if ("allow_metadata")
			config.allow_Metadata = 1

		if ("traitor_scaling")
			config.traitor_scaling = 1

		if ("objectives_disabled")
			config.objectives_disabled = 1

		if("protect_roles_from_antagonist")
			config.protect_roles_from_antagonist = 1

		if ("probability")
			var/prob_pos = findtext(value, " ")
			var/prob_name = null
			var/prob_value = null

			if (prob_pos)
				prob_name = lowertext(copytext(value, 1, prob_pos))
				prob_value = copytext(value, prob_pos + 1)
				if (prob_name in config.modes)
					config.probabilities[prob_name] = text2num(prob_value)
				else
					log_misc("Unknown game mode probability configuration definition: [prob_name].")
			else
				log_misc("Incorrect probability configuration definition: [prob_name]  [prob_value].")

		if("allow_random_events")
			config.allow_random_events = 1

		if("kick_inactive")
			config.kick_inactive = 1

		if("show_mods")
			config.show_mods = 1

		if("show_mentors")
			config.show_mentors = 1

		if("load_jobs_from_txt")
			load_jobs_from_txt = 1

		if("alert_red_upto")
			config.alert_desc_red_upto = value

		if("alert_red_downto")
			config.alert_desc_red_downto = value

		if("alert_blue_downto")
			config.alert_desc_blue_downto = value

		if("alert_blue_upto")
			config.alert_desc_blue_upto = value

		if("alert_green")
			config.alert_desc_green = value

		if("alert_delta")
			config.alert_desc_delta = value

		if("forbid_singulo_possession")
			forbid_singulo_possession = 1

		if("popup_admin_pm")
			config.popup_admin_pm = 1

		if("allow_holidays")
			Holiday = 1

		if("use_irc_bot")
			use_irc_bot = 1

		if("ticklag")
			Ticklag = text2num(value)

		if("allow_antag_hud")
			config.antag_hud_allowed = 1
		if("antag_hud_restricted")
			config.antag_hud_restricted = 1

		if("socket_talk")
			socket_talk = text2num(value)

		if("tickcomp")
			Tickcomp = 1

		if("humans_need_surnames")
			humans_need_surnames = 1

		if("tor_ban")
			ToRban = 1

		if("automute_on")
			automute_on = 1

		if("usealienwhitelist")
			usealienwhitelist = 1

		if("alien_player_ratio")
			limitalienplayers = 1
			alien_to_human_ratio = text2num(value)

		if("assistant_maint")
			config.assistant_maint = 1

		if("gateway_delay")
			config.gateway_delay = text2num(value)

		if("continuous_rounds")
			config.continous_rounds = 1

		if("ghost_interaction")
			config.ghost_interaction = 1

		if("disable_player_mice")
			config.disable_player_mice = 1

		if("uneducated_mice")
			config.uneducated_mice = 1

		if("comms_password")
			config.comms_password = value

		if("irc_bot_host")
			config.irc_bot_host = value

		if("main_irc")
			config.main_irc = value

		if("admin_irc")
			config.admin_irc = value

		if("python_path")
			if(value)
				config.python_path = value
			else
				if(world.system_type == UNIX)
					config.python_path = "/usr/bin/env python2"
				else //probably windows, if not this should work anyway
					config.python_path = "python"

		if("use_lib_nudge")
			config.use_lib_nudge = 1

		if("allow_cult_ghostwriter")
			config.cult_ghostwriter = 1

		if("req_cult_ghostwriter")
			config.cult_ghostwriter_req_cultists = text2num(value)

		if("allow_drone_spawn")
			config.allow_drone_spawn = text2num(value)

		if("drone_build_time")
			config.drone_build_time = text2num(value)

		if("max_maint_drones")
			config.max_maint_drones = text2num(value)

		else
			log_misc("Unknown setting in configuration: '[name]'")

/datum/configuration/proc/loadsql(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("address")
				sqladdress = value
			if ("port")
				sqlport = value
			if ("database")
				sqldb = value
			if ("login")
				sqllogin = value
			if ("password")
				sqlpass = value
			if ("feedback_database")
				sqlfdbkdb = value
			if ("feedback_login")
				sqlfdbklogin = value
			if ("feedback_password")
				sqlfdbkpass = value
			if ("enable_stat_tracking")
				sqllogging = 1
			else
				log_misc("Unknown setting in configuration: '[name]'")

/datum/configuration/proc/loadforumsql(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("address")
				forumsqladdress = value
			if ("port")
				forumsqlport = value
			if ("database")
				forumsqldb = value
			if ("login")
				forumsqllogin = value
			if ("password")
				forumsqlpass = value
			if ("activatedgroup")
				forum_activated_group = value
			if ("authenticatedgroup")
				forum_authenticated_group = value
			else
				log_misc("Unknown setting in configuration: '[name]'")

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		if (M.config_tag && M.config_tag == mode_name)
			return M
		cdel(M)
	return new /datum/game_mode/extended()

/datum/configuration/proc/get_runnable_modes()
	var/list/datum/game_mode/runnable_modes = new
	for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		//world << "DEBUG: [T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]"
		if (!(M.config_tag in modes))
			cdel(M)
			continue
		if (probabilities[M.config_tag]<=0)
			cdel(M)
			continue
		if (M.can_start())
			runnable_modes[M] = probabilities[M.config_tag]
			//world << "DEBUG: runnable_mode\[[runnable_modes.len]\] = [M.config_tag]"
	return runnable_modes
