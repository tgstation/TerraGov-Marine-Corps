/obj/item/assembly/voice
	name = "voice analyzer"
	desc = "A small electronic device able to record a voice sample, and send a signal when that sample is repeated."
	icon_state = "voice"
	matter = list("metal" = 500, "glass" = 50, "waste" = 10)
	origin_tech = "magnets=1"
	var/listening = 0
	var/recorded	//the activation message

/obj/item/assembly/voice/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(listening)
		recorded = message
		listening = 0
		var/turf/T = get_turf(src)	//otherwise it won't work in hand
		T.visible_message("[icon2html(src, viewers(T))] beeps, \"Activation message is '[recorded]'.\"")
	else
		if(findtext(message, recorded))
			pulse(0)

/obj/item/assembly/voice/activate()
	if(secured)
		if(!holder)
			listening = !listening
			var/turf/T = get_turf(src)
			T.visible_message("[icon2html(src, viewers(T))] beeps, \"[listening ? "Now" : "No longer"] recording input.\"")


/obj/item/assembly/voice/attack_self(mob/user)
	if(!user)	return 0
	activate()
	return 1


/obj/item/assembly/voice/toggle_secure()
	. = ..()
	listening = 0