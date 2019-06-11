// Doors!
#define DOOR_CRUSH_DAMAGE 10

/*
	Atmos Machinery
*/
#define MAX_SIPHON_FLOWRATE		2500	//L/s	This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE	200		//L/s	Max flow rate when scrubbing from a turf.

//These balance how easy or hard it is to create huge pressure gradients with pumps and filters. Lower values means it takes longer to create large pressures differences.
//Has no effect on pumping gasses from high pressure to low, only from low to high. Must be between 0 and 1.
#define ATMOS_PUMP_EFFICIENCY	2.5
#define ATMOS_FILTER_EFFICIENCY	2.5

//will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINUMUM_MOLES_TO_PUMP	0.01
#define MINUMUM_MOLES_TO_FILTER	0.1

//The flow rate/effectiveness of various atmos devices is limited by their internal volume, so for many atmos devices these will control maximum flow rates in L/s
#define ATMOS_DEFAULT_VOLUME_PUMP	200	//L
#define ATMOS_DEFAULT_VOLUME_FILTER	200	//L
#define ATMOS_DEFAULT_VOLUME_MIXER	200	//L
#define ATMOS_DEFAULT_VOLUME_PIPE	70	//L

// bitflags for machine stat variable
#define BROKEN		(1<<0)
#define NOPOWER		(1<<1)
#define POWEROFF	(1<<2)		// tbd
#define MAINT		(1<<3)		// under maintaince
#define EMPED		(1<<4)		// temporary broken by EMP pulse
#define PANEL_OPEN	(1<<5)
#define MACHINE_DO_NOT_PROCESS 32768 //Do not added these to processing queue.

#define ENGINE_EJECT_Z	3

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

var/list/liftable_structures = list(
	/obj/machinery/autolathe,
	/obj/machinery/constructable_frame,
	/obj/machinery/portable_atmospherics/hydroponics,
	/obj/machinery/computer,
	/obj/machinery/optable,
	/obj/structure/dispenser,
	/obj/machinery/gibber,
	/obj/machinery/microwave,
	/obj/machinery/vending,
	/obj/machinery/seed_extractor,
	/obj/machinery/space_heater,
	/obj/machinery/recharge_station,
	/obj/machinery/flasher,
	/obj/structure/bed/stool,
	/obj/structure/closet,
	/obj/machinery/photocopier,
	/obj/structure/filingcabinet,
	/obj/structure/reagent_dispensers,
	/obj/machinery/portable_atmospherics/canister)

//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
//feel free to add shit to lists below
var/list/tachycardics = list("coffee", "inaprovaline", "hyperzine", "nitroglycerin", "thirteenloko", "nicotine")	//increase heart rate
var/list/bradycardics = list("neurotoxin", "cryoxadone", "clonexadone", "space_drugs", "sleeptoxin")					//decrease heart rate
var/list/heartstopper = list("potassium_phorochloride", "zombie_powder") //this stops the heart
var/list/cheartstopper = list("potassium_chloride") //this stops the heart when overdose is met -- c = conditional

//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

var/list/RESTRICTED_CAMERA_NETWORKS = list( //Those networks can only be accessed by preexisting terminals. AIs and new terminals can't use them.
	"thunder",
	"ERT",
	"NUKE"
	)

#define STASIS_IN_BAG 		1
#define STASIS_IN_CRYO_CELL 2


// Diagonal movement for movable atoms
#define FIRST_DIAG_STEP 	1
#define SECOND_DIAG_STEP 	2

// Shuttle defines

#define SHUTTLE_OPTIMIZE_FACTOR_RECHARGE 0.75
#define SHUTTLE_OPTIMIZE_FACTOR_TRAVEL 0.5
#define SHUTTLE_COOLING_FACTOR_RECHARGE 0.5
#define SHUTTLE_FUEL_ENHANCE_FACTOR_TRAVEL 0.75


//sharp item defines
#define IS_SHARP_ITEM_SIMPLE 		1 //not easily usable to cut or slice. e.g. shard, wirecutters, spear
#define IS_SHARP_ITEM_ACCURATE		2 //knife, scalpel
#define IS_SHARP_ITEM_BIG			3 //fireaxe, hatchet, energy sword


//pry capable item defines
#define IS_PRY_CAPABLE_SIMPLE		1
#define IS_PRY_CAPABLE_CROWBAR		2 //actual crowbar
#define IS_PRY_CAPABLE_FORCE		3 //can force open even powered airlocks

//plasma cutter

#define PLASMACUTTER_MIN_MOD	0.01
#define PLASMACUTTER_VLOW_MOD	0.1
#define PLASMACUTTER_LOW_MOD	0.5
#define PLASMACUTTER_HIGH_MOD	2
#define PLASMACUTTER_VHIGH_MOD	3
#define PLASMACUTTER_CUT_DELAY	30
#define PLASMACUTTER_RESIN_MULTIPLIER	4
#define PLASMACUTTER_BASE_COST	1000

//flags_token & tokensupport
//used for coins and vendors, restricting specific tokens to associated vendors.

#define TOKEN_GENERAL			1
#define TOKEN_MARINE			2
#define TOKEN_ENGI				4
#define TOKEN_SPEC				8
#define TOKEN_ALL				15

//MEDEVAC DEFINES
#define MEDEVAC_COOLDOWN		3000 //300 seconds or 5 minutes
#define MEDEVAC_TELE_DELAY		50 //5 seconds
//Sentry defines
#define SENTRY_ALERT_AMMO				1
#define SENTRY_ALERT_HOSTILE			2
#define SENTRY_ALERT_FALLEN				3
#define SENTRY_ALERT_DAMAGE				4
#define SENTRY_ALERT_BATTERY			5
#define SENTRY_ALERT_DELAY				20 SECONDS
#define SENTRY_DAMAGE_ALERT_DELAY		5 SECONDS


//Scout cloak defines
#define SCOUT_CLOAK_ENERGY	100
#define SCOUT_CLOAK_STEALTH_DELAY 30
#define SCOUT_CLOAK_RUN_DRAIN	5
#define SCOUT_CLOAK_WALK_DRAIN	1
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
#define B18_CHEM_COOLDOWN				2.5 MINUTES
#define B18_CHEM_MOD					0.5
#define B18_BRUTE_CODE					1
#define B18_BURN_CODE					2
#define B18_OXY_CODE					3
#define B18_TOX_CODE					4
#define B18_PAIN_CODE					5
#define B18_DAMAGE_MIN					50
#define B18_DAMAGE_MAX					150
#define B18_PAIN_MIN					50
#define B18_PAIN_MAX					150


//Razor wire

#define RAZORWIRE_BASE_DAMAGE		40
#define RAZORWIRE_ENTANGLE_DELAY	5 SECONDS
#define RAZORWIRE_SOAK				5
#define RAZORWIRE_MAX_HEALTH		200
#define RAZORWIRE_SLOWDOWN			10
#define RAZORWIRE_MIN_DAMAGE_MULT_LOW	0.4 //attacking
#define RAZORWIRE_MAX_DAMAGE_MULT_LOW	0.6
#define RAZORWIRE_MIN_DAMAGE_MULT_MED	0.8 //climbing into, disentangling or crusher charging it
#define RAZORWIRE_MAX_DAMAGE_MULT_MED	1.2
#define RAZORWIRE_MIN_DAMAGE_MULT_HIGH	1.6 //pouncing into it
#define RAZORWIRE_MAX_DAMAGE_MULT_HIGH	2.4

//Flares

#define FLARE_BRIGHTNESS				5

//Scope accuracy defines
#define SCOPE_RAIL				0.4
#define SCOPE_RAIL_MINI			0.2
#define SCOPE_RAIL_SNIPER		0.5


//Hypospray

#define HYPOSPRAY_INJECT_MODE_DRAW		0
#define HYPOSPRAY_INJECT_MODE_INJECT	1

// Random item spawns for huntergames
#define HG_RANDOM_ITEM_CRAP 1
#define HG_RANDOM_ITEM_GOOD 2

//Lighter

#define LIGHTER_LUMINOSITY	2

//Tank

#define TANK_OVERDRIVE_BOOST_DURATION	5 SECONDS
#define TANK_OVERDRIVE_BOOST_COOLDOWN	20 SECONDS