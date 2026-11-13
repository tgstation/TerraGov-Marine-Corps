#define SOLID 1
#define LIQUID 2
#define GAS 3

// reagent_flags defines
/// Makes it possible to add reagents through droppers and syringes
#define INJECTABLE (1<<0)
/// Makes it possible to remove reagents through syringes
#define DRAWABLE (1<<1)
/// Makes it possible to add reagents through any reagent container
#define REFILLABLE (1<<2)
/// Makes it possible to remove reagents through any reagent container
#define DRAINABLE (1<<3)
/// Used on containers which you want to be able to see the reagents off
#define TRANSPARENT (1<<4)
/// For non-transparent containers that still have the general amount of reagents in them visible.
#define AMOUNT_VISIBLE (1<<5)
/// For containers which apply a skill check for wheter showing their reagents to the user or not.
#define AMOUNT_SKILLCHECK (1<<6)
/// For containers without volume meters on (e.g. drinking glasses, cans, sprays)
#define AMOUNT_ESTIMEE (1<<7)

#define NO_REACT (1<<8)

// Is an open container for all intents and purposes.
#define OPENCONTAINER (REFILLABLE | DRAINABLE | TRANSPARENT)
#define OPENCONTAINER_NOUNIT (REFILLABLE | DRAINABLE | AMOUNT_ESTIMEE)

// trait_flags
#define TACHYCARDIC (1<<0)
#define BRADYCARDICS (1<<1)
#define HEARTSTOPPER (1<<2)
#define CHEARTSTOPPER (1<<3)

#define TOUCH 1  // splashing
#define INGEST 2 // ingestion
#define VAPOR 3  // foam, spray, blob attack
#define PATCH 4  // patches
#define INJECT 5 // injection

#define DEL_REAGENT 1	// reagent deleted (fully cleared)
#define ADD_REAGENT 2	// reagent added
#define REM_REAGENT 3	// reagent removed (may still exist)


#define REAGENTS_OVERDOSE 30
#define REAGENTS_OVERDOSE_CRITICAL 50

// How many units of reagent are consumed per tick, by default.
#define REAGENTS_METABOLISM 0.2

// Reagent metabolism defines.
#define FOOD_METABOLISM 0.4

// Factor of how fast mob nutrition decreases
#define HUNGER_FACTOR 0.05

//Specific Heat, unused stuff right now..
#define SPECIFIC_HEAT_DEFAULT 200

#define SPECIFIC_HEAT_PLASMA 500

// Reagent ordering, lower the number the higher the priority
#define REAGENT_UI_IMMEDIATE 1 // Reagents that should be seen immediatly
#define REAGENT_UI_TOXINS 2    // Xenomorph chems and other deliberatly hostile chems
#define REAGENT_UI_UNIQUE 3    // Unique healing chems that should come before others
#define REAGENT_UI_BKTT 4      // Chems that are normally in use by patients
#define REAGENT_UI_SPACEA 5    // Normally taken chems that last a long time
#define REAGENT_UI_MEDICINE 6  // Generic positive effect chems
#define REAGENT_UI_BASE 7      // Base /datum/reagent order level
#define REAGENT_UI_MUNDANE 10  // Who cares about these chems?
