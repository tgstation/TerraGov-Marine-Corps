/datum/hud/larva/New(mob/living/carbon/xenomorph/larva/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/mov_intent/alien()
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	healths = new /atom/movable/screen/healths/alien()
	healths.alpha = ui_alpha
	infodisplay += healths

	alien_evolve_display = new /atom/movable/screen/alien/evolvehud()
	alien_evolve_display.alpha = ui_alpha
	infodisplay += alien_evolve_display

	locate_leader = new /atom/movable/screen/alien/queen_locator()
	locate_leader.icon = 'icons/mob/screen/alien_better.dmi'
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader
