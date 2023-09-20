/mob/living/carbon/xenomorph/proc/handle_regular_health_hud_updates()
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

/mob/living/carbon/xenomorph/handle_regular_hud_updates()
	if(!client)
		return FALSE

	handle_regular_health_hud_updates()

	// Evolve Hud
	if(hud_used && hud_used.alien_evolve_display)
		if(stat != DEAD)
			var/amount = 0
			if(xeno_caste.evolution_threshold)
				amount = round(evolution_stored * 100 / xeno_caste.evolution_threshold, 5)
				hud_used.alien_evolve_display.icon_state = "evolve[amount]"
				if(!hive.check_ruler() && !isxenolarva(src))
					hud_used.alien_evolve_display.overlays += image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "evolve_cant")
				else
					hud_used.alien_evolve_display.overlays -= image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "evolve_cant")
				update_overlays(hud_used.alien_evolve_display)
			else
				hud_used.alien_evolve_display.icon_state = "evolve_empty"
		else
			hud_used.alien_evolve_display.icon_state = "evolve_empty"

	//Sunder Hud
	if(hud_used && hud_used.alien_sunder_display)
		if(stat != DEAD)
			var/amount = round( 100 - sunder , 5)
			hud_used.alien_sunder_display.icon_state = "sunder[amount]"
			switch(amount)
				if(80 to 100)
					hud_used.alien_sunder_display.overlays += image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "sunder_warn0")
					update_overlays(hud_used.alien_sunder_display)
				if(60 to 80)
					hud_used.alien_sunder_display.overlays += image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "sunder_warn1")
					update_overlays(hud_used.alien_sunder_display)
				if(40 to 60)
					hud_used.alien_sunder_display.overlays += image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "sunder_warn2")
					update_overlays(hud_used.alien_sunder_display)
				if(20 to 40)
					hud_used.alien_sunder_display.overlays += image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "sunder_warn3")
					update_overlays(hud_used.alien_sunder_display)
				if(0 to 20)
					hud_used.alien_sunder_display.overlays += image('modular_RUtgmc/icons/mob/screen/alien_better.dmi', icon_state = "sunder_warn4")
					update_overlays(hud_used.alien_sunder_display)
		else
			hud_used.alien_sunder_display.icon_state = "sunder0"

	interactee?.check_eye(src)

	return TRUE

/mob/living/carbon/xenomorph/updatehealth()
	. = ..()

	handle_regular_health_hud_updates()
