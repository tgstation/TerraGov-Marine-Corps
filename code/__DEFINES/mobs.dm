//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6
///Comment out if you don't want VOX to be enabled and have players download the voice sounds.
#define AI_VOX

// Overlay Indexes
#define BODYPARTS_LAYER 28
#define WOUND_LAYER 27
#define MOTH_WINGS_LAYER 26
#define DAMAGE_LAYER 25
#define UNIFORM_LAYER 24
#define ID_LAYER 23
#define SHOES_LAYER 22
#define GLOVES_LAYER 21
#define BELT_LAYER 20
#define GLASSES_LAYER 19
#define SUIT_LAYER 18 //Possible make this an overlay of somethign required to wear a belt?
#define HAIR_LAYER 17 //TODO: make part of head layer?
#define EARS_LAYER 16
#define FACEMASK_LAYER 15
#define GOGGLES_LAYER 14	//For putting Ballistic goggles and potentially other things above masks
#define HEAD_LAYER 13
#define COLLAR_LAYER 12
#define SUIT_STORE_LAYER 11
#define BACK_LAYER 10
#define KAMA_LAYER 9
#define CAPE_LAYER 8
#define HANDCUFF_LAYER 7
#define L_HAND_LAYER 6
#define R_HAND_LAYER 5
#define BURST_LAYER 4 //Chestburst overlay
#define OVERHEALTH_SHIELD_LAYER 3
#define FIRE_LAYER 2 //If you're on fire
#define LASER_LAYER 1 //For sniper targeting laser

#define TOTAL_LAYERS 28

#define MOTH_WINGS_BEHIND_LAYER 1

#define TOTAL_UNDERLAYS 1

//Mob movement define

///Speed mod for walk intent
#define MOB_WALK_MOVE_MOD 4
///Speed mod for run intent
#define MOB_RUN_MOVE_MOD 3
///Move mod for going diagonally
#define DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER 1.6


//Pain or shock reduction for different reagents
#define PAIN_REDUCTION_VERY_LIGHT -5 //alkysine
#define PAIN_REDUCTION_LIGHT -15 //inaprovaline
#define PAIN_REDUCTION_MEDIUM -25 //synaptizine
#define PAIN_REDUCTION_HEAVY -35 //paracetamol
#define PAIN_REDUCTION_VERY_HEAVY -50 //tramadol
#define PAIN_REDUCTION_SUPER_HEAVY -100 //oxycodone


#define PAIN_REACTIVITY 0.15


//Nutrition

#define NUTRITION_STARVING 150
#define NUTRITION_HUNGRY 250
#define NUTRITION_WELLFED 400
#define NUTRITION_OVERFED 450

//=================================================
/*
	Germs and infections
*/

#define GERM_LEVEL_AMBIENT 110		//maximum germ level you can reach by standing still
#define GERM_LEVEL_MOVE_CAP 200		//maximum germ level you can reach by running around

#define INFECTION_LEVEL_ONE 100
#define INFECTION_LEVEL_TWO 500
#define INFECTION_LEVEL_THREE 800

#define MIN_ANTIBIOTICS 0.1


#define LIVING_PERM_COEFF 0
#define XENO_PERM_COEFF 0.8
//=================================================
#define POCKET_STRIP_DELAY 20

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.

//Life variables

///The amount of damage you'll take per tick when you can't breath. Default value is 1
#define CARBON_CRIT_MAX_OXYLOSS (round(SSmobs.wait/5, 0.1))
///the amount of oxyloss recovery per successful breath tick.
#define CARBON_RECOVERY_OXYLOSS -5

#define CARBON_KO_OXYLOSS 50
#define HUMAN_CRITDRAG_OXYLOSS 6 //the amount of oxyloss taken per tile a human is dragged by a xeno while unconscious

#define HEAT_DAMAGE_LEVEL_1 1 //Amount of damage applied when your body temperature just passes the 360.15k safety point
#define HEAT_DAMAGE_LEVEL_2 2 //Amount of damage applied when your body temperature passes the 400K point
#define HEAT_DAMAGE_LEVEL_3 4 //Amount of damage applied when your body temperature passes the 1000K point

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

//=================================================

//disabilities
#define BLIND (1<<0)
#define DEAF (1<<1)
#define NEARSIGHTED (1<<2)
//=================================================

//mob/var/stat things
#define CONSCIOUS 0
#define UNCONSCIOUS 1
#define DEAD 2

//Damage things
//Way to waste perfectly good damagetype names (BRUTE) on this... If you were really worried about case sensitivity, you could have just used lowertext(damagetype) in the proc...
#define BRUTE "brute"
#define BURN "fire"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"
#define CUT "cut"
#define BRUISE "bruise"
#define STAMINA "stamina"
#define PAIN "pain"
#define EYE_DAMAGE "eye_damage"
#define BRAIN_DAMAGE "brain_damage"
#define INTERNAL_BLEEDING "internal_bleeding"
#define ORGAN_DAMAGE "organ_damage"
#define INFECTION "infection"

//=================================================

#define EFFECT_STUN "stun"
#define EFFECT_PARALYZE "paralyze"
#define EFFECT_UNCONSCIOUS "unconscious"
#define EFFECT_STAGGER "stagger"
#define EFFECT_STAMLOSS "stamloss"
#define EFFECT_STUTTER "stutter"
#define EFFECT_EYE_BLUR "eye_blur"
#define EFFECT_DROWSY "drowsy"

//=================================================

//damagetype
#define BRUTELOSS (1<<0)
#define FIRELOSS (1<<1)
#define TOXLOSS (1<<2)
#define OXYLOSS (1<<3)
#define STAMINALOSS (1<<4)
//=================================================

//status_flags
#define CANSTUN (1<<0)
#define CANKNOCKDOWN (1<<1)
#define CANKNOCKOUT (1<<2)
#define CANPUSH (1<<3)
#define GODMODE (1<<4)
#define FAKEDEATH (1<<5)	//Unused
#define DISFIGURED (1<<6)	//I'll probably move this elsewhere if I ever get wround to writing a bitflag mob-damage system
#define XENO_HOST (1<<7)	//Tracks whether we're gonna be a baby alien's mummy.
#define TK_USER (1<<8)
#define CANUNCONSCIOUS (1<<9)
#define CANCONFUSE (1<<10)
#define INCORPOREAL (1<<11) // Whether not this unit should be detectable by automated means (like turrets). Used by hivemind

// =============================
// hive types

#define XENO_HIVE_NONE "none_hive"
#define XENO_HIVE_NORMAL "normal_hive"
#define XENO_HIVE_CORRUPTED "corrupted_hive"
#define XENO_HIVE_ALPHA "alpha_hive"
#define XENO_HIVE_BETA "beta_hive"
#define XENO_HIVE_ZETA "zeta_hive"
#define XENO_HIVE_ADMEME "admeme_hive"
#define XENO_HIVE_FALLEN "fallen_hive"

// =============================
// xeno tiers

#define XENO_TIER_MINION "ai"
#define XENO_TIER_ZERO "zero" // god forgive me because i wont forgive myself
#define XENO_TIER_ONE "one"
#define XENO_TIER_TWO "two"
#define XENO_TIER_THREE "three"
#define XENO_TIER_FOUR "four"

GLOBAL_LIST_INIT(xenotiers, list(XENO_TIER_MINION, XENO_TIER_ZERO, XENO_TIER_ONE, XENO_TIER_TWO, XENO_TIER_THREE, XENO_TIER_FOUR))
GLOBAL_LIST_INIT(tier_as_number, list(XENO_TIER_MINION = -1, XENO_TIER_ZERO = 0, XENO_TIER_ONE = 1, XENO_TIER_TWO = 2, XENO_TIER_THREE = 3, XENO_TIER_FOUR = 4))

// =============================
// xeno upgrades

#define XENO_UPGRADE_BASETYPE "basetype"
#define XENO_UPGRADE_INVALID "invalid" // not applicable, the old -1
#define XENO_UPGRADE_NORMAL "zero"	// god forgive me again
#define XENO_UPGRADE_PRIMO "one"

#define XENO_UPGRADE_MANIFESTATION "manifestation" //just for the hivemind

GLOBAL_LIST_INIT(xenoupgradetiers, list(XENO_UPGRADE_BASETYPE, XENO_UPGRADE_INVALID, XENO_UPGRADE_NORMAL, XENO_UPGRADE_PRIMO, XENO_UPGRADE_MANIFESTATION))

//=================================================

///////////////////HUMAN BLOODTYPES///////////////////

#define HUMAN_BLOODTYPES list("O-","O+","A-","A+","B-","B+","AB-","AB+")

//limb_status
#define LIMB_BLEEDING (1<<0)
#define LIMB_BROKEN (1<<1)
#define LIMB_DESTROYED (1<<2) //limb is missing
#define LIMB_ROBOT (1<<3)
#define LIMB_SPLINTED (1<<4)
#define LIMB_NECROTIZED (1<<5) //necrotizing limb, nerves are dead.
#define LIMB_AMPUTATED (1<<6) //limb was amputated cleanly or destroyed limb was cleaned up, thus causing no pain
#define LIMB_REPAIRED (1<<7) //we just repaired the bone, stops the gelling after setting
#define LIMB_STABILIZED (1<<8) //certain suits will support a broken limb while worn such as the b18
#define LIMB_BIOTIC (1<<9) //limb is biotic

//limb_wound_status
#define LIMB_WOUND_BANDAGED (1<<0)
#define LIMB_WOUND_SALVED (1<<1)
#define LIMB_WOUND_DISINFECTED (1<<2)
#define LIMB_WOUND_CLAMPED (1<<3)

/// If the limb's total damage percent is higher than this, it can be severed.
#define LIMB_MAX_DAMAGE_SEVER_RATIO 0.8

/////////////////MOVE DEFINES//////////////////////
#define MOVE_INTENT_WALK 0
#define MOVE_INTENT_RUN 1
#define XENO_HUMAN_PUSHED_DELAY 5

///////////////////INTERNAL ORGANS DEFINES///////////////////

#define ORGAN_ASSISTED 1
#define ORGAN_ROBOT 2

#define ORGAN_HEART 1
#define ORGAN_LUNGS 2
#define ORGAN_LIVER 3
#define ORGAN_KIDNEYS 4
#define ORGAN_BRAIN 5
#define ORGAN_EYES 6
#define ORGAN_APPENDIX 7

#define ORGAN_HEALTHY 0
#define ORGAN_BRUISED 1
#define ORGAN_BROKEN 2

//Brain Damage defines
#define BRAIN_DAMAGE_MILD 20
#define BRAIN_DAMAGE_SEVERE 100
#define BRAIN_DAMAGE_DEATH 200

///////////////SURGERY DEFINES///////////////
#define SURGERY_CANNOT_USE 0
#define SURGERY_CAN_USE 1
#define SURGERY_INVALID 2

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

#define SUTURE_MIN_DURATION 80
#define SUTURE_MAX_DURATION 90

#define DEFAT_MIN_DURATION 120
#define DEFAT_MAX_DURATION 150

#define LIMB_PRINTING_TIME 30
#define LIMB_METAL_AMOUNT 125
#define LIMB_MATTER_AMOUNT 100

//How long it takes for a human to become undefibbable
#define TIME_BEFORE_DNR 150 //In life ticks, multiply by 2 to have seconds

///Default living `maxHealth`
#define LIVING_DEFAULT_MAX_HEALTH 100

//species_flags
#define NO_BLOOD (1<<0)
#define NO_BREATHE (1<<1)
#define NO_SCAN (1<<2)
#define NO_PAIN (1<<3)
#define NO_OVERDOSE (1<<4)
#define NO_POISON (1<<5)
#define NO_CHEM_METABOLIZATION (1<<6)
#define HAS_SKIN_COLOR (1<<7)
#define HAS_LIPS (1<<8)
#define HAS_UNDERWEAR (1<<9)
#define HAS_NO_HAIR (1<<10)
#define IS_SYNTHETIC (1<<11)
#define NO_STAMINA (1<<12)
#define DETACHABLE_HEAD (1<<13)
#define USES_ALIEN_WEAPONS (1<<14)
#define NO_DAMAGE_OVERLAY (1<<15)
#define HEALTH_HUD_ALWAYS_DEAD (1<<16)
#define PARALYSE_RESISTANT (1<<17)
#define ROBOTIC_LIMBS (1<<18)
#define GREYSCALE_BLOOD (1<<19)
#define IS_INSULATED (1<<20)

//=================================================

//Some on_mob_life() procs check for alien races.
#define IS_HUMAN (1<<0)
#define IS_XENO (1<<1)
#define IS_MOTH (1<<3)
#define IS_SECTOID (1<<4)
#define IS_MONKEY (1<<5)
//=================================================

//AFK status
#define MOB_CONNECTED 0
#define MOB_RECENTLY_DISCONNECTED 1 //Still within the grace period.
#define MOB_DISCONNECTED 2
#define MOB_AGHOSTED 3 //This body was just aghosted, do not offer it

//Mob sizes
#define MOB_SIZE_SMALL 0
#define MOB_SIZE_HUMAN 1
#define MOB_SIZE_XENO 2
#define MOB_SIZE_BIG 3

// Height defines
// - They are numbers so you can compare height values (x height < y height)
// - They do not start at 0 for futureproofing
// - They skip numbers for futureproofing as well
// Otherwise they are completely arbitrary
#define MONKEY_HEIGHT_DWARF 2
#define MONKEY_HEIGHT_MEDIUM 4
#define MONKEY_HEIGHT_TALL HUMAN_HEIGHT_DWARF
#define HUMAN_HEIGHT_DWARF 6
#define HUMAN_HEIGHT_SHORTEST 8
#define HUMAN_HEIGHT_SHORT 10
#define HUMAN_HEIGHT_MEDIUM 12
#define HUMAN_HEIGHT_TALL 14
#define HUMAN_HEIGHT_TALLER 16
#define HUMAN_HEIGHT_TALLEST 18

/// Assoc list of all heights, cast to strings, to """"tuples"""""
/// The first """tuple""" index is the upper body offset
/// The second """tuple""" index is the lower body offset
GLOBAL_LIST_INIT(human_heights_to_offsets, list(
	"[MONKEY_HEIGHT_DWARF]" = list(-9, -3),
	"[MONKEY_HEIGHT_MEDIUM]" = list(-7, -4),
	"[HUMAN_HEIGHT_DWARF]" = list(-5, -4),
	"[HUMAN_HEIGHT_SHORTEST]" = list(-2, -1),
	"[HUMAN_HEIGHT_SHORT]" = list(-1, -1),
	"[HUMAN_HEIGHT_MEDIUM]" = list(0, 0),
	"[HUMAN_HEIGHT_TALL]" = list(1, 1),
	"[HUMAN_HEIGHT_TALLER]" = list(2, 1),
	"[HUMAN_HEIGHT_TALLEST]" = list(3, 2),
))

#define UPPER_BODY "upper body"
#define LOWER_BODY "lower body"
#define NO_MODIFY "do not modify"


//tivi todo finish below with our used stuff
/// Used for human height overlay adjustments
/// Certain standing overlay layers shouldn't have a filter applied and should instead just offset by a pixel y
/// This list contains all the layers that must offset, with its value being whether it's a part of the upper half of the body (TRUE) or not (FALSE)
GLOBAL_LIST_INIT(layers_to_offset, list(
	// Very tall hats will get cut off by filter
	"[HEAD_LAYER]" = UPPER_BODY,
	// Hair will get cut off by filter
	"[HAIR_LAYER]" = UPPER_BODY,
	// Long belts (sabre sheathe) will get cut off by filter
	"[BELT_LAYER]" = LOWER_BODY,
	// Everything below looks fine with or without a filter, so we can skip it and just offset
	// (In practice they'd be fine if they got a filter but we can optimize a bit by not.)
	"[GLASSES_LAYER]" = UPPER_BODY,
	"[GLOVES_LAYER]" = LOWER_BODY,
	"[HANDCUFF_LAYER]" = LOWER_BODY,
	"[ID_LAYER]" = UPPER_BODY,
	// These DO get a filter, I'm leaving them here as reference,
	// to show how many filters are added at a glance
	// BACK_LAYER (backpacks are big)
	// BODYPARTS_HIGH_LAYER (arms)
	// BODY_LAYER (body markings (full body), underwear (full body), eyes)
	// BODY_ADJ_LAYER (external organs like wings)
	// BODY_BEHIND_LAYER (external organs like wings)
	// BODY_FRONT_LAYER (external organs like wings)
	// DAMAGE_LAYER (full body)
	// HIGHEST_LAYER (full body)
	// UNIFORM_LAYER (full body)
	// WOUND_LAYER (full body)
))

//taste sensitivity defines, used in mob/living/proc/taste
#define TASTE_HYPERSENSITIVE 5 //anything below 5% is not tasted
#define TASTE_SENSITIVE 10 //anything below 10%
#define TASTE_NORMAL 15 //anything below 15%
#define TASTE_DULL 30 //anything below 30%
#define TASTE_NUMB 101 //no taste

//Blood levels
#define BLOOD_VOLUME_MAXIMUM 600
#define BLOOD_VOLUME_NORMAL 560
#define BLOOD_VOLUME_SAFE 501
#define BLOOD_VOLUME_OKAY 336
#define BLOOD_VOLUME_BAD 224
#define BLOOD_VOLUME_SURVIVE 122

#define BASE_GRAB_SLOWDOWN 3 //Slowdown called by /mob/setGrabState(newstate) in mob.dm when grabbing a target aggressively.

///Stamina exhaustion

#define LIVING_STAMINA_EXHAUSTION_COOLDOWN 10 SECONDS //Amount of time between 0 stamina exhaustion events
#define STAMINA_EXHAUSTION_STAGGER_DURATION 10 SECONDS //Amount of stagger applied on stamina exhaustion events
#define STAMINA_EXHAUSTION_DEBUFF_STACKS 6 //Amount of slow and eyeblur stacks applied on stamina exhaustion events


//Shock defines

#define LIVING_SHOCK_EFFECT_COOLDOWN 10 SECONDS


//Xeno Defines
//Xeno flags
///Xeno is currently performing a leap/dash attack
#define XENO_LEAPING (1<<0)
///Hive leader
#define XENO_LEADER (1<<1)
///Zoomed out
#define XENO_ZOOMED (1<<2)
///mobhud on
#define XENO_MOBHUD (1<<3)
///rouny mode
#define XENO_ROUNY (1<<4)


#define XENO_DEFAULT_VENT_ENTER_TIME 4.5 SECONDS //Standard time for a xeno to enter a vent.
#define XENO_DEFAULT_VENT_EXIT_TIME 2 SECONDS //Standard time for a xeno to exit a vent.
#define XENO_DEFAULT_ACID_PUDDLE_DAMAGE 14 //Standard damage dealt by acid puddles
#define XENO_ACID_WELL_FILL_TIME 2 SECONDS //How long it takes to add a charge to an acid pool
#define XENO_ACID_WELL_FILL_COST 150 //Cost in plasma to apply a charge to an acid pool
#define XENO_ACID_WELL_MAX_CHARGES 5 //Maximum number of charges for the acid well

#define HIVE_CAN_HIJACK (1<<0)

#define XENO_PULL_CHARGE_TIME 2 SECONDS
#define XENO_SLOWDOWN_REGEN 0.4

#define XENO_DEADHUMAN_DRAG_SLOWDOWN 2
#define XENO_EXPLOSION_GIB_THRESHOLD 0.95 //if your effective bomb armour is less than 5, devestating explosions will gib xenos

#define SPIT_UPGRADE_BONUS(Xenomorph) (Xenomorph.upgrade_as_number() ?  0.6 : 0.45 ) //Primo damage increase

#define PLASMA_TRANSFER_AMOUNT 100

#define XENO_NEURO_AMOUNT_RECURRING 5
#define XENO_NEURO_CHANNEL_TIME 0.25 SECONDS

#define XENO_HEALTH_ALERT_TRIGGER_PERCENT 0.25 //If a xeno is damaged while its current hit points are less than this percent of its maximum, we send out an alert to the hive
#define XENO_HEALTH_ALERT_TRIGGER_THRESHOLD 50 //If a xeno is damaged while its current hit points are less than this amount, we send out an alert to the hive
#define XENO_HEALTH_ALERT_COOLDOWN 60 SECONDS //The cooldown on these xeno damage alerts
#define XENO_HEALTH_ALERT_POINTER_DURATION 6 SECONDS //How long the alert directional pointer lasts.
#define XENO_RALLYING_POINTER_DURATION 15 SECONDS //How long the rally hive pointer lasts

#define XENO_RESTING_COOLDOWN 2 SECONDS
#define XENO_UNRESTING_COOLDOWN 0.5 SECONDS

#define XENO_HIVEMIND_DETECTION_RANGE 10 //How far out (in tiles) can the hivemind detect hostiles
#define XENO_HIVEMIND_DETECTION_COOLDOWN 1 MINUTES

#define XENO_PARALYZE_NORMALIZATION_MULTIPLIER 5 //Multiplies an input to normalize xeno paralyze duration times.
#define XENO_STUN_NORMALIZATION_MULTIPLIER 2 //Multiplies an input to normalize xeno stun duration times.

#define CANNOT_HOLD_EGGS 0
#define CAN_HOLD_TWO_HANDS 1
#define CAN_HOLD_ONE_HAND 2

// Xenomorph caste_flags:
// TODO: A lot of caste_flags and can_flags should just be traits using caste_traits instead.
#define CASTE_INNATE_HEALING (1<<0) // Xenomorphs that heal outside of weeds. Larvas, for example.
#define CASTE_QUICK_HEAL_STANDING (1<<1) // If standing, should we heal as fast as if we're resting?
#define CASTE_INNATE_PLASMA_REGEN (1<<2) // Xenomorphs that regenerate plasma outside of weeds.
#define CASTE_PLASMADRAIN_IMMUNE (1<<3) // Are we immune to plasma drain?

#define CASTE_IS_INTELLIGENT (1<<4) // Can we use human controls? Typically given to hive leaders for purposes of touching alamo/dropship controls.
#define CASTE_IS_BUILDER (1<<5) // Whether we are classified as a builder caste. Allows specific construction options (like removing acid wells).
#define CASTE_IS_A_MINION (1<<6) // Whether we are classified as a minion caste. Minions are not counted toward silo spawn count ratio.

#define CASTE_FIRE_IMMUNE (1<<7) // Are we immune to fire? This includes immunity from getting set on fire and effects of it.
#define CASTE_ACID_BLOOD (1<<8) // Randomly inflicts burn damage to nearby humans when taking damage.
#define CASTE_STAGGER_RESISTANT (1<<9) // Resistant to getting staggered from projectiles.

#define CASTE_DO_NOT_ALERT_LOW_LIFE (1<<10) // When at low life, does not alerts other Xenomorphs (who opt into these low-life alerts). Decreases the font size for the death announcement message.
#define CASTE_DO_NOT_ANNOUNCE_DEATH (1<<11) // Do not announce to Hive if this Xenomorph died.
#define CASTE_HIDE_IN_STATUS (1<<12) // Do not count them in the hive status TGUI.
#define CASTE_NOT_IN_BIOSCAN (1<<13) // Do not count them toward the xenomorph count for the bioscan. Typically given to summoned minions (puppet/spiderling).
#define CASTE_HAS_WOUND_MASK (1<<14) // Uses an alpha mask for wounded states.

// Xenomorph caste_flags (for evolution):
// TODO: Consider making a new variable for these.
#define CASTE_EVOLUTION_ALLOWED (1<<15) // Are we allowed to evolve & do we gain any evolution points?
#define CASTE_INSTANT_EVOLUTION (1<<16) // Whether we require no evolution progress to evolve to this caste.
#define CASTE_CANNOT_EVOLVE_IN_CAPTIVITY (1<<17) // Whether we cannot evolve in the research lab.
#define CASTE_REQUIRES_FREE_TILE (1<<18) // Whether we require a free tile to evolve.
#define CASTE_LEADER_TYPE (1<<19) // Whether this is a leader type caste (e.g. Queen/Shrike/King/Dragon). Restricts who can play these castes based on: playtime & if banned from Queen.
#define CASTE_EXCLUDE_STRAINS (1<<20) // Excludes this caste/basetype from strain selection.

// Xenomorph can_flags:
#define CASTE_CAN_HOLD_FACEHUGGERS (1<<0) // Are we allowed to carry facehuggers in our hands?
#define CASTE_CAN_BE_GIVEN_PLASMA (1<<1) // Can we receive plasma / have our plasma be taken away?
#define CASTE_CAN_BE_LEADER (1<<2) // Can we be selected as a hive leader (not to be confused with hive ruler)?
#define CASTE_CAN_HEAL_WITHOUT_QUEEN (1<<3) // Can we ignore the healing penalty associated with having a hive ruler not being on the same z-level as us? Only matters on gamemodes where hive rulers are optional.
#define CASTE_CAN_CORRUPT_GENERATOR (1<<4) // Can we corrupt a generator?
#define CASTE_CAN_RIDE_CRUSHER (1<<5) // Can we ride a crusher (or behemoth)?
#define CASTE_CAN_BE_RULER (1<<6) // Caste can become a ruler if no queen / shrike / king exists in the hive.

//Charge-Crush
#define CHARGE_OFF 0
#define CHARGE_BUILDINGUP 1
#define CHARGE_ON 2
#define CHARGE_MAX 3

//Hunter Defines
#define HUNTER_STEALTH_COOLDOWN 50 //5 seconds
#define HUNTER_STEALTH_WALK_PLASMADRAIN 2
#define HUNTER_STEALTH_RUN_PLASMADRAIN 5
#define HUNTER_STEALTH_STILL_ALPHA 25 //90% transparency
#define HUNTER_STEALTH_WALK_ALPHA 38 //85% transparency
#define HUNTER_STEALTH_RUN_ALPHA 128 //50% transparency
#define HUNTER_STEALTH_STEALTH_DELAY 30 //3 seconds before 95% stealth
#define HUNTER_STEALTH_INITIAL_DELAY 20 //2 seconds before we can increase stealth
#define HUNTER_POUNCE_SNEAKATTACK_DELAY 30 //3 seconds before we can sneak attack
#define HUNTER_SNEAK_SLASH_ARMOR_PEN 10 //bonus AP
#define HUNTER_SNEAK_ATTACK_RUN_DELAY 2 SECONDS
#define HUNTER_PSYCHIC_TRACE_COOLDOWN 5 SECONDS //Cooldown of the Hunter's Psychic Trace, and duration of its arrow
#define HUNTER_SILENCE_STAGGER_DURATION 1 SECONDS //Silence imposes this much stagger
#define HUNTER_SILENCE_SENSORY_STACKS 7 //Silence imposes this many eyeblur and deafen stacks.
#define HUNTER_SILENCE_MUTE_DURATION 10 SECONDS //Silence imposes this many seconds of the mute status effect.
#define HUNTER_SILENCE_RANGE 5 //Range in tiles of the Hunter's Silence.
#define HUNTER_SILENCE_AOE 2 //AoE size of Silence in tiles
#define HUNTER_SILENCE_MULTIPLIER 1.5 //Multiplier of stacks vs Hunter's Mark targets
#define HUNTER_SILENCE_WHIFF_COOLDOWN 3 SECONDS //If we fail to target anyone with Silence, partial cooldown to prevent spam.
#define HUNTER_SILENCE_COOLDOWN 30 SECONDS //Silence's cooldown
#define HUNTER_VENT_CRAWL_TIME 2 SECONDS //Hunters can enter vents fast

//Ravager defines:
#define RAV_CHARGESPEED 2
#define RAV_CHARGEDISTANCE 4

#define RAV_RAVAGE_THROW_RANGE 1

#define RAVAGER_ENDURE_DURATION				10 SECONDS
#define RAVAGER_ENDURE_DURATION_WARNING		0.7
#define RAVAGER_ENDURE_HP_LIMIT				-100

#define RAVAGER_RAGE_DURATION							10 SECONDS
#define RAVAGER_RAGE_WARNING							0.7
#define RAVAGER_RAGE_POWER_MULTIPLIER					0.5 //How much we multiply our % of missing HP by to determine Rage Power
#define RAVAGER_RAGE_MIN_HEALTH_THRESHOLD				0.5 //The maximum % of HP we can have to trigger Rage
#define RAVAGER_RAGE_SUPER_RAGE_THRESHOLD				0.5 //The minimum amount of Rage Power we need to trigger the bonus Rage effects
#define RAVAGER_RAGE_ENDURE_INCREASE_PER_SLASH			2 SECONDS //The amount of time each slash during Super Rage increases Endure's duration

//crusher defines
#define CRUSHER_STOMP_LOWER_DMG 40
#define CRUSHER_STOMP_UPPER_DMG 60
#define CRUSHER_CHARGE_BARRICADE_MULTI 60
#define CRUSHER_CHARGE_RAZORWIRE_MULTI 100
#define CRUSHER_CHARGE_TANK_MULTI 100

//gorger defines
#define GORGER_REGURGITATE_DELAY 1 SECONDS
#define GORGER_DEVOUR_DELAY 2 SECONDS
#define GORGER_DRAIN_INSTANCES 2 // amuont of times the target is drained
#define GORGER_DRAIN_DELAY 1 SECONDS // time needed to drain a marine once
#define GORGER_DRAIN_HEAL 40 // overheal gained each time the target is drained
#define GORGER_DRAIN_BLOOD_DRAIN 20 // amount of plasma drained when feeding on something
#define GORGER_TRANSFUSION_HEAL 0.3 // in %
#define GORGER_OPPOSE_COST 80
#define GORGER_OPPOSE_HEAL 0.2 // in %
#define GORGER_PSYCHIC_LINK_CHANNEL 5 SECONDS
#define GORGER_PSYCHIC_LINK_RANGE 15
#define GORGER_PSYCHIC_LINK_REDIRECT 0.5 //in %
#define GORGER_PSYCHIC_LINK_MIN_HEALTH 0.5 //in %
#define GORGER_CARNAGE_HEAL 0.2
#define GORGER_CARNAGE_MOVEMENT -0.5
#define GORGER_FEAST_DURATION -1 // lasts indefinitely, self-cancelled when insufficient plasma left

#define GORGER_GREENBLOOD_STEAL_FLAT 10 //This many units of greenblood are always stolen
#define GORGER_GREENBLOOD_STEAL_PERCENTAGE 25 //bonus % of current greenblood taken from vali on drain
#define GORGER_GREENBLOOD_CONVERSION 1.25 //Amount of blood(plasma) gained per unit of greenblood drained from target.

//carrier defines
#define CARRIER_HUGGER_THROW_SPEED 2
#define CARRIER_HUGGER_THROW_DISTANCE 5
#define CARRIER_SLASH_HUGGER_DAMAGE 25

//Defiler defines
#define DEFILER_GAS_CHANNEL_TIME 0.5 SECONDS
#define DEFILER_GAS_DELAY 1 SECONDS
#define DEFILER_REAGENT_SLASH_COUNT 3
#define DEFILER_REAGENT_SLASH_INJECT_AMOUNT 7
#define DEFILER_REAGENT_SLASH_DURATION 4 SECONDS
#define DEFILER_TRANSVITOX_CAP 180 //Max toxin damage transvitox will allow
#define DEFILER_DEFILE_CHANNEL_TIME 0.5 SECONDS //Wind up time for the Defile ability
#define DEFILER_DEFILE_FAIL_COOLDOWN 5 SECONDS //Time Defile goes on cooldown for when it fails
#define DEFILER_DEFILE_STRENGTH_MULTIPLIER 0.5 //Base multiplier for determining the power of Defile
#define DEFILER_SANGUINAL_DAMAGE 1 //Damage dealt per tick per xeno toxin by the sanguinal toxin
#define DEFILER_SANGUINAL_SMOKE_MULTIPLIER 0.03 //Amount the defile power is multiplied by which determines sanguinal smoke strength/size
#define TENTACLE_ABILITY_RANGE 5

// Pyrogen defines
/// Damage per melting fire stack
#define PYROGEN_DAMAGE_PER_STACK 2
/// Amount of ticks of fire removed when helped by another human to extinguish
#define PYROGEN_ASSIST_REMOVAL_STRENGTH 2
/// How fast the pyrogen moves when charging using fire charge
#define PYROGEN_CHARGESPEED 3
/// Maximum charge distance.
#define PYROGEN_CHARGEDISTANCE 5
/// Damage on hitting a mob using fire charge
#define PYROGEN_FIRECHARGE_DAMAGE 10
/// Bonus damage per fire stack
#define PYROGEN_FIRECHARGE_DAMAGE_PER_STACK 5
/// Bonus damage for directly hitting someone
#define PYROGEN_FIREBALL_DIRECT_DAMAGE 30
/// Damage in a 3x3 AOE when we hit anything
#define PYROGEN_FIREBALL_AOE_DAMAGE 20
/// Damage in a 3x3 AOE when we hit a vehicle
#define PYROGEN_FIREBALL_VEHICLE_AOE_DAMAGE 10
/// Fire stacks on FIREBALL burst in the 3x3 AOE
#define PYROGEN_FIREBALL_MELTING_STACKS 2
/// How many turfs can our fireball move
#define PYROGEN_FIREBALL_MAXDIST 8
/// How fast the fireball moves
#define PYROGEN_FIREBALL_SPEED 1
/// How much damage the fire does per tick or cross.
#define PYROGEN_MELTING_FIRE_DAMAGE 10
/// How many melting fire effect stacks we give per tick or cross
#define PYROGEN_MELTING_FIRE_EFFECT_STACK 2
/// How many  tornadoes we unleash when using the firestorm
#define PYROGEN_FIRESTORM_TORNADE_COUNT 3
/// Damage on fire tornado hit
#define PYROGEN_TORNADE_HIT_DAMAGE 50
/// melting fire stacks on fire tornado hit
#define PYROGEN_TORNADO_MELTING_FIRE_STACKS 2
/// damage on direct hit with the heatray
#define PYROGEN_HEATRAY_HIT_DAMAGE 50
/// damage on vehicles with the heatray
#define PYROGEN_HEATRAY_VEHICLE_HIT_DAMAGE 30
/// damage per melting fire stack
#define PYROGEN_HEATRAY_BONUS_DAMAGE_PER_MELTING_STACK 10
/// Range for the heatray
#define PYROGEN_HEATRAY_RANGE 7
/// Time before the beam fires
#define PYROGEN_HEATRAY_CHARGEUP 1 SECONDS
/// Max duration of the heatray
#define PYROGEN_HEATRAY_MAXDURATION 3 SECONDS
/// Time between each refire of the pyrogen heatray (in 3 seconds it will fire 3 times)
#define PYROGEN_HEATRAY_REFIRE_TIME 1 SECONDS
/// Amount of stacks removed per resist.
#define PYROGEN_MELTING_FIRE_STACKS_PER_RESIST 4

//Drone defines
#define DRONE_HEAL_RANGE 1
#define AUTO_WEEDING_MIN_DIST 4 //How far the xeno must be from the last spot to auto weed
#define RESIN_SELF_TIME 2 SECONDS //Time it takes to apply resin jelly on themselves
#define RESIN_OTHER_TIME 1 SECONDS //Time it takes to apply resin jelly to other xenos

//Boiler defines
#define BOILER_LUMINOSITY_BASE 0
#define BOILER_LUMINOSITY_BASE_COLOR LIGHT_COLOR_GREEN
#define BOILER_LUMINOSITY_AMMO 0.5 //don't set this to 0. How much each 'piece' of ammo in reserve glows by.
#define BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR LIGHT_COLOR_YELLOW
#define BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR LIGHT_COLOR_GREEN
#define BOILER_BOMBARD_COOLDOWN_REDUCTION 1.5 //Amount of seconds each glob stored reduces bombard cooldown by
#define	BOILER_LUMINOSITY_THRESHOLD 2 //Amount of ammo needed to start glowing

//Hivelord defines
#define HIVELORD_TUNNEL_DISMANTLE_TIME 3 SECONDS
#define HIVELORD_TUNNEL_MIN_TRAVEL_TIME 2 SECONDS
#define HIVELORD_TUNNEL_SMALL_MAX_TRAVEL_TIME 4 SECONDS
#define HIVELORD_TUNNEL_LARGE_MAX_TRAVEL_TIME 6 SECONDS
#define HIVELORD_TUNNEL_DIG_TIME 10 SECONDS
#define HIVELORD_TUNNEL_SET_LIMIT 8
#define HIVELORD_RECOVERY_PYLON_SET_LIMIT 4
#define HIVELORD_HEAL_RANGE 3
#define HIVELORD_HEALING_INFUSION_DURATION 60 SECONDS
#define HIVELORD_HEALING_INFUSION_TICKS 10

//Shrike defines
#define SHRIKE_FLAG_PAIN_HUD_ON (1<<0)
#define SHRIKE_CURE_HEAL_MULTIPLIER 10
#define SHRIKE_HEAL_RANGE 3

//Drone defines
#define DRONE_BASE_SALVE_HEAL 50
#define DRONE_ESSENCE_LINK_WINDUP 3 SECONDS
#define DRONE_ESSENCE_LINK_RANGE 6 // How far apart the linked xenos can be, in tiles. Going past this deactivates the buff.
#define DRONE_ESSENCE_LINK_REGEN 0.012 // Amount of health regen given as a percentage.
#define DRONE_ESSENCE_LINK_SHARED_HEAL 0.1 // The effectiveness of heals when applied to the other linked xeno, as a percentage

//Defender defines
#define DEFENDER_CHARGE_RANGE 4

//Baneling defines
/// Not specified in seconds because it causes smoke to last almost four times as long if done so
#define BANELING_SMOKE_DURATION 4
#define BANELING_SMOKE_RANGE 4

//Sentinel defines
#define SENTINEL_TOXIC_SPIT_STACKS_PER 2 //Amount of debuff stacks to be applied per spit.
#define SENTINEL_TOXIC_SLASH_COUNT 3 //Amount of slashes before the buff runs out
#define SENTINEL_TOXIC_SLASH_DURATION 4 SECONDS //Duration of the buff
#define SENTINEL_TOXIC_SLASH_STACKS_PER 2 //Amount of debuff stacks to be applied per slash.
#define SENTINEL_TOXIC_GRENADE_STACKS_PER 10 //Amount of debuff stacks to be applied for every tick spent inside the toxic gas.
#define SENTINEL_TOXIC_GRENADE_GAS_DAMAGE 20 //Amount of damage dealt for every tick spent in the Toxic Grenade's gas.
#define SENTINEL_DRAIN_STING_CRIT_REQUIREMENT 20 //Amount of stacks needed to activate Drain Sting's critical effect.
#define SENTINEL_DRAIN_MULTIPLIER 6 //Amount to multiply Drain Sting's restoration by
#define SENTINEL_DRAIN_SURGE_ARMOR_MOD 20 //Amount to modify the Sentinel's armor by when under the effects of Drain Surge.
#define SENTINEL_INTOXICATED_BASE_DAMAGE 1 //Amount of damage per tick dealt by the Intoxicated debuff
#define SENTINEL_INTOXICATED_RESIST_REDUCTION 8 //Amount of stacks removed every time the Intoxicated debuff is Resisted against.
#define SENTINEL_INTOXICATED_SANGUINAL_INCREASE 3 //Amount of debuff stacks applied for every tick of Sanguinal.

//Wraith defines

//Larva defines
#define LARVA_VENT_CRAWL_TIME 1 SECONDS //Larva can crawl into vents fast

//Widow Defines
#define WIDOW_SPEED_BONUS 1 // How much faster widow moves while she has wall_speedup element
#define WIDOW_WEB_HOOK_RANGE 10 // how far the web hook can reach
#define WIDOW_WEB_HOOK_MIN_RANGE 3 // the minimum range that the hook must travel to use the ability
#define WIDOW_WEB_HOOK_SPEED 3 // how fast widow yeets herself when using web hook

//Spiderling defines
#define TIME_TO_DISSOLVE 5 SECONDS
#define SPIDERLING_RAGE_RANGE 10 // how close a nearby human has to be in order to be targeted

//Praetorian defines
#define PRAE_CHARGEDISTANCE 5

//Dancer defines
#define DANCER_IMPALE_PENETRATION 20//armor penetration done by impale to marked targets
#define DANCER_MAX_IMPALE_MULT 2.5 //the maximum multiplier dancer impale can gain from debuffs
#define DANCER_NONHUMAN_IMPALE_MULT 1.5//the flat damage multiplier done by impale to non-carbon targets

//misc

#define STANDARD_SLOWDOWN_REGEN 0.3

#define HYPERVENE_REMOVAL_AMOUNT 8

#define GAS_INHALE_REAGENT_TRANSFER_AMOUNT 7

// Squad ID defines moved from game\jobs\job\squad.dm
#define NO_SQUAD "no_squad"
#define ALPHA_SQUAD "alpha_squad"
#define BRAVO_SQUAD "bravo_squad"
#define CHARLIE_SQUAD "charlie_squad"
#define DELTA_SQUAD "delta_squad"

#define ZULU_SQUAD "zulu_squad"
#define YANKEE_SQUAD "yankee_squad"
#define XRAY_SQUAD "xray_squad"
#define WHISKEY_SQUAD "whiskey_squad"

#define TYPING_INDICATOR_LIFETIME 3 SECONDS	//Grace period after which typing indicator disappears regardless of text in chatbar.


#define BODY_ZONE_HEAD "head"
#define BODY_ZONE_CHEST "chest"
#define BODY_ZONE_L_ARM "l_arm"
#define BODY_ZONE_R_ARM "r_arm"
#define BODY_ZONE_L_LEG "l_leg"
#define BODY_ZONE_R_LEG "r_leg"


#define BODY_ZONE_PRECISE_EYES "eyes"
#define BODY_ZONE_PRECISE_MOUTH "mouth"
#define BODY_ZONE_PRECISE_GROIN "groin"
#define BODY_ZONE_PRECISE_L_HAND "l_hand"
#define BODY_ZONE_PRECISE_R_HAND "r_hand"
#define BODY_ZONE_PRECISE_L_FOOT "l_foot"
#define BODY_ZONE_PRECISE_R_FOOT "r_foot"

GLOBAL_LIST_INIT(human_body_parts, list(BODY_ZONE_HEAD,
										BODY_ZONE_CHEST,
										BODY_ZONE_PRECISE_GROIN,
										BODY_ZONE_L_ARM,
										BODY_ZONE_PRECISE_L_HAND,
										BODY_ZONE_R_ARM,
										BODY_ZONE_PRECISE_R_HAND,
										BODY_ZONE_L_LEG,
										BODY_ZONE_PRECISE_L_FOOT,
										BODY_ZONE_R_LEG,
										BODY_ZONE_PRECISE_R_FOOT
										))

//Hostile simple animals
#define AI_ON 1
#define AI_IDLE 2
#define AI_OFF 3
#define AI_Z_OFF 4

//Stamina
#define STAMINA_STATE_IDLE 0
#define STAMINA_STATE_ACTIVE 1

#define UPDATEHEALTH(MOB) (addtimer(CALLBACK(MOB, TYPE_PROC_REF(/mob/living, updatehealth)), 1, TIMER_UNIQUE))

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 16

#define HUMAN_CARRY_SLOWDOWN 0.35
#define HUMAN_EXPLOSION_GIB_THRESHOLD 0.1


// =============================
// Hallucinations - health hud screws for carbon mobs
#define SCREWYHUD_NONE 0
#define SCREWYHUD_CRIT 1
#define SCREWYHUD_DEAD 2
#define SCREWYHUD_HEALTHY 3

// timed_action_flags parameter for `/proc/do_after`
/// Can do the action even if mob moves location
#define IGNORE_USER_LOC_CHANGE (1<<0)
/// Can do the action even if the target moves location
#define IGNORE_TARGET_LOC_CHANGE (1<<1)
/// Can do the action even if the item is no longer being held
#define IGNORE_HELD_ITEM (1<<2)
/// Can do the action even if the mob is incapacitated (ex. handcuffed)
#define IGNORE_INCAPACITATED (1<<3)
/// Used to prevent important slowdowns from being abused by drugs like kronkaine
#define IGNORE_SLOWDOWNS (1<<4)

#define IGNORE_LOC_CHANGE (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE)

#define TIER_ONE_THRESHOLD 300

#define TIER_TWO_THRESHOLD 600

#define TIER_THREE_THRESHOLD 900


// Pheromones and buff orders

#define AURA_XENO_RECOVERY "recovery"
#define AURA_XENO_WARDING "warding"
#define AURA_XENO_FRENZY "frenzy"

#define AURA_HUMAN_MOVE "move"
#define AURA_HUMAN_HOLD "hold"
#define AURA_HUMAN_FOCUS "focus"
#define AURA_HUMAN_FLAG "flag"

#define AURA_XENO_BLESSWARDING "Blessing Of Warding"
#define AURA_XENO_BLESSFRENZY "Blessing Of Frenzy"
#define AURA_XENO_BLESSFURY "Blessing Of Fury"

//slowdown defines for liquid turfs

///Default slowdown for mobs moving through liquid
#define MOB_WATER_SLOWDOWN 1.75
///Slowdown for xenos moving through liquid
#define XENO_WATER_SLOWDOWN 1.3
///Slowdown for boilers moving through liquid
#define BOILER_WATER_SLOWDOWN 0
///Slowdown for warlocks moving through liquid
#define WARLOCK_WATER_SLOWDOWN 0


//Species defines

///Human species or those that functional behave like them. Default species
#define SPECIES_HUMAN "species_human"
///Combat robot species
#define SPECIES_COMBAT_ROBOT "species_combat_robot"

///Nextmove delay after performing an interaction with a grab on something
#define GRAB_SLAM_DELAY 0.7 SECONDS
///Default damage for slamming a mob against an object
#define BASE_OBJ_SLAM_DAMAGE 10
///Default damage for slamming a mob against a wall
#define BASE_WALL_SLAM_DAMAGE 15
///Default damage for slamming a mob against another mob
#define BASE_MOB_SLAM_DAMAGE 8

//chest burst defines
#define CARBON_NO_CHEST_BURST 0
#define CARBON_IS_CHEST_BURSTING 1
#define CARBON_CHEST_BURSTED 2

///Pixel_y offset when lying down
#define CARBON_LYING_Y_OFFSET -6

///Filter name for illusion impacts
#define ILLUSION_HIT_FILTER "illusion_hit_filter"

//This is here because the damage defines aren't set before the AI defines and it breaks everything and I don't know where else to put it
///Assoc list of items to use to treat different damage types
GLOBAL_LIST_INIT(ai_damtype_to_heal_list, list(
	BRUTE = GLOB.ai_brute_heal_items,
	BURN = GLOB.ai_burn_heal_items,
	TOX = GLOB.ai_tox_heal_items,
	OXY = GLOB.ai_oxy_heal_items,
	CLONE = GLOB.ai_clone_heal_items,
	PAIN = GLOB.ai_pain_heal_items,
	EYE_DAMAGE = GLOB.ai_eye_heal_items,
	BRAIN_DAMAGE = GLOB.ai_brain_heal_items,
	INTERNAL_BLEEDING = GLOB.ai_ib_heal_items,
	ORGAN_DAMAGE = GLOB.ai_organ_heal_items,
	INFECTION = GLOB.ai_infection_heal_items,
))

#define POINT_TIME 4 SECONDS
