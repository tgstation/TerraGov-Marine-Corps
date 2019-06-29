#define RESTART_COUNTER_PATH "data/round_counter.txt"


GLOBAL_VAR(restart_counter)
//TODO: Replace INFINITY with the version that fixes http://www.byond.com/forum/?post=2407430
GLOBAL_VAR_INIT(bypass_tgs_reboot, world.system_type == UNIX && world.byond_build < INFINITY)


//This happens after the Master subsystem new(s) (it's a global datum)
//So subsystems globals exist, but are not initialised
/world/New()
	hub_password = "kMZy3U5jJHSiBQjr"

	log_world("World loaded at [time_stamp()]!")

	GLOB.config_error_log = GLOB.world_qdel_log = GLOB.world_manifest_log = GLOB.sql_error_log = GLOB.world_telecomms_log = GLOB.world_href_log = GLOB.world_runtime_log = GLOB.world_attack_log = GLOB.world_game_log = "data/logs/config_error.[GUID()].log" //temporary file used to record errors with loading config, moved to log directory once logging is set

	TgsNew(new /datum/tgs_event_handler/tg, minimum_required_security_level = TGS_SECURITY_TRUSTED)

	GLOB.revdata = new

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	SetupExternalRSC()
	
	populate_seed_list()
	populate_gear_list()
	make_datum_references_lists()

	//SetupLogs depends on the RoundID, so lets check
	//DB schema and set RoundID if we can
	SSdbcore.CheckSchemaVersion()
	SSdbcore.SetRoundID()
	SetupLogs()

	world.log = file("[GLOB.log_directory]/runtime.log")

	LoadVerbs(/datum/verbs/menu)
	load_admins()

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

	if(NO_INIT_PARAMETER in params)
		return

	Master.Initialize(10, FALSE, TRUE)

	GLOB.timezoneOffset = text2num(time2text(0,"hh")) * 36000

	load_mode()

	if(byond_version < RECOMMENDED_VERSION)
		log_world("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	update_status()

	world.tick_lag = CONFIG_GET(number/ticklag)

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
	GLOB.world_telecomms_log = "[GLOB.log_directory]/telecomms.log"
	GLOB.world_qdel_log = "[GLOB.log_directory]/qdel.log"
	GLOB.world_runtime_log = "[GLOB.log_directory]/runtime.log"
	GLOB.world_paper_log = "[GLOB.log_directory]/paper.log"

	start_log(GLOB.world_game_log)
	start_log(GLOB.world_attack_log)
	start_log(GLOB.world_manifest_log)
	start_log(GLOB.world_href_log)
	start_log(GLOB.sql_error_log)
	start_log(GLOB.world_telecomms_log)
	start_log(GLOB.world_qdel_log)
	start_log(GLOB.world_runtime_log)
	start_log(GLOB.world_paper_log)

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

/world/Topic(T, addr, master, key)
	TGS_TOPIC	//redirect to server tools if necessary

	var/static/list/topic_handlers = TopicHandlers()

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


/world/Reboot(ping)
	if(ping)
		send2update(CONFIG_GET(string/restart_message))
		send2update("Round ID [GLOB.round_id] finished | Next Ground Map: [length(SSmapping?.next_map_configs) ? SSmapping.next_map_configs[GROUND_MAP].map_name : "Default"] | Next Ship Map: [length(SSmapping?.next_map_configs) ? SSmapping.next_map_configs[SHIP_MAP].map_name : "Default"] | Round End State: [SSticker?.mode?.round_finished] | Players: [length(GLOB.clients)]")
	TgsReboot()
	for(var/i in GLOB.clients)
		var/client/C = i
		if(CONFIG_GET(string/server))
			C << link("byond://[CONFIG_GET(string/server)]")
	return ..()


/world/proc/load_mode()
	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			GLOB.master_mode = Lines[1]
			log_config("Saved mode is '[GLOB.master_mode]'")


/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)


/world/proc/update_status()
	//Note: Hub content is limited to 254 characters, including HTML/CSS. Image width is limited to 450 pixels.
	var/s = ""

	if(CONFIG_GET(string/server_name))
		if(CONFIG_GET(string/discordurl))
			s += "<a href=\"[CONFIG_GET(string/discordurl)]\"><b>[CONFIG_GET(string/server_name)] &#8212; [CONFIG_GET(string/ship_name)]</a></b>"
		else
			s += "<b>[CONFIG_GET(string/server_name)] &#8212; [CONFIG_GET(string/ship_name)]</b>"
		var/map_name = length(SSmapping.configs) ? SSmapping.configs[GROUND_MAP].map_name : null
		if(Master?.current_runlevel && GLOB.master_mode)
			switch(map_name)
				if("Ice Colony")
					s += "<br>Map: <a href='[CONFIG_GET(string/icecolonyurl)]'><b>[map_name]</a></b>"
				if("LV624")
					s += "<br>Map: <a href='[CONFIG_GET(string/lv624url)]'><b>[map_name]</a></b>"
				if("Big Red")
					s += "<br>Map: <a href='[CONFIG_GET(string/bigredurl)]'><b>[map_name]</a></b>"
				if("Prison Station")
					s += "<br>Map: <a href='[CONFIG_GET(string/prisonstationurl)]'><b>[map_name]</a></b>"
				if("Whiskey Outpost")
					s += "<br>Map: <a href='[CONFIG_GET(string/whiskeyoutposturl)]'><b>[map_name]</a></b>"
				else
					s += "<br>Map: <b>[map_name ? map_name : "Loading..."]</b>"
			s += "<br>Mode: <b>[(Master.current_runlevel & RUNLEVELS_DEFAULT) ? SSticker.mode.name : "Lobby"]</b>"
			s += "<br>Round time: <b>[duration2text()]</b>"
		else
			s += "<br>Map: <b>[map_name ? map_name : "Loading..."]</b>"

		status = s


/world/proc/incrementMaxZ()
	maxz++
	SSmobs.MaxZChanged()
	SSidlenpcpool.MaxZChanged()


/world/proc/SetupExternalRSC()
	if(!CONFIG_GET(string/resource_url))
		return
	GLOB.external_rsc_url = CONFIG_GET(string/resource_url)


/world/proc/update_hub_visibility(new_visibility)
	if(new_visibility == GLOB.hub_visibility)
		return
	GLOB.hub_visibility = new_visibility
	if(GLOB.hub_visibility)
		hub_password = "kMZy3U5jJHSiBQjr"
	else
		hub_password = "SORRYNOPASSWORD"