//disabling some of the enemy's firesupport options
/datum/campaign_mission/destroy_mission/fire_support_raid
	name = "Fire support raid"
	map_name = "Lunar base BD-832"
	map_file = '_maps/map_files/Campaign maps/jungle_test/jungle_outpost.dmm'
	objectives_total = 5
	min_destruction_amount = 3
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

	starting_faction_additional_rewards = "Severely degrade enemy fire support options in the future"
	hostile_faction_additional_rewards = "Protect our fire support options so they can still be used in the future"

/datum/campaign_mission/destroy_mission/fire_support_raid/play_start_intro()
	intro_message = list(
		"starting_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Locate and destroy all [objectives_total] [hostile_faction] fire support installations before further [hostile_faction] reinforcements can arrive. Good hunting!",
		"hostile_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect all [objectives_total] fire support installations until reinforcements arrive. Eliminate all [starting_faction] forces and secure the area.",
	)
	return ..()

/datum/campaign_mission/destroy_mission/load_mission_brief()
	starting_faction_mission_brief = "A [hostile_faction] fire support position has been identified in this area. This key location provides fire support to [hostile_faction] forces across the region. \
		By destroying this outpost we can silence their guns and greatly weaken the enemy's forces. \
		Move quickly and destroy all fire support installations before they have time to react."
	hostile_faction_mission_brief = "[starting_faction] forces have been detected moving against our fire support installation in this area. \
		Repel the enemy and protect the installations until reinforcements can arrive. \
		Loss of these fire support installations will significantly weaken our forces across this region."

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_major_victory()
	. = ..()
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		hostile_team.add_reward(/datum/campaign_reward/reward_disabler/tgmc_mortar/long)
	else if(hostile_faction == FACTION_SOM)
		hostile_team.add_reward(/datum/campaign_reward/reward_disabler/som_mortar/long)

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_minor_victory()
	. = ..()
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		hostile_team.add_reward(/datum/campaign_reward/reward_disabler/tgmc_mortar)
	else if(hostile_faction == FACTION_SOM)
		hostile_team.add_reward(/datum/campaign_reward/reward_disabler/som_mortar)

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_minor_loss()
	. = ..()

/datum/campaign_mission/destroy_mission/fire_support_raid/apply_major_loss()
	. = ..()
