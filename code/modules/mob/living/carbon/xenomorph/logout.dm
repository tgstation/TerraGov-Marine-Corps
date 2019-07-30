/mob/living/carbon/xenomorph/Logout()
	. = ..()
	addtimer(CALLBACK(src, .proc/handle_afk_takeover), XENO_AFK_TIMER)
