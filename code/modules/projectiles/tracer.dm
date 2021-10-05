/atom/movable/hitscan_projectile_effect
	name = "pew"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = ""
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = NONE

///Scale the effect
/atom/movable/hitscan_projectile_effect/proc/scale_to(x_scale_factor, y_scale_factor, override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Scale(x_scale_factor, y_scale_factor)
	transform = M

///Turn the effect
/atom/movable/hitscan_projectile_effect/proc/turn_to(angle, override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Turn(angle)
	transform = M

/atom/movable/hitscan_projectile_effect/Initialize(loc, angle_override, p_x, p_y, scaling = 1, effect_icon)
	. = ..()
	icon_state = effect_icon
	pixel_x = p_x
	pixel_y = p_y
	scale_to(1, scaling, FALSE)
	turn_to(angle_override, FALSE)
