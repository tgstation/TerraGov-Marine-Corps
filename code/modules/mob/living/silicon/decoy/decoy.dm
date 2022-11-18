/mob/living/silicon/decoy/ship_ai
	name = MAIN_AI_SYSTEM


/mob/living/silicon/decoy/ship_ai/Initialize(mapload, ...)
	. = ..()
	desc = "This is the artificial intelligence system for the [SSmapping.configs[SHIP_MAP].map_name]. Like many other military-grade AI systems, this one was manufactured by NanoTrasen."


//Should likely just replace this with an actual AI mob in the future. Might as well.
/mob/living/silicon/decoy
	name = "AI"
	icon = 'icons/Marine/ai.dmi'
	icon_state = "hydra"
	anchored = TRUE
	canmove = FALSE
	density = TRUE //Do not want to see past it.
	bound_height = 64 //putting this in so we can't walk through our machine.
	bound_width = 96
	var/sound/ai_sound //The lines that it plays when speaking.


/mob/living/silicon/decoy/Life()
	if(stat == DEAD)
		SSmobs.stop_processing(src)
		return FALSE
	if(health <= get_death_threshold() && stat != DEAD)
		death()

/mob/living/silicon/decoy/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		set_stat(CONSCIOUS)
	else
		health = 100 - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss()

	update_stat()


/mob/living/silicon/decoy/death(gibbing, deathmessage = "sparks up and falls silent...", silent)
	if(stat == DEAD)
		return ..()
	return ..()


/mob/living/silicon/decoy/on_death()
	density = TRUE
	icon_state = "hydra-off"
	addtimer(CALLBACK(src, .proc/post_mortem_explosion), 2 SECONDS)
	return ..()


/mob/living/silicon/decoy/proc/post_mortem_explosion()
	if(isnull(loc))
		return
	explosion(get_turf(src), 0, 1, 9, 12, small_animation = TRUE)


/mob/living/silicon/decoy/say(message, new_sound, datum/language/language) //General communication across the ship.
	if(stat || !message)
		return FALSE

	ai_sound = new_sound ? new_sound : 'sound/misc/interference.ogg' //Remember the sound we need to play.

	message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))

	var/datum/language/message_language = get_message_language(message)
	if(message_language)
		if(can_speak_in_language(message_language))
			language = message_language
		message = copytext_char(message, 3)

		if(findtext_char(message, " ", 1, 2))
			message = copytext_char(message, 2)

	if(!language)
		language = get_default_language()

	var/message_mode = get_message_mode(message)

	switch(message_mode)
		if(MODE_HEADSET)
			message = copytext_char(message, 2)
		if("broadcast")
			message_mode = MODE_HEADSET

	radio.talk_into(src, message, message_mode, language = language)
	return TRUE
