#define CHANGETURF_DEFER_CHANGE (1<<0)
#define CHANGETURF_IGNORE_AIR (1<<1) // This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_FORCEOP (1<<2)
#define CHANGETURF_SKIP (1<<3) // A flag for PlaceOnTop to just instance the new turf instead of calling ChangeTurf. Used for uninitialized turfs NOTHING ELSE
#define CHANGETURF_KEEP_WEEDS (1<<4) /// keep xeno nodes when changing turfs, instead of removing them

#define IS_OPAQUE_TURF(turf) (turf.directional_opacity == ALL_CARDINALS)

//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
///Returns a list of turf in a square
#define RANGE_TURFS(RADIUS, CENTER) \
	RECT_TURFS(RADIUS, RADIUS, CENTER)

#define RECT_TURFS(H_RADIUS, V_RADIUS, CENTER) \
	block( \
	(CENTER).x - (H_RADIUS), (CENTER).y - (V_RADIUS), (CENTER).z, \
	(CENTER).x + (H_RADIUS), (CENTER).y + (V_RADIUS), (CENTER).z \
	)

///Returns all turfs in a zlevel
#define Z_TURFS(ZLEVEL) block(1, 1, ZLEVEL, world.maxx, world.maxy, ZLEVEL)

///Returns all currently loaded turfs
#define ALL_TURFS(...) block(1, 1, 1, world.maxx, world.maxy, world.maxz)

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))

/// Returns a list of turfs in the rectangle specified by BOTTOM LEFT corner and height/width, checks for being outside the world border for you
#define CORNER_BLOCK(corner, width, height) CORNER_BLOCK_OFFSET(corner, width, height, 0, 0)

/// Returns a list of turfs similar to CORNER_BLOCK but with offsets
#define CORNER_BLOCK_OFFSET(corner, width, height, offset_x, offset_y) ((block(corner.x + offset_x, corner.y + offset_y, corner.z, corner.x + (width - 1) + offset_x, corner.y + (height - 1) + offset_y, corner.z)))

/// Returns an outline (neighboring turfs) of the given block
#define CORNER_OUTLINE(corner, width, height) ( \
	CORNER_BLOCK_OFFSET(corner, width + 2, 1, -1, -1) + \
	CORNER_BLOCK_OFFSET(corner, width + 2, 1, -1, height) + \
	CORNER_BLOCK_OFFSET(corner, 1, height, -1, 0) + \
	CORNER_BLOCK_OFFSET(corner, 1, height, width, 0))

/// Returns a list of around us
#define TURF_NEIGHBORS(turf) (CORNER_BLOCK_OFFSET(turf, 3, 3, -1, -1) - turf)

/// Makes the set turf transparent
#define ADD_TURF_TRANSPARENCY(modturf, source) \
	if(!HAS_TRAIT(modturf, TURF_Z_TRANSPARENT_TRAIT)) { modturf.AddElement(/datum/element/turf_z_transparency) }; \
	ADD_TRAIT(modturf, TURF_Z_TRANSPARENT_TRAIT, (source))

/// Removes the transparency from the set turf
#define REMOVE_TURF_TRANSPARENCY(modturf, source) \
	REMOVE_TRAIT(modturf, TURF_Z_TRANSPARENT_TRAIT, (source)); \
	if(!HAS_TRAIT(modturf, TURF_Z_TRANSPARENT_TRAIT)) { modturf.RemoveElement(/datum/element/turf_z_transparency) }
