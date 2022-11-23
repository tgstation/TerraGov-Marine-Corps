// Flags for the obj_flags var on /obj

#define IN_USE (1<<0) // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
#define CAN_BE_HIT (1<<1) //can this be bludgeoned by items?
#define PROJ_IGNORE_DENSITY (1<<2) // If non-dense structures can still get hit by projectiles
#define LIGHT_CAN_BE_SHUT (1<<3) // Is sensible to nightfall ability, and its light will be turned off

//Fire and Acid stuff, for resistance_flags
#define INDESTRUCTIBLE (1<<0) //doesn't take damage
#define UNACIDABLE (1<<1) //immune to acid
#define ON_FIRE (1<<2) //currently on fire
#define XENO_DAMAGEABLE (1<<3) //xenos can damage this by slashing and spitting
#define DROPSHIP_IMMUNE (1<<4) //dropship cannot land on it
#define CRUSHER_IMMUNE (1<<5) //is immune to crusher's charge destruction
#define BANISH_IMMUNE (1<<6) //is immune it wraith's banish ability
#define PLASMACUTTER_IMMUNE (1<<7) //is immune to being cut by a plasmacutter
#define PROJECTILE_IMMUNE (1<<8) //Cannot be hit by projectiles

#define RESIST_ALL (UNACIDABLE|INDESTRUCTIBLE)
