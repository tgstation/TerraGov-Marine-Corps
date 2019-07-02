/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
	var/mob/M = speaker.GetSource()
	if(M)
		return "<a href='?src=[REF(src)];track=[html_encode(namepart)]'> "
	return ""


/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""] "


/mob/living/silicon/ai/radio(message, message_mode, list/spans, language)
	if(incapacitated())
		return FALSE
	if(control_disabled)
		to_chat(src, "<span class='danger'>Your radio transmitter is offline!</span>")
		return FALSE
	return ..()


//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, language)
	message = trim(message)
	if(!message)
		return

	var/obj/machinery/holopad/T = current
	if(!istype(T) || !T.masters[src])
		to_chat(src, "<span class='warning'>No holopad connected.</span>")
		return

	var/turf/padturf = get_turf(T)
	var/padloc
	if(padturf)
		padloc = AREACOORD(padturf)
	else
		padloc = "(UNKNOWN)"
	log_talk(message, LOG_SAY, tag = "HOLOPAD in [padloc]")
	send_speech(message, 7, T, "robot", message_language = language)
	to_chat(src, "<span class='notice'>Holopad transmitted: [real_name]: \"[message]\"</span>")