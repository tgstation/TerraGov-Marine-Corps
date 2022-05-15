// SETUP
/proc/TopicHandlers()
	. = list()
	var/list/all_handlers = subtypesof(/datum/world_topic)
	for(var/I in all_handlers)
		var/datum/world_topic/WT = I
		var/keyword = initial(WT.keyword)
		if(!keyword)
			stack_trace("[WT] has no keyword! Ignoring...")
			continue
		var/existing_path = .[keyword]
		if(existing_path)
			stack_trace("[existing_path] and [WT] have the same keyword! Ignoring [WT]...")
		else if(keyword == "key")
			stack_trace("[WT] has keyword 'key'! Ignoring...")
		else
			.[keyword] = WT


// DATUM
/datum/world_topic
	var/keyword
	var/log = TRUE
	var/key_valid
	var/require_comms_key = FALSE


/datum/world_topic/proc/TryRun(list/input)
	key_valid = config && (CONFIG_GET(string/comms_key) == input["key"])
	input -= "key"
	if(require_comms_key && !key_valid)
		. = "Bad Key"
		if (input["format"] == "json")
			. = list("error" = .)
	else
		. = Run(input)
	if (input["format"] == "json")
		. = json_encode(.)
	else if(islist(.))
		. = list2params(.)


/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")


// TOPICS
/datum/world_topic/status
	keyword = "status"


/datum/world_topic/status/Run(list/input)
	. = list()
	.["version"] = GLOB.game_version
	.["mode"] = GLOB.master_mode
	.["respawn"] = GLOB.respawn_allowed
	.["enter"] = GLOB.enter_allowed
	.["vote"] = CONFIG_GET(flag/allow_vote_mode)
	.["ai"] = CONFIG_GET(flag/allow_ai)
	.["host"] = world.host ? world.host : null
	.["round_id"] = GLOB.round_id
	.["players"] = length(GLOB.clients)
	.["revision"] = GLOB.revdata.commit
	.["revision_date"] = GLOB.revdata.date
	.["hub"] = GLOB.hub_visibility

	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = length(presentmins) + length(afkmins)
	.["gamestate"] = SSticker.current_state

	.["map_name"] = length(SSmapping.configs) ? "[SSmapping.configs[GROUND_MAP].map_name] ([SSmapping.configs[SHIP_MAP].map_name])" : "Loading..."

	.["security_level"] = GLOB.marine_main_ship?.get_security_level()
	.["round_duration"] = SSticker ? round((world.time - SSticker.round_start_time) / 10) : 0

	.["time_dilation_current"] = SStime_track.time_dilation_current
	.["time_dilation_avg"] = SStime_track.time_dilation_avg
	.["time_dilation_avg_slow"] = SStime_track.time_dilation_avg_slow
	.["time_dilation_avg_fast"] = SStime_track.time_dilation_avg_fast

	.["soft_popcap"] = CONFIG_GET(number/soft_popcap) || 0
	.["hard_popcap"] = CONFIG_GET(number/hard_popcap) || 0
	.["extreme_popcap"] = CONFIG_GET(number/extreme_popcap) || 0
	.["popcap"] = max(CONFIG_GET(number/soft_popcap), CONFIG_GET(number/hard_popcap), CONFIG_GET(number/extreme_popcap)) //generalized field for this concept for use across ss13 codebases


/datum/world_topic/status2
	keyword = "status2"


/datum/world_topic/status2/Run(list/input)
	. = list()
	.["mode"] = GLOB.master_mode
	.["respawn"] = GLOB.respawn_allowed
	.["enter"] = GLOB.enter_allowed
	.["roundtime"] = gameTimestamp()
	.["listed"] = GLOB.hub_visibility
	.["players"] = length(GLOB.clients)
	.["ticker_state"] = SSticker.current_state
	.["mapname"] = length(SSmapping.configs) ? "[SSmapping.configs[GROUND_MAP].map_name] ([SSmapping.configs[SHIP_MAP].map_name])" : "Loading..."
	.["security_level"] = GLOB.marine_main_ship?.get_security_level()
	.["round_duration"] = SSticker ? round((world.time - SSticker.round_start_time) / 10) : 0

/datum/world_topic/playerlist_ext
	keyword = "playerlist_ext"
	require_comms_key = TRUE

/datum/world_topic/playerlist_ext/Run(list/input)
	. = list()
	var/list/players = list()
	var/list/disconnected_observers = list()

	for(var/mob/M in GLOB.dead_mob_list)
		if(!M.ckey)
			continue
		if (M.client)
			continue
		var/ckey = ckey(M.ckey)
		disconnected_observers[ckey] = ckey

	for(var/client/C as anything in GLOB.clients)
		var/ckey = C.ckey
		players[ckey] = ckey
		. += ckey

	for(var/mob/M in GLOB.alive_living_list)
		if(!M.ckey)
			continue
		var/ckey = ckey(M.ckey)
		if(players[ckey])
			continue
		if(disconnected_observers[ckey])
			continue
		players[ckey] = ckey
		. += ckey
