/datum/campaign_mission/raiding_base
	name = "Raiding Base"
	mission_icon = "raiding_base"
	map_name = "Raiding base Zulu"
	map_file = '_maps/map_files/Campaign maps/som_raid_base/som_raiding_base.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, COLOR_MISSION_RED, COLOR_MISSION_RED)
	starting_faction_objective_description = "Major Victory: Set and defend an orbital beacon inside the facility until a precision orbital strike can be called in."
	hostile_faction_objective_description = "Major Victory: Prevent the enemy from activating an orbital beacon inside the facility."
	intro_message = list(
		MISSION_STARTING_FACTION = "Infiltrate the SOM base, then plant and defend an orbital beacon until we can drop the hammer on them from orbit!",
		MISSION_HOSTILE_FACTION = "Stop TGMC forces from infiltrating the base. Prevent them from activating an orbital beacon at all costs!",
	)
	mission_flags = MISSION_DISALLOW_DROPPODS
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
		MISSION_OUTCOME_MAJOR_LOSS = list(10, 30),
	)

	starting_faction_mission_brief = "We have finally been able to track down a hidden SOM outpost which they have been using as a base of operations to raid our supply lines, wrecking havoc on our logistics. \
	Your unit has been tasked with ensuring the complete and utter destruction of this base and everything within it. \
	Infiltrate the facility, then deploy one of the orbital beacons you have been supplied with. \
	Defend the beacon until the TGS Horizon can secure a target lock and deploy a thermobaric bunker buster to wipe the outpost off the face of the planet."
	hostile_faction_mission_brief = "Intelligence has picked up a TGMC plan to assault Raiding base Zulu. This base has been key to our sabotage and disruption efforts, significantly degrading TGMC supply lines. \
	Intel suggests that the TGMC are seeking to infiltrate the base to deploy a orbital beacon, in order to call down an orbital strike. \
	Prevent TGMC forces from entering the base, and destroy any orbital beacon they try to deploy."
	starting_faction_additional_rewards = "Remove negative effects on our logistics"
	hostile_faction_additional_rewards = "Allow us to continue degrading TGMC logistics"
	outro_message = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Major victory</u><br> Confirming good hit. Successful destruction of target facility. Outstanding marines!",
			MISSION_HOSTILE_FACTION = "<u>Major loss</u><br> We've lost Zulu, any survivors, fallback to exfil point Charlie, retreat!",
		),
		MISSION_OUTCOME_MAJOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Major loss</u><br> SOM interceptors are inbound, all forces fallback, this operation is a loss.",
			MISSION_HOSTILE_FACTION = "<u>Major victory</u><br> Reinforcements are almost here and enemy forces are falling back, you've done Mars proud today marines.",
		),
	)
	///Records whether the OB has been called
	var/ob_called = FALSE
	///Count of beacons still in play
	var/beacons_remaining = 4

/datum/campaign_mission/raiding_base/get_status_tab_items(mob/source, list/items)
	. = ..()
	items += "Beacons remaining: [beacons_remaining]"

/datum/campaign_mission/raiding_base/load_pre_mission_bonuses()
	spawn_mech(starting_faction, 0, 0, 3)
	spawn_mech(hostile_faction, 0, 2)
	new /obj/item/storage/box/crate/loot/materials_pack(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))
	for(var/i = 1 to beacons_remaining)
		new /obj/item/explosive/plastique(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))
		new /obj/item/explosive/plastique(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))
		new /obj/item/campaign_beacon/bunker_buster(get_turf(pick(GLOB.campaign_reward_spawners[starting_faction])))

/datum/campaign_mission/raiding_base/start_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OB_BEACON_ACTIVATION, PROC_REF(beacon_placed))
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_OB_BEACON_TRIGGERED, PROC_REF(beacon_triggered))

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

/datum/campaign_mission/raiding_base/unregister_mission_signals()
	. = ..()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_CAMPAIGN_OB_BEACON_ACTIVATION, COMSIG_GLOB_CAMPAIGN_OB_BEACON_TRIGGERED))

/datum/campaign_mission/raiding_base/apply_major_victory()
	. = ..()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.remove_asset(/datum/campaign_asset/attrition_modifier/malus_strong)
	winning_team.remove_asset(/datum/campaign_asset/attrition_modifier/malus_standard)
	//We don't have enough missions in the pool yet to activate this
	//GLOB.campaign_mission_pool[hostile_faction] -= /datum/campaign_mission/destroy_mission/supply_raid/som
	//GLOB.campaign_mission_pool[hostile_faction] -= /datum/campaign_mission/destroy_mission/supply_raid


/datum/campaign_mission/raiding_base/apply_major_loss()
	. = ..()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		winning_team.add_asset(/datum/campaign_asset/equipment/power_armor)
	else if(hostile_faction == FACTION_SOM)
		winning_team.add_asset(/datum/campaign_asset/mech/light/som)
		winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)

///Returns a list of areas in which the beacon can be deployed
/datum/campaign_mission/raiding_base/proc/get_valid_beacon_areas()
	return list(
		/area/campaign/som_raiding/outpost/command,
		/area/campaign/som_raiding/outpost/command/captain,
		/area/campaign/som_raiding/outpost/command/telecom,
		/area/campaign/som_raiding/outpost/command/cic,
		/area/campaign/som_raiding/outpost/command/north,
		/area/campaign/som_raiding/outpost/command/living,
		/area/campaign/som_raiding/outpost/medbay,
		/area/campaign/som_raiding/outpost/central_corridor,
	)

///Reacts to an OB beacon being successfully triggered
/datum/campaign_mission/raiding_base/proc/beacon_placed(datum/source, obj/structure/campaign_objective/destruction_objective/bunker_buster/beacon)
	SIGNAL_HANDLER
	RegisterSignal(beacon, COMSIG_QDELETING, PROC_REF(beacon_destroyed))
	pause_mission_timer(REF(beacon))
	var/area/deployed_area = get_area(beacon)
	map_text_broadcast(starting_faction, "Confirming beacon deployed in [deployed_area]. Defend it until we can secure a target lock marines!", "TGS Horizon", /atom/movable/screen/text/screen_text/picture/potrait/pod_officer, "sound/effects/alert.ogg")
	map_text_broadcast(hostile_faction, "Orbital beacon detected in [deployed_area]. Destroy that beacon before they can secure a target lock!", "Overwatch", sound_effect = "sound/effects/alert.ogg")

///Handles a beacon being destroyed. Separate from normal objective destruction for convenience as we want the specific beacon ref
/datum/campaign_mission/raiding_base/proc/beacon_destroyed(obj/structure/campaign_objective/destruction_objective/bunker_buster/beacon)
	SIGNAL_HANDLER
	UnregisterSignal(beacon, COMSIG_QDELETING)
	resume_mission_timer(REF(beacon))
	beacons_remaining --
	if(outcome)
		return
	var/beacons_destroyed = initial(beacons_remaining) - beacons_remaining
	map_text_broadcast(starting_faction, "We've lost [beacons_destroyed] beacon[beacons_destroyed > 1 ? "s" : null], get it together!", "Overwatch")
	map_text_broadcast(hostile_faction, "[beacons_destroyed] beacon[beacons_destroyed > 1 ? "s" : null] destroyed, keep up the good work!", "Overwatch")

///Reacts to an OB beacon being successfully triggered
/datum/campaign_mission/raiding_base/proc/beacon_triggered(datum/source, obj/structure/campaign_objective/destruction_objective/bunker_buster/beacon, activation_delay)
	SIGNAL_HANDLER
	pause_mission_timer() //stops the game from ending if it comes down to the wire
	addtimer(CALLBACK(src, PROC_REF(beacon_effect), beacon, beacon.loc), activation_delay)

///Handles the actual detonation effects
/datum/campaign_mission/raiding_base/proc/beacon_effect(obj/structure/campaign_objective/destruction_objective/bunker_buster/beacon, turf/location)
	ob_called = TRUE
	resume_mission_timer(src, TRUE)
	//We handle this here instead of the beacon structure because it could be destroyed before this triggers
	explosion(location, 45, flame_range = 45)
	if(QDELETED(beacon))
		return
	qdel(beacon)
