/obj/effect/projectile
	name = "pew"
	icon = 'icons/obj/items/projectiles.dmi'
	icon_state = "nothing"
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

/obj/effect/projectile/New(loc, angle_override, p_x, p_y, color_override, scaling = TRUE)
	. = ..()
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
	appearance = look
	scale_to(1,scaling, FALSE)
	turn_to(angle_override, FALSE)

/obj/effect/projectile/laser
	name = "laser"
	icon_state = "beam"

/obj/effect/projectile/laser_blue
	icon_state = "beam_blue"

