#define ALL (~0) //For convenience.
#define NONE 0

//check if all bitflags specified are present
#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) ((flagvar & (flags)) == flags)

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

// for /datum/var/datum_flags
#define DF_USE_TAG		(1<<0)
#define DF_VAR_EDITED	(1<<1)
#define DF_ISPROCESSING (1<<2)

//FLAGS BITMASK

#define HEAR_1						(1<<3)		// This flag is what recursive_hear_check() uses to determine wether to add an item to the hearer list or not.
#define CHECK_RICOCHET_1			(1<<4)		// Projectiels will check ricochet on things impacted that have this.
#define CONDUCT_1					(1<<5)		// conducts electricity (metal etc.)
#define NODECONSTRUCT_1				(1<<7)		// For machines and structures that should not break into parts, eg, holodeck stuff
#define OVERLAY_QUEUED_1			(1<<8)		// atom queued to SSoverlay
#define ON_BORDER_1					(1<<9)		// item has priority to check when entering or leaving
#define PREVENT_CLICK_UNDER_1		(1<<11)	//Prevent clicking things below it on the same turf eg. doors/ fulltile windows
#define HOLOGRAM_1					(1<<12)
#define TESLA_IGNORE_1				(1<<13) // TESLA_IGNORE grants immunity from being targeted by tesla-style electricity
#define INITIALIZED_1				(1<<14)  //Whether /atom/Initialize() has already run for the object
#define ADMIN_SPAWNED_1			(1<<15) 	//was this spawned by an admin? used for stat tracking stuff.
