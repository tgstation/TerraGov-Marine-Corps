/datum/round_event_control/stock_uptick
	name = "Supply point increase"
	typepath = /datum/round_event/stock_uptick
	weight = 15
	earliest_start = 30 MINUTES
	max_occurrences = 10

	gamemode_blacklist = list("Crash", "Combat Patrol", "Sensor Capture", "Campaign")

/datum/round_event_control/stock_uptick/can_spawn_event(players_amt, gamemode)
	if(SSpoints.supply_points[FACTION_TERRAGOV] >= 300)
		return FALSE
	return ..()

/datum/round_event/stock_uptick/start()
	var/faction = pick(SSpoints.supply_points)
	var/points_to_be_added = rand(1,30*length(GLOB.player_list))
	if(points_to_be_added > 1250) //cap the max amount of points at 1250
		points_to_be_added = 1250
	SSpoints.add_supply_points(faction, points_to_be_added)
	if(faction == FACTION_TERRAGOV || faction == FACTION_VSD)
		priority_announce("Due to an increase in [faction] quarterly revenues, their supply allotment has increased by [points_to_be_added] points.")
	else
		priority_announce("Due to an increase in anonymous donations to [faction], their supply allotment has increased by [points_to_be_added] points.")
