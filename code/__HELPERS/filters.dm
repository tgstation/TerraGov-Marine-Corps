#define ICON_NOT_SET "Not Set"

//This is stored as a nested list instead of datums or whatever because it json encodes nicely for usage in tgui
GLOBAL_LIST_INIT(master_filter_info, list(
	"alpha" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"icon" = ICON_NOT_SET,
			"render_source" = "",
			"flags" = 0
		),
		"flags" = list(
			"MASK_INVERSE" = MASK_INVERSE,
			"MASK_SWAP" = MASK_SWAP
		)
	),
	"angular_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1
		)
	),
	"bloom" = list(
		"defaults" = list(
			"threshold" = COLOR_BLACK,
			"size" = 1,
			"offset" = 0,
			"alpha" = 255
		)
	),
	/* Not supported because making a proper matrix editor on the frontend would be a huge dick pain.
		Uncomment if you ever implement it
	"color" = list(
		"defaults" = list(
			"color" = matrix(),
			"space" = FILTER_COLOR_RGB
		)
	),
	*/
	"displace" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = null,
			"icon" = ICON_NOT_SET,
			"render_source" = ""
		)
	),
	"drop_shadow" = list(
		"defaults" = list(
			"x" = 1,
			"y" = -1,
			"size" = 1,
			"offset" = 0,
			"color" = COLOR_HALF_TRANSPARENT_BLACK
		)
	),
	"blur" = list(
		"defaults" = list(
			"size" = 1
		)
	),
	"layer" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"icon" = ICON_NOT_SET,
			"render_source" = "",
			"flags" = FILTER_OVERLAY,
			"color" = "",
			"transform" = null,
			"blend_mode" = BLEND_DEFAULT
		)
	),
	"motion_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0
		)
	),
	"outline" = list(
		"defaults" = list(
			"size" = 0,
			"color" = COLOR_BLACK,
			"flags" = NONE
		),
		"flags" = list(
			"OUTLINE_SHARP" = OUTLINE_SHARP,
			"OUTLINE_SQUARE" = OUTLINE_SQUARE
		)
	),
	"radial_blur" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 0.01
		)
	),
	"rays" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 16,
			"color" = COLOR_WHITE,
			"offset" = 0,
			"density" = 10,
			"threshold" = 0.5,
			"factor" = 0,
			"flags" = FILTER_OVERLAY | FILTER_UNDERLAY
		),
		"flags" = list(
			"FILTER_OVERLAY" = FILTER_OVERLAY,
			"FILTER_UNDERLAY" = FILTER_UNDERLAY
		)
	),
	"ripple" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1,
			"repeat" = 2,
			"radius" = 0,
			"falloff" = 1,
			"flags" = NONE
		),
		"flags" = list(
			"WAVE_BOUNDED" = WAVE_BOUNDED
		)
	),
	"wave" = list(
		"defaults" = list(
			"x" = 0,
			"y" = 0,
			"size" = 1,
			"offset" = 0,
			"flags" = NONE
		),
		"flags" = list(
			"WAVE_SIDEWAYS" = WAVE_SIDEWAYS,
			"WAVE_BOUNDED" = WAVE_BOUNDED
		)
	)
))

#undef ICON_NOT_SET

//Helpers to generate lists for filter helpers
//This is the only practical way of writing these that actually produces sane lists
/proc/alpha_mask_filter(x, y, icon/icon, render_source, flags)
	. = list("type" = "alpha")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(flags))
		.["flags"] = flags

/proc/angular_blur_filter(x, y, size)
	. = list("type" = "angular_blur")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size

/proc/color_matrix_filter(matrix/in_matrix, space)
	. = list("type" = "color")
	.["color"] = in_matrix
	if(!isnull(space))
		.["space"] = space

/proc/displacement_map_filter(icon, render_source, x, y, size = 32)
	. = list("type" = "displace")
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size

/proc/drop_shadow_filter(x, y, size, offset, color)
	. = list("type" = "drop_shadow")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(size))
		.["size"] = size
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(color))
		.["color"] = color

/proc/gauss_blur_filter(size)
	. = list("type" = "blur")
	if(!isnull(size))
		.["size"] = size

/proc/bloom_filter(threshold, size, offset, alpha)
	. = list("type" = "bloom")
	if(!isnull(threshold))
		.["threshold"] = threshold
	if(!isnull(size))
		.["size"] = size
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(alpha))
		.["alpha"] = alpha

/proc/layering_filter(icon, render_source, x, y, flags, color, transform, blend_mode)
	. = list("type" = "layer")
	if(!isnull(icon))
		.["icon"] = icon
	if(!isnull(render_source))
		.["render_source"] = render_source
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(color))
		.["color"] = color
	if(!isnull(flags))
		.["flags"] = flags
	if(!isnull(transform))
		.["transform"] = transform
	if(!isnull(blend_mode))
		.["blend_mode"] = blend_mode

/proc/motion_blur_filter(x, y)
	. = list("type" = "motion_blur")
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/outline_filter(size, color, flags)
	. = list("type" = "outline")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(color))
		.["color"] = color
	if(!isnull(flags))
		.["flags"] = flags

/proc/radial_blur_filter(size, x, y)
	. = list("type" = "radial_blur")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/rays_filter(size, color, offset, density, threshold, factor, x, y, flags)
	. = list("type" = "rays")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(color))
		.["color"] = color
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(density))
		.["density"] = density
	if(!isnull(threshold))
		.["threshold"] = threshold
	if(!isnull(factor))
		.["factor"] = factor
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(flags))
		.["flags"] = flags

/proc/ripple_filter(radius, size, falloff, repeat, x, y, flags)
	. = list("type" = "ripple")
	if(!isnull(radius))
		.["radius"] = radius
	if(!isnull(size))
		.["size"] = size
	if(!isnull(falloff))
		.["falloff"] = falloff
	if(!isnull(repeat))
		.["repeat"] = repeat
	if(!isnull(flags))
		.["flags"] = flags
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y

/proc/wave_filter(x, y, size, offset, flags)
	. = list("type" = "wave")
	if(!isnull(size))
		.["size"] = size
	if(!isnull(x))
		.["x"] = x
	if(!isnull(y))
		.["y"] = y
	if(!isnull(offset))
		.["offset"] = offset
	if(!isnull(flags))
		.["flags"] = flags

/proc/apply_wibbly_filters(atom/in_atom, length)
	for(var/i in 1 to 7)
		//This is a very baffling and strange way of doing this but I am just preserving old functionality
		var/X
		var/Y
		var/rsq
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900) // Yeah let's just loop infinitely due to bad luck what's the worst that could happen?
		var/random_roll = rand()
		in_atom.add_filter("wibbly-[i]", 5, wave_filter(x = X, y = Y, size = rand() * 2.5 + 0.5, offset = random_roll))
		var/filter = in_atom.get_filter("wibbly-[i]")
		animate(filter, offset = random_roll, time = 0, loop = -1, flags = ANIMATION_PARALLEL)
		animate(offset = random_roll - 1, time = rand() * 20 + 10)

/proc/remove_wibbly_filters(atom/in_atom)
	var/filter
	for(var/i in 1 to 7)
		filter = in_atom.get_filter("wibbly-[i]")
		animate(filter)
		in_atom.remove_filter("wibbly-[i]")

/obj/effect/abstract/normalmap_bumpy
	icon = 'icons/effects/128x128.dmi'
	icon_state = "normalmap_bumpy"
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	plane = GRAVITY_PULSE_PLANE
	blocks_emissive = EMISSIVE_BLOCK_NONE

/**
 * Adds a warping effect to the provided atom, while making it invisible
 * Note: alpha on the target decreases the strength of the effect
 * Also overrides any render target on the target atom temporarily while active
 * do we want to consider a managed render target thing for this?
 * @param invis_atom The atom to apply the effect to
 * @param strength The strength of the effect, 100 is highest, 0 means no effect
 */
/atom/movable/proc/become_warped_invisible(strength=100)
	if(HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
		CRASH("already warped invis, fix your code")
	var/obj/effect/abstract/normalmap_bumpy/normal_bumpy = new(src)
	var/render_tgt = "*warped_invis_[REF(normal_bumpy)]"
	if(render_target)
		render_tgt += "_oldtgt_" + render_target
	normal_bumpy.alpha = (255/100) * strength
	render_target = render_tgt
	apply_wibbly_filters(normal_bumpy)
	normal_bumpy.add_filter("mask", 1, alpha_mask_filter(-48, -48, render_source = render_target))
	vis_contents += normal_bumpy
	ADD_TRAIT(src, TRAIT_WARPED_INVISIBLE, TRAIT_GENERIC)
	RegisterSignal(src, COMSIG_ATOM_POST_UPDATE_OVERLAYS, PROC_REF(on_warped_overlays))
	update_appearance(UPDATE_OVERLAYS)

///signal handler to remove any emissives while we're warped invis
/atom/movable/proc/on_warped_overlays(atom/movable/source, list/new_overlays)
	SIGNAL_HANDLER
	for(var/image/img AS in new_overlays)
		if(PLANE_TO_TRUE(img.plane) == EMISSIVE_PLANE)
			new_overlays -= img

///Stops the warped invisibility effect
/atom/movable/proc/stop_warped_invisible()
	if(!HAS_TRAIT(src, TRAIT_WARPED_INVISIBLE))
		return
	var/list/split_result = splittext(render_target, "_oldtgt_")
	var/ref_part = split_result[1]
	if(length(split_result) > 1)
		var/old_part = split_result[2]
		render_target = old_part
	else
		render_target = null
	ref_part = copytext(ref_part, 15)
	var/obj/effect/abstract/normalmap_bumpy/normal_bumpy = locate(ref_part) in vis_contents
	vis_contents -= normal_bumpy
	qdel(normal_bumpy)
	REMOVE_TRAIT(src, TRAIT_WARPED_INVISIBLE, TRAIT_GENERIC)
	UnregisterSignal(src, COMSIG_ATOM_POST_UPDATE_OVERLAYS)
