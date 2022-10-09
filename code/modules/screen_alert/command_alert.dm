#define MAX_COMMAND_MESSAGE_LEN 300

/obj/screen/text/screen_text/command_order
	maptext_height = 64
	maptext_width = 480
	maptext_x = 0
	maptext_y = 0
	screen_loc = "LEFT,TOP-3"

	letters_per_update = 2
	fade_out_delay = 5 SECONDS
	style_open = "<span class='maptext' style=font-size:20pt;text-align:center valign='top'>"
	style_close = "</span>"

/obj/screen/text/screen_text/command_order/intro
	maptext_x = 66
	maptext_y = 32
	letters_per_update = 1
	screen_loc = "WEST:6,1:5"
	style_open = "<span class='maptext' style=font-size:20pt;text-align:left valign='top'>"
	layer = INTRO_LAYER
	plane = INTRO_PLANE
	///image that will display on the left of the screen alert
	var/image_to_play = "lrprr"
	///y offset of image
	var/image_to_play_offset_y = 32
	///x offset of image
	var/image_to_play_offset_x = 0

/obj/screen/text/screen_text/command_order/intro/Initialize()
	. = ..()
	overlays += image('icons/UI_Icons/screen_alert_images.dmi', icon_state = image_to_play, pixel_y = image_to_play_offset_y, pixel_x = image_to_play_offset_x)

/obj/screen/text/screen_text/command_order/intro/tdf
	image_to_play = "tdf"

/obj/screen/text/screen_text/command_order/intro/shokk
	image_to_play = "shokk"

/obj/screen/text/screen_text/command_order/intro/blackop
	image_to_play = "blackops"

/obj/screen/text/screen_text/command_order/intro/potrait
	screen_loc = "LEFT,TOP-3"
	image_to_play = "overwatch"
	image_to_play_offset_y = 0
	maptext_y = 0

/obj/screen/text/screen_text/command_order/intro/potrait/som_over
	image_to_play = "overwatch_som"

/datum/action/innate/message_squad
	name = "Send Order"
	action_icon_state = "screen_order_marine"
	keybind_signal = COMSIG_KB_SENDORDER
	///What skill is needed to have this action
	var/skill_name = "leadership"
	///What minimum level in that skill is needed to have that action
	var/skill_min = SKILL_LEAD_EXPERT

/datum/action/innate/message_squad/should_show()
	return owner.skills.getRating(skill_name) >= skill_min

/datum/action/innate/message_squad/can_use_action()
	. = ..()
	if(owner.stat)
		to_chat(owner, span_warning("You cannot give orders in your current state."))
		return FALSE
	if(TIMER_COOLDOWN_CHECK(owner, COOLDOWN_HUD_ORDER))
		to_chat(owner, span_warning("Your last order was too recent."))
		return FALSE

/datum/action/innate/message_squad/action_activate()
	var/mob/living/carbon/human/human_owner = owner
	if(!can_use_action())
		return
	var/text = stripped_input(human_owner, "Maximum message length [MAX_COMMAND_MESSAGE_LEN]", "Send message to squad", max_length = MAX_COMMAND_MESSAGE_LEN)
	if(!text)
		return
	if(CHAT_FILTER_CHECK(text))
		to_chat(human_owner, span_warning("That message contained a word prohibited in IC chat! Consider reviewing the server rules.\n<span replaceRegex='show_filtered_ic_chat'>\"[text]\"</span>"))
		SSblackbox.record_feedback(FEEDBACK_TALLY, "ic_blocked_words", 1, lowertext(config.ic_filter_regex.match))
		return
	if(!can_use_action())
		return
	human_owner.playsound_local(owner, "sound/effects/CIC_order.ogg", 10, 1)
	TIMER_COOLDOWN_START(owner, COOLDOWN_HUD_ORDER, ORDER_COOLDOWN)
	log_game("[key_name(human_owner)] has broadcasted the hud message [text] at [AREACOORD(human_owner)]")
	deadchat_broadcast(" has sent the command order \"[text]\"", human_owner, human_owner)
	if(human_owner.assigned_squad)
		for(var/mob/living/carbon/human/marine AS in human_owner.assigned_squad.marines_list)
			marine.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>SQUAD ORDERS UPDATED:</u></span><br>" + text, /obj/screen/text/screen_text/command_order)
		return
	for(var/mob/living/carbon/human/human AS in GLOB.alive_human_list)
		if(human.faction == human_owner.faction)
			human.play_screen_text("<span class='maptext' style=font-size:24pt;text-align:center valign='top'><u>ORDERS UPDATED:</u></span><br>" + text, /obj/screen/text/screen_text/command_order)
