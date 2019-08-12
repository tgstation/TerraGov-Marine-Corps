/mob/living/carbon/human/Login()
	. = ..()
	species?.handle_login_special(src)
	if(afk_timer_id)
		deltimer(afk_timer_id)
		afk_timer_id = null
