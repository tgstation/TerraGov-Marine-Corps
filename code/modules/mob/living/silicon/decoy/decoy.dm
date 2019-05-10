/mob/living/silicon/decoy/ship_ai //For the moment, pending better pathing.

/mob/living/silicon/decoy/ship_ai/Initialize()
	. = ..()
	name = MAIN_AI_SYSTEM
	desc = "This is the artificial intelligence system for the [CONFIG_GET(string/ship_name)]. Like many other military-grade AI systems, this one was manufactured by NanoTrasen."


//Should likely just replace this with an actual AI mob in the future. Might as well.
/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/Marine/ai.dmi'
	icon_state = "hydra"
	voice_name = "ARES v3.2"
	anchored = 1
	canmove = FALSE
	density = TRUE //Do not want to see past it.
	bound_height = 64 //putting this in so we can't walk through our machine.
	bound_width = 96
	var/obj/item/radio/headset/almayer/mcom/ai/radio //The thing it speaks into.
	var/sound/ai_sound //The lines that it plays when speaking.

/mob/living/silicon/decoy/Initialize()
	. = ..()
	radio = new(src)

/mob/living/silicon/decoy/Life()
	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return FALSE
	if(health <= get_death_threshold() && stat != DEAD)
		death(FALSE, "<b>\The [name]</b> sparks up and falls silent...")

/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

	update_stat()

/mob/living/silicon/decoy/death(gibbed, deathmessage)
	set waitfor = 0
	. = ..()
	density = TRUE
	icon_state = "hydra-off"
	sleep(20)
	explosion(loc, -1, 0, 8, 12)


/mob/living/silicon/decoy/say(message, new_sound, datum/language/language) //General communication across the ship.
	if(stat || !message)
		return FALSE

	ai_sound = new_sound ? new_sound : 'sound/misc/interference.ogg' //Remember the sound we need to play.

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		if(can_speak_in_language(message_language))
			language = message_language
		message = copytext(message, 3)

		if(findtext(message, " ", 1, 2))
			message = copytext(message, 2)

	if(!language)
		language = get_default_language()

	var/message_mode = get_message_mode(message)

	switch(message_mode)
		if(MODE_HEADSET)
			message = copytext(message, 2)
		if("broadcast")
			message_mode = MODE_HEADSET

	radio.talk_into(src, message, message_mode, language = language)
	return TRUE