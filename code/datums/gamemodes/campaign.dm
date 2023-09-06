#define CAMPAIGN_MAX_VICTORY_POINTS 12

/datum/game_mode/hvh/campaign
	name = "Campaign"
	config_tag = "Campaign"
	flags_round_type = MODE_TWO_HUMAN_FACTIONS|MODE_HUMAN_ONLY //any changes needed? MODE_LATE_OPENING_SHUTTER_TIMER handled by missions
	shutters_drop_time = 2 MINUTES //will need changing
	whitelist_ship_maps = list(MAP_ITERON)
	whitelist_ground_maps = list(MAP_FORT_PHOBOS)
	bioscan_interval = 3 MINUTES
	valid_job_types = list(
		/datum/job/terragov/command/fieldcommander = 1,
		/datum/job/terragov/squad/engineer = 4,
		/datum/job/terragov/squad/corpsman = 8,
		/datum/job/terragov/squad/smartgunner = 4,
		/datum/job/terragov/squad/leader = 4,
		/datum/job/terragov/squad/standard = -1,
		/datum/job/som/command/fieldcommander = 1,
		/datum/job/som/squad/leader = 4,
		/datum/job/som/squad/veteran = 2,
		/datum/job/som/squad/engineer = 4,
		/datum/job/som/squad/medic = 8,
		/datum/job/som/squad/standard = -1,
	)
	///The current mission type being played
	var/datum/campaign_mission/current_mission
	///campaign stats organised by faction
	var/list/datum/faction_stats/stat_list = list()

/datum/game_mode/hvh/campaign/announce()
	to_chat(world, "<b>The current game mode is - Campaign!</b>")
	to_chat(world, "<b>The TGMC and SOM both lay claim to this planet. Across contested areas, small combat patrols frequently clash in their bid to enforce their respective claims. Seek and destroy any hostiles you encounter, good hunting!</b>")
	to_chat(world, "<b>WIP, report bugs on the github!</b>")

/datum/game_mode/hvh/campaign/pre_setup()
	. = ..()
	for(var/faction in factions)
		stat_list[faction] = new /datum/faction_stats(faction)

/datum/game_mode/hvh/campaign/post_setup()
	. = ..()
	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list) //som 'ship' map is now ground, but this ensures we clean up exit points if this changes in the future
		qdel(exit_point)
	load_new_mission(new /datum/campaign_mission/capture_mission(factions[1])) //this is the 'roundstart' mission

	for(var/i in stat_list)
		var/datum/faction_stats/selected_faction = stat_list[i]
		selected_faction.choose_faction_leader()

/datum/game_mode/hvh/campaign/setup_blockers() //to be updated
	. = ..()
	addtimer(CALLBACK(SSticker.mode, TYPE_PROC_REF(/datum/game_mode/hvh/campaign, intro_sequence)), SSticker.round_start_time + shutters_drop_time) //starts intro sequence 10 seconds before shutter drop

/datum/game_mode/hvh/campaign/player_respawn(mob/respawnee)
	attempt_attrition_respawn(respawnee)

/datum/game_mode/hvh/campaign/intro_sequence() //update this, new fluff message etc etc, make it faction generic
	var/op_name_tgmc = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	var/op_name_som = GLOB.operation_namepool[/datum/operation_namepool].get_random_name()
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == factions[1])
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_tgmc]</u></span><br>" + "campaign intro here<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Territorial Defense Force Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/tdf)
		else if(human.faction == factions[2]) //assuming only 2 factions
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:left valign='top'><u>[op_name_som]</u></span><br>" + "campaign intro here<br>" + "[GAME_YEAR]-[time2text(world.realtime, "MM-DD")] [stationTimestamp("hh:mm")]<br>" + "Shokk Infantry Platoon<br>" + "[human.job.title], [human]<br>", /atom/movable/screen/text/screen_text/picture/shokk)

/datum/game_mode/hvh/campaign/process()
	if(round_finished)
		return PROCESS_KILL

	if(!istype(current_mission))  //runtimes as process happens before post_setup, probably need a better method
		return
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_BIOSCAN) || bioscan_interval == 0 || current_mission.mission_state != MISSION_STATE_ACTIVE)
		return
	announce_bioscans_marine_som() //todo: make this faction neutral

//End game checks
/datum/game_mode/hvh/campaign/check_finished(game_status) //todo: add the actual logic once the persistance stuff is done
	if(round_finished)
		message_admins("check_finished called when game already over")
		return TRUE

	//placeholder/fall back win condition
	for(var/faction in factions)
		if(stat_list[faction].victory_points >= CAMPAIGN_MAX_VICTORY_POINTS)
			switch(faction)
				if(FACTION_SOM)
					round_finished = MODE_COMBAT_PATROL_SOM_MINOR
				if(FACTION_TERRAGOV)
					round_finished = MODE_COMBAT_PATROL_MARINE_MINOR
			message_admins("Round finished: [round_finished]")
			return TRUE

/datum/game_mode/hvh/campaign/declare_completion() //todo: update fluff message
	. = ..()
	to_chat(world, span_round_header("|[round_finished]|"))
	log_game("[round_finished]\nGame mode: [name]\nRound time: [duration2text()]\nEnd round player population: [length(GLOB.clients)]\nTotal TGMC spawned: [GLOB.round_statistics.total_humans_created[FACTION_TERRAGOV]]\nTotal SOM spawned: [GLOB.round_statistics.total_humans_created[FACTION_SOM]]")
	to_chat(world, span_round_body("Thus ends the story of the brave men and women of both the TGMC and SOM, and their struggle on [SSmapping.configs[GROUND_MAP].map_name]."))

///selects the next mission to be played
/datum/game_mode/hvh/campaign/proc/select_next_mission(mob/selector) //basic placeholder
	var/list/mission_choices = list()
	for(var/datum/campaign_mission/mission_option AS in stat_list[selector.faction].potential_missions)
		mission_choices[mission_option] = mission_option.name
	var/choice = tgui_input_list(selector, "What course of action would you like to take?", "Mission selection", mission_choices, timeout = 2 MINUTES)
	if(!choice)
		choice = pick(mission_choices) //placeholder pick

	//probably have some time limit on the choice, so need some logic for that
	load_new_mission(choice)

	select_attrition_points() //both teams choose the number of lads to commit

/datum/game_mode/hvh/campaign/get_status_tab_items(datum/dcs, mob/source, list/items)
	. = ..()
	if(!istype(current_mission))
		return

	items += "Mission: [current_mission.name]"
	items += "Area of operation: [current_mission.map_name]"

	if(current_mission.max_time_reached)
		items += "Mission status: Mission complete"
	else if(current_mission.game_timer)
		items += "Mission time remaining: [current_mission.mission_end_countdown()]"

	if(source.faction == current_mission.starting_faction)
		items += "[current_mission.starting_faction] mission objectives: [current_mission.objective_description["starting_faction"]]"
	else if(source.faction == current_mission.hostile_faction)
		items += "[current_mission.hostile_faction] mission objectives: [current_mission.objective_description["hostile_faction"]]"
	else if(source.faction == FACTION_NEUTRAL)
		items += "[current_mission.starting_faction] Mission objectives:> [current_mission.objective_description["starting_faction"]]"
		items += "[current_mission.hostile_faction] Mission objectives: [current_mission.objective_description["hostile_faction"]]"

///sets up the newly selected mission
/datum/game_mode/hvh/campaign/proc/load_new_mission(datum/campaign_mission/new_mission)
	current_mission = new_mission
	current_mission.load_mission()
	TIMER_COOLDOWN_START(src, COOLDOWN_BIOSCAN, bioscan_interval)

///each faction chooses how many attrition points to use for the upcoming mission - PLACEHOLDER UNTIL INTERFACE
/datum/game_mode/hvh/campaign/proc/select_attrition_points() //placeholder basic
	for(var/i in stat_list) //note to self: does the input mean this gets delayed for one team until the other chooses?
		var/datum/faction_stats/team = stat_list[i]
		var/choice = tgui_input_number(team.get_selector(), "How much manpower would you like to dedicate to this mission?", "Attrition Point selection", 0, team.total_attrition_points, 0, 60 SECONDS)
		if(!choice)
			choice = 0
		team.total_attrition_points -= choice
		team.active_attrition_points = choice //unused points are lost

///ends the current mission and cleans up
/datum/game_mode/hvh/campaign/proc/end_current_mission()
	if(check_finished()) //check if the game should end
		return
	send_global_signal(COMSIG_GLOB_CLOSE_CAMPAIGN_SHUTTERS)

	for(var/faction in factions)
		stat_list[faction].total_attrition_points += round(length(GLOB.clients) * 0.5 * stat_list[faction].attrition_gain_multiplier)
		for(var/mob/living/carbon/human/human_mob AS in GLOB.alive_human_list_faction[faction]) //forcemove everyone by faction back to their spawn points, to clear out the z-level
			human_mob.revive(TRUE)
			human_mob.forceMove(pick(GLOB.spawns_by_job[human_mob.job.type]))

	for(var/obj/effect/landmark/patrol_point/exit_point AS in GLOB.patrol_point_list)
		qdel(exit_point) //purge all existing links, cutting off the current ground map. Start point links are auto severed, and will reconnect to new points when a new map is loaded and upon use.

	//add a delay probably
	select_next_mission(stat_list[current_mission.winning_faction].get_selector()) //winning team chooses new mission

///////////////////////////respawn stuff/////////

///respawns the player if attrition points are available
/datum/game_mode/hvh/campaign/proc/attempt_attrition_respawn(mob/candidate)
	if(!candidate?.client)
		return

	if(!(candidate.faction in factions))
		return candidate.respawn()

	var/list/dat = list("<div class='notice'>Mission Duration: [DisplayTimeText(world.time - SSticker.round_start_time)]</div>")
	if(!GLOB.enter_allowed)
		dat += "<div class='notice red'>You may no longer join the mission.</div><br>"
	var/forced_faction
	if(candidate.faction in SSticker.mode.get_joinable_factions(FALSE))
		forced_faction = candidate.faction
	else
		forced_faction = tgui_input_list(candidate, "What faction do you want to join", "Faction choice", SSticker.mode.get_joinable_factions(TRUE))
		if(!forced_faction)
			return
	dat += "<div class='latejoin-container' style='width: 100%'>"
	for(var/cat in SSjob.active_joinable_occupations_by_category)
		var/list/category = SSjob.active_joinable_occupations_by_category[cat]
		var/datum/job/job_datum = category[1] //use the color of the first job in the category (the department head) as the category color
		dat += "<fieldset class='latejoin' style='border-color: [job_datum.selection_color]'>"
		dat += "<legend align='center' style='color: [job_datum.selection_color]'>[job_datum.job_category]</legend>"
		var/list/dept_dat = list()
		for(var/job in category)
			job_datum = job
			if(!IsJobAvailable(candidate, job_datum, forced_faction))
				continue
			var/command_bold = ""
			if(job_datum.job_flags & JOB_FLAG_BOLD_NAME_ON_SELECTION)
				command_bold = " command"
			var/position_amount
			if(job_datum.job_flags & JOB_FLAG_HIDE_CURRENT_POSITIONS)
				position_amount = "?"
			else if(job_datum.job_flags & JOB_FLAG_SHOW_OPEN_POSITIONS)
				position_amount = "[job_datum.total_positions - job_datum.current_positions] open positions"
			else
				position_amount = job_datum.current_positions
			dept_dat += "<a class='job[command_bold]' href='byond://?src=[REF(src)];campaign_choice=SelectedJob;player=[REF(candidate)];job_selected=[REF(job_datum)]'>[job_datum.title] ([position_amount])</a>"
		if(!length(dept_dat))
			dept_dat += span_nopositions("No positions open.")
		dat += jointext(dept_dat, "")
		dat += "</fieldset><br>"
	dat += "</div>"
	var/datum/browser/popup = new(candidate, "latechoices", "Choose Occupation", 680, 580)
	popup.add_stylesheet("latechoices", 'html/browser/latechoices.css')
	popup.set_content(jointext(dat, ""))
	popup.open(FALSE)

/datum/game_mode/hvh/campaign/Topic(href, href_list[])
	switch(href_list["campaign_choice"])
		if("SelectedJob")
			if(!SSticker)
				return
			var/mob/candidate = locate(href_list["player"])
			if(!candidate.client)
				return

			if(!GLOB.enter_allowed)
				to_chat(candidate, span_warning("Spawning currently disabled, please observe."))
				return

			var/mob/new_player/ready_candidate = new()
			candidate.client.screen.Cut()
			ready_candidate.name = candidate.key
			ready_candidate.key = candidate.key

			var/datum/job/job_datum = locate(href_list["job_selected"])

			if(attrition_respawn(ready_candidate, job_datum))
				if(isobserver(candidate))
					qdel(candidate)
				return

			ready_candidate.client.screen.Cut()
			candidate.name = ready_candidate.key
			candidate.key = ready_candidate.key

///Actually respawns the player, if still able
/datum/game_mode/hvh/campaign/proc/attrition_respawn(mob/new_player/ready_candidate, datum/job/job_datum)
	if(!ready_candidate.IsJobAvailable(job_datum, TRUE))
		to_chat(usr, "<span class='warning'>Selected job is not available.<spawn>")
		return
	if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
		to_chat(usr, "<span class='warning'>The mission is either not ready, or has already finished!<spawn>")
		return
	if(!GLOB.enter_allowed)
		to_chat(usr, "<span class='warning'>Spawning currently disabled, please observe.<spawn>")
		return
	if(!ready_candidate.client.prefs.random_name)
		var/name_to_check = ready_candidate.client.prefs.real_name
		if(job_datum.job_flags & JOB_FLAG_SPECIALNAME)
			name_to_check = job_datum.get_special_name(ready_candidate.client)
		if(CONFIG_GET(flag/prevent_dupe_names) && GLOB.real_names_joined.Find(name_to_check))
			to_chat(usr, "<span class='warning'>Someone has already joined the mission with this character name. Please pick another.<spawn>")
			return
	if(!SSjob.AssignRole(ready_candidate, job_datum, TRUE))
		to_chat(usr, "<span class='warning'>Failed to assign selected role.<spawn>")
		return

	stat_list[job_datum.faction].active_attrition_points -= job_datum.job_cost
	LateSpawn(ready_candidate)
	return TRUE

///A (probably) placeholder proc to check which jobs are valid, to add to the job selector menu
/datum/game_mode/hvh/campaign/proc/IsJobAvailable(mob/candidate, datum/job/job, faction)
	if(!job)
		return FALSE
	if(job.faction != faction)
		return FALSE
	if((job.current_positions >= job.total_positions) && job.total_positions != -1)
		return FALSE
	if(job.job_cost > stat_list[faction].active_attrition_points)
		return FALSE
	if(is_banned_from(candidate.ckey, job.title))
		return FALSE
	if(QDELETED(candidate))
		return FALSE
	if(!job.player_old_enough(candidate.client))
		return FALSE
	if(job.required_playtime_remaining(candidate.client))
		return FALSE
	if(!job.special_check_latejoin(candidate.client))
		return FALSE
	return TRUE


//////////////////tgui stuff/////////////////

/obj/machinery/tgui_test
	name = "placeholder"
	desc = "placeholder"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "specialist"
	density = TRUE
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	req_access = null
	req_one_access = null
	interaction_flags = INTERACT_MACHINE_TGUI
	///The faction of this quick load vendor
	var/faction = FACTION_TERRAGOV

/obj/machinery/tgui_test/som
	faction = FACTION_SOM

/obj/machinery/tgui_test/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!ishuman(user))
		return FALSE

	var/mob/living/carbon/human/human_user = user
	if(!allowed(human_user))
		return FALSE

	if(!isidcard(human_user.get_idcard())) //not wearing an ID
		return FALSE

	var/obj/item/card/id/user_id = human_user.get_idcard()
	if(user_id.registered_name != human_user.real_name)
		return FALSE
	return TRUE

/obj/machinery/tgui_test/ui_interact(mob/living/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "CampaignUI") //whats the name?
	ui.open()

/obj/machinery/tgui_test/ui_state(mob/user)
	return GLOB.human_adjacent_state

/obj/machinery/tgui_test/ui_data(mob/living/user)
	. = ..()
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/datum/faction_stats/team = current_mode.stat_list[faction]

	var/list/data = list()
	var/ui_theme
	switch(faction)
		if(FACTION_SOM)
			ui_theme = "som"
		else
			ui_theme = "ntos"
	data["ui_theme"] = ui_theme

	//complex ones
	var/list/current_mission_data = list()
	var/datum/campaign_mission/current_mission = current_mode.current_mission
	current_mission_data["name"] = current_mission.name
	current_mission_data["map_name"] = current_mission.map_name
	current_mission_data["starting_faction"] = current_mission.starting_faction
	current_mission_data["hostile_faction"] = current_mission.hostile_faction
	current_mission_data["winning_faction"] = current_mission.winning_faction
	current_mission_data["outcome"] = current_mission.outcome
	current_mission_data["objective_description"] = current_mission.objective_description[faction == current_mission.starting_faction ? "starting_faction" : "hostile_faction"]
	current_mission_data["mission_brief"] = current_mission.mission_brief[faction == current_mission.starting_faction ? "starting_faction" : "hostile_faction"]
	current_mission_data["mission_rewards"] = current_mission.additional_rewards[faction == current_mission.starting_faction ? "starting_faction" : "hostile_faction"]
	data["current_mission"] = current_mission_data

	var/list/potential_missions_data = list()
	for(var/datum/campaign_mission/potential_mission AS in team.potential_missions)
		var/list/mission_data = list() //each relevant bit of info regarding the mission is added to the list. Many more to come
		mission_data["typepath"] = potential_mission.type
		mission_data["name"] = potential_mission.name
		mission_data["map_name"] = potential_mission.map_name
		mission_data["objective_description"] = potential_mission.objective_description["starting_faction"]
		mission_data["mission_brief"] = potential_mission.mission_brief["starting_faction"]
		mission_data["mission_rewards"] = potential_mission.additional_rewards["starting_faction"]
		potential_missions_data += list(mission_data)
	data["potential_missions"] = potential_missions_data

	var/list/finished_missions_data = list()
	for(var/datum/campaign_mission/finished_mission AS in team.finished_missions)
		var/list/mission_data = list() //each relevant bit of info regarding the mission is added to the list. Many more to come
		mission_data["name"] = finished_mission.name
		mission_data["map_name"] = finished_mission.map_name
		mission_data["starting_faction"] = finished_mission.starting_faction
		mission_data["hostile_faction"] = finished_mission.hostile_faction
		mission_data["winning_faction"] = finished_mission.winning_faction
		mission_data["outcome"] = finished_mission.outcome
		mission_data["objective_description"] = finished_mission.objective_description[faction == finished_mission.starting_faction ? "starting_faction" : "hostile_faction"]
		mission_data["mission_brief"] = finished_mission.mission_brief[faction == finished_mission.starting_faction ? "starting_faction" : "hostile_faction"]
		mission_data["mission_rewards"] = finished_mission.additional_rewards[faction == finished_mission.starting_faction ? "starting_faction" : "hostile_faction"]
		finished_missions_data += list(mission_data)
	data["finished_missions"] = finished_missions_data

	var/list/faction_rewards_data = list()
	for(var/datum/campaign_reward/reward AS in team.faction_rewards)
		var/list/reward_data = list() //each relevant bit of info regarding the reward is added to the list. Many more to come
		reward_data["name"] = reward.name
		reward_data["desc"] = reward.desc
		reward_data["detailed_desc"] = reward.detailed_desc
		reward_data["uses_remaining"] = reward.uses
		reward_data["uses_original"] = initial(reward.uses)
		faction_rewards_data += list(reward_data)
	data["faction_rewards_data"] = faction_rewards_data

	//simple ones
	data["active_attrition_points"] = team.active_attrition_points
	data["total_attrition_points"] = team.total_attrition_points
	data["faction_leader"] = team.faction_leader
	data["victory_points"] = team.victory_points
	data["faction"] = team.faction

	return data

/obj/machinery/tgui_test/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	if(!istype(current_mode))
		CRASH("campaign_mission loaded without campaign game mode")

	var/datum/faction_stats/team = current_mode.stat_list[faction]
	var/mob/user = usr
	if(user != team.faction_leader)
		return

	switch(action)
		if("set_attrition_points")
			team.total_attrition_points -= params["attrition_points"]
			team.active_attrition_points = params["attrition_points"] //unused points are lost

		if("set_next_mission")
			var/datum/campaign_mission/choice = team.potential_missions[text2path(params["new_mission"])] //locate or something maybe?
			current_mode.load_new_mission(choice)

		if("activate_reward")
			var/datum/campaign_reward/choice = team.faction_rewards[text2path(params["selected_reward"])] //locate or something maybe?
			choice.activated_effect()
