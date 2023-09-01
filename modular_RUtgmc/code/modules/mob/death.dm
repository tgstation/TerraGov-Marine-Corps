/mob/proc/on_death()
	if(hud_used && hud_used.healths)
		hud_used.healths.icon_state = "health_dead"
