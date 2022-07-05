
//Filters
#define AMBIENT_OCCLUSION filter(type="drop_shadow", x=0, y=-2, size=4, color="#04080FAA")
#define GAUSSIAN_BLUR(filter_size) filter(type="blur", size=filter_size)

//https://secure.byond.com/docs/ref/info.html#/atom/var/mouse_opacity
#define MOUSE_OPACITY_TRANSPARENT 0
#define MOUSE_OPACITY_ICON 1
#define MOUSE_OPACITY_OPAQUE 2

//defines for atom layers

//the hardcoded ones are AREA_LAYER = 1, TURF_LAYER = 2, OBJ_LAYER = 3, MOB_LAYER = 4, FLY_LAYER = 5

//#define AREA_LAYER 1

//#define TURF_LAYER 2

//NEVER HAVE ANYTHING BELOW THIS PLANE ADJUST IF YOU NEED MORE SPACE
#define LOWEST_EVER_PLANE -200

#define CLICKCATCHER_PLANE -99

#define PLANE_SPACE -95
#define PLANE_SPACE_PARALLAX -90

#define GRAVITY_PULSE_PLANE -11
#define GRAVITY_PULSE_RENDER_TARGET "*GRAVPULSE_RENDER_TARGET"

#define OPENSPACE_LAYER 18 //Openspace layer over all
#define OPENSPACE_PLANE -9 //Openspace plane below all turfs
#define OPENSPACE_BACKDROP_PLANE -8 //Black square just over openspace plane to guaranteed cover all in openspace turf

#define FLOOR_PLANE -5
#define GAME_PLANE -4

#define BLACKNESS_PLANE 0 //To keep from conflicts with SEE_BLACKNESS internals

#define SPACE_LAYER 1.8

#define UNDER_TURF_LAYER 1.99
#define ABOVE_TURF_LAYER 2.01
#define ABOVE_OPEN_TURF_LAYER 2.04
#define ABOVE_NORMAL_TURF_LAYER 2.08
#define LATTICE_LAYER 2.15

#define ANIMAL_HIDING_LAYER 2.2

#define DISPOSAL_PIPE_LAYER 2.25
#define GAS_PIPE_HIDDEN_LAYER 2.35

#define BELOW_ATMOS_PIPE_LAYER 2.37
#define ATMOS_PIPE_SCRUBBER_LAYER 2.38
#define ATMOS_PIPE_SUPPLY_LAYER 2.39
#define ATMOS_PIPE_LAYER 2.4

#define GAS_SCRUBBER_LAYER 2.41
#define GAS_PIPE_VISIBLE_LAYER 2.42
#define GAS_FILTER_LAYER 2.43
#define GAS_PUMP_LAYER 2.44

#define WIRE_LAYER 2.45
#define WIRE_TERMINAL_LAYER 2.46

#define LOW_OBJ_LAYER 2.5
#define UNDERFLOOR_OBJ_LAYER 2.5 //bluespace beacon, navigation beacon, etc

#define CATWALK_LAYER 2.51 //catwalk overlay of /turf/open/floor/plating/plating_catwalk
#define HOLOPAD_LAYER 2.515 //layer for the holopads so they render over catwalks, yet still get covered like regular floor.
#define XENO_WEEDS_LAYER 2.52 //weed layer so that it goes above catwalks

#define ATMOS_DEVICE_LAYER 2.53 //vents, connector ports, atmos devices that should be above pipe layer.

#define FIREDOOR_OPEN_LAYER 2.549		//Right under poddoors
#define PODDOOR_OPEN_LAYER 2.55		//Under doors and virtually everything that's "above the floor"

#define CONVEYOR_LAYER 2.56 //conveyor belt

#define TALL_GRASS_LAYER 2.5 //tall grass

#define RESIN_STRUCTURE_LAYER 2.6

#define LADDER_LAYER 2.7

#define WINDOW_FRAME_LAYER 2.72

#define XENO_HIDING_LAYER 2.75

#define BELOW_TABLE_LAYER 2.79
#define TABLE_LAYER 2.8
#define ABOVE_TABLE_LAYER 2.81

#define DOOR_OPEN_LAYER 2.85	//Under all objects if opened. 2.85 due to tables being at 2.8

#define DOOR_HELPER_LAYER 2.86 //keep this above OPEN_DOOR_LAYER

#define BELOW_OBJ_LAYER 2.98 //just below all items

#define LOWER_ITEM_LAYER 2.99 //for items that should be at the bottom of the pile of items

//#define OBJ_LAYER 3

#define UPPER_ITEM_LAYER 3.01 //for items that should be at the top of the pile of items

#define ABOVE_OBJ_LAYER 3.02 //just above all items

#define BUSH_LAYER 3.05

#define DOOR_CLOSED_LAYER 3.1	//Above most items if closed
#define FIREDOOR_CLOSED_LAYER 3.189		//Right under poddoors
#define PODDOOR_CLOSED_LAYER 3.19	//Above doors which are at 3.1


#define WINDOW_LAYER 3.2 //above closed doors
#define ABOVE_WINDOW_LAYER 3.3

#define WALL_OBJ_LAYER 3.5 //posters on walls

#define POWERLOADER_LAYER 3.6 //above windows and wall mounts so the top of the loader doesn't clip.

#define BELOW_MOB_LAYER 3.79
#define LYING_MOB_LAYER 3.8

#define ABOVE_LYING_MOB_LAYER 3.9 //drone (not the xeno)

//#define MOB_LAYER 4
#define RIVER_OVERLAY_LAYER 4.01

#define ABOVE_MOB_LAYER 4.1

#define TANK_BARREL_LAYER 4.2

#define TANK_TURRET_LAYER 4.27

#define TANK_DECORATION_LAYER 4.3

#define FACEHUGGER_LAYER 4.45

#define ABOVE_ALL_MOB_LAYER 4.5

//#define FLY_LAYER 5

#define WELDING_TOOL_EFFECT_LAYER 5.05
#define RIPPLE_LAYER 5.1

#define GHOST_LAYER 6
#define ABOVE_FLY_LAYER 6

#define LOW_LANDMARK_LAYER 9
#define MID_LANDMARK_LAYER 9.1
#define HIGH_LANDMARK_LAYER 9.2

#define LIGHTING_LAYER 10									//Drawing layer for lighting overlays
#define AREAS_LAYER 10 //for areas, so they appear above everything else on map file.

#define POINT_LAYER 12


#define CHAT_LAYER 12.0001 // Do not insert layers between these two values
#define CHAT_LAYER_MAX 12.9999


//---------- EMISSIVES -------------
//Layering order of these is not particularly meaningful.
//Important part is the seperation of the planes for control via plane_master

/// This plane masks out lighting to create an "emissive" effect, ie for glowing lights in otherwise dark areas.
#define EMISSIVE_PLANE 90
/// The render target used by the emissive layer.
#define EMISSIVE_RENDER_TARGET "*EMISSIVE_PLANE"
/// The layer you should use if you _really_ don't want an emissive overlay to be blocked.
#define EMISSIVE_LAYER_UNBLOCKABLE 9999

#define LIGHTING_BACKPLANE_LAYER 14.5

#define LIGHTING_PLANE 100
#define LIGHTING_RENDER_TARGET "LIGHT_PLANE"

#define SHADOW_RENDER_TARGET "SHADOW_RENDER_TARGET"

/// Plane for balloon text (text that fades up)
#define BALLOON_CHAT_PLANE 110

#define O_LIGHTING_VISUAL_PLANE 120
#define O_LIGHTING_VISUAL_LAYER 16
#define O_LIGHTING_VISUAL_RENDER_TARGET "O_LIGHT_VISUAL_PLANE"

#define LIGHTING_PRIMARY_LAYER 15	//The layer for the main lights of the station
#define LIGHTING_PRIMARY_DIMMER_LAYER 15.1	//The layer that dims the main lights of the station
#define LIGHTING_SECONDARY_LAYER 16	//The colourful, usually small lights that go on top

#define LIGHTING_SHADOW_LAYER 17	//Where the shadows happen

#define ABOVE_LIGHTING_PLANE 150
#define ABOVE_LIGHTING_LAYER 18


#define CAMERA_STATIC_PLANE 200
#define CAMERA_STATIC_LAYER 20


#define BELOW_FULLSCREEN_LAYER 20.9 //blip from motion detector

#define FULLSCREEN_LAYER 22
#define FULLSCREEN_IMPAIRED_LAYER 22.02 //visual impairment from wearing welding helmet, etc
#define FULLSCREEN_DRUGGY_LAYER 22.03
#define FULLSCREEN_BLURRY_LAYER 22.04
#define FULLSCREEN_INFECTION_LAYER	22.041 //purple cloud
#define FULLSCREEN_FLASH_LAYER 22.05 //flashed
#define FULLSCREEN_DAMAGE_LAYER 22.1 //red circles when hurt
#define FULLSCREEN_NERVES_LAYER 22.11 //red nerve-like lines
#define FULLSCREEN_BLIND_LAYER 22.15 //unconscious
#define FULLSCREEN_PAIN_LAYER	22.2 //pain flashes
#define FULLSCREEN_CRIT_LAYER 22.25 //in critical
#define FULLSCREEN_MACHINE_LAYER 22.3
#define FULLSCREEN_INTRO_LAYER 22.4 //black screen when you spawn

#define FULLSCREEN_PLANE 500


//-------------------- Rendering ---------------------
#define RENDER_PLANE_GAME 990
#define RENDER_PLANE_NON_GAME 995
#define RENDER_PLANE_MASTER 999


#define HUD_PLANE 1000
#define HUD_LAYER 24
#define ABOVE_HUD_PLANE 2000
#define ABOVE_HUD_LAYER 25

#define ADMIN_POPUP_LAYER 1

#define SPLASHSCREEN_LAYER 9999
#define SPLASHSCREEN_PLANE 9999
