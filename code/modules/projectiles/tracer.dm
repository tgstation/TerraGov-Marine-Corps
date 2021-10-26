/atom/movable/hitscan_projectile_effect
	name = "pew"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = ""
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = NONE

/atom/movable/hitscan_projectile_effect/Initialize(loc, angle_override, p_x, p_y, scaling = 1, effect_icon)
	. = ..()
	icon_state = effect_icon
	pixel_x = p_x
	pixel_y = p_y
	var/matrix/M = transform
	M.Turn(angle_override)
	M.Scale(1, scaling)
	transform = M

///Signal handler to delete this effect
/atom/movable/hitscan_projectile_effect/proc/remove_effect()
	SIGNAL_HANDLER
	qdel(src)
