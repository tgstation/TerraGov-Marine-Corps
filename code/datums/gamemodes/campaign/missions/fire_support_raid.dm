//disabling some of the enemy's firesupport options
/datum/campaign_mission/destroy_mission/fire_support_raid
	name = "Fire support raid"
	mission_icon = "mortar_raid"
	mission_flags = MISSION_DISALLOW_DROPPODS
	map_name = "Jungle outpost SR-422"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	objectives_total = 10
	min_destruction_amount = 7
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
		MISSION_OUTCOME_MAJOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(5, 0),
		MISSION_OUTCOME_DRAW = list(0, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 25),
	)

	starting_faction_additional_rewards = "Severely degrade enemy fire support, preventing their use of mortars for a period of time."
	hostile_faction_additional_rewards = "Protect our fire support options to ensure continued access to mortar support. Additional equipment and fire support is available if you successfully defend this outpost."

/datum/campaign_mission/destroy_mission/fire_support_raid/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Locate and destroy all [objectives_total] [hostile_faction] fire support installations before further [hostile_faction] reinforcements can arrive. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect all [objectives_total] fire support installations until reinforcements arrive. Eliminate all [starting_faction] forces and secure the area.",
	)
	return ..()

/datum/campaign_mission/destroy_mission/fire_support_raid/load_pre_mission_bonuses()
	. = ..()
	for(var/i = 1 to objectives_total)
		new /obj/item/storage/box/explosive_mines(get_turf(pick(GLOB.campaign_reward_spawners[defending_faction])))

/datum/campaign_mission/destroy_mission/fire_support_raid/load_mission_brief()
	starting_faction_mission_brief = "A [hostile_faction] fire support position has been identified in this area. This key location provides fire support to [hostile_faction] forces across the region. \
		By destroying this outpost we can silence their guns and greatly weaken the enemy's forces. \
		Move quickly and destroy all fire support installations before they have time to react."
	hostile_faction_mission_brief = "[starting_faction] forces have been detected moving against our fire support installation in this area. \
		Repel the enemy and protect the installations until reinforcements can arrive. \
		Loss of these fire support installations will significantly weaken our forces across this region."

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		hostile_team.add_asset(/datum/campaign_asset/asset_disabler/tgmc_mortar/long)
	else if(hostile_faction == FACTION_SOM)
		hostile_team.add_asset(/datum/campaign_asset/asset_disabler/som_mortar/long)

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		hostile_team.add_asset(/datum/campaign_asset/asset_disabler/tgmc_mortar)
	else if(hostile_faction == FACTION_SOM)
		hostile_team.add_asset(/datum/campaign_asset/asset_disabler/som_mortar)

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		winning_team.add_asset(/datum/campaign_asset/bonus_job/combat_robots)
		winning_team.add_asset(/datum/campaign_asset/fire_support/mortar)
	else if(hostile_faction == FACTION_SOM)
		winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)
		winning_team.add_asset(/datum/campaign_asset/fire_support/som_mortar)

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		winning_team.add_asset(/datum/campaign_asset/bonus_job/combat_robots)
		winning_team.add_asset(/datum/campaign_asset/fire_support/mortar)
	else if(hostile_faction == FACTION_SOM)
		winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)
		winning_team.add_asset(/datum/campaign_asset/fire_support/som_mortar)

/datum/campaign_mission/destroy_mission/fire_support_raid/som
	mission_flags = MISSION_DISALLOW_TELEPORT
	mission_icon = "mortar_raid"
	map_name = "Patrick's Rest"
	map_file = '_maps/map_files/Campaign maps/patricks_rest/patricks_rest.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE)
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_light_levels = list(225, 150, 100, 75)
	objectives_total = 8
	min_destruction_amount = 6
	hostile_faction_additional_rewards = "Protect our fire support options to ensure continued access to mortar support. Combat robots and fire support is available if you successfully defend this outpost."
