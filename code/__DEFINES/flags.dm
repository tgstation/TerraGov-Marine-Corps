#define ALL (~0) //For convenience.
#define NONE 0

#define ENABLE_BITFIELD(variable, flag)  ((variable) |= (flag))
#define DISABLE_BITFIELD(variable, flag) ((variable) &= ~(flag))
#define CHECK_BITFIELD(variable, flag)   ((variable) & (flag))
#define TOGGLE_BITFIELD(variable, flag)  ((variable) ^= (flag))

//check if all bitflags specified are present
#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) (((flagvar) & (flags)) == (flags))

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

// for /datum/var/datum_flags
#define DF_USE_TAG		(1<<0)
#define DF_VAR_EDITED	(1<<1)
#define DF_ISPROCESSING (1<<2)