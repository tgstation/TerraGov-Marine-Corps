// This is where the fun begins.
// These are the main datums that emit light.

/datum/static_light_source
	///The atom we're emitting light from (for example a mob if we're from a flashlight that's being held).
	var/atom/top_atom
	///The atom that we belong to.
	var/atom/source_atom

	///The turf under the source atom.
	var/turf/source_turf
	///The turf the top_atom appears to over.
	var/turf/pixel_turf
	///Intensity of the emitter light.
	var/light_power
	/// The range of the emitted light.
	var/light_range
	/// The colour of the light, string, decomposed by parse_light_color()
	var/light_color
	// Variables for keeping track of the colour.
	var/lum_r
	var/lum_g
	var/lum_b

	// The lumcount values used to apply the light.
	var/tmp/applied_lum_r
	var/tmp/applied_lum_g
	var/tmp/applied_lum_b

	/// List used to store how much we're affecting corners.
	var/list/datum/static_lighting_corner/effect_str

	/// Whether we have applied our light yet or not.
	var/applied = FALSE

	/// whether we are to be added to SSlighting's static_sources_queue list for an update
	var/needs_update = LIGHTING_NO_UPDATE

// Thanks to Lohikar for flinging this tiny bit of code at me, increasing my brain cell count from 1 to 2 in the process.
// This macro will only offset up to 1 tile, but anything with a greater offset is an outlier and probably should handle its own lighting offsets.
// Anything pixelshifted 16px or more will be considered on the next tile.
#define GET_APPROXIMATE_PIXEL_DIR(PX, PY) ((!(PX) ? 0 : ((PX >= 16 ? EAST : (PX <= -16 ? WEST : 0)))) | (!PY ? 0 : (PY >= 16 ? NORTH : (PY <= -16 ? SOUTH : 0))))
#define UPDATE_APPROXIMATE_PIXEL_TURF var/_mask = GET_APPROXIMATE_PIXEL_DIR(top_atom.pixel_x, top_atom.pixel_y); pixel_turf = _mask ? (get_step(source_turf, _mask) || source_turf) : source_turf

/datum/static_light_source/New(atom/owner, atom/top)
	source_atom = owner // Set our new owner.
	LAZYADD(source_atom.static_light_sources, src)
	top_atom = top
	if (top_atom != source_atom)
		LAZYADD(top_atom.static_light_sources, src)

	source_turf = top_atom
	UPDATE_APPROXIMATE_PIXEL_TURF

	light_power = source_atom.light_power
	light_range = source_atom.light_range
	light_color = source_atom.light_color

	PARSE_LIGHT_COLOR(src)

	update()

/datum/static_light_source/Destroy(force)
	remove_lum()
	if (source_atom)
		LAZYREMOVE(source_atom.static_light_sources, src)

	if (top_atom)
		LAZYREMOVE(top_atom.static_light_sources, src)

	SSlighting.static_sources_queue -= src
	return ..()

// Yes this doesn't align correctly on anything other than 4 width tabs.
// If you want it to go switch everybody to elastic tab stops.
// Actually that'd be great if you could!
#define EFFECT_UPDATE(level)                \
	if (needs_update == LIGHTING_NO_UPDATE) \
		SSlighting.static_sources_queue += src; \
	if (needs_update < level)               \
		needs_update = level;    \


/// This proc will cause the light source to update the top atom, and add itself to the update queue.
/datum/static_light_source/proc/update(atom/new_top_atom)
	// This top atom is different.
	if (new_top_atom && new_top_atom != top_atom)
		if(top_atom != source_atom && top_atom.static_light_sources) // Remove ourselves from the light sources of that top atom.
			LAZYREMOVE(top_atom.static_light_sources, src)

		top_atom = new_top_atom

		if (top_atom != source_atom)
			LAZYADD(top_atom.static_light_sources, src) // Add ourselves to the light sources of our new top atom.

	EFFECT_UPDATE(LIGHTING_CHECK_UPDATE)

/// Will force an update without checking if it's actually needed.
/datum/static_light_source/proc/force_update()
	EFFECT_UPDATE(LIGHTING_FORCE_UPDATE)

/// Will cause the light source to recalculate turfs that were removed or added to visibility only.
/datum/static_light_source/proc/vis_update()
	EFFECT_UPDATE(LIGHTING_VIS_UPDATE)

// Macro that applies light to a new corner.
// It is a macro in the interest of speed, yet not having to copy paste it.
// If you're wondering what's with the backslashes, the backslashes cause BYOND to not automatically end the line.
// As such this all gets counted as a single line.
// The braces and semicolons are there to be able to do this on a single line.

//Original lighting falloff calculation. This looks the best out of the three. However, this is also the most expensive.
//#define LUM_FALLOFF(C, T) (1 - CLAMP01(sqrt((C.x - T.x) ** 2 + (C.y - T.y) ** 2 + LIGHTING_HEIGHT) / max(1, light_range)))

//Cubic lighting falloff. This has the *exact* same range as the original lighting falloff calculation, down to the exact decimal, but it looks a little unnatural due to the harsher falloff and how it's generally brighter across the board.
//#define LUM_FALLOFF(C, T) (1 - CLAMP01((((C.x - T.x) * (C.x - T.x)) + ((C.y - T.y) * (C.y - T.y)) + LIGHTING_HEIGHT) / max(1, light_range*light_range)))

//Linear lighting falloff. This resembles the original lighting falloff calculation the best, but results in lights having a slightly larger range, which is most noticable with large light sources. This also results in lights being diamond-shaped, fuck. This looks the darkest out of the three due to how lights are brighter closer to the source compared to the original falloff algorithm. This falloff method also does not at all take into account lighting height, as it acts as a flat reduction to light range with this method.
//#define LUM_FALLOFF(C, T) (1 - CLAMP01(((abs(C.x - T.x) + abs(C.y - T.y))) / max(1, light_range+1)))

//Linear lighting falloff but with an octagonal shape in place of a diamond shape. Lummox JR please add pointer support.
#define GET_LUM_DIST(DISTX, DISTY) (DISTX + DISTY + abs(DISTX - DISTY)*0.4)
// This exists so we can cache the vars used in this macro, and save MASSIVE time :)
// Most of this is saving off datum var accesses, tho some of it does actually cache computation
// You will NEED to call this before you call APPLY_CORNER
#define SETUP_CORNERS_CACHE(lighting_source) \
	var/_turf_x = lighting_source.pixel_turf.x; \
	var/_turf_y = lighting_source.pixel_turf.y; \
	var/_range_divisor = max(1, lighting_source.light_range); \
	var/_light_power = lighting_source.light_power; \
	var/_applied_lum_r = lighting_source.applied_lum_r; \
	var/_applied_lum_g = lighting_source.applied_lum_g; \
	var/_applied_lum_b = lighting_source.applied_lum_b; \
	var/_lum_r = lighting_source.lum_r; \
	var/_lum_g = lighting_source.lum_g; \
	var/_lum_b = lighting_source.lum_b; \

#define SETUP_CORNERS_REMOVAL_CACHE(lighting_source) \
	var/_applied_lum_r = lighting_source.applied_lum_r; \
	var/_applied_lum_g = lighting_source.applied_lum_g; \
	var/_applied_lum_b = lighting_source.applied_lum_b;

#define LUM_FALLOFF(C) (1 - CLAMP01(sqrt((C.x - _turf_x) ** 2 + (C.y - _turf_y) ** 2 + LIGHTING_HEIGHT) / _range_divisor))

#define APPLY_CORNER(C)                          \
	. = LUM_FALLOFF(C);              \
	. *= _light_power;                            \
	var/OLD = effect_str[C];                     \
	C.update_lumcount                            \
	(                                            \
		(. * _lum_r) - (OLD * _applied_lum_r),     \
		(. * _lum_g) - (OLD * _applied_lum_g),     \
		(. * _lum_b) - (OLD * _applied_lum_b)      \
	);

#define REMOVE_CORNER(C)                         \
	. = -effect_str[C];                          \
	C.update_lumcount                            \
	(                                            \
		. * _applied_lum_r,                       \
		. * _applied_lum_g,                       \
		. * _applied_lum_b                        \
	);

/// This is the define used to calculate falloff.
/datum/static_light_source/proc/remove_lum()
	SETUP_CORNERS_REMOVAL_CACHE(src)
	applied = FALSE
	for(var/datum/static_lighting_corner/corner AS in effect_str)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)

	effect_str = null

/datum/static_light_source/proc/recalc_corner(datum/static_lighting_corner/corner)
	SETUP_CORNERS_CACHE(src)
	LAZYINITLIST(effect_str)
	if (effect_str[corner]) // Already have one.
		REMOVE_CORNER(corner)
		effect_str[corner] = 0

	APPLY_CORNER(corner)
	effect_str[corner] = .

// Keep in mind. Lighting corners accept the bottom left (northwest) set of cords to them as input
#define GENERATE_MISSING_CORNERS(gen_for) \
	if (!gen_for.lighting_corner_NE) { \
		gen_for.lighting_corner_NE = new /datum/static_lighting_corner(gen_for.x, gen_for.y, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_SE) { \
		gen_for.lighting_corner_SE = new /datum/static_lighting_corner(gen_for.x, gen_for.y - 1, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_SW) { \
		gen_for.lighting_corner_SW = new /datum/static_lighting_corner(gen_for.x - 1, gen_for.y - 1, gen_for.z); \
	} \
	if (!gen_for.lighting_corner_NW) { \
		gen_for.lighting_corner_NW = new /datum/static_lighting_corner(gen_for.x - 1, gen_for.y, gen_for.z); \
	} \
	gen_for.lighting_corners_initialised = TRUE;

/datum/static_light_source/proc/update_corners()
	var/update = FALSE
	var/atom/source_atom = src.source_atom

	if (QDELETED(source_atom))
		qdel(src)
		return

	if (source_atom.light_power != light_power)
		light_power = source_atom.light_power
		update = TRUE

	if (source_atom.light_range != light_range)
		light_range = source_atom.light_range
		update = TRUE

	if (!top_atom)
		top_atom = source_atom
		update = TRUE

	if (!light_range || !light_power)
		qdel(src)
		return

	if (isturf(top_atom))
		if (source_turf != top_atom)
			source_turf = top_atom
			UPDATE_APPROXIMATE_PIXEL_TURF
			update = TRUE
	else if (top_atom.loc != source_turf)
		source_turf = top_atom.loc
		UPDATE_APPROXIMATE_PIXEL_TURF
		update = TRUE
	else
		var/pixel_loc = get_turf_pixel(top_atom)
		if (pixel_loc != pixel_turf)
			pixel_turf = pixel_loc
			update = TRUE

	if (!isturf(source_turf))
		if (applied)
			remove_lum()
		return

	if (light_range && light_power && !applied)
		update = TRUE

	if (source_atom.light_color != light_color)
		light_color = source_atom.light_color
		PARSE_LIGHT_COLOR(src)
		update = TRUE

	else if (applied_lum_r != lum_r || applied_lum_g != lum_g || applied_lum_b != lum_b)
		update = TRUE

	if (update)
		needs_update = LIGHTING_CHECK_UPDATE
		applied = TRUE
	else if (needs_update == LIGHTING_CHECK_UPDATE)
		return //nothing's changed

	var/list/datum/static_lighting_corner/corners = list()
	if (source_turf)
		var/oldlum = source_turf.luminosity
		source_turf.luminosity = CEILING(light_range, 1)
		for(var/turf/T in view(CEILING(light_range, 1), source_turf))
			if(IS_OPAQUE_TURF(T))
				continue
			if (!T.lighting_corners_initialised)
				GENERATE_MISSING_CORNERS(T)

			corners[T.lighting_corner_NE] = 0
			corners[T.lighting_corner_SE] = 0
			corners[T.lighting_corner_SW] = 0
			corners[T.lighting_corner_NW] = 0
		source_turf.luminosity = oldlum

	SETUP_CORNERS_CACHE(src)

	var/list/datum/static_lighting_corner/new_corners = (corners - src.effect_str)
	LAZYINITLIST(src.effect_str)
	var/list/effect_str = src.effect_str
	if (needs_update == LIGHTING_VIS_UPDATE)
		for (var/datum/static_lighting_corner/corner AS in new_corners)
			APPLY_CORNER(corner)
			if (. != 0)
				LAZYADD(corner.affecting, src)
				effect_str[corner] = .
	else
		for (var/datum/static_lighting_corner/corner AS in new_corners)
			APPLY_CORNER(corner)
			if (. != 0)
				LAZYADD(corner.affecting, src)
				effect_str[corner] = .

		// New corners are a subset of corners. so if they're both the same length, there are NO old corners!
		if(length(corners) != length(new_corners))
			for (var/datum/static_lighting_corner/corner as anything in corners - new_corners) // Existing corners
				APPLY_CORNER(corner)
				if (. != 0)
					effect_str[corner] = .
				else
					LAZYREMOVE(corner.affecting, src)
					effect_str -= corner
	var/list/datum/static_lighting_corner/gone_corners = effect_str - corners
	for (var/datum/static_lighting_corner/corner AS in gone_corners)
		REMOVE_CORNER(corner)
		LAZYREMOVE(corner.affecting, src)
	effect_str -= gone_corners

	applied_lum_r = lum_r
	applied_lum_g = lum_g
	applied_lum_b = lum_b

	UNSETEMPTY(src.effect_str)

#undef EFFECT_UPDATE
#undef LUM_FALLOFF
#undef GET_LUM_DIST
#undef REMOVE_CORNER
#undef APPLY_CORNER
#undef SETUP_CORNERS_REMOVAL_CACHE
#undef SETUP_CORNERS_CACHE
#undef GENERATE_MISSING_CORNERS
