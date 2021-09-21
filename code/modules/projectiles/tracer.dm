/proc/generate_tracer_between_points(datum/point/starting, datum/point/ending, beam_type, color, qdel_in = 5, light_range = 2, light_color_override, light_intensity = 1, instance_key) //Do not pass z-crossing points as that will not be properly (and likely will never be properly until it's absolutely needed) supported!
	if(!istype(starting) || !istype(ending) || !ispath(beam_type))
		return
	var/datum/point/midpoint = point_midpoint_points(starting, ending)
	var/obj/effect/projectile/PB = new beam_type(angle_between_points(starting, ending), midpoint.return_px(), midpoint.return_py(), color, pixel_length_between_points(starting, ending) / world.icon_size, midpoint.return_turf(), 0)
	if(isnull(light_color_override))
		light_color_override = color
	. = PB
	if(qdel_in)
		QDEL_IN(PB, qdel_in)

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

/obj/effect/projectile/New(loc, angle_override, p_x, p_y, color_override, scaling = TRUE, increment)
	. = ..()
	if(!angle_override || !p_x || !p_y || !color_override || !scaling)
		return
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
	appearance = look
	scale_to(1,scaling, FALSE)
	turn_to(angle_override, FALSE)
	for(var/i in 1 to increment)
		pixel_x += round((sin(angle_override)+16*sin(angle_override)*2), 1)
		pixel_y += round((cos(angle_override)+16*cos(angle_override)*2), 1)

/obj/effect/projectile/laser
	name = "laser"
	icon_state = "beam"

/obj/effect/projectile/laser_blue
	icon_state = "beam_blue"

