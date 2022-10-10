/datum/round_event_control/hostile_ert
	name = "Hostile ERT"
	typepath = /datum/round_event/hostile_ert
	weight = 4
	earliest_start = 90 MINUTES
	max_occurrences = 1

	gamemode_blacklist = list("Crash","Combat Patrol","Civil War","Extended")
	min_players = 50

/datum/round_event_control/hostile_ert/can_spawn_event(players_amt, gamemode)
	var/xeno_to_marine_ratio = (length(GLOB.alive_xeno_list)/length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]))
	if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) < 30)
		return FALSE
	if(xeno_to_marine_ratio > 0.15)
		return FALSE
	else if(SSticker.mode.on_distress_cooldown)
		return FALSE

	return ..()

/datum/round_event/hostile_ert/
	announce_when = 0

/datum/round_event/hostile_ert/start()
	priority_announce("Attention, ship sensors have detected a hostile vessel approaching at high speeds, all crew standby and prepare to be boarded.", sound = 'sound/misc/interference.ogg')
	var/minimum_ert = (length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) * 0.04) //roughly comes out to 1 at min population of 30
	var/maximum_ert = (length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) * 0.07) //roughly comes out to 2 at min population of 30
	var/selected_ert = pick("CLF Cell","Sectoid Expedition","Sons of Mars Squad","USL Pirate Band","The Bone Zone","Pizza Delivery")
	for(var/datum/emergency_call/C in SSticker.mode.all_calls)
		if(C.name == selected_ert)
			SSticker.mode.picked_call = C
			break
	SSticker.mode.picked_call.mob_max = maximum_ert
	SSticker.mode.picked_call.mob_min = minimum_ert
	SSticker.mode.picked_call.activate(FALSE)
