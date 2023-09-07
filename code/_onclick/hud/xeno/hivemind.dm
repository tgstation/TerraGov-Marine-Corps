/datum/hud/hivemind/New(mob/living/carbon/xenomorph/hivemind/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	alien_plasma_display = new /atom/movable/screen/alien/plasmadisplay()
	alien_plasma_display.alpha = ui_alpha
	infodisplay += alien_plasma_display

	healths = new /atom/movable/screen/healths/alien()
	healths.alpha = ui_alpha
	infodisplay += healths

	locate_leader = new /atom/movable/screen/alien/queen_locator()
	locate_leader.icon = 'icons/mob/screen/alien_better.dmi'
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader
