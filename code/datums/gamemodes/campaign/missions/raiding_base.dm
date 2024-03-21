//placeholder
/datum/campaign_mission/raiding_base
	name = "Raiding Base"
	mission_icon = "raiding_base"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	starting_faction_objective_description = "Major Victory: Set and defend an orbital beacon inside the facility until a precision orbital strike can be called in."
	hostile_faction_objective_description = "Major Victory: Prevent the enemy destroying the base via orbital strike with an orbtial beacon placed inside the facility."
	intro_message = list(
		MISSION_STARTING_FACTION = "Infiltrate the SOM base, then plant and defend an orbital beacon so we can drop the hammer on them from orbit!",
		MISSION_HOSTILE_FACTION = "Stop TGMC forces from infiltrating the base. Prevent them from activating an orbital beacon at all costs!",
	)
	max_game_time = 12 MINUTES
	mission_start_delay = 90 SECONDS
	shutter_open_delay = list(
		MISSION_STARTING_FACTION = 90 SECONDS,
		MISSION_HOSTILE_FACTION = 0,
	)
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(2, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 2),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(20, 20),
		MISSION_OUTCOME_MINOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 0),
		MISSION_OUTCOME_MAJOR_LOSS = list(10, 20),
	)

	starting_faction_mission_brief = "We have finally been able to track down a hidden SOM outpost which they have been using as a base of operations to raid our supply lines. \
	The SOM have been wreaking havoc with our logistics, they must be stopped with extreme prejudice. \
	Infiltrate the facility, then deploy one of the orbital beacons you have been supplied with. \
	Defend the beacon until the TGS Horizon can secure a target lock and deploy a thermobaric bunker buster to wipe the outpost off the face of the planet."
	hostile_faction_mission_brief = "Intelligence has picked up a TGMC plan to assault Raiding base Zulu. This base has been key to our sabotage and disruption efforts, significantly degrading TGMC supply lines. \
	Intel suggests that the TGMC are seeking to infiltrate the base to deploy a orbital beacon, in order to call down an orbital strike. \
	Prevent TGMC forces from entering the base, and destroy any orbital beacon they try to deploy."
	starting_faction_additional_rewards = "Remove negative effects on our logistics"
	hostile_faction_additional_rewards = "Allow us to continue degrading TGMC logistics"
	///Records whether the OB has been called
	var/ob_called = FALSE

/datum/campaign_mission/raiding_base/load_pre_mission_bonuses()
	new /obj/item/storage/box/crate/loot/materials_pack(get_turf(pick(GLOB.campaign_reward_spawners[defending_faction])))
	for(var/i = 1 to 3)
		new /obj/item/campaign_beacon/bunker_buster(get_turf(pick(GLOB.campaign_reward_spawners[starting_faction])))
		new /obj/item/explosive/plastique(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))
		new /obj/item/explosive/plastique(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))

/datum/campaign_mission/raiding_base/start_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_CAMPAIGN_OB_BEACON_ACTIVATION, PROC_REF(beacon_placed))
	RegisterSignal(SSdcs, COMSIG_CAMPAIGN_OB_BEACON_TRIGGERED, PROC_REF(beacon_triggered))

/datum/campaign_mission/raiding_base/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(ob_called)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]") //Attackers dropped the hammer
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
		return TRUE

	var/attacker_lost

	if(!length(GLOB.campaign_objectives) || max_time_reached)
		attacker_lost = TRUE
	else
		var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
		var/num_team_one = length(player_list[1])
		var/datum/faction_stats/attacker_stats = mode.stat_list[starting_faction]
		if(!num_team_one && !attacker_stats.active_attrition_points)
			attacker_lost = TRUE

	if(!attacker_lost)
		return FALSE
	message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]") //Attackers run out of beacons, time or bodies
	outcome = MISSION_OUTCOME_MAJOR_LOSS
	return TRUE

//todo: remove these if nothing new is added
/datum/campaign_mission/raiding_base/apply_major_victory()
	. = ..()

/datum/campaign_mission/raiding_base/apply_major_loss()
	. = ..()

///Reacts to an OB beacon being successfully triggered
/datum/campaign_mission/raiding_base/proc/beacon_placed(obj/structure/campaign_objective/destruction_objective/bunker_buster/source)
	SIGNAL_HANDLER
	var/area/deployed_area = get_area(source)
	map_text_broadcast(starting_faction, "Confirming beacon deployed in [deployed_area.name]. Defend it until we can secure a target lock marines!", "TGS Horizon", /atom/movable/screen/text/screen_text/picture/potrait/pod_officer, "sound/effects/alert.ogg")
	map_text_broadcast(hostile_faction, "Orbital beacon detected in [deployed_area.name]. Destroy that beacon before they can secure a target lock!", "Overwatch", sound_effect = "sound/effects/alert.ogg")

///Reacts to an OB beacon being successfully triggered
/datum/campaign_mission/raiding_base/proc/beacon_triggered(datum/source)
	SIGNAL_HANDLER
	deltimer(game_timer)
	addtimer(VARSET_CALLBACK(src, ob_called, TRUE), CAMPAIGN_OB_BEACON_IMPACT_DELAY + 1 SECONDS)

