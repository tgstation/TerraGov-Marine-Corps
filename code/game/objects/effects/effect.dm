/obj/effect
	icon = 'icons/effects/effects.dmi'
	resistance_flags = RESIST_ALL | PROJECTILE_IMMUNE
	move_resist = INFINITY

/obj/effect/add_debris_element() //they're not hittable, and prevents recursions
	return

/obj/effect/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	return
