//Loot capture mission
/datum/campaign_mission/capture_mission/phoron_capture
	name = "Phoron retrieval"
	mission_icon = "phoron_raid"
	map_name = "Jungle Outpost SR-422"
	map_file = '_maps/map_files/Campaign maps/jungle_outpost/jungle_outpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating", ZTRAIT_RAIN = TRUE)
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
	outro_message = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Major victory</u><br> How'd you manage to secure all of the phoron? Outstanding marines, drinks are on me!",
			MISSION_HOSTILE_FACTION = "<u>Major loss</u><br> How'd you let them capture ALL of the phoron? All forces, retreat, retreat!",
		),
		MISSION_OUTCOME_MINOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Minor victory</u><br> Confirming successful capture. This is gonna be a costly one for the SOM!",
			MISSION_HOSTILE_FACTION = "<u>Minor loss</u><br> Majority of phoron lost. This one's a failure, regroup marines.",
		),
		MISSION_OUTCOME_DRAW = list(
			MISSION_STARTING_FACTION = "<u>Draw</u><br> We made it costly for them, but not enough marines. All units, fallback.",
			MISSION_HOSTILE_FACTION = "<u>Draw</u><br> We've put a stop to those Terran thieves but it hasn't come cheap... All units, prepare for counter attack.",
		),
		MISSION_OUTCOME_MINOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Minor loss</u><br> Mission failed. We didn't get nearly enough phoron marines, fallback!",
			MISSION_HOSTILE_FACTION = "<u>Minor victory</u><br> Confirming phoron requirements met. They bit off more than they could chew, you've done Mars proud marines.",
		),
		MISSION_OUTCOME_MAJOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Major loss</u><br> What a disaster, were you marines asleep out there? All forces, pull back!",
			MISSION_HOSTILE_FACTION = "<u>Major victory</u><br> All phoron recovered. Outstanding work marines, that'll teach them to try steal from the SOM!",
		),
	)

/datum/campaign_mission/capture_mission/phoron_capture/get_mission_deploy_message(mob/living/user, text_source = "Overwatch", portrait_to_use = GLOB.faction_to_portrait[user.faction], message)
	if(message)
		return ..()
	switch(user.faction)
		if(FACTION_TERRAGOV)
			message = "We've caught the SOM with their pants down marines. Move in and secure all the phoron you can find!"
		if(FACTION_SOM)
			message = "TGMC fast movers are closing in! Secure all our phoron stores before those thieves can take it!"
	return ..()

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
