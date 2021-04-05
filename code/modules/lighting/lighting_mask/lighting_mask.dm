#define LIGHTING_MASK_RADIUS 4
#define LIGHTING_MASK_SPRITE_SIZE LIGHTING_MASK_RADIUS * 64

/atom/movable/lighting_mask
	name = ""

	icon = LIGHTING_ICON_BIG
	icon_state  = "light_big"

	anchored = TRUE
	plane = LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = LIGHTING_SECONDARY_LAYER
	invisibility = INVISIBILITY_LIGHTING
	blend_mode = BLEND_ADD
	appearance_flags = KEEP_TOGETHER | RESET_TRANSFORM
	move_resist = INFINITY


	var/current_angle = 0

	//The radius of the mask
	var/radius = 0

	//The atom that we are attached to
	var/atom/attached_atom = null

	//Tracker var for the holder
	var/obj/effect/lighting_mask_holder/mask_holder

	//Tracker var for tracking init dupe requests
	var/awaiting_update = FALSE
	var/is_directional = FALSE
	var/must_rotate_with_owner = FALSE

/atom/movable/lighting_mask/Destroy()
	//Delete the holder object
	mask_holder = null
	//Remove reference to the atom we are attached to
	attached_atom = null
	//Continue with deletiib
	return ..()

/atom/movable/lighting_mask/proc/set_radius(radius, transform_time = 0)
	//Update our matrix
	var/matrix/M = get_matrix(radius)
	apply_matrix(M, transform_time)
	//Set the radius variable
	src.radius = radius
	//Calculate shadows
	calculate_lighting_shadows()
	//Update our holders thing
	mask_holder.update_matrix(M)

/atom/movable/lighting_mask/proc/apply_matrix(matrix/M, transform_time = 0)
	if(transform_time)
		animate(src, transform = M, time = transform_time)
	else
		transform = M

/atom/movable/lighting_mask/proc/get_matrix(radius = 1)
	var/matrix/M = new()
	//Scale
	// - Scale to the appropriate radius
	M.Scale(radius / LIGHTING_MASK_RADIUS)
	//Translate
	// - Center the overlay image
	// - Ok so apparently translate is affected by the scale we already did huh.
	// ^ Future me here, its because it works as translate then scale since its backwards.
	// ^ ^ Future future me here, it totally shouldnt since the translation component of a matrix is independant to the scale component.
	M.Translate(-128 + 16)
	//Adjust for pixel offsets
	var/invert_offsets = attached_atom.dir & (NORTH | EAST)
	var/left_or_right = attached_atom.dir & (EAST | WEST)
	var/offset_x = (left_or_right ? attached_atom.light_pixel_y : attached_atom.light_pixel_x) * (invert_offsets ? -1 : 1)
	var/offset_y = (left_or_right ? attached_atom.light_pixel_x : attached_atom.light_pixel_y) * (invert_offsets ? -1 : 1)
	M.Translate(offset_x, offset_y)
	if(is_directional)
		//Rotate
		// - Rotate (Directional lights)
		M.Turn(current_angle)
	return M

#define ROTATION_PARTS_PER_DECISECOND 1

///Rotates the light source to angle degrees.
/atom/movable/lighting_mask/proc/rotate(angle = 0)
	//Converting our transform is pretty simple.
	var/matrix/M = matrix()
	M.Turn(angle - current_angle)
	M *= transform
	//Overlays are in nullspace while applied, meaning their transform cannot be changed.
	//Disconnect the shadows from the overlay, apply the transform and then reapply them as an overlay.
	//Oh also since the matrix is really weird standard rotation matrices wont work here.
	overlays.Cut()
	//Disconnect from parent matrix, become a global position
	for(var/mutable_appearance/shadow AS in shadows)	//Mutable appearances are children of icon
		shadow.transform *= transform
		shadow.transform /= M
	//Apply our matrix
	transform = M
	//Readd the shadow overlays.
	overlays += shadows
	//Now we are facing this direction
	current_angle = angle

///Setter proc for colors
/atom/movable/lighting_mask/proc/set_color(colour = "#ffffff")
	color = colour

///Setter proc for the intensity of the mask
/atom/movable/lighting_mask/proc/set_intensity(intensity = 1)
	if(intensity >= 0)
		alpha = ALPHA_TO_INTENSITY(intensity)
		blend_mode = BLEND_ADD
	else
		alpha = ALPHA_TO_INTENSITY(-intensity)
		blend_mode = BLEND_SUBTRACT

///The holder atom turned, spin the mask if it's needed
/atom/movable/lighting_mask/proc/rotate_mask_on_holder_turn(new_direction)
	rotate(dir2angle(new_direction) - 180)

//Flicker

/atom/movable/lighting_mask/flicker
	icon_state = "light_flicker"

///Conical Light
/atom/movable/lighting_mask/conical
	icon_state = "light_conical"
	is_directional = TRUE
	must_rotate_with_owner = TRUE

//Rotating Light

/atom/movable/lighting_mask/rotating
	icon_state = "light_rotating-1"

/atom/movable/lighting_mask/rotating/Initialize(mapload, ...)
	. = ..()
	icon_state = "light_rotating-[rand(1, 3)]"

/*
//Client light
//It just works
/atom/movable/lighting_mask/personal_light
	var/mob/owner

/atom/movable/lighting_mask/personal_light/proc/give_owner(mob/_owner)
	owner = _owner
	var/image/blank = image(loc = src)
	blank.override = TRUE
	remove_alt_appearance("nightvision")
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/allbutone, "nightvision", blank, owner)
*/


/atom/movable/lighting_mask/ex_act(severity, target)
	return

/atom/movable/lighting_mask/fire_act(exposed_temperature, exposed_volume)
	return

#undef LIGHTING_MASK_SPRITE_SIZE
