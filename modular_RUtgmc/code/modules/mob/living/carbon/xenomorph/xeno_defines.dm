/mob/living/carbon/xenomorph
	hud_possible = list(HEALTH_HUD_XENO, PLASMA_HUD, PHEROMONE_HUD, XENO_RANK_HUD, QUEEN_OVERWATCH_HUD, ARMOR_SUNDER_HUD, XENO_DEBUFF_HUD, XENO_FIRE_HUD, XENO_BANISHED_HUD)
	var/talk_sound = "alien_talk"  // sound when talking
	var/footsteps = FOOTSTEP_XENO_MEDIUM

/mob/living/carbon/xenomorph/send_speech(message_raw, message_range = 7, obj/source = src, bubble_type = bubble_icon, list/spans, datum/language/message_language=null, message_mode, tts_message, list/tts_filter)
	. = ..()
	playsound(loc, talk_sound, 25, 1)
