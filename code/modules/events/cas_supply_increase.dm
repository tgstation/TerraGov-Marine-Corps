/datum/round_event_control/cas_supply_increase
	name = "Dropship Point Increase"
	typepath = /datum/round_event/cas_supply_increase
	weight = 20
	earliest_start = 35 MINUTES
	alert_observers = FALSE
	max_occurrences = 10

	gamemode_blacklist = list("Crash","Civil War","Combat Patrol","Sensor Capture")

/datum/round_event_control/cas_supply_increase/can_spawn_event(players_amt, gamemode)
	if(length(GLOB.alive_human_list_faction[FACTION_TERRAGOV]) < 25)
		return FALSE
	if(SSpoints.dropship_points >= 250)
		return FALSE
	return ..()

/datum/round_event/cas_supply_increase/start()
	var/cas_points_to_be_added //var to keep track of how many point we're adding to dropship
	for(var/mob/living/carbon/human/H in GLOB.alive_human_list_faction[FACTION_TERRAGOV])
		if(ismarinepilotjob(H))
			cas_points_to_be_added += rand(50,175)
	if(cas_points_to_be_added > 300) //cap the added points to 300 in case rng really favors pilots
		cas_points_to_be_added = 300
	SSpoints.dropship_points += cas_points_to_be_added
	priority_announce("Due to recycling of discarded ammo casings, our dropship fabricator has absorbed enough material to increase capacity by [cas_points_to_be_added] points.")
