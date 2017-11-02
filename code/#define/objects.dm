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

// channel numbers for power
#define EQUIP	1
#define LIGHT	2
#define ENVIRON	3
#define TOTAL	4	//for total power used only

// bitflags for machine stat variable
#define BROKEN		1
#define NOPOWER		2
#define POWEROFF	4		// tbd
#define MAINT		8			// under maintaince
#define EMPED		16		// temporary broken by EMP pulse
#define MACHINE_DO_NOT_PROCESS 32768 //Do not added these to processing queue.

//bitflags for door switches.
#define OPEN	1
#define IDSCAN	2
#define BOLTS	4
#define SHOCK	8
#define SAFE	16

#define ENGINE_EJECT_Z	3

//metal, glass, rod stacks
#define MAX_STACK_AMOUNT_METAL	50
#define MAX_STACK_AMOUNT_GLASS	50
#define MAX_STACK_AMOUNT_RODS	60

#define GAS_O2 	(1 << 0)
#define GAS_N2	(1 << 1)
#define GAS_PL	(1 << 2)
#define GAS_CO2	(1 << 3)
#define GAS_N2O	(1 << 4)

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
var/list/bradycardics = list("neurotoxin", "cryoxadone", "clonexadone", "space_drugs", "stoxin")					//decrease heart rate
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

