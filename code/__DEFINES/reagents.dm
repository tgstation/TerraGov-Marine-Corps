#define SOLID 1
#define LIQUID 2
#define GAS 3

// reagent_flags defines
#define INJECTABLE (1<<0) // Makes it possible to add reagents through droppers and syringes.
#define DRAWABLE (1<<1) // Makes it possible to remove reagents through syringes.

#define REFILLABLE (1<<2) // Makes it possible to add reagents through any reagent container.
#define DRAINABLE (1<<3) // Makes it possible to remove reagents through any reagent container.
#define DUNKABLE (1<<4) // Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.

#define TRANSPARENT (1<<5) // Used on containers which you want to be able to see the reagents of.
#define AMOUNT_VISIBLE (1<<6) // For non-transparent containers that still have the general amount of reagents in them visible.
#define NO_REACT (1<<7) // Applied to a reagent holder, the contents will not react with each other.
#define REAGENT_HOLDER_INSTANT_REACT (1<<8)  // Applied to a reagent holder, all of the reactions in the reagents datum will be instant. Meant to be used for things like smoke effects where reactions aren't meant to occur
///If the holder is "alive" (i.e. mobs and organs) - If this flag is applied to a holder it will cause reagents to split upon addition to the object
#define REAGENT_HOLDER_ALIVE (1<<9)

///If the holder a sealed container - Used if you don't want reagent contents boiling out (plasma, specifically, in which case it only bursts out when at ignition temperatures)
#define SEALED_CONTAINER (1<<10)

#define AMOUNT_SKILLCHECK (1<<11) //For containers which apply a skill check for wheter showing their reagents to the user or not.
#define AMOUNT_ESTIMEE (1<<12) //For containers without volume meters on (e.g. drinking glasses, cans, sprays)


// Is an open container for all intents and purposes.
#define OPENCONTAINER (REFILLABLE | DRAINABLE | TRANSPARENT)
#define OPENCONTAINER_NOUNIT (REFILLABLE | DRAINABLE | AMOUNT_ESTIMEE)


// trait_flags
#define TACHYCARDIC (1<<0)
#define BRADYCARDICS (1<<1)
#define HEARTSTOPPER (1<<2)
#define CHEARTSTOPPER (1<<3)


#define TOUCH 1	// splashing
#define INGEST 2	// ingestion
#define VAPOR 3	// foam, spray, blob attack
#define PATCH 4	// patches
#define INJECT 5	// injection

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

///reagent tags - used to look up reagents for specific effects. Feel free to add to but comment it
/// This reagent does brute effects (BOTH damaging and healing)
#define REACTION_TAG_BRUTE (1<<0)
/// This reagent does burn effects (BOTH damaging and healing)
#define REACTION_TAG_BURN (1<<1)
/// This reagent does toxin effects (BOTH damaging and healing)
#define REACTION_TAG_TOXIN (1<<2)
/// This reagent does oxy effects (BOTH damaging and healing)
#define REACTION_TAG_OXY (1<<3)
/// This reagent does clone effects (BOTH damaging and healing)
#define REACTION_TAG_CLONE (1<<4)
/// This reagent primarily heals, or it's supposed to be used for healing (in the case of c2 - they are healing)
#define REACTION_TAG_HEALING (1<<5)
/// This reagent primarily damages
#define REACTION_TAG_DAMAGING (1<<6)
/// This reagent explodes as a part of it's intended effect (i.e. not overheated/impure)
#define REACTION_TAG_EXPLOSIVE (1<<7)
/// This reagent does things that are unique and special
#define REACTION_TAG_OTHER (1<<8)
/// This reagent's reaction is dangerous to create (i.e. explodes if you fail it)
#define REACTION_TAG_DANGEROUS (1<<9)
/// This reagent's reaction is easy
#define REACTION_TAG_EASY (1<<10)
/// This reagent's reaction is difficult/involved
#define REACTION_TAG_MODERATE (1<<11)
/// This reagent's reaction is hard
#define REACTION_TAG_HARD (1<<12)
/// This reagent affects organs
#define REACTION_TAG_ORGAN (1<<13)
/// This reaction creates a drink reagent
#define REACTION_TAG_DRINK (1<<14)
/// This reaction has something to do with food
#define REACTION_TAG_FOOD (1<<15)
/// This reaction is a slime reaction
#define REACTION_TAG_SLIME (1<<16)
/// This reaction is a drug reaction
#define REACTION_TAG_DRUG (1<<17)
/// This reaction is a unique reaction
#define REACTION_TAG_UNIQUE (1<<18)
/// This reaction is produces a product that affects reactions
#define REACTION_TAG_CHEMICAL (1<<19)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_PLANT (1<<20)
/// This reaction is produces a product that affects plants
#define REACTION_TAG_COMPETITIVE (1<<21)
