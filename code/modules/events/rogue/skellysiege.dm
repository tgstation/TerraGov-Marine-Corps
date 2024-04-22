/datum/round_event_control/rogue/skellysiege
	name = "skellysiege"
	typepath = /datum/round_event/rogue/skellysiege
	weight = 10
	max_occurrences = 999
	min_players = 0
	req_omen = TRUE
	todreq = list("dusk", "night", "dawn", "day")
	earliest_start = 2 HOURS
	var/last_siege = 0


/datum/round_event/rogue/skellysiege
	announceWhen	= 1

/datum/round_event/rogue/skellysiege/setup()
	return

/datum/round_event/rogue/skellysiege/start()
	if(SSticker.mode)
		var/datum/game_mode/chaosmode/C = SSticker.mode
		if(istype(C))
			C.skeletons = TRUE
			addtimer(CALLBACK(C, TYPE_PROC_REF(/datum/game_mode/chaosmode, reset_skeletons)), rand(4 MINUTES, 8 MINUTES))
			for(var/mob/dead/observer/O in GLOB.player_list)
				addtimer(CALLBACK(O, TYPE_PROC_REF(/mob/dead/observer, horde_respawn)), 1)
	return
