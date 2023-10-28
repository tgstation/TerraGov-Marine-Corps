//basic tdm mission - i.e. combat patrol
/datum/campaign_mission/tdm
	name = "Combat patrol"
	map_name = "Desparity"
	map_file = '_maps/map_files/desparity/desparity.dmm'
	map_light_colours = list(COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW)
	map_light_levels = list(225, 150, 100, 75)
	mission_icon = "combat_patrol"
	starting_faction_objective_description = "Major Victory: Wipe out all hostiles in the AO or capture and hold the sensor towers for a points victory. Minor Victory: Eliminate more hostiles than you lose."
	hostile_faction_objective_description = "Major Victory: Wipe out all hostiles in the AO or capture and hold the sensor towers for a points victory. Minor Victory: Eliminate more hostiles than you lose."
	max_game_time = 15 MINUTES
	game_timer_delay = 5 MINUTES
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(2, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 2),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(15, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(10, 5),
		MISSION_OUTCOME_DRAW = list(10, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(5, 10),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 15),
	)

	starting_faction_mission_brief = "Hostile forces have been attempting to expand the territory under their control in this area.\
		Although this territory is of limited direct strategic value, \
		to prevent them from establishing a permanent presence in the area command has ordered your battalion to execute force recon patrols to locate and eliminate any hostile presence. \
		Eliminate all hostiles you come across while preserving your own forces. Good hunting."
	hostile_faction_mission_brief = "Intelligence indicates that hostile forces are massing for a coordinated push to dislodge us from territory where we are aiming to establish a permanent presence. \
		Your battalion has been issued orders to regroup and counter attack the enemy push before they can make any progress, and kill their ambitions in this region. \
		Eliminate all hostiles you come across while preserving your own forces. Good hunting."
	starting_faction_additional_rewards = "If the enemy force is wiped out entirely, additional supplies can be diverted to your battalion."
	hostile_faction_additional_rewards = "If the enemy force is wiped out entirely, additional supplies can be diverted to your battalion."

	major_victory_reward_table = list(
		/obj/effect/supply_drop/medical_basic = 7,
		/obj/effect/supply_drop/marine_sentry = 5,
		/obj/effect/supply_drop/recoilless_rifle = 3,
		/obj/effect/supply_drop/armor_upgrades = 5,
		/obj/effect/supply_drop/mmg = 4,
		/obj/effect/supply_drop/zx_shotgun = 3,
		/obj/effect/supply_drop/minigun = 3,
		/obj/effect/supply_drop/scout = 3,
	)
	minor_victory_reward_table = list(
		/obj/effect/supply_drop/medical_basic = 7,
		/obj/effect/supply_drop/marine_sentry = 5,
		/obj/effect/supply_drop/recoilless_rifle = 3,
		/obj/effect/supply_drop/armor_upgrades = 5,
		/obj/effect/supply_drop/mmg = 4,
	)
	minor_loss_reward_table = list(
		/obj/effect/supply_drop/medical_basic = 7,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 5,
		/obj/effect/supply_drop/som_rpg = 3,
		/obj/effect/supply_drop/som_armor_upgrades = 5,
		/obj/effect/supply_drop/charger = 4,
	)
	major_loss_reward_table = list(
		/obj/effect/supply_drop/medical_basic = 7,
		/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope = 5,
		/obj/effect/supply_drop/som_rpg = 3,
		/obj/effect/supply_drop/som_armor_upgrades = 5,
		/obj/effect/supply_drop/charger = 4,
		/obj/effect/supply_drop/culverin = 3,
		/obj/effect/supply_drop/blink_kit = 3,
		/obj/effect/supply_drop/som_shotgun_burst = 3,
	)
	///Point limit to win the game via objectives
	var/capture_point_target = 400
	///starting team's point count
	var/start_team_cap_points = 0
	///hostile team's point count
	var/hostile_team_cap_points = 0

/datum/campaign_mission/tdm/load_mission()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, PROC_REF(objective_captured))
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED, PROC_REF(objective_cap_started))

/datum/campaign_mission/tdm/unregister_mission_signals()
	. = ..()
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAPTURED, COMSIG_GLOB_CAMPAIGN_CAPTURE_OBJECTIVE_CAP_STARTED))

/datum/campaign_mission/tdm/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
	)
	. = ..()

/datum/campaign_mission/tdm/get_status_tab_items(mob/source, list/items)
	. = ..()
	if(!length(GLOB.campaign_objectives))
		return
	items += "[starting_faction] Capture points: [start_team_cap_points] / [capture_point_target]"
	items += "[hostile_faction] Capture points: [hostile_team_cap_points] / [capture_point_target]"
	items += ""

/datum/campaign_mission/tdm/process()
	for(var/obj/structure/campaign_objective/capture_objective/sensor_tower/tower in GLOB.campaign_objectives)
		if(tower.owning_faction == starting_faction)
			start_team_cap_points += 1
		else if(tower.owning_faction == hostile_faction)
			hostile_team_cap_points += 1
	return ..()

/datum/campaign_mission/tdm/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return

	//we check points first, and only check deaths after
	if(start_team_cap_points >= capture_point_target && hostile_team_cap_points >= capture_point_target)
		message_admins("Mission finished: [MISSION_OUTCOME_DRAW]")
		outcome = MISSION_OUTCOME_DRAW
		return TRUE
	if(start_team_cap_points >= capture_point_target)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
		return TRUE
	if(hostile_team_cap_points >= capture_point_target)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
		return TRUE

	///pulls the number of both factions, dead or alive
	var/list/player_list = count_humans(count_flags = COUNT_IGNORE_ALIVE_SSD)
	var/num_start_team = length(player_list[1])
	var/num_hostile_team = length(player_list[2])
	var/num_dead_start_team = length(player_list[3])
	var/num_dead_hostile_team = length(player_list[4])

	if(num_hostile_team && num_start_team && !max_time_reached)
		return //fighting is ongoing

	//major victor for wiping out the enemy, or draw if both sides wiped simultaneously somehow
	if(!num_hostile_team)
		if(!num_start_team)
			message_admins("Mission finished: [MISSION_OUTCOME_DRAW]") //everyone died at the same time, no one wins
			outcome = MISSION_OUTCOME_DRAW
			return TRUE
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]") //starting team wiped the hostile team
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
		return TRUE

	if(!num_start_team)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]") //hostile team wiped the starting team
		outcome = MISSION_OUTCOME_MAJOR_LOSS
		return TRUE

	//minor victories for more kills or draw for equal kills
	if(num_dead_hostile_team > num_dead_start_team)
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]") //starting team got more kills
		outcome = MISSION_OUTCOME_MINOR_VICTORY
		return TRUE
	if(num_dead_start_team > num_dead_hostile_team)
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]") //hostile team got more kills
		outcome = MISSION_OUTCOME_MINOR_LOSS
		return TRUE

	message_admins("Mission finished: [MISSION_OUTCOME_DRAW]") //equal number of kills, or any other edge cases
	outcome = MISSION_OUTCOME_DRAW
	return TRUE

/datum/campaign_mission/tdm/apply_major_victory()
	. = ..()
	Generate_rewards(2, starting_faction)

/datum/campaign_mission/tdm/apply_minor_victory()
	. = ..()
	Generate_rewards(1, starting_faction)

/datum/campaign_mission/tdm/apply_draw()
	winning_faction = pick(starting_faction, hostile_faction)

/datum/campaign_mission/tdm/apply_minor_loss()
	. = ..()
	Generate_rewards(1, hostile_faction)

/datum/campaign_mission/tdm/apply_major_loss()
	. = ..()
	Generate_rewards(2, hostile_faction)

///An objective capture cycle was started
/datum/campaign_mission/tdm/proc/objective_cap_started(datum/source, obj/structure/campaign_objective/capture_objective/fultonable/objective, mob/living/user)
	SIGNAL_HANDLER
	var/capturing_team = user.faction
	var/losing_team = objective.owning_faction

	if(losing_team) //decapping enemy tower
		map_text_broadcast(capturing_team, "Good work, [objective] is being deactivated. Don't let them stop it!", "Enemy deactivating")
		map_text_broadcast(losing_team, "[objective] is being deactived, stop them!", "Objective deactivating")
	else if(objective.capturing_faction)
		losing_team = objective.capturing_faction //stopping enemy cap
		map_text_broadcast(capturing_team, "Good work, enemy activation of [objective] was cancelled. Don't let them get it back!", "Activation cancelled")
		map_text_broadcast(losing_team, "[objective] activation was overridden, take it back!", "Activation cancelled")
	else //we're capping
		losing_team = starting_faction == capturing_team ? hostile_faction : starting_faction
		map_text_broadcast(capturing_team, "[objective] is being activated. hold it down until it's done!", "Objective activating")
		map_text_broadcast(losing_team, "[objective] is being activated by the enemy. Get in there and stop them!", "Enemy activating")

///Handles the effect of an objective being claimed
/datum/campaign_mission/tdm/proc/objective_captured(datum/source, obj/structure/campaign_objective/capture_objective/fultonable/objective, mob/living/user)
	SIGNAL_HANDLER
	var/capturing_team = user.faction
	var/losing_team = starting_faction == user.faction ? hostile_faction : starting_faction

	map_text_broadcast(capturing_team, "[objective] is active. Don't let them retake it!", "Objective activated")
	map_text_broadcast(losing_team, "[objective] was activated by the enemy. Get it offline!", "Activation cancelled")

///test missions
/datum/campaign_mission/tdm/lv624
	name = "Combat patrol 2"
	map_name = "Orion outpost"
	map_file = '_maps/map_files/Orion_Military_Outpost/orionoutpost.dmm'
	map_light_colours = list(COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW)
	map_light_levels = list(225, 150, 100, 75)

/datum/campaign_mission/tdm/first_mission
	name = "First Contact"
	map_name = "Jungle outpost SR-422"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	map_light_levels = list(200, 100, 75, 50)

/datum/campaign_mission/tdm/first_mission/end_mission()
	. = ..()
	for(var/i in mode.stat_list)
		var/datum/faction_stats/team = mode.stat_list[i]
		team.add_asset(/datum/campaign_asset/strategic_reserves)
