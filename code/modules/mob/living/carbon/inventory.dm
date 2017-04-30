

/mob/living/carbon/proc/handcuff_update()
	if(handcuffed)
		drop_held_items()
		stop_pulling()
	update_inv_handcuffed()

/mob/living/carbon/proc/legcuff_update()
	if(legcuffed)
		if(m_intent != "walk")
			m_intent = "walk"
			if(hud_used && hud_used.move_intent)
				hud_used.move_intent.icon_state = "walking"
	update_inv_legcuffed()