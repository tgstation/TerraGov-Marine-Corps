// Flags for the obj_flags var on /obj

///If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
#define IN_USE (1<<0)
///Can this be bludgeoned by items?
#define CAN_BE_HIT (1<<1)
///If non-dense structures can still get hit by projectiles
#define PROJ_IGNORE_DENSITY (1<<2)
///Is sensible to nightfall ability, and its light will be turned off
#define LIGHT_CAN_BE_SHUT (1<<3)
///Admin possession yes/no
#define DANGEROUS_POSSESSION (1<<4)
///! Does this object prevent things from being built on it?
#define BLOCKS_CONSTRUCTION (1<<5)
///! Does this object prevent same-direction things from being built on it?
#define BLOCKS_CONSTRUCTION_DIR (1<<6)
///! Can we ignore density when building on this object? (for example, directional windows and grilles)
#define IGNORE_DENSITY (1<<7)
#define BLOCK_Z_OUT_DOWN (1<<8)  // Should this object block z falling from loc?
#define BLOCK_Z_OUT_UP (1<<9) // Should this object block z uprise from loc?
#define BLOCK_Z_IN_DOWN (1<<10) // Should this object block z falling from above?
#define BLOCK_Z_IN_UP (1<<11) // Should this object block z uprise from below?


//Fire and Acid stuff, for resistance_flags
#define INDESTRUCTIBLE (1<<0) //doesn't take damage
#define UNACIDABLE (1<<1) //immune to acid
#define ON_FIRE (1<<2) //currently on fire
#define XENO_DAMAGEABLE (1<<3) //xenos can damage this by slashing and spitting
#define DROPSHIP_IMMUNE (1<<4) //dropship cannot land on it
#define CRUSHER_IMMUNE (1<<5) //is immune to crusher's charge destruction
#define PLASMACUTTER_IMMUNE (1<<6) //is immune to being cut by a plasmacutter
#define PROJECTILE_IMMUNE (1<<7) //Cannot be hit by projectiles
#define PORTAL_IMMUNE (1<<8) //Cannot be teleported by wraith's portals

#define RESIST_ALL (UNACIDABLE|INDESTRUCTIBLE|PLASMACUTTER_IMMUNE)

//projectile flags
///Indicates a projectile is no longer moving
#define PROJECTILE_FROZEN (1<<0)
///Indicates we've hit something
#define PROJECTILE_HIT (1<<1)
///This projectile will ignore non targetted mobs
#define PROJECTILE_PRECISE_TARGET (1<<2)
