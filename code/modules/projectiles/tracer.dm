/atom/movable/hitscan_projectile_effect
	name = "pew"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = ""
	layer = ABOVE_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = KEEP_TOGETHER
	move_resist = INFINITY
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 1

/atom/movable/hitscan_projectile_effect/Initialize(mapload, angle_override, p_x, p_y, scaling = 1, effect_icon, laser_color)
	. = ..()
	set_light_color(laser_color)
	set_light_on(TRUE)
	icon_state = effect_icon
	add_overlay(emissive_appearance(icon, icon_state, src, attached = TRUE))
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
