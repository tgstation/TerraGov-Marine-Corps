/datum/round_event_control/stock_uptick
	name = "Supply point increase"
	typepath = /datum/round_event/stock_uptick
	weight = 15
	earliest_start = 30 MINUTES
	max_occurrences = 10

	gamemode_blacklist = list("Crash", "Combat Patrol", "Sensor Capture", "Campaign", "Zombie Crash")
	/// the faction for the next event to activate
	var/faction = null

/datum/round_event_control/stock_uptick/can_spawn_event(players_amt, gamemode, force = FALSE)
	. = ..()
	if(!.)
		return
	if((faction in SSpoints.supply_points) && !(SSpoints.supply_points[faction] >= 3000))
		return TRUE
	for(var/possible_faction in shuffle(SSpoints.supply_points))
		if(SSpoints.supply_points[possible_faction] >= 3000)
			continue
		faction = possible_faction
		return TRUE
	faction = null
	return FALSE

/datum/round_event/stock_uptick/start()
	var/datum/round_event_control/stock_uptick/stock_control = control
	if(!istype(stock_control))
		stock_control = new
	var/faction = stock_control.faction
	if(!(faction in SSpoints.supply_points) || (SSpoints.supply_points[faction] >= 3000))
		if(!stock_control.can_spawn_event(force = TRUE))
			qdel(src)
			return
		faction = stock_control.faction
	stock_control.faction = null
	var/points_to_be_added = rand(1,30*length(GLOB.player_list))
	if(points_to_be_added > 1250) //cap the max amount of points at 1250
		points_to_be_added = 1250
	SSpoints.add_supply_points(faction, points_to_be_added)
	if(faction == FACTION_TERRAGOV || faction == FACTION_VSD || faction == FACTION_NANOTRASEN)
		priority_announce("Due to an increase in [faction] quarterly revenues, their supply allotment has increased by [points_to_be_added] points.")
	else
		priority_announce("Due to an increase in anonymous donations to [faction], their supply allotment has increased by [points_to_be_added] points.")

	qdel(src)
