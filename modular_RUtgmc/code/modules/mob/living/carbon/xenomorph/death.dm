/mob/living/carbon/xenomorph/on_death()
	. = ..()
	if(hud_used)
		if(hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used.staminas)
			hud_used.staminas.icon_state = "staminaloss200"
		if(hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_0"
		if(hud_used.alien_evolve_display)
			hud_used.alien_evolve_display.icon_state = "evolve0"
