/mob/living/carbon/xenomorph/Logout()
	. = ..()
	if(key && !isclientedaghost(src)) //Disconnected.
		set_afk_status(MOB_AFK, XENO_AFK_TIMER)
	if(hive) //This can happen after the mob is destroyed.
		hive.on_xeno_logout(src)
