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
///For containers which apply a skill check for wheter showing their reagents to the user or not.
#define AMOUNT_SKILLCHECK (1<<6)
///For containers without volume meters on (e.g. drinking glasses, cans, sprays)
#define AMOUNT_ESTIMEE (1<<7)
#define NO_REACT (1<<8)
///Allows items to be dunked into this container for transfering reagents. Used in conjunction with the dunkable component.
#define DUNKABLE (1<<9)

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

/// When returned by on_mob_life(), on_mob_dead(), overdose_start() or overdose_processed(), will cause the mob to updatehealth() afterwards
#define UPDATE_MOB_HEALTH 1


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

//reagent bitflags, used for altering how they works
///allows on_mob_dead() if present in a dead body
#define REAGENT_DEAD_PROCESS (1<<0)
///Do not split the chem at all during processing - ignores all purity effects
#define REAGENT_DONOTSPLIT (1<<1)
///Doesn't appear on handheld health analyzers.
#define REAGENT_INVISIBLE (1<<2)
///When inverted, the inverted chem uses the name of the original chem
#define REAGENT_SNEAKYNAME (1<<3)
///Retains initial volume of chem when splitting for purity effects
#define REAGENT_SPLITRETAINVOL (1<<4)
///Lets a given reagent be synthesized important for random reagents and things like the odysseus syringe gun(Replaces the old can_synth variable)
#define REAGENT_CAN_BE_SYNTHESIZED (1<<5)
///Allows a reagent to work on a mob regardless of stasis
#define REAGENT_IGNORE_STASIS (1<<6)
///This reagent won't be used in most randomized recipes. Meant for reagents that could be synthetized but are normally inaccessible or TOO hard to get.
#define REAGENT_NO_RANDOM_RECIPE (1<<7)
///Does this reagent clean things?
#define REAGENT_CLEANS (1<<8)
///Does this reagent affect wounds? Used to check if some procs should be ran.
#define REAGENT_AFFECTS_WOUNDS (1<<9)
/// If present, when metabolizing out of a mob, we divide by the mob's metabolism rather than multiply.
/// Without this flag: Higher metabolism means the reagent exits the system faster.
/// With this flag: Higher metabolism means the reagent exits the system slower.
#define REAGENT_REVERSE_METABOLISM (1<<10)
/// If present, this reagent will not be affected by the mob's metabolism at all, meaning it exits at a fixed rate for all mobs.
/// Supercedes [REAGENT_REVERSE_METABOLISM].
#define REAGENT_UNAFFECTED_BY_METABOLISM (1<<11)
//Used in holder.dm/equlibrium.dm to set values and volume limits
///The minimum volume of reagents than can be operated on.
#define CHEMICAL_QUANTISATION_LEVEL 0.0001 //stops floating point errors causing issues with checking reagent amounts
