#define RESTART_COUNTER_PATH "data/round_counter.txt"
#define MAX_TOPIC_LEN 100
#define TOPIC_BANNED 1


GLOBAL_VAR(restart_counter)

/**
 * WORLD INITIALIZATION
 * THIS IS THE INIT ORDER:
 *
 * BYOND =>
 * - (secret init native) =>
 *   - world.Genesis() =>
 *     - world.init_byond_tracy()
 *     - (Start native profiling)
 *     - world.init_debugger()
 *     - Master =>
 *       - config *unloaded
 *       - (all subsystems) PreInit()
 *       - GLOB =>
 *         - make_datum_reference_lists()
 *   - (/static variable inits, reverse declaration order)
 * - (all pre-mapped atoms) /atom/New()
 * - world.New() =>
 *   - config.Load()
 *   - world.InitTgs() =>
 *     - TgsNew() *may sleep
 *     - GLOB.rev_data.load_tgs_info()
 *   - world.ConfigLoaded() =>
 *     - SSdbcore.InitializeRound()
 *     - world.SetupLogs()
 *     - load_admins()
 *     - ...
 *   - Master.Initialize() =>
 *     - (all subsystems) Initialize()
 *     - Master.StartProcessing() =>
 *       - Master.Loop() =>
 *         - Failsafe
 *   - world.RunUnattendedFunctions()
 *
 * Now listen up because I want to make something clear:
 * If something is not in this list it should almost definitely be handled by a subsystem Initialize()ing
 * If whatever it is that needs doing doesn't fit in a subsystem you probably aren't trying hard enough tbhfam
 *
 * GOT IT MEMORIZED?
 * - Dominion/Cyberboss
 */

/**
 * THIS !!!SINGLE!!! PROC IS WHERE ANY FORM OF INIITIALIZATION THAT CAN'T BE PERFORMED IN MASTER/NEW() IS DONE
 * NOWHERE THE FUCK ELSE
 * I DON'T CARE HOW MANY LAYERS OF DEBUG/PROFILE/TRACE WE HAVE, YOU JUST HAVE TO DEAL WITH THIS PROC EXISTING
 * I'M NOT EVEN GOING TO TELL YOU WHERE IT'S CALLED FROM BECAUSE I'M DECLARING THAT FORBIDDEN KNOWLEDGE
 * SO HELP ME GOD IF I FIND ABSTRACTION LAYERS OVER THIS!
 */
/world/proc/Genesis(tracy_initialized = FALSE)
	RETURN_TYPE(/datum/controller/master)

#ifdef USE_BYOND_TRACY
#warn USE_BYOND_TRACY is enabled
	if(!tracy_initialized)
		init_byond_tracy()
		Genesis(tracy_initialized = TRUE)
		return
#endif

	Profile(PROFILE_RESTART)
	Profile(PROFILE_RESTART, type = "sendmaps")

	// Write everything to this log file until we get to SetupLogs() later
	_initialize_log_files("data/logs/config_error.[GUID()].log")

	// Init the debugger first so we can debug Master
	init_debugger()

	// Create the logger
	logger = new

	// THAT'S IT, WE'RE DONE, THE. FUCKING. END.
	Master = new


//This happens after the Master subsystem new(s) (it's a global datum)
//So subsystems globals exist, but are not initialised
/world/New()
	log_world("World loaded at [time_stamp()]!")

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	//First possible sleep()
	InitTgs()

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	ConfigLoaded()

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	change_tick_lag(CONFIG_GET(number/ticklag))

	RunUnattendedFunctions()

	return ..()

/// Runs after config is loaded but before Master is initialized
/world/proc/ConfigLoaded()
	// Everything in here is prioritized in a very specific way.
	// If you need to add to it, ask yourself hard if what your adding is in the right spot
	// (i.e. basically nothing should be added before load_admins() in here)

	// Try to set round ID
	SSdbcore.InitializeRound()
	SetupLogs()
	load_admins()
	load_poll_data()
	LoadVerbs(/datum/verbs/menu)

	load_mode()

	update_status()

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)


/// Initializes TGS and loads the returned revising info into GLOB.revdata
/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/// Runs after the call to Master.Initialize, but before the delay kicks in. Used to turn the world execution into some single function then exit
/world/proc/RunUnattendedFunctions()
	#ifdef UNIT_TESTS
	HandleTestRun()
	#endif

/world/proc/HandleTestRun()
	//trigger things to run the whole process
	Master.sleep_offline_after_initializations = FALSE
	SSticker.start_immediately = TRUE
	SSticker.bypass_checks = TRUE
	CONFIG_SET(number/mission_end_countdown, 0)
	var/datum/callback/cb
#ifdef UNIT_TESTS
	cb = CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(RunUnitTests))
#else
	cb = VARSET_CALLBACK(SSticker, force_ending, TRUE)
#endif
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(_addtimer), cb, 10 SECONDS))

/// Returns a list of data about the world state, don't clutter
/world/proc/get_world_state_for_logging()
	var/data = list()
	data["tick_usage"] = world.tick_usage
	data["tick_lag"] = world.tick_lag
	data["time"] = world.time
	data["timestamp"] = rustg_unix_timestamp()
	return data

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

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : 0 //for telling if the changelog has changed recently

	logger.init_logging()

	if(GLOB.round_id)
		log_game("Round ID: [GLOB.round_id]")

	// This was printed early in startup to the world log and config_error.log,
	// but those are both private, so let's put the commit info in the runtime
	// log which is ultimately public.
	log_runtime(GLOB.revdata.get_log_message())

#ifndef USE_CUSTOM_ERROR_HANDLER
	world.log = file("[GLOB.log_directory]/dd.log")
#else
	if (TgsAvailable()) // why
		world.log = file("[GLOB.log_directory]/dd.log") //not all runtimes trigger world/Error, so this is the only way to ensure we can see all of them.
#endif

/world/Topic(T, addr, master, key)
	TGS_TOPIC	//redirect to server tools if necessary

	var/static/list/bannedsourceaddrs = list()

	var/static/list/lasttimeaddr = list()
	var/static/list/topic_handlers = TopicHandlers()

	//LEAVE THIS COOLDOWN HANDLING IN PLACE, OR SO HELP ME I WILL MAKE YOU SUFFER
	if (bannedsourceaddrs[addr])
		return

	var/list/filtering_whitelist = CONFIG_GET(keyed_list/topic_filtering_whitelist)
	var/host = splittext(addr, ":")
	if(!filtering_whitelist[host[1]]) // We only ever check the host, not the port (if provided)
		if(length(T) >= MAX_TOPIC_LEN)
			log_admin_private("[addr] banned from topic calls for a round for too long status message")
			bannedsourceaddrs[addr] = TOPIC_BANNED
			return

		if(lasttimeaddr[addr])
			var/lasttime = lasttimeaddr[addr]
			if(world.time < lasttime)
				log_admin_private("[addr] banned from topic calls for a round for too frequent messages")
				bannedsourceaddrs[addr] = TOPIC_BANNED
				return

		lasttimeaddr[addr] = world.time + 2 SECONDS

	var/list/input = params2list(T)
	var/datum/world_topic/handler
	for(var/I in topic_handlers)
		if(I in input)
			handler = topic_handlers[I]
			break

	if((!handler || initial(handler.log)) && config && CONFIG_GET(flag/log_world_topic))
		log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if(!handler)
		return

	handler = new handler()
	return handler.TryRun(input)

/world/proc/FinishTestRun()
	set waitfor = FALSE
	var/list/fail_reasons
	if(GLOB)
		if(GLOB.total_runtimes != 0)
			fail_reasons = list("Total runtimes: [GLOB.total_runtimes]")
#ifdef UNIT_TESTS
		if(GLOB.failed_any_test)
			LAZYADD(fail_reasons, "Unit Tests failed!")
#endif
		if(!GLOB.log_directory)
			LAZYADD(fail_reasons, "Missing GLOB.log_directory!")
	else
		fail_reasons = list("Missing GLOB!")
	if(!fail_reasons)
		text2file("Success!", "[GLOB.log_directory]/clean_run.lk")
	else
		log_world("Test run failed!\n[fail_reasons.Join("\n")]")
	sleep(0)	//yes, 0, this'll let Reboot finish and prevent byond memes
	qdel(src)	//shut it down

/world/Reboot(ping)
	if(ping)
		// TODO: Replace the second arguments of send2chat with custom config tags. See __HELPERS/chat.dm
		send2chat(CONFIG_GET(string/restart_message), CONFIG_GET(string/end_of_round_channel))
		var/list/msg = list()

		if(GLOB.round_id)
			msg += "Round ID [GLOB.round_id] finished"

		var/datum/map_config/next_gound_map
		var/datum/map_config/next_ship_map

		if(length(SSmapping.next_map_configs)) //To avoid a bad index, let's check if there's actually a list.
			next_gound_map = SSmapping.next_map_configs[GROUND_MAP]
			next_ship_map = SSmapping.next_map_configs[SHIP_MAP]

		if(!next_gound_map) //The list could hold a single item, so better check each because there's no guarantee both exist.
			next_gound_map = SSmapping.configs[GROUND_MAP]
		if(!next_ship_map)
			next_ship_map = SSmapping.configs[SHIP_MAP]

		if(next_gound_map)
			msg += "Next Ground Map: [next_gound_map.map_name]"
		if(next_ship_map)
			msg += "Next Ship Map: [next_ship_map.map_name]"

		if(SSticker.mode)
			msg += "Game Mode: [SSticker.mode.name]"
			msg += "Round End State: [SSticker.mode.round_finished]"

		if(length(GLOB.clients))
			msg += "Players: [length(GLOB.clients)]"

		if(length(msg))
			send2chat(msg.Join(" | "), CONFIG_GET(string/end_of_round_channel))

	Master.Shutdown()
	TgsReboot()

	#ifdef UNIT_TESTS
	FinishTestRun()
	return
	#endif

	if(TgsAvailable())
		var/do_hard_reboot
		// check the hard reboot counter
		var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
		switch(ruhr)
			if(-1)
				do_hard_reboot = FALSE
			if(0)
				do_hard_reboot = TRUE
			else
				if(GLOB.restart_counter >= ruhr)
					do_hard_reboot = TRUE
				else
					text2file("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
					do_hard_reboot = FALSE

		if(do_hard_reboot)
			log_world("World rebooted at [time_stamp()]")
			shutdown_logging() // Past this point, no logging procs can be used, at risk of data loss.
			TgsEndProcess()

	var/linkylink = CONFIG_GET(string/server)
	if(linkylink)
		for(var/cli in GLOB.clients)
			cli << link("byond://[linkylink]")

	return ..()


/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(length(Lines))
		if(Lines[1])
			GLOB.master_mode = Lines[1]
			log_config("Saved mode is '[GLOB.master_mode]'")


/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)


/world/proc/update_status()
	var/server_name = CONFIG_GET(string/server_name)
	if(!server_name || Master?.current_runlevel == RUNLEVEL_INIT)
		// If you didn't see a server name, or the master controller
		// is stilling initing, we don't update the hub.
		return

	// Start generating the hub status
	// Note: Hub content is limited to 254 characters, including HTML/CSS. Image width is limited to 450 pixels.
	// Current outputt should look like
	/*
	Something — Lost in space...	|	TerraGov Marine Corps — Sulaco
	Map: Loading...					|	Map: Icy Caves
	Mode: Lobby						|	Mode: Crash
	Round time: 0:0					|	Round time: 4:54
	*/
	var/discord_url = CONFIG_GET(string/discordurl)
	var/webmap_host = CONFIG_GET(string/webmap_host)
	var/shipname = length(SSmapping?.configs) && SSmapping.configs[SHIP_MAP] ? SSmapping.configs[SHIP_MAP].map_name : "Lost in space..."
	var/map_name = length(SSmapping.configs) && SSmapping.configs[GROUND_MAP] ? SSmapping.configs[GROUND_MAP].map_name : "Loading..."
	var/ground_map_file = length(SSmapping.configs) && SSmapping.configs[GROUND_MAP] ? SSmapping.configs[GROUND_MAP].map_file : ""

	var/new_status = ""
	new_status += "<b><a href='[discord_url ? discord_url : "#"]'>[server_name] &#8212; [shipname]</a></b>"
	new_status += "<br>Map: <a href='[webmap_host][ground_map_file]'><b>[map_name]</a></b>"
	new_status += "<br>Mode: <b>[SSticker.mode ? SSticker.mode.name : "Lobby"]</b>"
	new_status += "<br>Round time: <b>[gameTimestamp("hh:mm")]</b>"

	// Finally set the new status
	status = new_status


/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSidlenpcpool.MaxZChanged()


/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"

/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()


/world/proc/change_tick_lag(new_value = 0.5)
	if(new_value <= 0)
		CRASH("change_tick_lag() called with [new_value] new_value.")
	if(tick_lag == new_value)
		return //No change required.

	tick_lag = new_value
	on_tickrate_change()


/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()
	SSrunechat?.reset_buckets()
	SSautomatedfire?.reset_buckets()

/world/proc/init_byond_tracy()
	var/library

	switch (system_type)
		if (MS_WINDOWS)
			library = "prof.dll"
		if (UNIX)
			library = "libprof.so"
		else
			CRASH("Unsupported platform: [system_type]")
	var/init_result = call_ext(library, "init")("block")
	if (init_result != "0")
		CRASH("Error initializing byond-tracy: [init_result]")

/world/proc/init_debugger()
	var/dll = GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (dll)
		call_ext(dll, "auxtools_init")()
		enable_debugging()

#undef MAX_TOPIC_LEN
#undef TOPIC_BANNED
