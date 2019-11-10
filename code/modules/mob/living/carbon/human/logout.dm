/mob/living/carbon/human/Logout()
	. = ..()
	species?.handle_logout_special(src)
	if(key && !isclientedaghost(src)) //Disconnected.
		set_afk_status(MOB_AFK, 15 MINUTES)
