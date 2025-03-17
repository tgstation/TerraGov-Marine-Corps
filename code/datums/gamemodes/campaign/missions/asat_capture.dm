//ASAT capture mission
/datum/campaign_mission/capture_mission/asat
	name = "ASAT capture"
	mission_icon = "asat_capture"
	map_name = "Lawanka Outpost"
	map_file = '_maps/map_files/Lawanka_Outpost/LawankaOutpost.dmm'
	map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating", ZTRAIT_RAIN = TRUE)
	map_light_colours = list(LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN, LIGHT_COLOR_PALE_GREEN)
	mission_flags = MISSION_DISALLOW_TELEPORT
	max_game_time = 9 MINUTES
	game_timer_delay = 90 SECONDS
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
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 10),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 15),
	)
	intro_message = list(
		MISSION_STARTING_FACTION = "Locate and recover all ASAT systems in the AO before the enemy has time to respond.",
		MISSION_HOSTILE_FACTION = "Protect all ASAT systems in the AO from the SOM attack.",
	)
	starting_faction_mission_brief = "A TGMC ASAT battery has been detected in this location. It forms part if their space defense grid across the planet and so is a valuable installation to them. \
		Although the destruction of this site is unlikely to weaken their space defenses appreciably, \
		the capture of these weapons would provide us with a unique opportunity to bypass parts of their own ship defenses. \
		Capture as many of the weapons as possible so we can put them to proper use."
	hostile_faction_mission_brief = "SOM forces are moving towards one our our ASAT installations in this location. \
		The loss of this installation would weaken our space defense grid which currently guarantees our orbital superiority. \
		Protect the ASAT weapons at all costs. Do not allow them to be destroyed or to fall into enemy hands."
	starting_faction_additional_rewards = "Additional ICC support, ability to counteract TGMC drop pod usage"
	hostile_faction_additional_rewards = "Preserve the ability to use drop pods uncontested"
	outro_message = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Major victory</u><br> All targets captured and Terrans in disarray. Pack it up, you've done Mars proud!",
			MISSION_HOSTILE_FACTION = "<u>Major loss</u><br> All objectives lost. All remaining forces pull back, we'll get them next time.",
		),
		MISSION_OUTCOME_MINOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Minor victory</u><br> Objectives achieved. Nice work Martians, head to exfil.",
			MISSION_HOSTILE_FACTION = "<u>Minor loss</u><br> Pull back all forces, we'll get them next time.",
		),
		MISSION_OUTCOME_MINOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Minor loss</u><br> Insufficient targts captured. All forces pull back, we'll get them next time.",
			MISSION_HOSTILE_FACTION = "<u>Minor victory</u><br> Excellent work marines, we held them off. Regroup and prepare for the counter attack!",
		),
		MISSION_OUTCOME_MAJOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Major loss</u><br> Damn it, all surviving forces retreat. The operation is a failure.",
			MISSION_HOSTILE_FACTION = "<u>Major victory</u><br> Enemy forces routed, outstanding work! The SOM came to the wrong neighbourhood today marines!",
		),
	)

	objectives_total = 6
	min_capture_amount = 5

/datum/campaign_mission/capture_mission/asat/load_pre_mission_bonuses()
	. = ..()
	var/datum/faction_stats/attacking_team = mode.stat_list[starting_faction]
	attacking_team.add_asset(/datum/campaign_asset/asset_disabler/som_cas/instant)

	var/tanks_to_spawn = 0
	var/mechs_to_spawn = 0
	var/current_pop = length(GLOB.clients)
	switch(current_pop)
		if(0 to 59)
			tanks_to_spawn = 0
		if(60 to 75)
			tanks_to_spawn = 1
		if(76 to 90)
			tanks_to_spawn = 2
		else
			tanks_to_spawn = 3

	switch(current_pop)
		if(0 to 39)
			mechs_to_spawn = 0
		if(40 to 49)
			mechs_to_spawn = 2
		if(50 to 79)
			mechs_to_spawn = 3
		else
			mechs_to_spawn = 4

	spawn_tank(starting_faction, tanks_to_spawn)
	spawn_tank(hostile_faction, tanks_to_spawn)
	spawn_mech(hostile_faction, 0, 0, mechs_to_spawn)
	spawn_mech(starting_faction, 0, 0, max(0, mechs_to_spawn - 1))

/datum/campaign_mission/capture_mission/asat/load_objective_description()
	starting_faction_objective_description = "Major Victory:Capture all [objectives_total] ASAT systems.[min_capture_amount ? " Minor Victory: Capture at least [min_capture_amount] ASAT systems." : ""]"
	hostile_faction_objective_description = "Major Victory:Prevent the capture of all [objectives_total] ASAT systems.[min_capture_amount ? " Minor Victory: Prevent the capture of atleast [objectives_total - min_capture_amount + 1] ASAT systems." : ""]"

/datum/campaign_mission/capture_mission/asat/get_mission_deploy_message(mob/living/user, text_source = "Overwatch", portrait_to_use = GLOB.faction_to_portrait[user.faction], message)
	switch(user.faction)
		if(FACTION_TERRAGOV)
			message = "Protect our ASAT systems at all cost! Deactivate any the SOM try and steal."
		if(FACTION_SOM)
			message = "Move fast marines. Capture every ASAT system you can, and we'll give the Terrans a taste of their own medicine!"
	return ..()

/datum/campaign_mission/capture_mission/asat/check_mission_progress()
	if(outcome)
		return TRUE

	if(!game_timer)
		return FALSE

	if(!max_time_reached && objectives_remaining)
		return FALSE

	if(capture_count[MISSION_STARTING_FACTION] >= objectives_total)
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_VICTORY]")
		outcome = MISSION_OUTCOME_MAJOR_VICTORY
	else if(min_capture_amount && (capture_count[MISSION_STARTING_FACTION] >= min_capture_amount))
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_VICTORY]")
		outcome = MISSION_OUTCOME_MINOR_VICTORY
	else if(capture_count[MISSION_STARTING_FACTION] > 0)
		message_admins("Mission finished: [MISSION_OUTCOME_MINOR_LOSS]")
		outcome = MISSION_OUTCOME_MINOR_LOSS
	else
		message_admins("Mission finished: [MISSION_OUTCOME_MAJOR_LOSS]")
		outcome = MISSION_OUTCOME_MAJOR_LOSS
	return TRUE

/datum/campaign_mission/capture_mission/asat/apply_major_victory()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[starting_faction]
	som_team.add_asset(/datum/campaign_asset/droppod_disable)
	som_team.add_asset(/datum/campaign_asset/bonus_job/icc)
	som_team.add_asset(/datum/campaign_asset/bonus_job/icc)

/datum/campaign_mission/capture_mission/asat/apply_minor_victory()
	. = ..()
	var/datum/faction_stats/som_team = mode.stat_list[starting_faction]
	som_team.add_asset(/datum/campaign_asset/droppod_disable)
	som_team.add_asset(/datum/campaign_asset/bonus_job/icc)

/datum/campaign_mission/capture_mission/asat/apply_minor_loss()
	. = ..()
	var/datum/faction_stats/tgmc_team = mode.stat_list[hostile_faction]
	tgmc_team.add_asset(/datum/campaign_asset/equipment/power_armor)

/datum/campaign_mission/capture_mission/asat/apply_major_loss()
	. = ..()
	var/datum/faction_stats/tgmc_team = mode.stat_list[hostile_faction]
	tgmc_team.add_asset(/datum/campaign_asset/equipment/power_armor)

/datum/campaign_mission/capture_mission/asat/objective_reward_bonus()
	return
