///dropship equipment flags

///The dropship equipment cannot be rmeoved
#define IS_NOT_REMOVABLE (1<<0)
///The equipment uses ammo
#define USES_AMMO (1<<1)
///The equipment is a weapon
#define IS_WEAPON (1<<2)
///This equipment can only be used in firemissions
#define FIRE_MISSION_ONLY (1<<3)
///Whether we can interact with this equipment
#define IS_INTERACTABLE (1<<4)

///Ammo type defines
#define CAS_LASER_BATTERY 1
#define CAS_MINI_ROCKET 2
#define CAS_MISSILE 3
#define CAS_30MM 4
