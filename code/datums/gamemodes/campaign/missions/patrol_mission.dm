/////basic tdm mission - i.e. combat patrol
/datum/campaign_mission/tdm
	name = "Combat patrol"
	map_name = "Orion Outpost"
	//map_file = '_maps/map_files/Orion_Military_Outpost/orionoutpost.dmm' //testing new map
	map_file = '_maps/map_files/Campaign maps/jungle_test/jungle_outpost.dmm'
	starting_faction_objective_description = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose."
	hostile_faction_objective_description = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose."
	max_game_time = 20 MINUTES
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(3, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 3),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(20, 5),
		MISSION_OUTCOME_MINOR_VICTORY = list(15, 10),
		MISSION_OUTCOME_DRAW = list(10, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(10, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(5, 20),
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

/datum/campaign_mission/tdm/play_start_intro()
	intro_message = list(
		"starting_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		"hostile_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
	)
	. = ..()

/datum/campaign_mission/tdm/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return

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
	Generate_rewards(3, starting_faction)

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
	Generate_rewards(3, hostile_faction)


///test missions
/datum/campaign_mission/tdm/lv624
	name = "Combat patrol 2"
	map_name = "LV-624"
	map_file = '_maps/map_files/LV624/LV624.dmm' //todo: make modulars work with late load

/datum/campaign_mission/tdm/desparity
	name = "Combat patrol 3"
	map_name = "Desparity"
	map_file = '_maps/map_files/desparity/desparity.dmm'
