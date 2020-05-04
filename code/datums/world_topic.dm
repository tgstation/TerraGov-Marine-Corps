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
	var/log = FALSE


/datum/world_topic/proc/TryRun(list/input)
	input -= "key"
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
