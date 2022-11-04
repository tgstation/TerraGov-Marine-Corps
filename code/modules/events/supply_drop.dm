//Supplies are dropped onto the map for both factions to fight over
/datum/round_event_control/supply_drop
	name = "Supply drop"
	typepath = /datum/round_event/supply_drop
	weight = 10
	earliest_start = 5 MINUTES

	gamemode_whitelist = list("Combat Patrol","Civil War","Sensor Capture")

/datum/round_event/supply_drop
	///How long between the event firing and the supply drop actually landing
	var/drop_delay = 2 MINUTES
	///How much of an early warning the supplying faction gets vs their opponents
	var/alert_delay = 30 SECONDS

/datum/round_event/supply_drop/start()
	var/turf/target_turf = null
	while(!target_turf)
		var/turf/potential_turf = locate(rand(0, world.maxx), rand(0,world.maxy), 2) //placeholder z value
		if(isclosedturf(potential_turf) || isspaceturf(potential_turf))
			continue
		target_turf = potential_turf
		set_target(target_turf)

///sets the target for this event, and notifies the hive
/datum/round_event/supply_drop/proc/set_target(turf/target_turf)
	var/supplying_faction = pick(SSticker.mode.factions)
	//the eta might display incorrectly, to check
	priority_announce("Friendly supply drop arriving in AO in [drop_delay / 600] minutes. Drop zone at [target_turf.loc]", "Short Range Tactical Radar Status", sound = 'sound/AI/bioscan.ogg', receivers = (GLOB.alive_human_list_faction[supplying_faction] + GLOB.observer_list))
	addtimer(CALLBACK(src, .proc/alert_hostiles, target_turf, supplying_faction), alert_delay)
	addtimer(CALLBACK(src, .proc/drop_supplies, target_turf, supplying_faction), drop_delay)

///Alerts the hostile faction(s)
/datum/round_event/supply_drop/proc/alert_hostiles(turf/target_turf, supplying_faction)
	var/list/humans_to_alert = GLOB.alive_human_list
	for(var/mob/living/carbon/human/alerted_human AS in humans_to_alert)
		if(alerted_human.faction == supplying_faction)
			humans_to_alert -= alerted_human

	priority_announce("[supplying_faction] supply drop detected, ETA [(drop_delay - alert_delay) / 600] minutes. Drop zone estimated as [target_turf.loc]", "Short Range Tactical Radar Status", sound = 'sound/AI/bioscan.ogg', receivers = (humans_to_alert + GLOB.observer_list))


///deploys the actual supply drop
/datum/round_event/supply_drop/proc/drop_supplies(turf/target_turf, faction)
	//rng rolls a faction loot box, and deploys it to the target turf
	//message to both factions that the drop has actually occured

