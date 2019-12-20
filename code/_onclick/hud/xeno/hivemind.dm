/datum/hud/hivemind/New(mob/living/carbon/xenomorph/larva/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/obj/screen/using

	using = new /obj/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	locate_leader = new /obj/screen/alien/queen_locator()
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader
