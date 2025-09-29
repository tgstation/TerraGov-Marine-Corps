/mob/living/carbon/human/verb/toggle_fallback_icons()
	set category = "OOC"
	set name = "Toggle fallback icons"
	set desc = "Use if your sprite is invisible"
	set src = usr
	if(icon_state == "body_m_s")
		icon_state = "body_[get_gender_name(physique)]"
		src.log_message("switched to fallback human icons", LOG_GAME)
	else
		icon_state = "body_m_s"
		src.log_message("switched back from fallback human icons to normal ones", LOG_GAME)
