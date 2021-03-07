
#define COMSIG_MOB_HUDMAP_TOGGLED "mob_hudmap_toggle"

#define MINIMAP_FLAG_XENO (1<<0)
#define MINIMAP_FLAG_MARINE (1<<1)
#define MINIMAP_FLAG_ALPHA (1<<2)
#define MINIMAP_FLAG_BRAVO (1<<3)
#define MINIMAP_FLAG_CHARLIE (1<<4)
#define MINIMAP_FLAG_DELTA (1<<5)
#define MINIMAP_FLAG_ALL (MINIMAP_FLAG_XENO|MINIMAP_FLAG_MARINE|MINIMAP_FLAG_ALPHA|MINIMAP_FLAG_BRAVO|MINIMAP_FLAG_CHARLIE|MINIMAP_FLAG_DELTA)

///Converts the overworld x and y to minimap x and y values
#define MINIMAP_PIXEL_FROM_WORLD(val) (val*2-3)

//actual size of a users screen in pixels
#define SCREEN_PIXEL_SIZE 480

GLOBAL_LIST_INIT(all_minimap_flags, bitfield2list(MINIMAP_FLAG_ALL))

#define MINIMAP_SOLID		"#ebe5e5ee"
#define MINIMAP_DOOR		"#451e5eb8"
#define MINIMAP_FENCE		"#8d2294ad"
#define MINIMAP_AREA		"#66666699"

#define MINIMAP_AREA_ENGI "#c16604e7"
#define MINIMAP_AREA_MEDBAY "#3dbf75ee"
#define MINIMAP_AREA_SEC "#a22d2dee"
#define MINIMAP_AREA_CAVES "#656060b1"
#define MINIMAP_AREA_JUNGLE "#2b5b2bee"
#define MINIMAP_AREA_COLONY "#6c6767ee"
#define MINIMAP_AREA_LZ "#ebe5e5ee"
