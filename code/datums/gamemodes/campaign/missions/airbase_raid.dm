#define AIRBASE_START_BIKE_MULT 0.15
#define AIRBASE_HOSTILE_BIKE_MULT 0.1

#define AIRBASE_MIN_START_BIKE_AMOUNT 3
#define AIRBASE_MIN_HOSTILE_BIKE_AMOUNT 2

//disabling an enemy logistics hub
/datum/campaign_mission/destroy_mission/airbase
	name = "Airbase assault"
	mission_icon = "cas_raid"
	mission_flags = MISSION_DISALLOW_DROPPODS
	map_name = "Rocinante base"
	map_file = '_maps/map_files/Campaign maps/som_base/sombase.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating", ZTRAIT_SNOWSTORM = TRUE)
	map_light_colours = list(COLOR_MISSION_BLUE, COLOR_MISSION_BLUE, COLOR_MISSION_BLUE, COLOR_MISSION_BLUE)
	map_light_levels = list(225, 150, 100, 75)
	map_armor_color = MAP_ARMOR_STYLE_ICE
	objectives_total = 6
	min_destruction_amount = 4
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(2, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 2),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(15, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_DRAW = list(0, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 25),
	)

	starting_faction_additional_rewards = "Disrupt enemy air support for a moderate period of time."
	hostile_faction_additional_rewards = "Ensure continued access to close air support. Hoverbike and gorgon armor available if you successfully protect this depot."

	starting_faction_mission_parameters = "Heavy snowstorms are active in the AO. High speed bikes are available. CAS is unavailable."
	hostile_faction_mission_parameters = "Heavy snowstorms are active in the AO. High speed bikes are available."

/datum/campaign_mission/destroy_mission/airbase/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Locate and destroy all [objectives_total] enemy aircraft before further [hostile_faction] reinforcements can arrive. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect all [objectives_total] aircraft until reinforcements arrive. Eliminate all [starting_faction] forces and secure the area.",
	)
	return ..()

/datum/campaign_mission/destroy_mission/airbase/load_mission_brief()
	starting_faction_mission_brief = "A hidden [hostile_faction] airbase has been located in the Great Dallard Highlands. Intelligence indicated this installation is a key [hostile_faction] air support base for close air support in this region. \
		The destruction of this airbase will have a severe impact on ability to use close air support in the near future. \
		Move quickly and destroy all designated targets in the AO before they have time to react."
	hostile_faction_mission_brief = "[starting_faction] forces have been detected moving against our airbase in the Great Dallard Highlands. \
		Repel the enemy and protect the installation until reinforcements can arrive. \
		The loss of this depot would be a heavy blow against our air power, greatly reducing our ability to field close air support in the near future."

/datum/campaign_mission/destroy_mission/airbase/load_pre_mission_bonuses()
	. = ..()

	var/obj/start_bike = GLOB.campaign_bike_by_faction[starting_faction]
	var/obj/hostile_bike = GLOB.campaign_bike_by_faction[hostile_faction]

	for(var/i = 1 to max(AIRBASE_MIN_START_BIKE_AMOUNT, floor(length(GLOB.clients) * AIRBASE_START_BIKE_MULT)))
		var/obj/bike = new start_bike(get_turf(pick(GLOB.campaign_reward_spawners[starting_faction])))
		GLOB.campaign_structures += bike
		RegisterSignal(bike, COMSIG_QDELETING, TYPE_PROC_REF(/datum/campaign_mission, remove_mission_object))

	for(var/i = 1 to max(AIRBASE_MIN_HOSTILE_BIKE_AMOUNT, floor(length(GLOB.clients) * AIRBASE_HOSTILE_BIKE_MULT)))
		var/obj/bike = new hostile_bike(get_turf(pick(GLOB.campaign_reward_spawners[hostile_faction])))
		GLOB.campaign_structures += bike
		RegisterSignal(bike, COMSIG_QDELETING, TYPE_PROC_REF(/datum/campaign_mission, remove_mission_object))

	var/datum/faction_stats/attacking_team = mode.stat_list[starting_faction]
	attacking_team.add_asset(GLOB.campaign_cas_disabler_by_faction[starting_faction])

/datum/campaign_mission/destroy_mission/airbase/apply_major_victory()
	winning_faction = starting_faction

	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	hostile_team.add_asset(/datum/campaign_asset/asset_disabler/som_cas)

	var/reward_bike = winning_faction == FACTION_SOM ? /datum/campaign_asset/equipment/som_bike : /datum/campaign_asset/equipment/bike
	mode.stat_list[winning_faction].add_asset(reward_bike)

	Generate_rewards(2, winning_faction)

/datum/campaign_mission/destroy_mission/airbase/apply_minor_victory()
	winning_faction = starting_faction

	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	hostile_team.add_asset(/datum/campaign_asset/asset_disabler/som_cas)

	Generate_rewards(1, winning_faction)

/datum/campaign_mission/destroy_mission/airbase/apply_minor_loss()
	winning_faction = hostile_faction

	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	var/reward_bike = winning_faction == FACTION_SOM ? /datum/campaign_asset/equipment/som_bike : /datum/campaign_asset/equipment/bike
	winning_team.add_asset(reward_bike)

	Generate_rewards(2, winning_faction)

/datum/campaign_mission/destroy_mission/airbase/apply_major_loss()
	winning_faction = hostile_faction

	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	var/reward_armour = winning_faction == FACTION_SOM ? /datum/campaign_asset/equipment/gorgon_armor : /datum/campaign_asset/equipment/power_armor
	var/reward_bike = winning_faction == FACTION_SOM ? /datum/campaign_asset/equipment/som_bike : /datum/campaign_asset/equipment/bike
	winning_team.add_asset(reward_armour)
	winning_team.add_asset(reward_bike)

	Generate_rewards(2, winning_faction)

/datum/campaign_mission/destroy_mission/airbase/som
	mission_flags = MISSION_DISALLOW_TELEPORT
	map_name = "Camp Broadsire Airbase"
	map_file = '_maps/map_files/Campaign maps/tgmc_airfield/tgmc_airfield.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating", ZTRAIT_SANDSTORM = TRUE)
	map_light_colours = list(COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW, COLOR_MISSION_YELLOW)
	map_light_levels = list(225, 150, 100, 75)
	map_armor_color = MAP_ARMOR_STYLE_DESERT
	objectives_total = 5
	min_destruction_amount = 3

	hostile_faction_additional_rewards = "Ensure continued access to close air support. B18 power armour available if you successfully protect this depot."

	starting_faction_mission_parameters = "Dangerous sandstorms are active in the AO. High speed bikes are available. CAS is unavailable."
	hostile_faction_mission_parameters = "Dangerous sandstorms are active in the AO. High speed bikes are available."

/datum/campaign_mission/destroy_mission/airbase/som/load_mission_brief()
	starting_faction_mission_brief = "A [hostile_faction] airbase has been located on the fringes of the Western Galloran Desert. Intelligence indicated this installation is a key [hostile_faction] air support base for close air support in this region. \
		The destruction of this airbase will have a severe impact on ability to use close air support in the near future. \
		Move quickly under the cover of a sandstorm and destroy all designated targets in the AO before they have time to react."
	hostile_faction_mission_brief = "[starting_faction] forces have been detected moving against the Camp Broadsire Airbase in the Western Galloran Desert under the cover of a sandstorm. \
		Repel the enemy and protect the installation until reinforcements can arrive. \
		The loss of this depot would be a heavy blow against our air power, greatly reducing our ability to field close air support in the near future."

#undef AIRBASE_START_BIKE_MULT
#undef AIRBASE_HOSTILE_BIKE_MULT
#undef AIRBASE_MIN_START_BIKE_AMOUNT
#undef AIRBASE_MIN_HOSTILE_BIKE_AMOUNT
