/obj/effect/abstract/ripple
	name = "ship shadow"
	desc = "Something is arriving\
		It's probably best not to be on top of these \
		when whatever is arriving comes through."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shadow"
	anchored = TRUE
	density = FALSE
	layer = RIPPLE_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 0

/obj/effect/abstract/ripple/Initialize(mapload, time_left)
	. = ..()
	notify_ai_hazard()
	animate(src, alpha=150, time=time_left)
