//mech on mech violence
/datum/campaign_mission/tdm/mech_wars
	name = "Combined Arms"
	mission_icon = "mech_war"
	map_name = "Patrick's Rest"
	map_file = '_maps/map_files/Campaign maps/patricks_rest/patricks_rest.dmm'
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating")
	map_light_levels = list(225, 150, 100, 75)
	map_armor_color = MAP_ARMOR_STYLE_JUNGLE
	starting_faction_objective_description = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose."
	hostile_faction_objective_description = "Major Victory: Wipe out all hostiles in the area of operation. Minor Victory: Eliminate more hostiles than you lose."
	mission_start_delay = 3 MINUTES //since there is actual mech prep time required
	capture_point_target = 400
	starting_faction_additional_rewards = "Mechanised units will be allocated to your battalion for use in future missions."
	hostile_faction_additional_rewards = "Mechanised units will be allocated to your battalion for use in future missions."
	outro_message = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Major victory</u><br> AO is secured. Enemy mechanised units all confirmed destroyed or falling back, excellent work!",
			MISSION_HOSTILE_FACTION = "<u>Major loss</u><br> We've lost control of this area, all units, regroup and retreat, we'll make them pay next time.",
		),
		MISSION_OUTCOME_MINOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Minor victory</u><br> Confirming hostile mechanised units have been degraded below combat ready status. We ground them down, good work.",
			MISSION_HOSTILE_FACTION = "<u>Minor loss</u><br> We've taken too many loses, all forces, pull back now!",
		),
		MISSION_OUTCOME_DRAW = list(
			MISSION_STARTING_FACTION = "<u>Draw</u><br> This was bloodbath on both sides. Any surviving units, retreat to nearest exfil point.",
			MISSION_HOSTILE_FACTION = "<u>Draw</u><br> What a bloodbath. We bled for it, but enemy assault repelled.",
		),
		MISSION_OUTCOME_MINOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Minor loss</u><br> We're losing to many mechs. All remaining units, regroup at point Echo, fallback!",
			MISSION_HOSTILE_FACTION = "<u>Minor victory</u><br> Confirming enemy forces are falling back. All units regroup and prepare to pursue!",
		),
		MISSION_OUTCOME_MAJOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Major loss</u><br> Control of AO lost, this is a disaster. All surviving units, retreat!",
			MISSION_HOSTILE_FACTION = "<u>Major victory</u><br> AO secured, enemy forces confirmed terminated or falling back. We've shown them who we are!",
		),
	)

/datum/campaign_mission/tdm/mech_wars/play_start_intro()
	intro_message = list(
		MISSION_STARTING_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [hostile_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
		MISSION_HOSTILE_FACTION = "[map_name]<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Eliminate all [starting_faction] resistance in the AO. Reinforcements are limited so preserve your forces as best you can. Good hunting!",
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

/datum/campaign_mission/tdm/mech_wars/get_mission_deploy_message(mob/living/user, text_source = "Overwatch", portrait_to_use = GLOB.faction_to_portrait[user.faction], message)
	if(message)
		return ..()
	switch(user.faction)
		if(FACTION_TERRAGOV)
			message = "Heavy mechanised hostile units closing on the AO! Smash their mechs into junk marines!"
		if(FACTION_SOM)
			message = "Terran mechanised units confirmed in the AO. Move in and wipe them out, for the glory of Mars!"
	return ..()

/datum/campaign_mission/tdm/mech_wars/load_pre_mission_bonuses()
	var/tanks_to_spawn = length(GLOB.clients) > 80 ? 3 : length(GLOB.clients) > 50 ? 2 : 1
	spawn_tank(starting_faction, tanks_to_spawn)
	spawn_tank(hostile_faction, tanks_to_spawn)

	var/mechs_to_spawn = floor(length(GLOB.clients) * 0.1) + 1
	var/heavy_spawn = floor(mechs_to_spawn / 6)
	var/med_spawn = floor(mechs_to_spawn / 4)
	var/light_spawn = mechs_to_spawn - heavy_spawn - med_spawn
	spawn_mech(starting_faction, heavy_spawn, med_spawn, light_spawn)
	spawn_mech(hostile_faction, heavy_spawn, med_spawn, light_spawn)

	for(var/faction in list(starting_faction, hostile_faction))
		for(var/i=1 to mechs_to_spawn + tanks_to_spawn)
			if(faction == FACTION_SOM)
				new /obj/item/storage/holster/backholster/rpg/som/heat(get_turf(pick(GLOB.campaign_reward_spawners[faction])))
			else
				new /obj/item/storage/holster/backholster/rpg/heam(get_turf(pick(GLOB.campaign_reward_spawners[faction])))

/datum/campaign_mission/tdm/mech_wars/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light)
	winning_team.add_asset(/datum/campaign_asset/mech)

/datum/campaign_mission/tdm/mech_wars/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light)

/datum/campaign_mission/tdm/mech_wars/apply_draw()
	winning_faction = hostile_faction

/datum/campaign_mission/tdm/mech_wars/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light/som)

/datum/campaign_mission/tdm/mech_wars/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light/som)
	winning_team.add_asset(/datum/campaign_asset/mech/som)

/datum/campaign_mission/tdm/mech_wars/remove_mission_object(obj/mission_obj)
	. = ..()
	if(outcome)
		return
	var/kill_reward = 0
	if(ismecha(mission_obj))
		kill_reward = 10
	if(isarmoredvehicle(mission_obj))
		kill_reward = 30
	if(!kill_reward)
		return
	var/obj/vehicle/sealed/obj_vehicle = mission_obj
	if(obj_vehicle.faction == hostile_faction)
		start_team_cap_points += kill_reward
	else if(obj_vehicle.faction == starting_faction)
		hostile_team_cap_points += kill_reward


/datum/campaign_mission/tdm/mech_wars/som
	map_name = "Big Red"
	map_file = '_maps/map_files/BigRed_v2/BigRed_v2.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating", ZTRAIT_SANDSTORM = TRUE)
	map_light_colours = list(COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED, COLOR_MISSION_RED)
	map_light_levels = list(225, 150, 100, 75)
	map_armor_color = MAP_ARMOR_STYLE_DESERT

/datum/campaign_mission/tdm/mech_wars/som/apply_major_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light/som)
	winning_team.add_asset(/datum/campaign_asset/mech/som)

/datum/campaign_mission/tdm/mech_wars/som/apply_minor_victory()
	winning_faction = starting_faction
	var/datum/faction_stats/winning_team = mode.stat_list[starting_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light/som)

/datum/campaign_mission/tdm/mech_wars/som/apply_minor_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light)

/datum/campaign_mission/tdm/mech_wars/som/apply_major_loss()
	winning_faction = hostile_faction
	var/datum/faction_stats/winning_team = mode.stat_list[hostile_faction]
	winning_team.add_asset(/datum/campaign_asset/mech/light)
	winning_team.add_asset(/datum/campaign_asset/mech)
