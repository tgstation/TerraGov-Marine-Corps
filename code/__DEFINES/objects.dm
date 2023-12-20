// Doors!
#define DOOR_CRUSH_DAMAGE 10

/*
	Atmos Machinery
*/
#define MAX_SIPHON_FLOWRATE 2500	//L/s	This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE 200		//L/s	Max flow rate when scrubbing from a turf.

//These balance how easy or hard it is to create huge pressure gradients with pumps and filters. Lower values means it takes longer to create large pressures differences.
//Has no effect on pumping gasses from high pressure to low, only from low to high. Must be between 0 and 1.
#define ATMOS_PUMP_EFFICIENCY 2.5
#define ATMOS_FILTER_EFFICIENCY 2.5

//will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINUMUM_MOLES_TO_PUMP 0.01
#define MINUMUM_MOLES_TO_FILTER 0.1

//The flow rate/effectiveness of various atmos devices is limited by their internal volume, so for many atmos devices these will control maximum flow rates in L/s
#define ATMOS_DEFAULT_VOLUME_PUMP 200	//L
#define ATMOS_DEFAULT_VOLUME_FILTER 200	//L
#define ATMOS_DEFAULT_VOLUME_MIXER 200	//L
#define ATMOS_DEFAULT_VOLUME_PIPE 70	//L

// bitflags for machine stat variable
#define BROKEN (1<<0)
#define NOPOWER (1<<1)
#define POWEROFF (1<<2)		// tbd
#define MAINT (1<<3)		// under maintaince
#define EMPED (1<<4)		// temporary broken by EMP pulse
#define PANEL_OPEN (1<<5)
#define DISABLED (1<<6)		// can be fixed with a welder; removes density. Used primary to stop otherwise indestructible computers from obstructing pathing.
#define KNOCKED_DOWN (1<<7) //Is knocked over, does not affect operational capacity.
#define MACHINE_DO_NOT_PROCESS (1<<8) //Do not added these to processing queue.

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL 50
#define MAX_STACK_AMOUNT_GLASS 50
#define MAX_STACK_AMOUNT_RODS 60

//Pulse levels, very simplified
#define PULSE_NONE 0	//so !M.pulse checks would be possible
#define PULSE_SLOW 1	//<60 bpm
#define PULSE_NORM 2	//60-90 bpm
#define PULSE_FAST 3	//90-120 bpm
#define PULSE_2FAST 4	//>120 bpm
#define PULSE_THREADY 5	//occurs during hypovolemic shock

//proc/get_pulse methods
#define GETPULSE_HAND 0	//less accurate (hand)
#define GETPULSE_TOOL 1	//more accurate (med scanner, sleeper, etc)

GLOBAL_LIST_INIT(restricted_camera_networks, list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"thunder",
	"ERT",
	"NUKE"
	))


// Diagonal movement for movable atoms
#define FIRST_DIAG_STEP 1
#define SECOND_DIAG_STEP 2

// Shuttle defines

#define SHUTTLE_OPTIMIZE_FACTOR_RECHARGE 0.75
#define SHUTTLE_OPTIMIZE_FACTOR_TRAVEL 0.5
#define SHUTTLE_COOLING_FACTOR_RECHARGE 0.5
#define SHUTTLE_FUEL_ENHANCE_FACTOR_TRAVEL 0.75


//sharp item defines
#define IS_NOT_SHARP_ITEM 0
#define IS_SHARP_ITEM_SIMPLE 1 //not easily usable to cut or slice. e.g. shard, wirecutters, spear
#define IS_SHARP_ITEM_ACCURATE 2 //knife, scalpel
#define IS_SHARP_ITEM_BIG 3 //fireaxe, hatchet, energy sword


//pry capable item defines
#define IS_PRY_CAPABLE_SIMPLE 1
#define IS_PRY_CAPABLE_CROWBAR 2 //actual crowbar
#define IS_PRY_CAPABLE_FORCE 3 //can force open even powered airlocks

//plasma cutter

#define PLASMACUTTER_VLOW_MOD 0.1
#define PLASMACUTTER_CUT_DELAY 30
#define PLASMACUTTER_RESIN_MULTIPLIER 2.3
#define PLASMACUTTER_BASE_COST 1000

//MEDEVAC DEFINES
#define MEDEVAC_COOLDOWN 1500 //150 seconds or 2,5 minutes aka 2 minutes and 30 secs
#define MEDEVAC_TELE_DELAY 50 // 5 seconds
//Sentry defines
#define SENTRY_ALERT_AMMO 1
#define SENTRY_ALERT_HOSTILE 2
#define SENTRY_ALERT_FALLEN 3
#define SENTRY_ALERT_DAMAGE 4
#define SENTRY_ALERT_DESTROYED 6
#define SENTRY_ALERT_DELAY 20 SECONDS
#define SENTRY_DAMAGE_ALERT_DELAY 4 SECONDS
#define SENTRY_LIGHT_POWER 7

//Scout cloak defines
#define SCOUT_CLOAK_ENERGY 100
#define SCOUT_CLOAK_STEALTH_DELAY 30
#define SCOUT_CLOAK_RUN_DRAIN 5
#define SCOUT_CLOAK_WALK_DRAIN 1
#define SCOUT_CLOAK_ACTIVE_RECOVERY -5 //You only get this once every obj tick, so it'll be comparable to the inactive value
#define SCOUT_CLOAK_INACTIVE_RECOVERY 5
#define SCOUT_CLOAK_COOLDOWN 100
#define SCOUT_CLOAK_TIMER 50
#define SCOUT_CLOAK_RUN_ALPHA 128
#define SCOUT_CLOAK_WALK_ALPHA 38
#define SCOUT_CLOAK_STILL_ALPHA 13
#define SCOUT_CLOAK_MAX_ENERGY 100
#define SCOUT_CLOAK_OFF_DAMAGE (1 << 0)
#define SCOUT_CLOAK_OFF_ATTACK (1 << 1)
//B18 DEFINES
#define B18_CHEM_COOLDOWN 2.5 MINUTES
#define B18_CHEM_MOD 0.5
#define B18_BRUTE_CODE 1
#define B18_BURN_CODE 2
#define B18_OXY_CODE 3
#define B18_TOX_CODE 4
#define B18_PAIN_CODE 5
#define B18_DAMAGE_MIN 50
#define B18_DAMAGE_MAX 150
#define B18_PAIN_MIN 50
#define B18_PAIN_MAX 150


//Razor wire

#define RAZORWIRE_BASE_DAMAGE 40
#define RAZORWIRE_ENTANGLE_DELAY 5 SECONDS
#define RAZORWIRE_SOAK 5
#define RAZORWIRE_MAX_HEALTH 100
#define RAZORWIRE_MIN_DAMAGE_MULT_LOW 0.4 //attacking
#define RAZORWIRE_MAX_DAMAGE_MULT_LOW 0.6
#define RAZORWIRE_MIN_DAMAGE_MULT_MED 0.8 //climbing into, disentangling or crusher charging it
#define RAZORWIRE_MAX_DAMAGE_MULT_MED 1.2
#define RAZORWIRE_MIN_DAMAGE_MULT_HIGH 1.6 //pouncing into it
#define RAZORWIRE_MAX_DAMAGE_MULT_HIGH 2.4

//Flares

#define FLARE_BRIGHTNESS 5

//Scope accuracy defines
#define SCOPE_RAIL 0.4
#define SCOPE_RAIL_MINI 0.2
#define SCOPE_RAIL_SNIPER 0.5


//Hypospray

#define HYPOSPRAY_INJECT_MODE_DRAW 0
#define HYPOSPRAY_INJECT_MODE_INJECT 1


//Lighter

#define LIGHTER_LUMINOSITY 2

//Tank

#define TANK_OVERDRIVE_BOOST_DURATION 5 SECONDS
#define TANK_OVERDRIVE_BOOST_COOLDOWN 20 SECONDS

//Closets
#define CLOSET_ALLOW_OBJS (1<<0)
#define CLOSET_ALLOW_DENSE_OBJ (1<<1)
#define CLOSET_IS_SECURE (1<<2)

#define STACK_WEIGHT_STEPS 3 //Currently weight updates in 3 intervals

#define STYLE_STANDARD 1
#define STYLE_BLUESPACE 2
#define STYLE_CENTCOM 3
#define STYLE_SYNDICATE 4
#define STYLE_BLUE 5
#define STYLE_CULT 6
#define STYLE_MISSILE 7
#define STYLE_RED_MISSILE 8
#define STYLE_BOX 9
#define STYLE_HONK 10
#define STYLE_FRUIT 11
#define STYLE_INVISIBLE 12
#define STYLE_GONDOLA 13
#define STYLE_SEETHROUGH 14

#define POD_ICON_STATE 1
#define POD_NAME 2
#define POD_DESC 3
#define POD_NUMBER 4

//For fob drone
#define EJECT_PLASTEEL 0
#define EJECT_METAL 1

//Item sprite variants
#define ITEM_JUNGLE_VARIANT (1<<0)
#define ITEM_ICE_VARIANT (1<<1)
#define ITEM_ICE_PROTECTION (1<<2)
#define ITEM_PRISON_VARIANT (1<<3)
#define ITEM_DESERT_VARIANT (1<<4)

#define ITEM_UNEQUIP_FAIL 0
#define ITEM_UNEQUIP_DROPPED 1
#define ITEM_UNEQUIP_UNEQUIPPED 2

//suit sensors: sensor_mode defines
#define SENSOR_OFF 0
#define SENSOR_LIVING 1
#define SENSOR_VITALS 2
#define SENSOR_COORDS 3

//suit sensors: has_sensor defines
#define BROKEN_SENSORS -1
#define NO_SENSORS 0
#define HAS_SENSORS 1
#define LOCKED_SENSORS 2

//Drop pods

///This number + standard alamo launch time is when droppods are allowed to launch
#define DROPPOD_DEPLOY_DELAY 10 MINUTES

//Lights define
#define CHECKS_PASSED 1
#define STILL_ON_COOLDOWN 2
#define NIGHTFALL_IMMUNE 3
#define NO_LIGHT_STATE_CHANGE 4

//Xeno turrets define
#define TURRET_SCAN_RANGE 25
#define TURRET_SCAN_FREQUENCY 10 SECONDS
#define TURRET_HEALTH_REGEN 8

//Unmanned vehicle define
#define OVERLAY_TURRET (1<<0)
#define HAS_HEADLIGHTS (1<<1)
#define GIVE_NIGHT_VISION (1<<2)

//Motion detector define
#define MOTION_DETECTOR_HOSTILE "hostile"
#define MOTION_DETECTOR_FRIENDLY "friendly"
#define MOTION_DETECTOR_DEAD "dead"

//Repair define
#define BELOW_INTEGRITY_THRESHOLD "below integrity threshold"

//light tile defines
#define LIGHT_TILE_OK 0
#define LIGHT_TILE_FLICKERING 1
#define LIGHT_TILE_BREAKING 2
#define LIGHT_TILE_BROKEN 3

//Teleporter array defines
#define TELEPORTER_ARRAY_INOPERABLE "teleporter_array_inoperable"
#define TELEPORTER_ARRAY_INACTIVE "teleporter_array_inactive"
#define TELEPORTER_ARRAY_READY "teleporter_array_ready"
#define TELEPORTER_ARRAY_IN_USE "teleporter_array_in_use"

#define DROPPOD_READY 1
#define DROPPOD_ACTIVE 2
#define DROPPOD_LANDED 3

//cameras
#define SOM_CAMERA_NETWORK "som_camera_network"
