/datum/hud/hivemind/New(mob/living/carbon/xenomorph/hivemind/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/obj/screen/using

	using = new /obj/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	alien_plasma_display = new /obj/screen/alien/plasmadisplay()
	alien_plasma_display.alpha = ui_alpha
	infodisplay += alien_plasma_display

	healths = new /obj/screen/healths/alien()
	healths.alpha = ui_alpha
	infodisplay += healths

	locate_leader = new /obj/screen/alien/queen_locator()
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader
