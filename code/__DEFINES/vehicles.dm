#define VEHICLE_MUST_TURN (1<<0)

//Vehicle control flags. control flags describe access to actions in a vehicle.

///controls the vehicles movement
#define VEHICLE_CONTROL_DRIVE (1<<0)
///Can't leave vehicle voluntarily, has to resist.
#define VEHICLE_CONTROL_KIDNAPPED (1<<1)
///melee attacks/shoves a vehicle may have
#define VEHICLE_CONTROL_MELEE (1<<2)
///using equipment/weapons on the vehicle
#define VEHICLE_CONTROL_EQUIPMENT (1<<3)
///changing around settings and the like.
#define VEHICLE_CONTROL_SETTINGS (1<<4)

///ez define for giving a single pilot mech all the flags it needs.
#define FULL_MECHA_CONTROL ALL

#define VEHICLE_FRONT_ARMOUR "vehicle_front"
#define VEHICLE_SIDE_ARMOUR "vehicle_side"
#define VEHICLE_BACK_ARMOUR "vehicle_back"

//car_traits flags
///Will this car kidnap people by ramming into them?
#define CAN_KIDNAP (1<<0)

#define TURRET_TYPE_DROIDLASER 3
#define TURRET_TYPE_HEAVY 2
#define TURRET_TYPE_LIGHT 1
#define TURRET_TYPE_EXPLOSIVE 0

#define CLOAK_ABILITY 0
#define CARGO_ABILITY 1

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


//Armored vehicle defines
#define ARMORED_HAS_UNDERLAY (1<<0)
#define ARMORED_HAS_MAP_VARIANTS (1<<2)
#define ARMORED_HAS_PRIMARY_WEAPON (1<<3)
#define ARMORED_HAS_SECONDARY_WEAPON (1<<4)
#define ARMORED_LIGHTS_ON (1<<5)
#define ARMORED_HAS_HEADLIGHTS (1<<6)
#define ARMORED_PURCHASABLE_ASSAULT (1<<7)
#define ARMORED_PURCHASABLE_TRANSPORT (1<<8)
///Turns into a wreck instead of being destroyed
#define ARMORED_WRECKABLE (1<<9)
///Is currently a wreck
#define ARMORED_IS_WRECK (1<<10)

#define MODULE_PRIMARY (1<<0)
#define MODULE_SECONDARY (1<<1)
///Can only shoot in the direction of the turret
#define MODULE_FIXED_FIRE_ARC (1<<2)
///Not available in the tank fab
#define MODULE_NOT_FABRICABLE (1<<3)

///Not available in the tank fab
#define TANK_MOD_NOT_FABRICABLE (1<<0)

#define IGUANA_MAX_INTEGRITY 150
