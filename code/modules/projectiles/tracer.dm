/obj/effect/projectile
	name = "pew"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = ""
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = 0

///Scale the effect
/obj/effect/projectile/proc/scale_to(nx, ny, override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Scale(nx,ny)
	transform = M

///Turn the effect
/obj/effect/projectile/proc/turn_to(angle, override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Turn(angle)
	transform = M

/obj/effect/projectile/New(loc, angle_override, p_x, p_y, scaling = 1, effect_icon)
	. = ..()
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	look.icon_state = effect_icon
	appearance = look
	scale_to(1, scaling, FALSE)
	turn_to(angle_override, FALSE)
