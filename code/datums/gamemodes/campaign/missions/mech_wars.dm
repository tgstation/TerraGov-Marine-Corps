//mech on mech violence
/datum/campaign_mission/tdm/mech_wars
	name = "Mech war"
	map_name = "Orion Outpost"
	map_file = '_maps/map_files/Campaign maps/jungle_test/jungle_outpost.dmm'
	starting_faction_objective_description = null
	hostile_faction_objective_description = null
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

	starting_faction_additional_rewards = "Mechanised units will be allocated to your battalion."
	hostile_faction_additional_rewards = "Mechanised units will be allocated to your battalion."

/datum/campaign_mission/tdm/mech_wars/play_start_intro()
	intro_message = list(
		"starting_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		"hostile_faction" = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
	)
	. = ..()

/datum/campaign_mission/tdm/mech_wars/load_mission_brief()
	. = ..()
	starting_faction_mission_brief = "[hostile_faction] mechanised forces have been identified staging in this region, in advance of a suspected strike against our lines. \
		A heavy mechanised force of our own has been authorised for deployment to crush their forces before they can strike. \
		Unleash the full power of our mechanised units and crush all enemy forces in the ao while preserving your own forces. Good hunting"
	hostile_faction_mission_brief = "A large [starting_faction] mechanised force has been detected enroute towards one of our staging points in this region. \
		Our mechanised forces here are vital to our future plans. The enemy assault has given us a unique opportunity to destroy a significant portion of their mechanised forces with a swift counter attack. \
		Eliminate all hostiles you come across while preserving your own forces. Good hunting."

/datum/campaign_mission/tdm/mech_wars/load_mission()
	. = ..()
	for(var/obj/effect/landmark/campaign/mech_spawner/spawner AS in GLOB.campaign_mech_spawners[starting_faction])
		spawner.spawn_mech()
	for(var/obj/effect/landmark/campaign/mech_spawner/spawner AS in GLOB.campaign_mech_spawners[hostile_faction])
		spawner.spawn_mech()

//todo: proper rewards
/datum/campaign_mission/tdm/mech_wars/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_reward(/datum/campaign_reward/equipment/mech_heavy)

/datum/campaign_mission/tdm/mech_wars/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_reward(/datum/campaign_reward/equipment/mech_heavy)

/datum/campaign_mission/tdm/mech_wars/apply_draw()
	winning_faction = hostile_faction

/datum/campaign_mission/tdm/mech_wars/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_reward(/datum/campaign_reward/equipment/mech_heavy)

/datum/campaign_mission/tdm/mech_wars/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_reward(/datum/campaign_reward/equipment/mech_heavy)

/obj/effect/landmark/campaign/mech_spawner
	name = "tgmc_mech_spawner"
	icon_state = "mech"
	var/faction = FACTION_TERRAGOV
	var/obj/vehicle/sealed/mecha/combat/greyscale/mech_type = /obj/vehicle/sealed/mecha/combat/greyscale/vanguard/noskill

/obj/effect/landmark/campaign/mech_spawner/Initialize(mapload)
	. = ..()
	GLOB.campaign_mech_spawners[faction] += list(src)

/obj/effect/landmark/campaign/mech_spawner/Destroy()
	GLOB.campaign_mech_spawners[faction] -= src
	return ..()

/obj/effect/landmark/campaign/mech_spawner/proc/spawn_mech()
	new mech_type(loc)

/obj/effect/landmark/campaign/mech_spawner/som
	name = "som_mech_spawner"
	faction = FACTION_SOM
