#define MAX_SQUAD_NAME_LEN 15

/obj/machinery/computer/squad_manager
	name = "squad managment console"
	desc = "A console for squad management. Allows squad leaders to manage their squad."
	screen_overlay = "rdcomp"
	light_color = LIGHT_COLOR_PINK
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
	data["valid_colors"] = GLOB.custom_squad_colors
	return data

/obj/machinery/computer/squad_manager/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/user = usr
	if(!ismarineleaderjob(user.job)  && !issommarineleaderjob(user.job))
		to_chat(user, span_danger("You must be a squad leader to edit squads."))
		return

	if(user.assigned_squad?.type == /datum/squad) //means its a generated squad
		to_chat(user, span_danger("You are already in a squad that has been created."))
		return

	if(action != "create_squad")
		return

	var/new_name = params["name"]
	var/new_color = params["color"]
	var/new_desc = sanitize(params["desc"])

	if(!GLOB.custom_squad_colors[new_color])
		return

	if(length(new_name) > MAX_SQUAD_NAME_LEN)
		to_chat(user, span_danger("Squad name is too long"))
		return FALSE
	new_name = sanitize(new_name)

	var/filter_result = is_ic_filtered(new_name)
	if(filter_result)
		to_chat(user, span_warning("That name contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[new_name]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(user, filter_result)
		log_filter("Squad naming", new_name, filter_result)
		return FALSE

	if(NON_ASCII_CHECK(new_desc))
		to_chat(user, span_danger("Squad description contained characters banned in IC chat"))
		return

	var/filter_result_desc = is_ic_filtered(new_name)
	if(filter_result_desc)
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(user, filter_result_desc)
		log_filter("Squad description", new_desc, filter_result_desc)
		return

	var/datum/squad/new_squad = create_squad(new_name, new_color, user)
	if(!new_squad)
		to_chat(user, span_danger("Error: squad creation failed"))
		return FALSE
	var/log_msg = "[key_name(user)] has created a new squad. Name: [new_name], Color: [new_color]"
	log_game(log_msg)
	message_admins(log_msg)
	new_squad.desc = new_desc
	ui_close(user)
	balloon_alert(user, "\"[new_name]\" created")
