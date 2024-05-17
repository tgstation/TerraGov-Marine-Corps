#define MAX_COMMAND_MESSAGE_LEN 120

/atom/movable/screen/text/screen_text/command_order
	maptext_height = 64
	maptext_width = 480
	maptext_x = 0
	maptext_y = 0
	screen_loc = "LEFT,TOP-3"

	letters_per_update = 2
	fade_out_delay = 10 SECONDS
	style_open = "<span class='maptext' style=font-size:24pt;text-align:center valign='top'>"
	style_close = "</span>"

/atom/movable/screen/text/screen_text/command_order/automated
	fade_out_delay = 3 SECONDS
	style_open = "<span class='maptext' style=font-size:20pt;text-align:center valign='top'>"

/datum/action/innate/message_squad
	name = "Send Order"
	action_icon_state = "screen_order_marine"
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_KB_SENDORDER,
	)
	///What skill is needed to have this action
	var/skill_name = SKILL_LEADERSHIP
	///What minimum level in that skill is needed to have that action
	var/skill_min = SKILL_LEAD_TRAINED

/datum/action/innate/message_squad/should_show()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/message_squad/can_use_action()
	. = ..()
	if(!.)
		return
	if(!should_show())
		return FALSE
	if(owner.stat != CONSCIOUS || TIMER_COOLDOWN_CHECK(owner, COOLDOWN_HUD_ORDER))
		return FALSE
	if(owner.skills.getRating(skill_name) < skill_min)
		return FALSE

/datum/action/innate/message_squad/action_activate()
	if(!can_use_action())
		return
	var/mob/living/carbon/human/human_owner = owner
	var/text = tgui_input_text(human_owner, "Maximum message length [MAX_COMMAND_MESSAGE_LEN]", "Send message to squad",  max_length = MAX_COMMAND_MESSAGE_LEN, multiline = TRUE)
	if(!text)
		return
	var/filter_result = CAN_BYPASS_FILTER(human_owner) ? null : is_ic_filtered(text)
	if(filter_result)
		to_chat(human_owner, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[text]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", text, filter_result)
		return
	if(!can_use_action())
		return
	var/sound/S //Unique sound for squad leaders/non-squad leaders set further down
	TIMER_COOLDOWN_START(owner, COOLDOWN_HUD_ORDER, ORDER_COOLDOWN)
	log_game("[key_name(human_owner)] has broadcasted the hud message [text] at [AREACOORD(human_owner)]")
	var/override_color // for squad colors
	var/list/alert_receivers = (GLOB.alive_human_list + GLOB.ai_list + GLOB.observer_list) // for full faction alerts, do this so that faction's AI and ghosts can hear aswell
	if(human_owner.assigned_squad)
		switch(human_owner.assigned_squad.id)
			if(ALPHA_SQUAD)
				override_color = "red"
			if(BRAVO_SQUAD)
				override_color = "orange"
			if(CHARLIE_SQUAD)
				override_color = "purple"
			if(DELTA_SQUAD)
				override_color = "blue"
		for(var/mob/living/carbon/human/marine AS in human_owner.assigned_squad.marines_list | GLOB.observer_list)
			marine.playsound_local(marine, 'sound/effects/sos-morse-code.ogg', 35)
			marine.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>Squad [human_owner.assigned_squad.name] Announcement:</u></span><br>" + text, /atom/movable/screen/text/screen_text/command_order, "[human_owner.assigned_squad.color]")
			to_chat(marine, assemble_alert(
				title = "Squad [human_owner.assigned_squad.name] Announcement",
				subtitle = "Sent by [human_owner.get_paygrade(0) ? human_owner.get_paygrade(0) : human_owner.job.title] [human_owner.real_name]",
				message = text,
				color_override = override_color,
				minor = TRUE
			))
		return
	for(var/mob/faction_receiver in alert_receivers)
		S = sound('sound/misc/notice2.ogg')
		S.channel = CHANNEL_ANNOUNCEMENTS
		if(faction_receiver.faction == human_owner.faction || isdead(faction_receiver))
			faction_receiver.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>[uppertext(human_owner.job.title)]'S ANNOUNCEMENT:</u></span><br>" + text, /atom/movable/screen/text/screen_text/command_order)
			to_chat(faction_receiver, assemble_alert(
				title = "[human_owner.job.title]'s Announcement",
				subtitle = "Sent by [human_owner.get_paygrade(0) ? human_owner.get_paygrade(0) : human_owner.job.title] [human_owner.real_name]",
				message = text
			))
			SEND_SOUND(faction_receiver, S)
