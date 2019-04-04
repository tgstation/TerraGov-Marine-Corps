//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6

#define BORGMESON 1
#define BORGTHERM 2
#define BORGXRAY  4

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


#define LIVING_PERM_COEFF 0
#define XENO_PERM_COEFF 0.8
//=================================================

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define POCKET_STRIP_DELAY 20

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.

//Life variables
#define CARBON_BREATH_DELAY 2 // The interval in life ticks between breathe()

#define CARBON_MAX_OXYLOSS 3 //Defines how much oxyloss humans can get per breath tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
#define CARBON_CRIT_MAX_OXYLOSS (round(SSmobs.wait/30, 0.1)) //The amount of damage you'll get when in critical condition.
#define CARBON_RECOVERY_OXYLOSS -5 //the amount of oxyloss recovery per successful breath tick.

#define CARBON_KO_OXYLOSS 50

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
#define NEARSIGHTED		(1<<0)
#define EPILEPSY		(1<<1)
#define COUGHING		(1<<2)
#define TOURETTES		(1<<3)
#define NERVOUS			(1<<4)
//=================================================

//sdisabilities
#define BLIND			(1<<0)
#define MUTE			(1<<1)
#define DEAF			(1<<2)
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

//damagetype
#define BRUTELOSS 	(1<<0)
#define FIRELOSS 	(1<<1)
#define TOXLOSS 	(1<<2)
#define OXYLOSS 	(1<<3)
//=================================================

//status_flags
#define CANSTUN			(1<<0)
#define CANKNOCKDOWN	(1<<1)
#define CANKNOCKOUT		(1<<2)
#define CANPUSH			(1<<3)
#define LEAPING			(1<<4)
#define PASSEMOTES		(1<<5)      //holders inside of mob that need to see emotes.
#define GODMODE			(1<<6)
#define FAKEDEATH		(1<<7)	//Replaces stuff like changeling.changeling_fakedeath
#define DISFIGURED		(1<<8)	//I'll probably move this elsewhere if I ever get wround to writing a bitflag mob-damage system
#define XENO_HOST		(1<<9)	//Tracks whether we're gonna be a baby alien's mummy.

// =============================
// hive types

#define XENO_HIVE_NONE "none"
#define XENO_HIVE_NORMAL "normal"
#define XENO_HIVE_CORRUPTED "corrupted"
#define XENO_HIVE_ALPHA "alpha"
#define XENO_HIVE_BETA "beta"
#define XENO_HIVE_ZETA "zeta"

// =============================
// xeno tiers

#define XENO_TIER_ZERO "zero" // god forgive me because i wont forgive myself
#define XENO_TIER_ONE "one"
#define XENO_TIER_TWO "two"
#define XENO_TIER_THREE "three"
#define XENO_TIER_FOUR "four"

GLOBAL_LIST_INIT(xenotiers, list(XENO_TIER_ZERO, XENO_TIER_ONE, XENO_TIER_TWO, XENO_TIER_THREE, XENO_TIER_FOUR))

// =============================
// xeno upgrades

#define XENO_UPGRADE_BASETYPE "basetype"
#define XENO_UPGRADE_INVALID "invalid" // not applicable, the old -1
#define XENO_UPGRADE_ZERO "zero"	// god forgive me again
#define XENO_UPGRADE_ONE "one"
#define XENO_UPGRADE_TWO "two"
#define XENO_UPGRADE_THREE "three"

GLOBAL_LIST_INIT(xenoupgradetiers, list(XENO_UPGRADE_BASETYPE, XENO_UPGRADE_INVALID, XENO_UPGRADE_ZERO, XENO_UPGRADE_ONE, XENO_UPGRADE_TWO, XENO_UPGRADE_THREE))

// =============================
// xeno slashing
#define XENO_SLASHING_FORBIDDEN 0
#define XENO_SLASHING_ALLOWED 1
#define XENO_SLASHING_RESTRICTED 2

//=================================================

///////////////////HUMAN BLOODTYPES///////////////////

#define HUMAN_BLOODTYPES list("O-","O+","A-","A+","B-","B+","AB-","AB+")

//limb_status
#define LIMB_BLEEDING 	(1<<0)
#define LIMB_BROKEN 	(1<<1)
#define LIMB_DESTROYED 	(1<<2) //limb is missing
#define LIMB_ROBOT 		(1<<3)
#define LIMB_SPLINTED 	(1<<4)
#define LIMB_NECROTIZED (1<<5) //necrotizing limb, nerves are dead.
#define LIMB_MUTATED 	(1<<6) //limb is deformed by mutations
#define LIMB_AMPUTATED 	(1<<7) //limb was amputated cleanly or destroyed limb was cleaned up, thus causing no pain
#define LIMB_REPAIRED 	(1<<8) //we just repaired the bone, stops the gelling after setting
#define LIMB_STABILIZED (1<<9) //certain suits will support a broken limb while worn such as the b18

/////////////////MOVE DEFINES//////////////////////
#define MOVE_INTENT_WALK        1
#define MOVE_INTENT_RUN         2
///////////////////INTERNAL ORGANS DEFINES///////////////////

#define ORGAN_ASSISTED	1
#define ORGAN_ROBOT		2

#define ORGAN_HEART 1
#define ORGAN_LUNGS 2
#define ORGAN_LIVER 3
#define ORGAN_KIDNEYS 4
#define ORGAN_BRAIN 5
#define ORGAN_EYES 6
#define ORGAN_APPENDIX 7

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
//language_flags
#define WHITELISTED (1<<0)  		// Language is available if the speaker is whitelisted.
#define RESTRICTED	(1<<1)   		// Language can only be accquired by spawning or an admin.
#define NONVERBAL 	(1<<2)    		// Language has a significant non-verbal component. Speech is garbled without line-of-sight
#define SIGNLANG 	(1<<3)     		// Language is completely non-verbal. Speech is displayed through emotes for those who can understand.
#define HIVEMIND 	(1<<4)         // Broadcast to all mobs with this language.
//=================================================


#define EMOTE_VISIBLE  1
#define EMOTE_AUDIBLE  2


//species_flags
#define NO_BLOOD 				(1<<0)
#define NO_BREATHE 				(1<<1)
#define NO_SCAN 				(1<<2)
#define NO_PAIN 				(1<<3)
#define NO_SLIP 				(1<<4)
#define NO_OVERDOSE 			(1<<5)
#define NO_POISON 				(1<<6)
#define NO_CHEM_METABOLIZATION 	(1<<7)
#define HAS_SKIN_TONE 			(1<<8)
#define HAS_SKIN_COLOR 			(1<<9)
#define HAS_LIPS 				(1<<10)
#define HAS_UNDERWEAR 			(1<<11)
#define HAS_NO_HAIR 			(1<<12)
#define IS_PLANT 				(1<<13)
#define IS_SYNTHETIC 			(1<<14)
//=================================================

//Some on_mob_life() procs check for alien races.
#define IS_VOX 2
#define IS_SKRELL 3
#define IS_UNATHI 4
#define IS_XENOS 5
#define IS_HORROR 6
#define IS_MOTH 7
//=================================================

//Mob sizes
#define MOB_SIZE_SMALL			0
#define MOB_SIZE_HUMAN			1
#define MOB_SIZE_XENO			2
#define MOB_SIZE_BIG		3

//taste sensitivity defines, used in mob/living/proc/taste
#define TASTE_HYPERSENSITIVE 5 //anything below 5% is not tasted
#define TASTE_SENSITIVE 10 //anything below 10%
#define TASTE_NORMAL 15 //anything below 15%
#define TASTE_DULL 30 //anything below 30%
#define TASTE_NUMB 101 //no taste

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
#define HUD_SL_LOCATOR_COOLDOWN		0.5 SECONDS
#define HUD_SL_LOCATOR_PROCESS_COOLDOWN		10 SECONDS


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

// halloss defines

#define BASE_HALLOSS_RECOVERY_RATE -4
#define WALK_HALLOSS_RECOVERY_RATE -12
#define DOWNED_HALLOSS_RECOVERY_RATE -16
#define REST_HALLOSS_RECOVERY_RATE -32

// Human Overlay Indexes
#define LASER_LAYER				27		//For sniper targeting laser
#define MOTH_WINGS_LAYER		26
#define MUTANTRACE_LAYER		25
#define MUTATIONS_LAYER			24
#define DAMAGE_LAYER			23
#define UNIFORM_LAYER			22
#define TAIL_LAYER				21		//bs12 specific. this hack is probably gonna come back to haunt me
#define ID_LAYER				20
#define SHOES_LAYER				19
#define GLOVES_LAYER			18
#define BELT_LAYER   			17
#define GLASSES_LAYER			16
#define SUIT_LAYER				15		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		14
#define BACK_LAYER				13
#define HAIR_LAYER				12		//TODO: make part of head layer?
#define EARS_LAYER				11
#define FACEMASK_LAYER			10
#define HEAD_LAYER				9
#define COLLAR_LAYER			8
#define HANDCUFF_LAYER			7
#define LEGCUFF_LAYER			6
#define L_HAND_LAYER			5
#define R_HAND_LAYER			4
#define BURST_LAYER				3 	//Chestburst overlay
#define TARGETED_LAYER			2	//for target sprites when held at gun point, and holo cards.
#define FIRE_LAYER				1		//If you're on fire		//BS12: Layer for the target overlay from weapon targeting system

#define TOTAL_LAYERS			27

#define MOTH_WINGS_BEHIND_LAYER	1

#define TOTAL_UNDERLAYS			1

#define ANTI_CHAINSTUN_TICKS	2

//Xeno Defines

#define XENO_SLOWDOWN_REGEN 0.4
#define XENO_HALOSS_REGEN 3
#define QUEEN_DEATH_TIMER 300 // 5 minutes
#define DEFENDER_CRESTDEFENSE_ARMOR 30
#define DEFENDER_CRESTDEFENSE_SLOWDOWN 0.8
#define DEFENDER_FORTIFY_ARMOR 60
#define WARRIOR_AGILITY_ARMOR 30
#define XENO_DEADHUMAN_DRAG_SLOWDOWN 2

#define SPIT_UPGRADE_BONUS ( max(0,upgrade_as_number()) * 0.15 ) //increase damage by 15% per upgrade level; compensates for the loss of insane attack speeds.
#define SPRAY_STRUCTURE_UPGRADE_BONUS 8
#define SPRAY_MOB_UPGRADE_BONUS 4

#define QUEEN_DEATH_LARVA_MULTIPLIER 0.17 // 85/68/51/34 for ancient/elder emp/elder queen/queen

#define PLASMA_TRANSFER_AMOUNT 50
#define PLASMA_SALVAGE_AMOUNT 40
#define PLASMA_SALVAGE_MULTIPLIER 0.5 // I'd not reccomend setting this higher than one.

#define XENO_LARVAL_ADVANCEMENT_COOLDOWN	15 SECONDS

#define XENO_LARVAL_GROWTH_COOLDOWN			12 SECONDS
#define XENO_LARVAL_AMOUNT_RECURRING		10
#define XENO_LARVAL_CHANNEL_TIME			1.5 SECONDS

#define XENO_NEURO_STING_COOLDOWN			12 SECONDS
#define XENO_NEURO_AMOUNT_RECURRING			15
#define XENO_NEURO_CHANNEL_TIME				1.5 SECONDS

#define CANNOT_HOLD_EGGS 0
#define CAN_HOLD_TWO_HANDS 1
#define CAN_HOLD_ONE_HAND 2

#define CASTE_CAN_HOLD_FACEHUGGERS 	(1<<0)
#define CASTE_CAN_VENT_CRAWL		(1<<1)
#define CASTE_CAN_BE_QUEEN_HEALED	(1<<2)
#define CASTE_CAN_BE_GIVEN_PLASMA	(1<<3)
#define CASTE_INNATE_HEALING		(1<<4)
#define CASTE_FIRE_IMMUNE			(1<<5)
#define CASTE_EVOLUTION_ALLOWED		(1<<6)
#define CASTE_IS_INTELLIGENT		(1<<7)
#define CASTE_IS_ROBOTIC			(1<<8)
#define CASTE_DECAY_PROOF			(1<<9)
#define CASTE_CAN_BE_LEADER			(1<<10)
#define CASTE_HIDE_IN_STATUS		(1<<11)

//Hunter Defines
#define HUNTER_STEALTH_COOLDOWN					50 //5 seconds
#define HUNTER_STEALTH_WALK_PLASMADRAIN			2
#define HUNTER_STEALTH_RUN_PLASMADRAIN			5
#define HUNTER_STEALTH_STILL_ALPHA				25 //90% transparency
#define HUNTER_STEALTH_WALK_ALPHA				38 //85% transparency
#define HUNTER_STEALTH_RUN_ALPHA				128 //50% transparency
#define HUNTER_STEALTH_STEALTH_DELAY			30 //3 seconds before 95% stealth
#define HUNTER_STEALTH_INITIAL_DELAY			20 //2 seconds before we can increase stealth
#define HUNTER_POUNCE_SNEAKATTACK_DELAY 		30 //3 seconds before we can sneak attack
#define HANDLE_STEALTH_CHECK					1
#define HANDLE_STEALTH_CODE_CANCEL				2
#define HANDLE_SNEAK_ATTACK_CHECK				3

//Ravager defines:
#define RAVAGER_MAX_RAGE 50
#define RAV_RAGE_ON_HIT					7.5 //+7.5 rage whenever we slash
#define RAV_CHARGESPEED					100
#define RAV_CHARGESTRENGTH				3
#define RAV_CHARGEDISTANCE				7
#define RAV_CHARGECOOLDOWN				30 SECONDS
#define RAV_CHARGE_TYPE					3
#define RAV_SECOND_WIND_COOLDOWN		240 SECONDS
#define RAV_RAVAGE_COOLDOWN				10 SECONDS
#define RAV_RAVAGE_DAMAGE_MULITPLIER	0.25 //+25% +3% bonus damage per point of Rage.relative to base melee damage.
#define RAV_RAVAGE_RAGE_MULITPLIER		0.03 //+25% +3% bonus damage per point of Rage.relative to base melee damage.
#define RAV_DAMAGE_RAGE_MULITPLIER		0.25  //Gain Rage stacks equal to 25% of damage received.
#define RAV_HANDLE_CHARGE				1

//defender defines

#define DEFENDER_HEADBUTT_COST			25
#define DEFENDER_TAILSWIPE_COST			35
#define DEFENDER_HEADBUTT_COOLDOWN		6 SECONDS
#define DEFENDER_TAILSWIPE_COOLDOWN		12 SECONDS
#define DEFENDER_FORTIFY_COOLDOWN		1 SECONDS
#define DEFENDER_CREST_DEFENSE_COOLDOWN	1 SECONDS

//crusher defines
#define CRUSHER_CRESTTOSS_COST			40
#define CRUSHER_CRESTTOSS_COOLDOWN		6 SECONDS
#define CRUSHER_STOMP_COST				80
#define CRUSHER_STOMP_COOLDOWN 			20 SECONDS
#define CRUSHER_STOMP_LOWER_DMG			80
#define CRUSHER_STOMP_UPPER_DMG			100
#define CRUSHER_CHARGE_BARRICADE_MULTI	60
#define CRUSHER_CHARGE_RAZORWIRE_MULTI	100
#define CRUSHER_CHARGE_TANK_MULTI		100

#define CRUSHER_STOMP_UPGRADE_BONUS ( 1 + upgrade_as_number() * 0.05 )

//carrier defines

#define CARRIER_SPAWN_HUGGER_COST 100
#define CARRIER_HUGGER_THROW_SPEED 2
#define CARRIER_HUGGER_THROW_DISTANCE 5

//Warrior defines

#define WARRIOR_LUNGE_COOLDOWN 10 SECONDS
#define WARRIOR_PUNCH_COOLDOWN 6 SECONDS
#define WARRIOR_FLING_COOLDOWN 6 SECONDS
#define WARRIOR_AGILITY_COOLDOWN 0.5 SECONDS

//Defiler defines

#define DEFILER_STING_COOLDOWN				20 SECONDS
#define DEFILER_GAS_COOLDOWN				40 SECONDS
#define DEFILER_CLAWS_COOLDOWN				1 SECONDS

#define DEFILER_GAS_CHANNEL_TIME			2 SECONDS
#define DEFILER_GAS_DELAY					1 SECONDS
#define DEFILER_STING_CHANNEL_TIME			1.5 SECONDS
#define DEFILER_CLAW_AMOUNT					6.5
#define DEFILER_STING_AMOUNT_RECURRING		10
#define GROWTH_TOXIN_METARATE		0.2

//Boiler defines

#define BOILER_LUMINOSITY					3

//misc

#define STANDARD_SLOWDOWN_REGEN 0.3

#define HYPERVENE_REMOVAL_AMOUNT	8

// Squad ID defines moved from game\jobs\job\squad.dm
#define NO_SQUAD 0
#define ALPHA_SQUAD 1
#define BRAVO_SQUAD 2
#define CHARLIE_SQUAD 3
#define DELTA_SQUAD 4

// tracking map ID, add more squads/ert leaders/hives etc to track via SSdirection here
#define TRACK_ALPHA_SQUAD "alpha"
#define TRACK_BRAVO_SQUAD "bravo"
#define TRACK_CHARLIE_SQUAD "charlie"
#define TRACK_DELTA_SQUAD "delta"


#define TYPING_INDICATOR_LIFETIME 3 SECONDS	//Grace period after which typing indicator disappears regardless of text in chatbar.