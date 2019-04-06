// Flags for the obj_flags var on /obj


#define EMAGGED					(1<<0)
#define IN_USE					(1<<1) // If we have a user using us, this will be set on. We will check if the user has stopped using us, and thus stop updating and LAGGING EVERYTHING!
#define CAN_BE_HIT				(1<<2) //can this be bludgeoned by items?

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
#define FIRE_PROOF		(1<<1) //100% immune to fire damage (but not necessarily to lava or heat)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
#define UNACIDABLE		(1<<4) //acid can't even appear on it, let alone melt it.
#define ACID_PROOF		(1<<5) //acid stuck on it doesn't melt it.
#define INDESTRUCTIBLE	(1<<6) //doesn't take damage
#define FREEZE_PROOF	(1<<7) //can't be frozen
