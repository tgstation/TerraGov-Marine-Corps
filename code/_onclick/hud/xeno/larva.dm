/datum/hud/larva/New(mob/living/carbon/xenomorph/larva/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/mov_intent/alien(null, src)
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/alien/nightvision(null, src)
	using.alpha = ui_alpha
	infodisplay += using

	healths = new /atom/movable/screen/healths/alien(null, src)
	healths.alpha = ui_alpha
	infodisplay += healths

	locate_leader = new /atom/movable/screen/alien/queen_locator(null, src)
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader
