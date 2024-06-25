GLOBAL_DATUM(campaign_admin_panel, /datum/campaign_admin_panel)

/datum/admins/proc/open_campaign_panel()
	set category = "Admin"
	set name = "Campaign Panel"
	set desc = "Opens the campaign panel UI."

	if(!iscampaigngamemode(SSticker.mode))
		return
	if(!check_rights(R_ADMIN))
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

//UI stuff
///datum/campaign_admin_panel/ui_assets(mob/user)
	//return list(get_asset_datum(/datum/asset/spritesheet/campaign/perks), get_asset_datum(/datum/asset/spritesheet/campaign/loadout_items))


/datum/campaign_admin_panel/ui_state(mob/user)
	return GLOB.always_state

/*
/datum/campaign_admin_panel/ui_data(mob/user)
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode

	var/list/data = list()


	return data
**/

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

		faction_data_list[faction] = faction_data
	data["faction_data"] = faction_data_list

	return data

/datum/campaign_admin_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	var/datum/game_mode/hvh/campaign/current_mode = SSticker.mode
	var/datum/faction_stats/faction_datum = current_mode?.stat_list[text2path(params["faction"])]

	switch(action)
		if("set_attrition_points")
			var/combined_attrition = faction_datum.total_attrition_points + faction_datum.active_attrition_points
			var/choice = tgui_input_number(user, "How much manpower would you like to dedicate to this mission?", "Attrition Point selection", 0, combined_attrition, 0, 60 SECONDS)
			faction_datum.set_attrition(choice, user)
			return TRUE
