/mob/living/carbon/xenomorph/handle_regular_hud_updates()
	if(!client)
		return FALSE

	// Sanity checks
	if(!maxHealth)
		stack_trace("[src] called handle_regular_hud_updates() while having [maxHealth] maxHealth.")
		return
	if(!xeno_caste.plasma_max)
		stack_trace("[src] called handle_regular_hud_updates() while having [xeno_caste.plasma_max] xeno_caste.plasma_max.")
		return

	// Health Hud
	if(hud_used && hud_used.healths)
		if(stat != DEAD)
			var/amount = round(health * 100 / maxHealth, 5)
			if(health < 0)
				amount = 0 //We dont want crit sprite only at 0 health
			hud_used.healths.icon_state = "health[amount]"
		else
			hud_used.healths.icon_state = "health_dead"

	// Plasma Hud
	if(hud_used && hud_used.alien_plasma_display)
		if(stat != DEAD)
			var/amount = round(plasma_stored * 100 / xeno_caste.plasma_max, 5)
			hud_used.alien_plasma_display.icon_state = "power_display_[amount]"
		else
			hud_used.alien_plasma_display.icon_state = "power_display_0"

	interactee?.check_eye(src)

	return TRUE
