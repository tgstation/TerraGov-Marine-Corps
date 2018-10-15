#define SOLID		1
#define LIQUID		2
#define GAS			3

// container_type defines
#define INJECTABLE		(1<<0)	// Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE		(1<<1)	// Makes it possible to remove reagents through syringes.

#define REFILLABLE		(1<<2)	// Makes it possible to add reagents through any reagent container.
#define DRAINABLE		(1<<3)	// Makes it possible to remove reagents through any reagent container.

#define TRANSPARENT		(1<<4)	// Used on containers which you want to be able to see the reagents off.
#define AMOUNT_VISIBLE	(1<<5)	// For non-transparent containers that still have the general amount of reagents in them visible.

#define AMOUNT_SKILLCHECK	(1<<6) //For containers which apply a skill check for wheter showing their reagents to the user or not.
#define AMOUNT_ESTIMEE	(1<<7)	//For containers without volume meters on (e.g. drinking glasses, cans, sprays)

// Is an open container for all intents and purposes.
#define OPENCONTAINER 	(REFILLABLE | DRAINABLE | TRANSPARENT)
#define OPENCONTAINER_NOUNIT	(REFILLABLE | DRAINABLE | AMOUNT_ESTIMEE)


#define TOUCH			1	// splashing
#define INGEST			2	// ingestion
#define VAPOR			3	// foam, spray, blob attack
#define PATCH			4	// patches
#define INJECT	5	// injection

#define DEL_REAGENT		1	// reagent deleted (fully cleared)
#define ADD_REAGENT		2	// reagent added
#define REM_REAGENT	3	// reagent removed (may still exist)


#define REM REAGENTS_EFFECT_MULTIPLIER

#define REAGENTS_OVERDOSE 30
#define REAGENTS_OVERDOSE_CRITICAL 50

//Flags for reagents
#define REAGENT_NOREACT (1<<0) //until we get to GLOB. lists and vars.


//Specific Heat, unused stuff right now..
#define SPECIFIC_HEAT_DEFAULT		200

#define SPECIFIC_HEAT_PLASMA		500