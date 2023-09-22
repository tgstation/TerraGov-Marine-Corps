/atom/movable/screen/alien/nightvision
	icon = 'modular_RUtgmc/icons/mob/screen/alien_better.dmi'

/atom/movable/screen/alien/queen_locator
	icon = 'modular_RUtgmc/icons/mob/screen/alien_better.dmi'

/atom/movable/screen/alien/plasmadisplay
	name = "plasma stored"
	icon = 'modular_RUtgmc/icons/mob/screen/alien_better.dmi'
	icon_state = "power_display_20"

/atom/movable/screen/alien/evolvehud
	icon = 'modular_RUtgmc/icons/mob/screen/alien_better.dmi'
	name = "Evolve Status"
	desc = "Click for evolve panel."
	icon_state = "evolve_empty"
	screen_loc = ui_evolvehud

/atom/movable/screen/alien/evolvehud/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = usr
	X.Evolve()

/atom/movable/screen/alien/sunderhud
	icon = 'modular_RUtgmc/icons/mob/screen/alien_better.dmi'
	icon_state = "sunder0"
	screen_loc = ui_sunderhud

/datum/hud/alien/New(mob/living/carbon/xenomorph/owner, ui_style, ui_color, ui_alpha = 230)
	..()

	alien_evolve_display = new /atom/movable/screen/alien/evolvehud()
	alien_evolve_display.alpha = ui_alpha
	infodisplay += alien_evolve_display

	alien_sunder_display = new /atom/movable/screen/alien/sunderhud()
	alien_sunder_display.alpha = ui_alpha
	infodisplay += alien_sunder_display
