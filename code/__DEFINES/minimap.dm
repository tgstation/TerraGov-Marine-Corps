
#define MINIMAP_FLAG_XENO (1<<0)
#define MINIMAP_FLAG_MARINE (1<<1)
#define MINIMAP_FLAG_MARINE_REBEL (1<<2)
#define MINIMAP_FLAG_MARINE_SOM (1<<3)
#define MINIMAP_FLAG_EXCAVATION_ZONE (1<<4)
#define MINIMAP_FLAG_ALL (1<<5) - 1

///Converts the overworld x and y to minimap x and y values
#define MINIMAP_PIXEL_FROM_WORLD(val) (val*2-3)

//actual size of a users screen in pixels
#define SCREEN_PIXEL_SIZE 480

GLOBAL_LIST_INIT(all_minimap_flags, bitfield2list(MINIMAP_FLAG_ALL))

//Drawing tool colors
#define MINIMAP_DRAWING_RED "#ff0000"
#define MINIMAP_DRAWING_YELLOW "#FFFF00"
#define MINIMAP_DRAWING_PURPLE "#A020F0"
#define MINIMAP_DRAWING_BLUE "#0000FF"


//Turf colours
#define MINIMAP_SOLID "#ebe5e5ee"
#define MINIMAP_DOOR "#451e5eee"
#define MINIMAP_FENCE "#8c2294ee"
#define MINIMAP_LAVA "#db4206d0"
#define MINIMAP_DIRT "#9c906dd0"
#define MINIMAP_SNOW "#c4e3e9d0"
#define MINIMAP_MARS_DIRT "#aa5f44d0"
#define MINIMAP_ICE "#93cae0d0"
#define MINIMAP_WATER "#94b0d59c" //lower opacity as its really bright

//Area colours
#define MINIMAP_AREA_ENGI "#c19504d0"
#define MINIMAP_AREA_ENGI_CAVE "#5a4501d0"
#define MINIMAP_AREA_MEDBAY "#3dbf75d0"
#define MINIMAP_AREA_MEDBAY_CAVE "#17472cd0"
#define MINIMAP_AREA_SEC "#a22d2dd0"
#define MINIMAP_AREA_SEC_CAVE "#421313d0"
#define MINIMAP_AREA_RESEARCH "#812da2d0"
#define MINIMAP_AREA_RESEARCH_CAVE "#2d1342d0"
#define MINIMAP_AREA_COMMAND "#2d3fa2d0"
#define MINIMAP_AREA_COMMAND_CAVE "#132242d0"
#define MINIMAP_AREA_CAVES "#3f3c3cd0"
#define MINIMAP_AREA_JUNGLE "#2b5b2bd0"
#define MINIMAP_AREA_COLONY "#6c6767d0"
#define MINIMAP_AREA_LZ "#ebe5e5d0"
#define MINIMAP_AREA_REQ "#936824d0"
#define MINIMAP_AREA_REQ_CAVE "#503914d0"
#define MINIMAP_AREA_PREP "#5b92e5d0"
#define MINIMAP_AREA_ESCAPE "#446791d0"
#define MINIMAP_AREA_LIVING "#2a9201d0"
#define MINIMAP_AREA_LIVING_CAVE "#195700d0"

//Prison
#define MINIMAP_AREA_CELL_MAX "#570101d0"
#define MINIMAP_AREA_CELL_HIGH "#a54b01d0"
#define MINIMAP_AREA_CELL_MED "#997102d0"
#define MINIMAP_AREA_CELL_LOW "#5a9201d0"
#define MINIMAP_AREA_CELL_VIP "#00857ad0"
#define MINIMAP_AREA_SHIP "#885a04d0"
