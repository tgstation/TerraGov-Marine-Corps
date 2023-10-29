//disabling an enemy logistics hub
/datum/campaign_mission/destroy_mission/supply_raid
	name = "Supply Depot raid"
	mission_icon = "supply_depot"
	mission_flags = MISSION_DISALLOW_DROPPODS
	map_name = "Rocinante base"
	map_file = '_maps/map_files/Campaign maps/som_base/sombase.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_SNOWSTORM = TRUE)
	map_light_colours = list(COLOR_MISSION_BLUE, COLOR_MISSION_BLUE, COLOR_MISSION_BLUE, COLOR_MISSION_BLUE)
	map_light_levels = list(225, 150, 100, 75)
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
		MISSION_OUTCOME_MAJOR_VICTORY = list(25, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(15, 0),
		MISSION_OUTCOME_DRAW = list(0, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 30),
	)
	starting_faction_additional_rewards = "Disrupt enemy supply routes, reducing enemy attrition generation for future missions."
	hostile_faction_additional_rewards = "Prevent the degradation of our attrition generation. Recon mech and gorgon armor available if you successfully protect this depot."

/datum/campaign_mission/destroy_mission/supply_raid/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Locate and destroy all [objectives_total] target objectives before further [hostile_faction] reinforcements can arrive. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect all [objectives_total] supply points until reinforcements arrive. Eliminate all [starting_faction] forces and secure the area.",
	)
	return ..()

/datum/campaign_mission/destroy_mission/supply_raid/load_mission_brief()
	starting_faction_mission_brief = "A [hostile_faction] supply depot has been identified in this area. This key location is a vital [hostile_faction] supply hub for their forces across the region. \
		The destruction of this depot will have a severe impact on their logistics, weakening their forces. \
		Move quickly and destroy all designated targets in the AO before they have time to react."
	hostile_faction_mission_brief = "[starting_faction] forces have been detected moving against our supply depot in this area. \
		Repel the enemy and protect the installation until reinforcements can arrive. \
		Loss of this depot will significantly degrade our logistical capabilities and weaken our forces going forwards."

/datum/campaign_mission/destroy_mission/supply_raid/load_pre_mission_bonuses()
	. = ..()
	spawn_mech(defending_faction, 0, 1)

/datum/campaign_mission/destroy_mission/supply_raid/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	hostile_team.add_asset(/datum/campaign_asset/attrition_modifier/malus_strong)

/datum/campaign_mission/destroy_mission/supply_raid/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	hostile_team.add_asset(/datum/campaign_asset/attrition_modifier/malus_standard)

/datum/campaign_mission/destroy_mission/supply_raid/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		winning_team.add_asset(/datum/campaign_asset/equipment/power_armor)
	else if(hostile_faction == FACTION_SOM)
		winning_team.add_asset(/obj/effect/landmark/campaign/mech_spawner/som/light)
		winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)

/datum/campaign_mission/destroy_mission/supply_raid/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	if(hostile_faction == FACTION_TERRAGOV)
		winning_team.add_asset(/datum/campaign_asset/equipment/power_armor)
	else if(hostile_faction == FACTION_SOM)
		winning_team.add_asset(/obj/effect/landmark/campaign/mech_spawner/som/light)
		winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)

/datum/campaign_mission/destroy_mission/supply_raid/som
	mission_flags = MISSION_DISALLOW_TELEPORT
	map_name = "Orion outpost"
	map_file = '_maps/map_files/Campaign maps/orion_2/orionoutpost_2.dmm'
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_traits = list(ZTRAIT_AWAY = TRUE)
	map_light_levels = list(225, 150, 100, 75)
	objectives_total = 8
	min_destruction_amount = 5
	hostile_faction_additional_rewards = "Prevent the degradation of our attrition generation. B18 power armour available if you successfully protect this depot."
