/datum/round_event_control/rogue/worldsiege
	name = "skellyworldsiege"
	typepath = /datum/round_event/rogue/worldsiege
	weight = 99
	max_occurrences = 999
	min_players = 4
	req_omen = FALSE
	todreq = list("dusk", "night")
	earliest_start = 35 MINUTES
	var/last_siege

/datum/round_event_control/rogue/worldsiege/canSpawnEvent(players_amt, gamemode)
	if(earliest_start >= world.time-SSticker.round_start_time)
		return FALSE
	if(players_amt < min_players)
		return FALSE
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.allmig)
			if(world.time > last_siege + 18 MINUTES)
				last_siege = world.time
				return TRUE

/datum/round_event_control/rogue/worldsiege/preRunEvent()
	. = ..()
	if(. == EVENT_READY)
		priority_announce("The skeleton horde approaches.", "", 'sound/misc/evilevent.ogg')

/datum/round_event/rogue/worldsiege
	announceWhen	= 1

/datum/round_event/rogue/worldsiege/setup()
	return TRUE

/datum/round_event/rogue/worldsiege/start()
	if(SSticker.mode)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(istype(C))
			C.skeletons = TRUE
			addtimer(CALLBACK(C, /datum/game_mode/chaosmode/.proc/reset_skeletons), rand(4 MINUTES, 8 MINUTES))
			for(var/mob/dead/observer/O in GLOB.player_list)
				addtimer(CALLBACK(O, /mob/dead/observer/.proc/horde_respawn), 1)
	return