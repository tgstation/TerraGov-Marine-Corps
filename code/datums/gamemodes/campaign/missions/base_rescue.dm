//disabling some of the enemy's firesupport options
/datum/campaign_mission/destroy_mission/base_rescue
	name = "NT base rescue"
	mission_icon = "nt_rescue"
	mission_flags = MISSION_DISALLOW_TELEPORT
	map_name = "Jungle outpost SR-422"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	objectives_total = 1
	min_destruction_amount = 1
	shutter_open_delay = list(
		MISSION_STARTING_FACTION = 60 SECONDS,
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
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 25),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 30),
	)
	objective_destruction_messages = list(
		"last" = list(
			MISSION_ATTACKING_FACTION = "Objective destroyed, outstanding work!",
			MISSION_DEFENDING_FACTION = "Objective destroyed, fallback, fallback!",
		),
	)

	starting_faction_additional_rewards = "NanoTrasen has offered a level of corporate assistance if their facility can be protected."
	hostile_faction_additional_rewards = "Improved relations with local militias will allow us to call on their assistance in the future."

/datum/campaign_mission/destroy_mission/base_rescue/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Protect all the NT base from SOM aggression until reinforcements arrive. Eliminate all SOM forces and prevent them from overriding the security lockdown and raiding the facility.",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "The NT facility is on lockdown. Find a way to override the lockdown, then penetrate the facility and destroy whatever you find inside.",
	)
	return ..()

/datum/campaign_mission/destroy_mission/base_rescue/load_pre_mission_bonuses()
	. = ..()
	for(var/i = 1 to objectives_total)
		new /obj/item/storage/box/explosive_mines(get_turf(pick(GLOB.campaign_reward_spawners[defending_faction])))

/datum/campaign_mission/destroy_mission/base_rescue/load_mission_brief()
	starting_faction_mission_brief = "NanoTrasen has issues an emergency request for assistance at an isolated medical facility located in the Western Ayolan Ranges. \
		SOM forces are rapidly approaching the facility, which is currently on emergency lockdown. \
		Move quickly prevent the SOM from lifting the lockdown and destroying the facility."
	hostile_faction_mission_brief = "Recon forces have led us to this secure Nanotrasen facility in the Western Ayolan Ranges. Sympathetic native elements suggest NT have been conducting secret research here to the detriment of the local ecosystem and human settlements. \
		Find the security override terminals to override the facility's emergency lockdown. \
		Once the lockdown is lifted, destroy what they're working on inside."

/datum/campaign_mission/destroy_mission/base_rescue/apply_major_victory()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
		winning_team.add_asset(/datum/campaign_asset/bonus_job/pmc)
		winning_team.add_asset(/datum/campaign_asset/attrition_modifier/corporate_approval)

/datum/campaign_mission/destroy_mission/base_rescue/apply_minor_victory()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
		winning_team.add_asset(/datum/campaign_asset/bonus_job/pmc)

/datum/campaign_mission/destroy_mission/base_rescue/apply_minor_loss()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
		winning_team.add_asset(/datum/campaign_asset/bonus_job/colonial_militia)

/datum/campaign_mission/destroy_mission/base_rescue/apply_major_loss()
	. = ..()
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
		winning_team.add_asset(/datum/campaign_asset/bonus_job/colonial_militia)
		winning_team.add_asset(/datum/campaign_asset/attrition_modifier/local_approval)
