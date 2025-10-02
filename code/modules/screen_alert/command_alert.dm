#define MAX_COMMAND_MESSAGE_LEN 200

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
	. = ..()
	if(!.)
		return
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/message_squad/can_use_action(silent, override_flags, selecting)
	. = ..()
	if(!.)
		return
	if(!should_show())
		return FALSE
	if(owner.stat != CONSCIOUS || TIMER_COOLDOWN_RUNNING(owner, COOLDOWN_HUD_ORDER))
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
	text = capitalize(text)
	var/filter_result = CAN_BYPASS_FILTER(human_owner) ? null : is_ic_filtered(text)
	if(filter_result)
		to_chat(human_owner, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[text]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		REPORT_CHAT_FILTER_TO_USER(src, filter_result)
		log_filter("IC", text, filter_result)
		return
	if(!can_use_action())
		return

	TIMER_COOLDOWN_START(owner, COOLDOWN_HUD_ORDER, CIC_ORDER_COOLDOWN)
	addtimer(CALLBACK(src, PROC_REF(update_button_icon)), CIC_ORDER_COOLDOWN + 1)
	update_button_icon()
	log_game("[key_name(human_owner)] has broadcasted the hud message [text] at [AREACOORD(human_owner)]")
	var/override_color
	var/list/alert_receivers
	var/sound_alert
	var/announcement_title

	if(human_owner.assigned_squad)
		alert_receivers = human_owner.assigned_squad.marines_list + GLOB.observer_list
		sound_alert = 'sound/effects/sos-morse-code.ogg'
		announcement_title = "Squad [human_owner.assigned_squad.name] Announcement"
		switch(human_owner.assigned_squad.id)
			if(ALPHA_SQUAD)
				override_color = "red"
			if(BRAVO_SQUAD)
				override_color = "yellow"
			if(CHARLIE_SQUAD)
				override_color = "purple"
			if(DELTA_SQUAD)
				override_color = "blue"
			else
				override_color = "grey"
	else
		alert_receivers = GLOB.alive_human_list_faction[human_owner.faction] + GLOB.ai_list + GLOB.observer_list
		sound_alert = 'sound/misc/notice2.ogg'
		announcement_title = "[human_owner.job.title]'s Announcement"

	for(var/mob/mob_receiver in alert_receivers)
		mob_receiver.playsound_local(mob_receiver, sound_alert, 35, channel = CHANNEL_ANNOUNCEMENTS)
		mob_receiver.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING(announcement_title, text, LEFT_ALIGN_TEXT), new /atom/movable/screen/text/screen_text/picture/potrait/custom_mugshot(null, null, owner), override_color)
		to_chat(mob_receiver, assemble_alert(
			title = announcement_title,
			subtitle = "Sent by [human_owner.get_paygrade(0) ? human_owner.get_paygrade(0) : human_owner.job.title] [human_owner.real_name]",
			message = text,
			color_override = override_color
		))

	var/list/tts_listeners = filter_tts_listeners(human_owner, alert_receivers, null, RADIO_TTS_COMMAND)
	if(!length(tts_listeners))
		return
	var/list/treated_message = human_owner?.treat_message(text) //we only treat the text here since it adds stutter to the text announcement otherwise
	var/list/extra_filters = list(TTS_FILTER_RADIO)
	if(isrobot(human_owner))
		extra_filters += TTS_FILTER_SILICON
	INVOKE_ASYNC(SStts, TYPE_PROC_REF(/datum/controller/subsystem/tts, queue_tts_message), human_owner, treated_message["tts_message"], human_owner.get_default_language(), human_owner.voice, human_owner.voice_filter, tts_listeners, FALSE, pitch = human_owner.pitch, special_filters = extra_filters.Join("|"), directionality = FALSE)

