/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = RESIST_ALL | PROJECTILE_IMMUNE
	move_resist = INFINITY

/obj/effect/add_debris_element() //they're not hittable, and prevents recursions
	return
