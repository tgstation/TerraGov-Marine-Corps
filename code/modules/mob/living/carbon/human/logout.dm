/mob/living/carbon/human/Logout()
	. = ..()
	species?.handle_logout_special(src)
	if(key && !isclientedaghost(src)) //Disconnected.
		afk_timer_id = addtimer(CALLBACK(GLOBAL_PROC, /proc/afk_message, src), 15 MINUTES, TIMER_STOPPABLE)
