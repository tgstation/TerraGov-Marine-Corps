/obj/effect/abstract/ripple
	name = ""
	desc = ""
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	mouse_opacity = FALSE
	alpha = 0

/obj/effect/abstract/ripple/Initialize(mapload, time_left)
	. = ..()
	animate(src, alpha=255, time=time_left)
	addtimer(CALLBACK(src, PROC_REF(stop_animation)), 8, TIMER_CLIENT_TIME)

/obj/effect/abstract/ripple/proc/stop_animation()
	icon_state = "shieldsparkles"
