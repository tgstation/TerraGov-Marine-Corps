/datum/hud/larva/New(mob/living/carbon/xenomorph/larva/owner, ui_alpha = 230)
	..()
	var/obj/screen/using

	using = new /obj/screen/mov_intent/alien()
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	healths = new /obj/screen/healths/alien()
	healths.alpha = ui_alpha
	infodisplay += healths

	locate_leader = new /obj/screen/alien/queen_locator()
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader



/mob/living/carbon/xenomorph/larva/create_hud()
	if(client && !hud_used)
		var/ui_alpha = client.prefs.ui_style_alpha
		hud_used = new /datum/hud/larva(src, ui_alpha)