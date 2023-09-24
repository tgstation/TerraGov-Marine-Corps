/obj/machinery/computer/squad_manager
	name = "squad managment console"
	desc = "A console for squad management. Allows squad leaders to manage their squad."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "rdcomp"
	interaction_flags = INTERACT_OBJ_UI

/obj/machinery/computer/squad_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadManager", name)
		ui.open()

/obj/machinery/computer/squad_manager/ui_data(mob/user)
	var/list/data = list()
	data["active_squads"] = list()
	for(var/datum/squad/squad AS in SSjob.active_squads[user.faction])
		var/leader_name = squad.squad_leader?.real_name ? squad.squad_leader.real_name : "NONE"
		data["active_squads"] += list(list("name" = squad.name, "leader" = leader_name, "color" = squad.color))
	return data

/obj/machinery/computer/squad_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = usr
	if(!ismarineleaderjob(user.job)  && !issommarineleaderjob(user.job))
		to_chat(user, span_danger("You must be a squad leader to edit squads."))
		return

	switch(action)
		if("create_squad")
			var/new_name = params["name"]
			var/new_color = params["color"]
			var/filter_result = is_ic_filtered(new_name)
			if(filter_result)
				to_chat(user, span_warning("That name contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[new_name]\"</span>"))
				SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
				REPORT_CHAT_FILTER_TO_USER(user, filter_result)
				log_filter("Squad naming", new_name, filter_result)
				return FALSE
			if(create_squad(new_name, new_color, user))
				var/log_msg = "[key_name(user)] has created a new squad. Name: [new_name], Color: [new_color]"
				log_game(log_msg)
				message_admins(log_msg)
				return TRUE
			to_chat(user, span_danger("Error: squad creation failed"))
		if("change_desc")
			var/datum/squad/squad = user.assigned_squad
			if(!squad)
				return
			var/new_desc = params["new_desc"]
			if(is_ic_filtered(new_desc) || NON_ASCII_CHECK(new_desc))
				to_chat(user, span_danger("Squad description contained characters or words banned in IC chat"))
				return
			log_game("[key_name(user)] has changed the squad description of \"[squad.name]\" to: [new_desc]")
			squad.desc = new_desc
			return TRUE
