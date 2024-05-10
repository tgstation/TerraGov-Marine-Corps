/datum/round_event_control/stock_uptick
	name = "Supply point increase"
	typepath = /datum/round_event/stock_uptick
	weight = 15
	earliest_start = 30 MINUTES
	max_occurrences = 10

	gamemode_blacklist = list("Crash","Combat Patrol","Sensor Capture")

/datum/round_event_control/stock_uptick/can_spawn_event(players_amt, gamemode)
	if(SSpoints.supply_points[FACTION_TERRAGOV] >= 300)
		return FALSE
	return ..()

/datum/round_event/stock_uptick/start()
	var/points_to_be_added //var to keep track of how many point we're adding to req
	for(var/mob/living/carbon/human/H in GLOB.alive_human_list_faction[FACTION_TERRAGOV])
		points_to_be_added += pick(1,2,3)
	if(points_to_be_added > 1250) //cap the max amount of points at 1250
		points_to_be_added = 1250
	SSpoints.supply_points[FACTION_TERRAGOV] += points_to_be_added
	priority_announce("Due to an increase in Nanotrasen quarterly revenues, our supply allotment has increased by [points_to_be_added] points.")
