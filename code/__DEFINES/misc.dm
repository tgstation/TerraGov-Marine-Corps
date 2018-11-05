
//for all defines that doesn't fit in any other file.


//dirt type for each turf types.

#define NO_DIRT				0
#define DIRT_TYPE_GROUND	1
#define DIRT_TYPE_MARS		2
#define DIRT_TYPE_SNOW		3

//wet floors

#define FLOOR_WET_WATER	1
#define FLOOR_WET_LUBE	2
#define FLOOR_WET_ICE	3

//subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

#define RESIZE_DEFAULT_SIZE 1

/var/static/global_unique_id = 1
#define UNIQUEID (global_unique_id++)