/mob/living/carbon/xenomorph/Logout()
	. = ..()
	if(key && !(isaghost(src) && GLOB.directory[key])) //Disconnected.
		afk_timer_id = addtimer(CALLBACK(src, .proc/handle_afk_takeover), XENO_AFK_TIMER, TIMER_STOPPABLE)
