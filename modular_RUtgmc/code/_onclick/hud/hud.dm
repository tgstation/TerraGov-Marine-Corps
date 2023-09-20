/datum/hud
	var/atom/movable/screen/alien_evolve_display
	var/atom/movable/screen/alien_sunder_display

/datum/hud/Destroy()
	alien_evolve_display = null

	return ..()
