//Loot capture mission
/datum/campaign_mission/capture_mission/phoron_capture
	name = "Phoron retrieval"
	mission_icon = "phoron_raid"
	map_name = "Jungle outpost SR-422"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	mission_flags = MISSION_DISALLOW_DROPPODS|MISSION_DISALLOW_TELEPORT
	victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(3, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(1, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 1),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 3),
	)
	attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(10, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(5, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 10),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 15),
	)
	intro_message = list(
		MISSION_STARTING_FACTION = "Locate and extract all phoron crates in the AO before the enemy does.",
		MISSION_HOSTILE_FACTION = "Locate and extract all phoron crates in the AO before the enemy does.",
	)
	starting_faction_mission_brief = "Hostile forces have been building a stock pile of valuable phoron in this location. \
		Before they have the chance to ship it out, your forces are being sent to intercept and liberate these supplies to hamper the enemy's war effort. \
		Hostile forces will likely be aiming to evacuate as much phoron out of the AO as well. Get to the phoron first and fulton out as much as you can."
	hostile_faction_mission_brief = "Enemy forces are moving to steal a stockpile of valuable phoron that we are transporting for a local union. \
		Send in your forces to fulton out the phoron as quickly as possible, before they can get to it first."
	starting_faction_additional_rewards = "Additional supplies for every phoron crate captured, and freelancer support"
	hostile_faction_additional_rewards = "Additional supplies for every phoron crate captured and local support"
	objectives_total = 11
	min_capture_amount = 7

/datum/campaign_mission/capture_mission/phoron_capture/apply_major_victory()
	. = ..()
	var/datum/faction_stats/tgmc_team = mode.stat_list[starting_faction]
	tgmc_team.add_asset(/datum/campaign_asset/mech/light)
	tgmc_team.add_asset(/datum/campaign_asset/bonus_job/freelancer)

/datum/campaign_mission/capture_mission/phoron_capture/apply_minor_victory()
	. = ..()
	var/datum/faction_stats/tgmc_team = mode.stat_list[starting_faction]
	tgmc_team.add_asset(/datum/campaign_asset/bonus_job/freelancer)

/datum/campaign_mission/capture_mission/phoron_capture/apply_minor_loss()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[hostile_faction]
	som_team.add_asset(/datum/campaign_asset/attrition_modifier/local_approval)

/datum/campaign_mission/capture_mission/phoron_capture/apply_major_loss()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[hostile_faction]
	som_team.add_asset(/datum/campaign_asset/attrition_modifier/local_approval)
