///Lighting mask sprite radius in tiles
#define LIGHTING_MASK_RADIUS 4
///Lighting mask sprite diameter in pixels
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
	appearance_flags = KEEP_TOGETHER|RESET_TRANSFORM
	move_resist = INFINITY

	///The current angle the item is pointing at
	var/current_angle = 0

	///The radius of illumination of the mask
	var/radius = 0

	///The atom that we are attached to, does not need hard del protection as we are deleted with it
	var/atom/attached_atom

	///Reference to the holder /atom/movable/effect
	var/atom/movable/effect/lighting_mask_holder/mask_holder

	///Prevents us from registering for update twice before SSlighting init
	var/awaiting_update = FALSE
	///Set to TRUE if you want the light to rotate with the owner
	var/is_directional = FALSE

/atom/movable/lighting_mask/Initialize(mapload, ...)
	. = ..()
	add_filter("pixel_smoother", 3, gauss_blur_filter(2))
	add_filter("shadow_alpha_masking", 4, alpha_mask_filter(render_source = SHADOW_RENDER_TARGET, flags = MASK_INVERSE))

/atom/movable/lighting_mask/Destroy()
	mask_holder = null
	attached_atom = null
	return ..()

///Sets the radius of the mask, and updates everything that needs to be updated
/atom/movable/lighting_mask/proc/set_radius(new_radius, transform_time = 0)
	//Update our matrix
	var/matrix/new_size_matrix = get_matrix(new_radius)
	apply_matrix(new_size_matrix, transform_time)
	radius = new_radius
	//then recalculate and redraw
	queue_mask_update()

///if you want the matrix to grow or shrink, you can do that using this proc when applyng it
/atom/movable/lighting_mask/proc/apply_matrix(matrix/to_apply, transform_time = 0)
	if(transform_time)
		animate(src, transform = to_apply, time = transform_time)
	else
		transform = to_apply

///Creates a matrix for the lighting mak to use
/atom/movable/lighting_mask/proc/get_matrix(radius = 1)
	var/matrix/new_size_matrix = new()
	//Scale
	// - Scale to the appropriate radius
	new_size_matrix.Scale(radius / LIGHTING_MASK_RADIUS)
	//Translate
	// - Center the overlay image
	// - Ok so apparently translate is affected by the scale we already did huh.
	// ^ Future me here, its because it works as translate then scale since its backwards.
	// ^ ^ Future future me here, it totally shouldnt since the translation component of a matrix is independant to the scale component.
	new_size_matrix.Translate(-128 + 16)
	//Adjust for pixel offsets
	var/invert_offsets = attached_atom.dir & (NORTH | EAST)
	var/left_or_right = attached_atom.dir & (EAST | WEST)
	var/offset_x = (left_or_right ? attached_atom.light_pixel_y : attached_atom.light_pixel_x) * (invert_offsets ? -1 : 1)
	var/offset_y = (left_or_right ? attached_atom.light_pixel_x : attached_atom.light_pixel_y) * (invert_offsets ? -1 : 1)
	new_size_matrix.Translate(offset_x, offset_y)
	if(is_directional)
		//Rotate
		// - Rotate (Directional lights)
		new_size_matrix.Turn(current_angle)
	return new_size_matrix

///Rotates the light source to angle degrees.
/atom/movable/lighting_mask/proc/rotate(angle = 0)
	//Converting our transform is pretty simple.
	var/matrix/rotated_matrix = matrix()
	rotated_matrix.Turn(angle - current_angle)
	rotated_matrix *= transform
	//Overlays cannot be edited while applied, meaning their transform cannot be changed.
	//Disconnect the shadows from the overlay, apply the transform and then reapply them as an overlay.
	//Oh also since the matrix is really weird standard rotation matrices wont work here.
	overlays.Cut()
	//Disconnect from parent matrix, become a global position
	for(var/mutable_appearance/shadow AS in shadows)	//Mutable appearances are children of icon
		shadow.transform *= transform
		shadow.transform /= rotated_matrix
	//Apply our matrix
	transform = rotated_matrix
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

///The holder atom turned, spins the mask if it's needed
/atom/movable/lighting_mask/proc/rotate_mask_on_holder_turn(new_direction)
	SIGNAL_HANDLER
	rotate(dir2angle(new_direction) - 180)

///Flickering lighting mask
/atom/movable/lighting_mask/flicker
	icon_state = "light_flicker"

///Conical Light mask
/atom/movable/lighting_mask/conical
	icon_state = "light_conical"
	is_directional = TRUE

///Rotating Light mask
/atom/movable/lighting_mask/rotating
	icon_state = "light_rotating-1"

/atom/movable/lighting_mask/rotating/Initialize(mapload, ...)
	. = ..()
	icon_state = "light_rotating-[rand(1, 3)]"

///rotating light mask, but only pointing in one direction
/atom/movable/lighting_mask/rotating_conical
	icon_state = "light_conical_rotating"

/atom/movable/lighting_mask/ex_act(severity, target)
	return

/atom/movable/lighting_mask/fire_act(exposed_temperature, exposed_volume)
	return

#undef LIGHTING_MASK_SPRITE_SIZE
#undef LIGHTING_MASK_RADIUS
