#define ALL (~0) //For convenience.
#define NONE 0

#define MAX_BITFIELD_SIZE 24

/// 33554431 (2^24 - 1) is the maximum value our bitflags can reach.
#define MAX_BITFLAG_DIGITS 8

#define ENABLE_BITFIELD(variable, flag) ((variable) |= (flag))
#define DISABLE_BITFIELD(variable, flag) ((variable) &= ~(flag))
#define CHECK_BITFIELD(variable, flag) ((variable) & (flag))
#define TOGGLE_BITFIELD(variable, flag) ((variable) ^= (flag))

//check if all bitflags specified are present
#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) (((flagvar) & (flags)) == (flags))

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

/* Directions */
///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)

// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)

//alternate appearance flags
#define AA_TARGET_SEE_APPEARANCE (1<<0)
#define AA_MATCH_TARGET_OVERLAYS (1<<1)

#define KEEP_TOGETHER_ORIGINAL "keep_together_original"

//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
	if ((x.appearance_flags & KEEP_TOGETHER) && !HAS_TRAIT(x, TRAIT_KEEP_TOGETHER)) ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL); \
	ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	x.appearance_flags |= KEEP_TOGETHER

#define REMOVE_KEEP_TOGETHER(x, source)\
	REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	if(HAS_TRAIT_FROM_ONLY(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL))\
		REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL);\
	else if(!HAS_TRAIT(x, TRAIT_KEEP_TOGETHER))\
		x.appearance_flags &= ~KEEP_TOGETHER
