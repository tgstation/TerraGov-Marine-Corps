#define CHARS_PER_LINE 5

#define SD_BLANK 0  // 0 = Blank
#define SD_EMERGENCY 1  // 1 = Emergency Shuttle timer
#define SD_MESSAGE 2  // 2 = Arbitrary message(s)
#define SD_PICTURE 3  // 3 = alert picture

#define SD_AI_EMOTE 1  // 1 = AI emoticon
#define SD_AI_BSOD 2  // 2 = Blue screen of death

/// Status display which can show images and scrolling text.
/obj/machinery/status_display
	name = "status display"
	desc = null
	icon = 'icons/obj/status_display.dmi'
	icon_state = "frame"
	density = FALSE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10

	maptext_height = 26
	maptext_width = 32

	var/message1 = ""	// message line 1
	var/message2 = ""	// message line 2
	var/index1			// display index for scrolling messages or 0 if non-scrolling
	var/index2

/// Immediately blank the display.
/obj/machinery/status_display/proc/remove_display()
	cut_overlays()
	if(maptext)
		maptext = ""


/// Immediately change the display to the given picture.
/obj/machinery/status_display/proc/set_picture(state)
	remove_display()
	add_overlay(state)


/// Immediately change the display to the given two lines.
/obj/machinery/status_display/proc/update_display(line1, line2)
	var/new_text = {"<div style="font-size:[FONT_SIZE];color:[FONT_COLOR];font:'[FONT_STYLE]';text-align:center;" valign="top">[line1]<br>[line2]</div>"}
	if(maptext != new_text)
		maptext = new_text


/// Prepare the display to marquee the given two lines.
///
/// Call with no arguments to disable.
/obj/machinery/status_display/proc/set_message(m1, m2)
	if(m1)
		index1 = (length_char(m1) > CHARS_PER_LINE)
		message1 = m1
	else
		message1 = ""
		index1 = 0

	if(m2)
		index2 = (length_char(m2) > CHARS_PER_LINE)
		message2 = m2
	else
		message2 = ""
		index2 = 0

// Timed process - performs default marquee action if so needed.
/obj/machinery/status_display/process()
	if(machine_stat & NOPOWER)
		remove_display()
		return PROCESS_KILL

	var/line1 = message1
	if(index1)
		line1 = copytext_char("[message1]|[message1]", index1, index1 + CHARS_PER_LINE)
		var/message1_len = length_char(message1)
		index1 += SCROLL_SPEED
		if(index1 > message1_len + 1)
			index1 -= (message1_len + 1)

	var/line2 = message2
	if(index2)
		line2 = copytext_char("[message2]|[message2]", index2, index2 + CHARS_PER_LINE)
		var/message2_len = length_char(message2)
		index2 += SCROLL_SPEED
		if(index2 > message2_len + 1)
			index2 -= (message2_len + 1)

	update_display(line1, line2)
	if(!index1 && !index2)
		return PROCESS_KILL


/// Update the display and, if necessary, re-enable processing.
/obj/machinery/status_display/proc/update()
	if(process() != PROCESS_KILL)
		start_processing()


/obj/machinery/status_display/power_change()
	. = ..()
	update()


/obj/machinery/status_display/emp_act(severity)
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	set_picture("ai_bsod")


/obj/machinery/status_display/examine(mob/user)
	. = ..()
	if(message1 || message2)
		var/list/msg = list("The display says:")
		if(message1)
			msg += "<br>\t<tt>[html_encode(message1)]</tt>"
		if(message2)
			msg += "<br>\t<tt>[html_encode(message2)]</tt>"
		. += msg.Join()


// Pictograph display which the AI can use to emote.
/obj/machinery/status_display/ai
	name = "\improper AI display"
	desc = "A small screen which the AI can use to present itself."

	var/mode = SD_BLANK
	var/emotion = "Neutral"


/obj/machinery/status_display/ai/Initialize(mapload)
	. = ..()
	GLOB.ai_status_displays.Add(src)


/obj/machinery/status_display/ai/Destroy()
	GLOB.ai_status_displays.Remove(src)
	return ..()


/obj/machinery/status_display/ai/attack_ai(mob/living/silicon/ai/user)
	user.display_status()


/obj/machinery/status_display/ai/process()
	if(mode == SD_BLANK || (machine_stat & NOPOWER))
		remove_display()
		return PROCESS_KILL

/// If you are adding more pictures, don't forget to complete the list in AI_verbs.dm

	if(mode == SD_AI_EMOTE)
		switch(emotion)
			if("Very Happy")
				set_picture("ai_veryhappy")
			if("Happy")
				set_picture("ai_happy")
			if("Neutral")
				set_picture("ai_neutral")
			if("Unsure")
				set_picture("ai_unsure")
			if("Confused")
				set_picture("ai_confused")
			if("Sad")
				set_picture("ai_sad")
			if("BSOD")
				set_picture("ai_bsod")
			if("Blank")
				set_picture("ai_off")
			if("Problems?")
				set_picture("ai_trollface")
			if("Awesome")
				set_picture("ai_awesome")
			if("Thinking")
				set_picture("ai_thinking")
			if("Facepalm")
				set_picture("ai_facepalm")
			if("Friend Computer")
				set_picture("ai_friend")
			if("Blue Glow")
				set_picture("ai_sal")
			if("Red Glow")
				set_picture("ai_hal")
		return PROCESS_KILL

	if(mode == SD_AI_BSOD)
		set_picture("ai_bsod")
		return PROCESS_KILL


#undef CHARS_PER_LINE
#undef FONT_SIZE
#undef FONT_COLOR
#undef FONT_STYLE
#undef SCROLL_SPEED
