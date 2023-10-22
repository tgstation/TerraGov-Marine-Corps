//disabling an enemy logistics hub
/datum/campaign_mission/destroy_mission/airbase
	name = "Airbase assault"
	mission_icon = "cas_raid"
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
		MISSION_OUTCOME_MAJOR_VICTORY = list(15, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_DRAW = list(0, 10),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 15),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 25),
	)
	starting_faction_additional_rewards = "Disrupt enemy air support for a moderate period of time."
	hostile_faction_additional_rewards = "Ensure continued access to close air support. Recon mech and gorgon armor available if you successfully protect this depot."
	///The mech spawner type to create a mech for the defending team
	var/mech_type = /obj/effect/landmark/campaign/mech_spawner/som

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
	spawn_mech(defending_faction, 0, 1, 2)
	spawn_mech(attacking_faction, 1, 1)

/datum/campaign_mission/destroy_mission/airbase/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	hostile_team.add_asset(/datum/campaign_asset/asset_disabler/som_cas)

/datum/campaign_mission/destroy_mission/airbase/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/hostile_team = mode.stat_list[hostile_faction]
	hostile_team.add_asset(/datum/campaign_asset/asset_disabler/som_cas)

/datum/campaign_mission/destroy_mission/airbase/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/obj/effect/landmark/campaign/mech_spawner/som/light)
	winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)

/datum/campaign_mission/destroy_mission/airbase/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/obj/effect/landmark/campaign/mech_spawner/som/light)
	winning_team.add_asset(/datum/campaign_asset/equipment/gorgon_armor)

/datum/campaign_mission/destroy_mission/airbase/som
	mission_flags = MISSION_DISALLOW_TELEPORT
	map_name = "Orion outpost"
	map_file = '_maps/map_files/Campaign maps/orion_2/orionoutpost_2.dmm'
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_traits = list(ZTRAIT_AWAY = TRUE)
	map_light_levels = list(225, 150, 100, 75)
	objectives_total = 8
	min_destruction_amount = 5
	mech_type = /obj/effect/landmark/campaign/mech_spawner
	hostile_faction_additional_rewards = "Ensure continued access to close air support. B18 power armour available if you successfully protect this depot."
