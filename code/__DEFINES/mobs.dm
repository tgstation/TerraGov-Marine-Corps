//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4


/*
	reagents defines
*/

#define SOLID 1
#define LIQUID 2
#define GAS 3
#define REAGENTS_OVERDOSE 30
#define REAGENTS_OVERDOSE_CRITICAL 50

// How many units of reagent are consumed per tick, by default.
#define REAGENTS_METABOLISM 0.2
// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4

#define REM REAGENTS_EFFECT_MULTIPLIER
// Reagent metabolism defines.
#define FOOD_METABOLISM 0.4
#define ALCOHOL_METABOLISM 0.1

// Factor of how fast mob nutrition decreases
#define HUNGER_FACTOR 0.05

//Pain or shock reduction for different reagents
#define PAIN_REDUCTION_VERY_LIGHT	-10 //alkysine
#define PAIN_REDUCTION_LIGHT		-25 //inaprovaline
#define PAIN_REDUCTION_MEDIUM		-40 //synaptizine
#define PAIN_REDUCTION_HEAVY		-50 //paracetamol
#define PAIN_REDUCTION_VERY_HEAVY	-80 //tramadol
#define PAIN_REDUCTION_FULL			-200 //oxycodone, neuraline


//=================================================
/*
	Germs and infections
*/

#define GERM_LEVEL_AMBIENT		110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP		200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE		100
#define INFECTION_LEVEL_TWO		500
#define INFECTION_LEVEL_THREE	800

#define MIN_ANTIBIOTICS			0
//=================================================

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define POCKET_STRIP_DELAY 20

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.

//Life variables
#define HUMAN_MAX_OXYLOSS 1 //Defines how much oxyloss humans can get per tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
#define HUMAN_CRIT_MAX_OXYLOSS 4 //The amount of damage you'll get when in critical condition. We want this to be a 5 minute deal = 300s. There are 50HP to get through, so (1/6)*last_tick_duration per second. Breaths however only happen every 4 ticks.

#define HEAT_DAMAGE_LEVEL_1 2 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 4 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 8 //Amount of damage applied when your body temperature passes the 1000K point

#define COLD_DAMAGE_LEVEL_1 0.2 //Amount of damage applied when your body temperature just passes the 260.15k safety point
#define COLD_DAMAGE_LEVEL_2 1.0 //Amount of damage applied when your body temperature passes the 200K point
#define COLD_DAMAGE_LEVEL_3 2 //Amount of damage applied when your body temperature passes the 120K point

//Note that gas heat damage is only applied once every FOUR ticks.
#define HEAT_GAS_DAMAGE_LEVEL_1 2 //Amount of damage applied when the current breath's temperature just passes the 360.15k safety point
#define HEAT_GAS_DAMAGE_LEVEL_2 4 //Amount of damage applied when the current breath's temperature passes the 400K point
#define HEAT_GAS_DAMAGE_LEVEL_3 8 //Amount of damage applied when the current breath's temperature passes the 1000K point

#define COLD_GAS_DAMAGE_LEVEL_1 0.2 //Amount of damage applied when the current breath's temperature just passes the 260.15k safety point
#define COLD_GAS_DAMAGE_LEVEL_2 0.6 //Amount of damage applied when the current breath's temperature passes the 200K point
#define COLD_GAS_DAMAGE_LEVEL_3 1.2 //Amount of damage applied when the current breath's temperature passes the 120K point

//bitflags for mutations
	// Extra powers:
#define LASER			(1<<8)	// harm intent - click anywhere to shoot lasers from eyes
#define HEAL			(1<<9)	// healing people with hands
#define SHADOW			(1<<10)	// shadow teleportation (create in/out portals anywhere) (25%)
#define SCREAM			(1<<11)	// supersonic screaming (25%)
#define EXPLOSIVE		(1<<12)	// exploding on-demand (15%)
#define REGENERATION	(1<<13)	// superhuman regeneration (30%)
#define REPROCESSOR		(1<<14)	// eat anything (50%)
#define SHAPESHIFTING	(1<<15)	// take on the appearance of anything (40%)
#define PHASING			(1<<16)	// ability to phase through walls (40%)
#define SHIELD			(1<<17)	// shielding from all projectile attacks (30%)
#define SHOCKWAVE		(1<<18)	// attack a nearby tile and cause a massive shockwave, knocking most people on their asses (25%)
#define ELECTRICITY		(1<<19)	// ability to shoot electric attacks (15%)
//=================================================

// String identifiers for associative list lookup

// mob/var/list/mutations
var/list/global_mutations = list() // list of hidden mutation things

#define STRUCDNASIZE 27
#define UNIDNASIZE 13

	// Generic mutations:
#define	TK				1
#define COLD_RESISTANCE	2
#define XRAY			3
#define HULK			4
#define CLUMSY			5
#define FAT				6
#define HUSK			7
#define NOCLONE			8
//=================================================

	//2spooky
#define SKELETON 29
#define PLANT 30

// Other Mutations:
#define mNobreath		100 	// no need to breathe
#define mRemote			101 	// remote viewing
#define mRegen			102 	// health regen
#define mRun			103 	// no slowdown
#define mRemotetalk		104 	// remote talking
#define mMorph			105 	// changing appearance
#define mBlend			106 	// nothing (seriously nothing)
#define mHallucination	107 	// hallucinations
#define mFingerprints	108 	// no fingerprints
#define mShock			109 	// insulated hands
#define mSmallsize		110 	// table climbing
//=================================================

//disabilities
#define NEARSIGHTED		1
#define EPILEPSY		2
#define COUGHING		4
#define TOURETTES		8
#define NERVOUS			16
//=================================================

//sdisabilities
#define BLIND			1
#define MUTE			2
#define DEAF			4
//=================================================

//mob/var/stat things
#define CONSCIOUS	0
#define UNCONSCIOUS	1
#define DEAD		2

//Damage things
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE		"brute"
#define BURN		"fire"
#define TOX			"tox"
#define OXY			"oxy"
#define CLONE		"clone"
#define CUT 		"cut"
#define BRUISE		"bruise"
#define HALLOSS		"halloss"
//=================================================

#define STUN		"stun"
#define WEAKEN		"weaken"
#define PARALYZE	"paralize"
#define IRRADIATE	"irradiate"
#define AGONY		"agony" // Added in PAIN!
#define STUTTER		"stutter"
#define EYE_BLUR	"eye_blur"
#define DROWSY		"drowsy"
#define SLUR 		"slur"
//=================================================

//I hate adding defines like this but I'd much rather deal with bitflags than lists and string searches
#define BRUTELOSS 1
#define FIRELOSS 2
#define TOXLOSS 4
#define OXYLOSS 8
//=================================================

//Bitflags defining which status effects could be or are inflicted on a mob
#define CANSTUN		1
#define CANKNOCKDOWN	2
#define CANKNOCKOUT	4
#define CANPUSH		8
#define LEAPING		16
#define PASSEMOTES	32      //holders inside of mob that need to see emotes.
#define GODMODE		4096
#define FAKEDEATH	8192	//Replaces stuff like changeling.changeling_fakedeath
#define DISFIGURED	16384	//I'll probably move this elsewhere if I ever get wround to writing a bitflag mob-damage system
#define XENO_HOST	32768	//Tracks whether we're gonna be a baby alien's mummy.

// =============================
// hive types

#define XENO_HIVE_NORMAL 1
#define XENO_HIVE_CORRUPTED 2
#define XENO_HIVE_ALPHA 3
#define XENO_HIVE_BETA 4
#define XENO_HIVE_ZETA 5

//=================================================

///////////////////HUMAN BLOODTYPES///////////////////

#define HUMAN_BLOODTYPES list("O-","O+","A-","A+","B-","B+","AB-","AB+")

///////////////////LIMB DEFINES///////////////////

#define LIMB_BLEEDING 1
#define LIMB_BROKEN 2
#define LIMB_DESTROYED 4 //limb is missing
#define LIMB_ROBOT 8
#define LIMB_SPLINTED 16
#define LIMB_NECROTIZED 32 //necrotizing limb, nerves are dead.
#define LIMB_MUTATED 64 //limb is deformed by mutations
#define LIMB_AMPUTATED 128 //limb was amputated cleanly or destroyed limb was cleaned up, thus causing no pain
#define LIMB_REPAIRED 256 //we just repaired the bone, stops the gelling after setting


/////////////////MOVE DEFINES//////////////////////
#define MOVE_INTENT_WALK        1
#define MOVE_INTENT_RUN         2
///////////////////INTERNAL ORGANS DEFINES///////////////////

#define ORGAN_ASSISTED	1
#define ORGAN_ROBOT		2


///////////////SURGERY DEFINES///////////////
#define SPECIAL_SURGERY_INVALID	"special_surgery_invalid"

#define NECRO_TREAT_MIN_DURATION 40
#define NECRO_TREAT_MAX_DURATION 60

#define NECRO_REMOVE_MIN_DURATION 60
#define NECRO_REMOVE_MAX_DURATION 80

#define HEMOSTAT_REMOVE_MIN_DURATION 40
#define HEMOSTAT_REMOVE_MAX_DURATION 60

#define BONESETTER_MIN_DURATION 60
#define BONESETTER_MAX_DURATION 80

#define BONEGEL_REPAIR_MIN_DURATION 40
#define BONEGEL_REPAIR_MAX_DURATION 60

#define FIXVEIN_MIN_DURATION 60
#define FIXVEIN_MAX_DURATION 80

#define FIX_ORGAN_MIN_DURATION 60
#define FIX_ORGAN_MAX_DURATION 80

#define BONEGEL_CLOSE_ENCASED_MIN_DURATION 40
#define BONEGEL_CLOSE_ENCASED_MAX_DURATION 60

#define RETRACT_CLOSE_ENCASED_MIN_DURATION 30
#define RETRACT_CLOSE_ENCASED_MAX_DURATION 40

#define RETRACT_OPEN_ENCASED_MIN_DURATION 30
#define RETRACT_OPEN_ENCASED_MAX_DURATION 40

#define SAW_OPEN_ENCASED_MIN_DURATION 60
#define SAW_OPEN_ENCASED_MAX_DURATION 80

#define INCISION_MANAGER_MIN_DURATION 60
#define INCISION_MANAGER_MAX_DURATION 80

#define CAUTERY_MIN_DURATION 60
#define CAUTERY_MAX_DURATION 80

#define BONECHIPS_REMOVAL_MIN_DURATION 40
#define BONECHIPS_REMOVAL_MAX_DURATION 60
#define BONECHIPS_MAX_DAMAGE 20

#define HEMOTOMA_MIN_DURATION 60
#define HEMOTOMA_MAX_DURATION 80

#define ROBOLIMB_CUT_MIN_DURATION 60
#define ROBOLIMB_CUT_MAX_DURATION 80

#define ROBOLIMB_MEND_MIN_DURATION 60
#define ROBOLIMB_MEND_MAX_DURATION 80

#define ROBOLIMB_PREPARE_MIN_DURATION 60
#define ROBOLIMB_PREPARE_MAX_DURATION 80

#define ROBOLIMB_ATTACH_MIN_DURATION 60
#define ROBOLIMB_ATTACH_MAX_DURATION 80

#define EYE_CUT_MIN_DURATION 60
#define EYE_CUT_MAX_DURATION 80

#define EYE_LIFT_MIN_DURATION 30
#define EYE_LIFT_MAX_DURATION 40

#define EYE_MEND_MIN_DURATION 40
#define EYE_MEND_MAX_DURATION 60

#define EYE_CAUTERISE_MIN_DURATION 60
#define EYE_CAUTERISE_MAX_DURATION 80

#define FACIAL_CUT_MIN_DURATION 60
#define FACIAL_CUT_MAX_DURATION 80

#define FACIAL_MEND_MIN_DURATION 40
#define FACIAL_MEND_MAX_DURATION 60

#define FACIAL_FIX_MIN_DURATION 30
#define FACIAL_FIX_MAX_DURATION 40

#define FACIAL_CAUTERISE_MIN_DURATION 60
#define FACIAL_CAUTERISE_MAX_DURATION 80

#define LIMB_PRINTING_TIME 550
#define LIMB_METAL_AMOUNT 125

//=================================================

//Languages!
#define LANGUAGE_HUMAN		1
#define LANGUAGE_ALIEN		2
#define LANGUAGE_DOG		4
#define LANGUAGE_CAT		8
#define LANGUAGE_BINARY		16
#define LANGUAGE_OTHER		32768
#define LANGUAGE_UNIVERSAL	65535
//=================================================

//Language flags.
#define WHITELISTED 1  		// Language is available if the speaker is whitelisted.
#define RESTRICTED 2   		// Language can only be accquired by spawning or an admin.
#define NONVERBAL 4    		// Language has a significant non-verbal component. Speech is garbled without line-of-sight
#define SIGNLANG 8     		// Language is completely non-verbal. Speech is displayed through emotes for those who can understand.
#define HIVEMIND 16         // Broadcast to all mobs with this language.
//=================================================

//Species flags.
#define NO_BLOOD 1
#define NO_BREATHE 2
#define NO_SCAN 4
#define NO_PAIN 8
#define NO_SLIP 16
#define NO_POISON 32
#define NO_CHEM_METABOLIZATION 64 //Prevents reagents from acting on_mob_life().
#define HAS_SKIN_TONE 128
#define HAS_SKIN_COLOR 256
#define HAS_LIPS 512
#define HAS_UNDERWEAR 1024
#define IS_PLANT 2048
#define IS_WHITELISTED 4096
#define IS_SYNTHETIC 8192
//=================================================

//Some on_mob_life() procs check for alien races.
#define IS_VOX 2
#define IS_SKRELL 3
#define IS_UNATHI 4
#define IS_XENOS 5
#define IS_YAUTJA 6
#define IS_HORROR 7
//=================================================

//Mob sizes
#define MOB_SIZE_SMALL			0
#define MOB_SIZE_HUMAN			1
#define MOB_SIZE_XENO			2
#define MOB_SIZE_BIG		3


//defines for the busy icons when the mob does something that takes time using do_after proc
#define BUSY_ICON_GENERIC	1
#define BUSY_ICON_MEDICAL	2
#define BUSY_ICON_BUILD		3
#define BUSY_ICON_FRIENDLY	4
#define BUSY_ICON_HOSTILE	5


//defins for datum/hud

#define HUD_STYLE_STANDARD	1
#define HUD_STYLE_REDUCED	2
#define HUD_STYLE_NOHUD		3
#define HUD_VERSIONS		3


//Blood levels
#define BLOOD_VOLUME_MAXIMUM	600
#define BLOOD_VOLUME_NORMAL		560
#define BLOOD_VOLUME_SAFE		501
#define BLOOD_VOLUME_OKAY		336
#define BLOOD_VOLUME_BAD		224
#define BLOOD_VOLUME_SURVIVE	122

#define HUMAN_MAX_PALENESS	30 //this is added to human skin tone to get value of pale_max variable


//diseases

#define SPECIAL -1
#define NON_CONTAGIOUS 0
#define BLOOD 1
#define CONTACT_FEET 2
#define CONTACT_HANDS 3
#define CONTACT_GENERAL 4
#define AIRBORNE 5

#define SCANNER 1
#define PANDEMIC 2


//forcesay types
#define SUDDEN 0
#define GRADUAL 1
#define PAINFUL 2
#define EXTREMELY_PAINFUL 3

// xeno abilities cooldown

#define CRUSHER_STOMP_COOLDOWN 200
