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
	if(require_comms_key && !key_valid)
		return "Bad Key"
	input -= "key"
	. = Run(input)
	if(islist(.))
		. = list2params(.)


/datum/world_topic/proc/Run(list/input)
	CRASH("Run() not implemented for [type]!")


// TOPICS
/datum/world_topic/ping
	keyword = "ping"
	log = FALSE


/datum/world_topic/ping/Run(list/input)
	. = 0
	for (var/client/C in GLOB.clients)
		++.


/datum/world_topic/playing
	keyword = "playing"
	log = FALSE


/datum/world_topic/playing/Run(list/input)
	return length(GLOB.player_list)


/datum/world_topic/pr_announce
	keyword = "announce"
	require_comms_key = TRUE
	var/static/list/PRcounts = list()	//PR id -> number of times announced this round


/datum/world_topic/pr_announce/Run(list/input)
	var/list/payload = json_decode(input["payload"])
	var/id = "[payload["pull_request"]["id"]]"
	if(!PRcounts[id])
		PRcounts[id] = 1
	else
		++PRcounts[id]
		if(PRcounts[id] > PR_ANNOUNCEMENTS_PER_ROUND)
			return

	var/final_composed = "<span class='announce'>PR: [input[keyword]]</span>"
	to_chat(world, final_composed)


/datum/world_topic/ahelp_relay
	keyword = "Ahelp"
	require_comms_key = TRUE


/datum/world_topic/ahelp_relay/Run(list/input)
	message_admins("<span class='adminnotice'><b><font color=red>RELAY: </font> [input["source"]] [input["message_sender"]]: [input["message"]]</b></span>")


/datum/world_topic/adminmsg
	keyword = "adminmsg"
	require_comms_key = TRUE


/datum/world_topic/adminmsg/Run(list/input)
	return IrcPm(input[keyword], input["msg"], input["sender"])


/datum/world_topic/adminwho
	keyword = "adminwho"
	require_comms_key = TRUE


/datum/world_topic/adminwho/Run(list/input)
	return ircadminwho()


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

	var/list/adm = get_admin_counts()
	var/list/presentmins = adm["present"]
	var/list/afkmins = adm["afk"]
	.["admins"] = length(presentmins) + length(afkmins)
	.["gamestate"] = SSticker.current_state

	.["map_name"] = length(SSmapping.configs) ? SSmapping.configs[GROUND_MAP].map_name : "Loading..."

	if(key_valid)
		if(SSticker.HasRoundStarted())
			.["real_mode"] = SSticker.mode.name

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