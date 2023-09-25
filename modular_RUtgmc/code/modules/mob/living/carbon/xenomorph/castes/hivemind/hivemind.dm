/obj/structure/xeno/hivemindcore
	plane = FLOOR_PLANE

/mob/living/carbon/xenomorph/hivemind/updatehealth()
	. = ..()

	handle_regular_hud_updates()
