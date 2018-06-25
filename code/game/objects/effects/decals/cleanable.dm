/obj/effect/decal/cleanable
	mouse_opacity = 0 //So that players trying to shoot in close-quarters don't end up smacking the blood stains with their gun.
	var/list/random_icon_states = list()
	var/targeted_by = null			// Used so cleanbots can't claim a mess.

/obj/effect/decal/cleanable/New()
	if (random_icon_states && length(src.random_icon_states) > 0)
		src.icon_state = pick(src.random_icon_states)
	..()
