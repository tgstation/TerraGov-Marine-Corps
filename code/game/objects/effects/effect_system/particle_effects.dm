

//the objects used by /datum/effect_system

/obj/effect/particle_effect
	name = "effect"
	icon = 'icons/effects/effects.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	allow_pass_flags = PASS_LOW_STRUCTURE|PASS_GRILLE|PASS_MOB

/obj/effect/particle_effect/water
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "extinguish"
	var/life = 15
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/particle_effect/water/Move(atom/newloc, direction, glide_size_override)
	if (--life < 1)
		qdel(src)
	if(newloc.density)
		return FALSE
	return ..()

/obj/effect/particle_effect/water/Bump(atom/A)
	if(reagents)
		reagents.reaction(A)
	return ..()
