/mob/living/carbon/human/handle_healths_hud_updates()
	if(!hud_used?.healths)
		return

	if(stat == DEAD)
		hud_used.healths.icon_state = "health_dead"
		return
