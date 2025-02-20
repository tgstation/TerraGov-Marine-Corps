GLOBAL_DATUM(campaign_admin_panel, /datum/campaign_admin_panel)

ADMIN_VERB(open_campaign_panel, R_ADMIN, "Campaign Panel", "Opens the campaign panel UI.", ADMIN_CATEGORY_FUN)
	if(!iscampaigngamemode(SSticker.mode))
		to_chat(user, span_notice("The campaign panel can only be used during campaign."))
		return

	if(!GLOB.campaign_admin_panel)
		GLOB.campaign_admin_panel = new /datum/campaign_admin_panel()

	GLOB.campaign_admin_panel.ui_interact(usr)
/datum/campaign_admin_panel
	interaction_flags = INTERACT_UI_INTERACT

/datum/campaign_admin_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return
	ui = new(user, src, "CampaignAdminPanel")
	ui.open()

/datum/campaign_admin_panel/ui_state(mob/user)
	return GLOB.always_state

/datum/campaign_admin_panel/ui_static_data(mob/user)
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode

	var/list/data = list()
	var/list/faction_data_list = list()

	for(var/faction in current_mode.factions)
		var/datum/faction_stats/faction_datum = current_mode.stat_list[faction]
		var/list/faction_data = list()
		faction_data["faction"] = faction
		faction_data["active_attrition"] = faction_datum.active_attrition_points
		faction_data["total_attrition"] = faction_datum.total_attrition_points
		faction_data["faction_leader"] = faction_datum.faction_leader
		faction_data["victory_points"] = faction_datum.victory_points
		faction_data["available_missions"] = faction_datum.available_missions
		faction_data["assets"] = faction_datum.faction_assets

		faction_data_list += list(faction_data)
	data["faction_data"] = faction_data_list
	data["vp_max"] = CAMPAIGN_MAX_VICTORY_POINTS

	return data

/datum/campaign_admin_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	var/datum/faction_stats/faction_datum = current_mode?.stat_list[params["target_faction"]]

	switch(action)
		if("set_attrition_points")
			var/combined_attrition = faction_datum.total_attrition_points + faction_datum.active_attrition_points
			var/choice = tgui_input_number(user, "How much manpower would you like to dedicate to this mission?", "Attrition Point selection", 0, combined_attrition, 0, 60 SECONDS)
			faction_datum.set_attrition(choice, user)
			message_admins("[usr.client] set the active attrition for [faction_datum.faction] to [choice]")
			log_admin("[usr.client] set the active attrition for [faction_datum.faction] to [choice]")
			update_static_data_for_all_viewers()
			return TRUE
		if("add_attrition_points")
			var/choice = tgui_input_number(user, "How much total attrition would you like to add?", "Attrition Point selection", 0, 9999, -9999)
			faction_datum.total_attrition_points += choice
			message_admins("[usr.client] added [choice] attrition to [faction_datum.faction]")
			log_admin("[usr.client] added [choice] attrition to [faction_datum.faction]")
			update_static_data_for_all_viewers()
			return TRUE
		if("set_leader")
			var/choice = tgui_input_list(user, "Who would you like to promote to faction leader?", "Leader selection", GLOB.alive_human_list_faction[faction_datum.faction], null)
			faction_datum.set_faction_leader(choice)
			message_admins("[usr.client] set faction leader of [faction_datum.faction] to [choice ? choice : "no one"]")
			log_admin("[usr.client] set faction leader of [faction_datum.faction] to [choice ? choice : "no one"]")
			update_static_data_for_all_viewers()
			return TRUE
		if("set_victory_points")
			var/choice = tgui_input_number(user, "How many victory points would you like to add?", "Attrition Point selection", 0, CAMPAIGN_MAX_VICTORY_POINTS, -CAMPAIGN_MAX_VICTORY_POINTS)
			faction_datum.victory_points += choice
			message_admins("[usr.client] set the victory points for [faction_datum.faction] to [choice]")
			log_admin("[usr.client] set the victory points for [faction_datum.faction] to [choice]")
			update_static_data_for_all_viewers()
			return TRUE
		if("add_mission")
			var/choice = tgui_input_list(user, "What mission would you like to add?", "Add mission", subtypesof(/datum/campaign_mission), null)
			if(!choice)
				return FALSE
			faction_datum.add_new_mission(choice)
			message_admins("[usr.client] added the mission [choice] to [faction_datum.faction]")
			log_admin("[usr.client] added the mission [choice] to [faction_datum.faction]")
			return TRUE
		if("add_asset")
			var/choice = tgui_input_list(user, "What asset would you like to add?", "Add asset", subtypesof(/datum/campaign_asset), null)
			if(!choice)
				return FALSE
			faction_datum.add_asset(choice)
			message_admins("[usr.client] added the asset [choice] to [faction_datum.faction]")
			log_admin("[usr.client] added the asst [choice] to [faction_datum.faction]")
			return TRUE
		if("autobalance")
			var/choice = tgui_input_list(user, "Would you like to force autobalance?", "Forced autobalance", list("No", "Yes"))
			if(!choice)
				return FALSE
			var/forced = choice == "Yes"
			current_mode.autobalance_cycle(forced)
			message_admins("[usr.client] [forced ? "forced" : "triggered"] autobalance")
			log_admin("[usr.client] [forced ? "forced" : "triggered"] autobalance")
			return TRUE
		if("shuffle_teams")
			var/choice = tgui_input_list(user, "Would you like to shuffle the teams?", "Shuffle teams", list("No", "Yes"))
			if(choice != "Yes")
				return FALSE
			current_mode.shuffle_teams()
			message_admins("[usr.client] shuffled the teams")
			log_admin("[usr.client] shuffled the teams")
			return TRUE
		if("mission_start_timer")
			if(current_mode.current_mission.mission_state != MISSION_STATE_LOADED)
				to_chat(user, "Mission is not in pregame.")
				return FALSE
			if(current_mode.current_mission.start_timer)
				deltimer(current_mode.current_mission.start_timer)
				current_mode.current_mission.start_timer = null
				message_admins("[usr.client] cancelled the mission start timer")
				log_admin("[usr.client] cancelled the mission start timer")
				return TRUE
			var/choice = tgui_input_number(user, "How long would you like to set the delay to?", "Mission start timer", current_mode.current_mission.mission_start_delay, 20 MINUTES, 1)
			if(!choice)
				return FALSE
			current_mode.current_mission.start_timer = addtimer(CALLBACK(current_mode.current_mission, TYPE_PROC_REF(/datum/campaign_mission, start_mission)), choice, TIMER_STOPPABLE)
			message_admins("[usr.client] resumed the mission start timer at [choice * 0.1] seconds.")
			log_admin("[usr.client] resumed the mission start timer at [choice * 0.1] seconds.")
			return TRUE
		if("mission_timer")
			if(current_mode.current_mission.mission_state != MISSION_STATE_ACTIVE)
				to_chat(user, "Mission is not active.")
				return FALSE
			if(current_mode.current_mission.game_timer)
				current_mode.current_mission.pause_mission_timer()
				message_admins("[usr.client] paused the mission timer")
				log_admin("[usr.client] paused the mission timer")
				return TRUE
			var/choice = tgui_input_list(user, "Force timer on?", "Force timer", list("Yes", "No"), "No")
			if(choice != "Yes")
				choice = null
			current_mode.current_mission.resume_mission_timer(forced = choice)
			message_admins("[usr.client] resumed the mission timer")
			log_admin("[usr.client] resumed the mission timer")
			return TRUE
