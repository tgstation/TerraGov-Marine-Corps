#define VEHICLE_MUST_TURN (1<<0)

#define TURRET_TYPE_DROIDLASER 3
#define TURRET_TYPE_HEAVY 2
#define TURRET_TYPE_LIGHT 1
#define TURRET_TYPE_EXPLOSIVE 0

#define CLOAK_ABILITY 0

#define NO_PATTERN 0
#define PATTERN_TRACKED 1
#define PATTERN_DROID 2

//Ridden vehicle flags

/// Does our vehicle require arms to operate? Also used for piggybacking on humans to reserve arms on the rider
#define RIDER_NEEDS_ARMS   (1<<0)
// As above but only used for riding cyborgs, and only reserves 1 arm instead of 2
#define RIDER_NEEDS_ARM   	(1<<1)
/// Do we need legs to ride this (checks against TRAIT_FLOORED)
#define RIDER_NEEDS_LEGS   (1<<2)
/// If the rider is disabled or loses their needed limbs, do they fall off?
#define UNBUCKLE_DISABLED_RIDER (1<<3)
// For fireman carries, the carrying human needs an arm
#define CARRIER_NEEDS_ARM (1<<4)

