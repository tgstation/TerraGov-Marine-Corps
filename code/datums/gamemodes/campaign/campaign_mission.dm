/datum/campaign_mission
	///name of the mission
	var/name
	///UI icon for the mission
	var/mission_icon
	///map name for this mission
	var/map_name
	///path of map for this mission
	var/map_file
	///map_traits, defaults to ZTRAIT_AWAY
	var/list/map_traits = list(ZTRAIT_AWAY = TRUE, ZTRAIT_BASETURF = "/turf/open/floor/plating")
	///Lightings colours for the map. Typically all the same for consistancy, but not required
	var/list/map_light_colours = list(COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE)
	///Light levels for the map
	var/list/map_light_levels = list(200, 100, 75, 50)
	///Camo color associated with this map
	var/map_armor_color = MAP_ARMOR_STYLE_DEFAULT
	///The actual z-level the mission is played on
	var/datum/space_level/mission_z_level
	///Optional delay for each faction to be able to deploy, typically used in attacker/defender missions
	var/list/shutter_open_delay = list(
		MISSION_STARTING_FACTION = 0,
		MISSION_HOSTILE_FACTION = 0,
	)
	///Any mission behavior flags
	var/mission_flags = NONE
	///faction that chose the mission
	var/starting_faction
	///faction that did not choose the mission
	var/hostile_faction
	///current state of the mission
	var/mission_state = MISSION_STATE_NEW
	///winning faction of the mission
	var/winning_faction
	///specific mission outcome
	var/outcome
	///The current gamemode. Var as its referred to often
	var/datum/game_mode/hvh/campaign/mode
	///The victory conditions for this mission for the starting faction, for display purposes
	var/starting_faction_objective_description = "Loading mission objectives"
	///The victory conditions for this mission for the hostile faction, for display purposes
	var/hostile_faction_objective_description = "Loading mission objectives"
	///Detailed mission description for the starting faction
	var/starting_faction_mission_brief = "starting faction mission brief here"
	///Detailed mission description for the hostile faction
	var/hostile_faction_mission_brief = "hostile faction mission brief here"
	///Optional mission parameters for the starting faction. Some are autopopulated
	var/starting_faction_mission_parameters
	///Optional mission parameters for the hostile faction. Some are autopopulated
	var/hostile_faction_mission_parameters
	///Any additional rewards for the starting faction, for display purposes
	var/starting_faction_additional_rewards = "starting faction mission rewards here"
	///Any additional rewards for the hostile faction, for display purposes
	var/hostile_faction_additional_rewards = "hostile faction mission rewards here"
	///Victory point rewards for the mission type
	var/list/victory_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 0),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 0),
	)
	///attrition point rewards for the mission type
	var/list/attrition_point_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_MINOR_VICTORY = list(0, 0),
		MISSION_OUTCOME_DRAW = list(0, 0),
		MISSION_OUTCOME_MINOR_LOSS = list(0, 0),
		MISSION_OUTCOME_MAJOR_LOSS = list(0, 0),
	)
	///cash rewards for the mission type
	var/list/cash_rewards = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(700, 500),
		MISSION_OUTCOME_MINOR_VICTORY = list(600, 500),
		MISSION_OUTCOME_DRAW = list(500, 500),
		MISSION_OUTCOME_MINOR_LOSS = list(500, 600),
		MISSION_OUTCOME_MAJOR_LOSS = list(500, 700),
	)
	/// Timer used to calculate how long till mission ends
	var/game_timer
	/// Timer for when the mission starts
	var/start_timer
	///The length of time until mission ends, if timed
	var/max_game_time = 0
	///Whether the max game time has been reached
	var/max_time_reached = FALSE
	///Delay before the mission actually starts
	var/mission_start_delay = 1.5 MINUTES
	///Delay from shutter drop until game TIMER starts
	var/game_timer_delay = 1 MINUTES
	///Map text intro message for the start of the mission
	var/list/intro_message = list(
		MISSION_STARTING_FACTION = "starting faction intro text here",
		MISSION_HOSTILE_FACTION = "hostile faction intro text here",
	)
	///Message to players when a mission ends
	var/list/outro_message = list(
		MISSION_OUTCOME_MAJOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Major victory</u><br> All mission objectives achieved, outstanding work!",
			MISSION_HOSTILE_FACTION = "<u>Major loss</u><br> All surviving forces fallback, we'll get them next time.",
		),
		MISSION_OUTCOME_MINOR_VICTORY = list(
			MISSION_STARTING_FACTION = "<u>Minor victory</u><br> That's a successful operation team, nice work. Head back to base!",
			MISSION_HOSTILE_FACTION = "<u>Minor loss</u><br> Pull back all forces, we'll get them next time.",
		),
		MISSION_OUTCOME_DRAW = list(
			MISSION_STARTING_FACTION = "<u>Draw</u><br> Mission objectives not met, pull back and regroup.",
			MISSION_HOSTILE_FACTION = "<u>Draw</u><br> Enemy operation disrupted, they're getting nothing out of this one. Good work.",
		),
		MISSION_OUTCOME_MINOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Minor loss</u><br> All forces pull back, mission failure. We'll get them next time.",
			MISSION_HOSTILE_FACTION = "<u>Minor victory</u><br> Excellent work, the enemy operation is in disarray. Get ready for the next move.",
		),
		MISSION_OUTCOME_MAJOR_LOSS = list(
			MISSION_STARTING_FACTION = "<u>Major loss</u><br> All surviving forces retreat. The operation is a failure.",
			MISSION_HOSTILE_FACTION = "<u>Major victory</u><br> Enemy forces routed, outstanding work! Regroup and get ready to counter attack!",
		),
	)
	///Operation name for starting faction
	var/op_name_starting
	///Operation name for hostile faction
	var/op_name_hostile
	///Possible rewards for a major victory, used by Generate_rewards()
	var/list/major_victory_reward_table
	///Possible rewards for a minor victory, used by Generate_rewards()
	var/list/minor_victory_reward_table
	///Possible rewards for a minor loss, used by Generate_rewards()
	var/list/minor_loss_reward_table
	///Possible rewards for a major loss, used by Generate_rewards()
	var/list/major_loss_reward_table
	///Possible rewards for a draw, used by Generate_rewards()
	var/list/draw_reward_table

/datum/campaign_mission/New(initiating_faction)
	. = ..()

	mode = SSticker.mode
	if(!istype(mode))
		CRASH("campaign_mission loaded without campaign game mode")

	starting_faction = initiating_faction
	for(var/faction in mode.factions) //this is pretty clunky but eh
		if(faction == starting_faction)
			continue
		hostile_faction = faction

	op_name_starting = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	op_name_hostile = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()

	load_mission_brief() //late loaded so we can ref the specific factions etc
	set_loot_tables()

/datum/campaign_mission/Destroy(force, ...)
	STOP_PROCESSING(SSslowprocess, src)
	mission_z_level = null
	mode = null
	return ..()

/datum/campaign_mission/process()
	if(!check_mission_progress())
		return
	end_mission()
	return PROCESS_KILL

///Sets up the loot tables for this mission, if required
/datum/campaign_mission/proc/set_loot_tables()
	if(starting_faction == FACTION_TERRAGOV)
		major_victory_reward_table = GLOB.campaign_tgmc_major_loot
		minor_victory_reward_table = GLOB.campaign_tgmc_minor_loot
	else if(starting_faction == FACTION_SOM)
		major_victory_reward_table = GLOB.campaign_som_major_loot
		minor_victory_reward_table = GLOB.campaign_som_minor_loot

	if(hostile_faction == FACTION_TERRAGOV)
		minor_loss_reward_table = GLOB.campaign_tgmc_minor_loot
		major_loss_reward_table = GLOB.campaign_tgmc_major_loot
	else if(hostile_faction == FACTION_SOM)
		minor_loss_reward_table = GLOB.campaign_som_minor_loot
		major_loss_reward_table = GLOB.campaign_som_major_loot

///Sets up the mission once it has been selected
/datum/campaign_mission/proc/load_mission()
	play_selection_intro()
	load_map()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/campaign_mission, load_objective_description)), 5 SECONDS) //will be called before the map is entirely loaded otherwise, but this is cringe
	start_timer = addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/campaign_mission, start_mission)), mission_start_delay, TIMER_STOPPABLE)
	load_pre_mission_bonuses()
	RegisterSignals(SSdcs, list(COMSIG_GLOB_CAMPAIGN_TELEBLOCKER_DISABLED, COMSIG_GLOB_CAMPAIGN_DROPBLOCKER_DISABLED), PROC_REF(remove_mission_flag))

///Generates a new z level for the mission
/datum/campaign_mission/proc/load_map()
	mission_z_level = load_new_z_level(map_file, map_name, TRUE, map_traits)
	set_z_lighting(mission_z_level.z_value, map_light_colours[1], map_light_levels[1], map_light_colours[2], map_light_levels[2], map_light_colours[3], map_light_levels[3], map_light_colours[4], map_light_levels[4])
	mission_state = MISSION_STATE_LOADED
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_MISSION_LOADED, mission_z_level.z_value)

///Generates the mission brief for the mission if it needs to be late loaded
/datum/campaign_mission/proc/load_mission_brief()
	return

///Generates the objective description for the mission if it needs to be late loaded
/datum/campaign_mission/proc/load_objective_description()
	return

///Get a mission specific message for the deploying user if there is one
/datum/campaign_mission/proc/get_mission_deploy_message(mob/living/user, text_source = "Overwatch", portrait_to_use = GLOB.faction_to_portrait[user.faction], message)
	if(!message) //overridden by specific missions
		switch(user.faction)
			if(FACTION_TERRAGOV)
				message = "Stick together and achieve those objectives marines. Good luck."
			if(FACTION_SOM)
				message = "Remember your training marines, show those Terrans the strength of the SOM, glory to Mars!"
			else
				return

	user.playsound_local(user, "sound/effects/CIC_order.ogg", 10, 1)
	user.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING("<u>[text_source]</u>", message, LEFT_ALIGN_TEXT), portrait_to_use)

///Generates status tab info for the mission
/datum/campaign_mission/proc/get_status_tab_items(mob/source, list/items)
	items += "Mission: [name]"
	items += "Area of operation: [map_name]"
	items += ""

	if(max_time_reached)
		items += "Mission status: Mission complete"
		items += ""
	else
		items += "Mission time remaining: [mission_end_countdown()]"
		items += ""

	if(source.faction == starting_faction || source.faction == FACTION_NEUTRAL)
		items += "[starting_faction] mission objectives:"
		items += splittext(starting_faction_objective_description, ".")
		items += ""
	if(source.faction == hostile_faction || source.faction == FACTION_NEUTRAL)
		items += "[hostile_faction] mission objectives:"
		items += splittext(hostile_faction_objective_description, ".")
		items += ""

///Generates any mission specific assets/benefits for the two teams
/datum/campaign_mission/proc/load_pre_mission_bonuses()
	return

///Generates mission rewards, if there is variability involved
/datum/campaign_mission/proc/Generate_rewards(reward_amount = 1, faction)
	if(!faction)
		return

	var/reward_table
	switch(outcome)
		if(MISSION_OUTCOME_MAJOR_VICTORY)
			reward_table = major_victory_reward_table
		if(MISSION_OUTCOME_MINOR_VICTORY)
			reward_table = minor_victory_reward_table
		if(MISSION_OUTCOME_MINOR_LOSS)
			reward_table = minor_loss_reward_table
		if(MISSION_OUTCOME_MAJOR_LOSS)
			reward_table = major_loss_reward_table
		if(MISSION_OUTCOME_DRAW)
			reward_table = draw_reward_table

	if(!length(reward_table))
		return

	for(var/i = 1 to reward_amount)
		var/obj/reward = pickweight(reward_table)
		new reward(get_turf(pick(GLOB.campaign_reward_spawners[faction])))

///Checks mission end criteria, and ends the mission if met
/datum/campaign_mission/proc/check_mission_progress()
	return FALSE

///sets up the timer for the mission
/datum/campaign_mission/proc/set_mission_timer()
	if(game_timer)
		return
	game_timer = addtimer(VARSET_CALLBACK(src, max_time_reached, TRUE), max_game_time, TIMER_STOPPABLE)

///Pauses the gametimer, recording the remaining time left in max_game_time
/datum/campaign_mission/proc/pause_mission_timer(trait_source = TRAIT_GENERIC)
	if(!trait_source)
		trait_source = TRAIT_GENERIC
	ADD_TRAIT(src, CAMPAIGN_MISSION_TIMER_PAUSED, trait_source)
	if(!game_timer)
		return
	max_game_time = timeleft(game_timer)
	deltimer(game_timer)
	game_timer = null

///Attempts to resume the gametimer
/datum/campaign_mission/proc/resume_mission_timer(trait_source = TRAIT_GENERIC, forced = FALSE)
	REMOVE_TRAIT(src, CAMPAIGN_MISSION_TIMER_PAUSED, trait_source)
	if(!forced && HAS_TRAIT(src, CAMPAIGN_MISSION_TIMER_PAUSED))
		return
	set_mission_timer()

///accesses the timer for status panel
/datum/campaign_mission/proc/mission_end_countdown()
	//if(max_time_reached)
	//	return "Mission finished"
	if(!game_timer && HAS_TRAIT(src, CAMPAIGN_MISSION_TIMER_PAUSED))
		return "Timer paused"
	var/eta = game_timer ? (timeleft(game_timer) * 0.1) : (max_game_time * 0.1)
	if(eta > 0)
		return "[(eta / 60) % 60]:[add_leading(num2text(eta % 60), 2, "0")]"

///Mission start proper
/datum/campaign_mission/proc/start_mission()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(SSdcs, COMSIG_GLOB_CAMPAIGN_MISSION_STARTED)
	start_timer = null
	if(!shutter_open_delay[MISSION_STARTING_FACTION])
		SEND_GLOBAL_SIGNAL(GLOB.faction_to_campaign_door_signal[starting_faction])
	else
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(send_global_signal), GLOB.faction_to_campaign_door_signal[starting_faction]), shutter_open_delay[MISSION_STARTING_FACTION])

	if(!shutter_open_delay[MISSION_HOSTILE_FACTION])
		SEND_GLOBAL_SIGNAL(GLOB.faction_to_campaign_door_signal[hostile_faction])
	else
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(send_global_signal), GLOB.faction_to_campaign_door_signal[hostile_faction]), shutter_open_delay[MISSION_HOSTILE_FACTION])

	START_PROCESSING(SSslowprocess, src) //this may be excessive
	play_start_intro()

	if(max_game_time)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/campaign_mission, set_mission_timer)), game_timer_delay)

	mission_state = MISSION_STATE_ACTIVE

///Mission end wrap up
/datum/campaign_mission/proc/end_mission()
	SHOULD_CALL_PARENT(TRUE)
	unregister_mission_signals()
	QDEL_LIST(GLOB.campaign_objectives)
	QDEL_LIST(GLOB.campaign_structures)
	QDEL_LIST(GLOB.patrol_point_list) //purge all existing links, cutting off the current ground map. Start point links are auto severed, and will reconnect to new points when a new map is loaded and upon use.
	STOP_PROCESSING(SSslowprocess, src)

	SSweather.remove_eligible(mission_z_level.z_value)

	mission_state = MISSION_STATE_FINISHED
	apply_outcome()
	play_outro()
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_CAMPAIGN_MISSION_ENDED, src, winning_faction)
	for(var/mob/living/carbon/human/corpse AS in GLOB.dead_human_list) //clean up all the bodies and refund normal roles if required
		if(corpse.z != mission_z_level.z_value)
			continue
		if(!HAS_TRAIT(corpse, TRAIT_UNDEFIBBABLE) && corpse?.job?.job_cost)
			corpse.job.free_job_positions(1)
		qdel(corpse)

///Unregisters all signals when the mission finishes
/datum/campaign_mission/proc/unregister_mission_signals()
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(SSdcs, list(COMSIG_GLOB_CAMPAIGN_TELEBLOCKER_DISABLED, COMSIG_GLOB_CAMPAIGN_DROPBLOCKER_DISABLED))

///Intro when the mission is selected
/datum/campaign_mission/proc/play_selection_intro()
	send_ooc_announcement(
		sender_override = "Mission Starting",
		title = name,
		text = "Next mission is [name], selected by [starting_faction] on the battlefield of [map_name].",
		sound_override = 'sound/ambience/votestart.ogg',
		style = OOC_ALERT_GAME
	)

///Intro when the mission is started
/datum/campaign_mission/proc/play_start_intro()
	map_text_broadcast(starting_faction, intro_message[MISSION_STARTING_FACTION], op_name_starting)
	map_text_broadcast(hostile_faction, intro_message[MISSION_HOSTILE_FACTION], op_name_hostile)

///Outro when the mission is finished
/datum/campaign_mission/proc/play_outro()
	log_game("[outcome]\nMission: [name]")

	send_ooc_announcement(
		sender_override = "[name] Complete",
		title = "[starting_faction] [outcome]",
		text = "The engagement between [starting_faction] and [hostile_faction] on [map_name] has ended in a [starting_faction] [outcome]!",
		play_sound = FALSE,
		style = OOC_ALERT_GAME
	)

	map_text_broadcast(starting_faction, outro_message[outcome][MISSION_STARTING_FACTION], op_name_starting)
	map_text_broadcast(hostile_faction, outro_message[outcome][MISSION_HOSTILE_FACTION], op_name_hostile)

///Applies the correct outcome for the mission
/datum/campaign_mission/proc/apply_outcome()
	switch(outcome)
		if(MISSION_OUTCOME_MAJOR_VICTORY)
			apply_major_victory()
		if(MISSION_OUTCOME_MINOR_VICTORY)
			apply_minor_victory()
		if(MISSION_OUTCOME_DRAW)
			apply_draw()
		if(MISSION_OUTCOME_MINOR_LOSS)
			apply_minor_loss()
		if(MISSION_OUTCOME_MAJOR_LOSS)
			apply_major_loss()
		else
			CRASH("mission ended with no outcome set")

	modify_attrition_points(attrition_point_rewards[outcome][1], attrition_point_rewards[outcome][2])
	apply_victory_points(victory_point_rewards[outcome][1], victory_point_rewards[outcome][2])
	apply_cash_reward(cash_rewards[outcome][1], cash_rewards[outcome][2])

	//reset attrition points - unused points are lost
	mode.stat_list[starting_faction].active_attrition_points = 0
	mode.stat_list[hostile_faction].active_attrition_points = 0

///Apply outcomes for major win
/datum/campaign_mission/proc/apply_major_victory()
	winning_faction = starting_faction

///Apply outcomes for minor win
/datum/campaign_mission/proc/apply_minor_victory()
	winning_faction = starting_faction

///Apply outcomes for draw
/datum/campaign_mission/proc/apply_draw()
	winning_faction = hostile_faction

///Apply outcomes for minor loss
/datum/campaign_mission/proc/apply_minor_loss()
	winning_faction = hostile_faction

///Apply outcomes for major loss
/datum/campaign_mission/proc/apply_major_loss()
	winning_faction = hostile_faction

///gives any victory points earned in the mission
/datum/campaign_mission/proc/apply_victory_points(start_team_points, hostile_team_points)
	mode.stat_list[starting_faction].victory_points += start_team_points
	mode.stat_list[hostile_faction].victory_points += hostile_team_points

///Modifies a faction's attrition points
/datum/campaign_mission/proc/modify_attrition_points(start_team_points, hostile_team_points)
	mode.stat_list[starting_faction].total_attrition_points += start_team_points
	mode.stat_list[hostile_faction].total_attrition_points += hostile_team_points

///applies mission cash bonuses to both factions
/datum/campaign_mission/proc/apply_cash_reward(start_team_cash, hostile_team_cash)
	mode.stat_list[starting_faction].apply_cash(start_team_cash)
	mode.stat_list[hostile_faction].apply_cash(hostile_team_cash)

///checks how many marines and SOM are still alive
/datum/campaign_mission/proc/count_humans(list/z_levels = SSmapping.levels_by_trait(ZTRAIT_AWAY), count_flags) //todo: make new Z's not away levels, or ensure ground and away is consistant in behavior
	var/list/team_one_alive = list()
	var/list/team_one_dead = list()
	var/list/team_two_alive = list()
	var/list/team_two_dead = list()

	for(var/z in z_levels)
		//counts the live marines and SOM
		for(var/i in GLOB.humans_by_zlevel["[z]"])
			var/mob/living/carbon/human/H = i
			if(!istype(H))
				continue
			if(count_flags & COUNT_IGNORE_HUMAN_SSD && !H.client)
				continue
			if(H.faction == starting_faction)
				team_one_alive += H
			else //assumption here that there is only 2 teams
				team_two_alive += H
	//counts the dead marines and SOM
	for(var/i in GLOB.dead_human_list)
		var/mob/living/carbon/human/H = i
		if(!istype(H))
			continue
		if(H.faction == starting_faction)
			team_one_dead += H
		else
			team_two_dead += H

	return list(team_one_alive, team_two_alive, team_one_dead, team_two_dead)

///Sends a maptext message to a specified faction
/datum/campaign_mission/proc/map_text_broadcast(faction, message, title = "OVERWATCH", atom/movable/screen/text/screen_text/picture/display_picture, sound_effect = "sound/effects/CIC_order.ogg")
	if(!faction || !message)
		return
	if(!display_picture)
		display_picture = GLOB.faction_to_portrait[faction] ? GLOB.faction_to_portrait[faction] : /atom/movable/screen/text/screen_text/picture/potrait/unknown

	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction != faction)
			continue
		human.playsound_local(null, sound_effect, 10, 1)
		human.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(title, message, LEFT_ALIGN_TEXT), display_picture)

///Removes a flag or flags from this mission
/datum/campaign_mission/proc/remove_mission_flag(datum/source, blocker, removed_flags, losing_faction)
	SIGNAL_HANDLER
	if(mission_state != MISSION_STATE_ACTIVE)
		return
	mission_flags &= ~(removed_flags)

	if(removed_flags & MISSION_DISALLOW_TELEPORT)
		tele_blocker_disabled(blocker, losing_faction)
	if(removed_flags & MISSION_DISALLOW_DROPPODS)
		drop_blocker_disabled(blocker, losing_faction)


///Handles notification of a teleblocker being disabled
/datum/campaign_mission/proc/tele_blocker_disabled(datum/blocker, losing_faction)
	if(!istype(blocker) || !losing_faction)
		return
	var/destroying_team = starting_faction == losing_faction ? hostile_faction : starting_faction

	map_text_broadcast(destroying_team, "[blocker] destroyed, we can now deploy via teleporter!", "Teleporter unblocked")
	map_text_broadcast(losing_faction, "[blocker] destroyed, the enemy can now teleport at will!", "Teleporter unblocked")

///Handles notification of a dropblocker being disabled
/datum/campaign_mission/proc/drop_blocker_disabled(obj/blocker, losing_faction)
	if(!istype(blocker) || !losing_faction)
		return
	var/destroying_team = starting_faction == losing_faction ? hostile_faction : starting_faction

	map_text_broadcast(destroying_team, "[blocker] destroyed, we can now deploy via drop pod!", "Drop pods unblocked")
	map_text_broadcast(losing_faction, "[blocker] destroyed, the enemy can now drop pod at will!", "Drop pods unblocked")

///Removes the object from the campaign_structrures list if they are destroyed mid mission
/datum/campaign_mission/proc/remove_mission_object(obj/mission_obj)
	SIGNAL_HANDLER
	GLOB.campaign_structures -= mission_obj

///spawns mechs for a faction
/datum/campaign_mission/proc/spawn_mech(mech_faction, heavy_mech, medium_mech, light_mech, override_message)
	if(!mech_faction)
		return
	var/total_count = (heavy_mech + medium_mech + light_mech)
	if(!total_count)
		return
	for(var/obj/effect/landmark/campaign/vehicle_spawner/mech/mech_spawner AS in GLOB.campaign_mech_spawners[mech_faction])
		if(!heavy_mech && !medium_mech && !light_mech)
			break
		var/new_mech
		if(heavy_mech && (mech_spawner.type == GLOB.faction_to_mech_spawner[mech_faction]["heavy"]))
			heavy_mech --
		else if(medium_mech && (mech_spawner.type == GLOB.faction_to_mech_spawner[mech_faction]["medium"]))
			medium_mech --
		else if(light_mech && (mech_spawner.type == GLOB.faction_to_mech_spawner[mech_faction]["light"]))
			light_mech --
		else
			continue
		new_mech = mech_spawner.spawn_vehicle()
		GLOB.campaign_structures += new_mech
		RegisterSignal(new_mech, COMSIG_QDELETING, TYPE_PROC_REF(/datum/campaign_mission, remove_mission_object))

	map_text_broadcast(mech_faction, override_message ? override_message : "[total_count] mechs have been deployed for this mission.", "Mechs available")

///spawns mechs for a faction
/datum/campaign_mission/proc/spawn_tank(tank_faction, quantity, override_message)
	if(!tank_faction)
		return
	if(!quantity)
		return
	var/remaining_count = quantity
	for(var/obj/effect/landmark/campaign/vehicle_spawner/tank/tank_spawner AS in GLOB.campaign_tank_spawners[tank_faction])
		if(!remaining_count)
			break
		remaining_count --
		var/new_tank = tank_spawner.spawn_vehicle()
		GLOB.campaign_structures += new_tank
		RegisterSignal(new_tank, COMSIG_QDELETING, TYPE_PROC_REF(/datum/campaign_mission, remove_mission_object))

	map_text_broadcast(tank_faction, override_message ? override_message : "[quantity] mechs have been deployed for this mission.", "Mechs available")

///Returns the current mission, if its the campaign gamemode
/proc/get_current_mission()
	if(!iscampaigngamemode(SSticker.mode))
		return null
	var/datum/game_mode/hvh/campaign/mode = SSticker.mode
	return mode.current_mission
