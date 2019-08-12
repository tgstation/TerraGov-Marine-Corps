/mob/living/carbon/xenomorph/Logout()
	. = ..()
	if(key && !isclientedaghost(src)) //Disconnected.
		afk_timer_id = addtimer(CALLBACK(src, .proc/handle_afk_takeover), XENO_AFK_TIMER, TIMER_STOPPABLE)
