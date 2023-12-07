//disabling SOM's ability to teleport deploy
/datum/campaign_mission/destroy_mission/teleporter_raid
	name = "Teleporter control raid"
	mission_icon = "teleporter_raid"
	map_name = "Lunar base BD-832"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_GRAVITY = 0.4) //moon gravity
	objectives_total = 1
	min_destruction_amount = 0
	objective_destruction_messages = list(
		"last" = list(
			MISSION_STARTING_FACTION = "Bluespace core destroyed, outstanding work marines!",
			MISSION_HOSTILE_FACTION = "Bluespace core destroyed, mission failed. All forces retreat!",
		),
	)
	starting_faction_objective_description = "Major Victory: Destroy the SOM Bluespace core at all costs"
	hostile_faction_objective_description = "Major Victory: Protect the Bluespace core at all costs"
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

	starting_faction_mission_brief = "Intelligence has pinpointed the SOM's Bluespace core on this remote lunar base. The core powers all SOM teleporter arrays in the system. \
		If we can destroy the core, we'll completely disable the SOM's ability to deploy forces into the field, crippling their mobility. \
		Move quickly and destroy the core at all costs, expect heavy resistance."
	hostile_faction_mission_brief = "Emergency scramble order received: TGMC forces detected enroute to lunar Bluespace core facility. \
		Protect the Bluespace core at all costs, without it all teleporter arrays in the system will be permanently disabled, severely restricting our mobility. \
		Eliminate all TGMC forces you encounter and secure the facility, or hold them off until further reinforcements can arrive."
	starting_faction_additional_rewards = "Permanently disable the SOM's ability to deploy via teleportation and impair their logistic network"
	hostile_faction_additional_rewards = "Additional use of the teleporter array will be granted if the Bluespace core can be protected"

/datum/campaign_mission/destroy_mission/teleporter_raid/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Locate and destroy the [hostile_faction] Bluespace core before further [hostile_faction] reinforcements can arrive. All other considerations are secondary. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect the Bluespace core at all costs! Eliminate all [starting_faction] forces and secure the base, reinforcements are enroute, hold them off until they arrive.",
	)
	. = ..()

/datum/campaign_mission/destroy_mission/teleporter_raid/load_objective_description()
	return

/datum/campaign_mission/destroy_mission/teleporter_raid/apply_major_victory()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[hostile_faction]
	som_team.add_asset(/datum/campaign_asset/teleporter_disabled)
	som_team.add_asset(/datum/campaign_asset/attrition_modifier/malus_teleporter)

/datum/campaign_mission/destroy_mission/teleporter_raid/apply_major_loss()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[hostile_faction]
	som_team.add_asset(/datum/campaign_asset/teleporter_enabled)
	som_team.add_asset(/datum/campaign_asset/teleporter_charges)
