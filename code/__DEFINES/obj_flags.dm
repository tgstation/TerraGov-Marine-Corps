// Flags for the obj_flags var on /obj

#define IN_USE					(1<<0) // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
#define CAN_BE_HIT				(1<<1) //can this be bludgeoned by items?

//Fire and Acid stuff, for resistance_flags
#define INDESTRUCTIBLE	(1<<0) //doesn't take damage
#define UNACIDABLE		(1<<1) //immune to acid
#define ON_FIRE			(1<<2) //currently on fire
#define XENO_DAMAGEABLE	(1<<3) //xenos can damage this by slashing and spitting

#define RESIST_ALL (UNACIDABLE|INDESTRUCTIBLE)
