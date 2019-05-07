/datum/hud/larva/New(mob/living/carbon/Xenomorph/Larva/owner)
	..()
	var/obj/screen/using

	using = new /obj/screen/mov_intent/alien()
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/alien/nightvision()
	infodisplay += using

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	locate_leader = new /obj/screen/alien/queen_locator()
	infodisplay += locate_leader



/mob/living/carbon/Xenomorph/Larva/create_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/larva(src)