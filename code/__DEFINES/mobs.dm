//Some mob defines below
#define AI_CAMERA_LUMINOSITY 6
///Comment out if you don't want VOX to be enabled and have players download the voice sounds.
#define AI_VOX

//Mob movement define
#define DIAG_MOVEMENT_ADDED_DELAY_MULTIPLIER 1.6


//Pain or shock reduction for different reagents
#define PAIN_REDUCTION_VERY_LIGHT -5 //alkysine
#define PAIN_REDUCTION_LIGHT -15 //inaprovaline
#define PAIN_REDUCTION_MEDIUM -25 //synaptizine
#define PAIN_REDUCTION_HEAVY -35 //paracetamol
#define PAIN_REDUCTION_VERY_HEAVY -50 //tramadol

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

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define POCKET_STRIP_DELAY 20

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.

//Life variables
#define CARBON_BREATH_DELAY 2 // The interval in life ticks between breathe()

#define CARBON_MAX_OXYLOSS 3 //Defines how much oxyloss humans can get per breath tick. A tile with no air at all (such as space) applies this value, otherwise it's a percentage of it.
#define CARBON_CRIT_MAX_OXYLOSS (round(SSmobs.wait/5, 0.1)) //The amount of damage you'll get when in critical condition.
#define CARBON_RECOVERY_OXYLOSS -5 //the amount of oxyloss recovery per successful breath tick.

#define CARBON_KO_OXYLOSS 50
#define HUMAN_CRITDRAG_OXYLOSS 3 //the amount of oxyloss taken per tile a human is dragged by a xeno while unconscious

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
//=================================================

#define STUN "stun"
#define WEAKEN "weaken"
#define PARALYZE "paralize"
#define AGONY "agony" // Added in PAIN!
#define STUTTER "stutter"
#define EYE_BLUR "eye_blur"
#define DROWSY "drowsy"
#define SLUR "slur"
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
#define XENO_UPGRADE_ZERO "zero"	// god forgive me again
#define XENO_UPGRADE_ONE "one"
#define XENO_UPGRADE_TWO "two"
#define XENO_UPGRADE_THREE "three"
#define XENO_UPGRADE_FOUR "four"

#define XENO_UPGRADE_MANIFESTATION "manifestation" //just for the hivemind

GLOBAL_LIST_INIT(xenoupgradetiers, list(XENO_UPGRADE_BASETYPE, XENO_UPGRADE_INVALID, XENO_UPGRADE_ZERO, XENO_UPGRADE_ONE, XENO_UPGRADE_TWO, XENO_UPGRADE_THREE, XENO_UPGRADE_FOUR))

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

//limb_wound_status
#define LIMB_WOUND_BANDAGED (1<<0)
#define LIMB_WOUND_SALVED (1<<1)
#define LIMB_WOUND_DISINFECTED (1<<2)
#define LIMB_WOUND_CLAMPED (1<<3)

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
#define SPECIAL_SURGERY_INVALID "special_surgery_invalid"

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

#define LIMB_PRINTING_TIME 30
#define LIMB_METAL_AMOUNT 125

//How long it takes for a human to become undefibbable
#define TIME_BEFORE_DNR 150 //In life ticks, multiply by 2 to have seconds


//species_flags
#define NO_BLOOD (1<<0)
#define NO_BREATHE (1<<1)
#define NO_SCAN (1<<2)
#define NO_PAIN (1<<3)
#define NO_OVERDOSE (1<<4)
#define NO_POISON (1<<5)
#define NO_CHEM_METABOLIZATION (1<<6)
#define HAS_SKIN_TONE (1<<7)
#define HAS_SKIN_COLOR (1<<8)
#define HAS_LIPS (1<<9)
#define HAS_UNDERWEAR (1<<10)
#define HAS_NO_HAIR (1<<11)
#define IS_PLANT (1<<12)
#define IS_SYNTHETIC (1<<13)
#define NO_STAMINA (1<<14)
#define DETACHABLE_HEAD (1<<15)
#define USES_ALIEN_WEAPONS (1<<16)
#define NO_DAMAGE_OVERLAY (1<<17)
#define CAN_VENTCRAWL (1<<18)
#define HEALTH_HUD_ALWAYS_DEAD (1<<19)
#define PARALYSE_RESISTANT (1<<20)
#define ROBOTIC_LIMBS (1<<21)
#define GREYSCALE_BLOOD (1<<22)
#define IS_INSULATED (1<<23)

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

//taste sensitivity defines, used in mob/living/proc/taste
#define TASTE_HYPERSENSITIVE 5 //anything below 5% is not tasted
#define TASTE_SENSITIVE 10 //anything below 10%
#define TASTE_NORMAL 15 //anything below 15%
#define TASTE_DULL 30 //anything below 30%
#define TASTE_NUMB 101 //no taste


//defins for datum/hud

#define HUD_STYLE_STANDARD 1
#define HUD_STYLE_REDUCED 2
#define HUD_STYLE_NOHUD 3
#define HUD_VERSIONS 3
#define HUD_SL_LOCATOR_COOLDOWN 0.5 SECONDS
#define HUD_SL_LOCATOR_PROCESS_COOLDOWN 10 SECONDS


//Blood levels
#define BLOOD_VOLUME_MAXIMUM 600
#define BLOOD_VOLUME_NORMAL 560
#define BLOOD_VOLUME_SAFE 501
#define BLOOD_VOLUME_OKAY 336
#define BLOOD_VOLUME_BAD 224
#define BLOOD_VOLUME_SURVIVE 122

#define HUMAN_MAX_PALENESS 30 //this is added to human skin tone to get value of pale_max variable


// Human Overlay Indexes
#define HEADBITE_LAYER 30
#define LASER_LAYER 29 //For sniper targeting laser
#define MOTH_WINGS_LAYER 28
#define MUTANTRACE_LAYER 27
#define MUTATIONS_LAYER 26
#define DAMAGE_LAYER 25
#define UNIFORM_LAYER 24
#define TAIL_LAYER 23 //bs12 specific. this hack is probably gonna come back to haunt me
#define ID_LAYER 22
#define SHOES_LAYER 21
#define GLOVES_LAYER 20
#define BELT_LAYER 19
#define GLASSES_LAYER 18
#define SUIT_LAYER 17 //Possible make this an overlay of somethign required to wear a belt?
#define HAIR_LAYER 16 //TODO: make part of head layer?
#define EARS_LAYER 15
#define FACEMASK_LAYER 14
#define GOGGLES_LAYER 13	//For putting Ballistic goggles and potentially other things above masks
#define HEAD_LAYER 12
#define COLLAR_LAYER 11
#define SUIT_STORE_LAYER 10
#define BACK_LAYER 9
#define CAPE_LAYER 8
#define HANDCUFF_LAYER 7
#define L_HAND_LAYER 6
#define R_HAND_LAYER 5
#define BURST_LAYER 4 //Chestburst overlay
#define OVERHEALTH_SHIELD_LAYER 3
#define TARGETED_LAYER 2 //for target sprites when held at gun point, and holo cards.
#define FIRE_LAYER 1 //If you're on fire

#define TOTAL_LAYERS 30

#define MOTH_WINGS_BEHIND_LAYER 1

#define TOTAL_UNDERLAYS 1

#define ANTI_CHAINSTUN_TICKS 2

#define BASE_GRAB_SLOWDOWN 3 //Slowdown called by /mob/setGrabState(newstate) in mob.dm when grabbing a target aggressively.

///Stamina exhaustion

#define LIVING_STAMINA_EXHAUSTION_COOLDOWN 10 SECONDS //Amount of time between 0 stamina exhaustion events
#define STAMINA_EXHAUSTION_DEBUFF_STACKS 6 //Amount of slow and stagger stacks applied on stamina exhaustion events


//Shock defines

#define LIVING_SHOCK_EFFECT_COOLDOWN 10 SECONDS


//Xeno Defines

#define XENO_DEFAULT_VENT_ENTER_TIME 4.5 SECONDS //Standard time for a xeno to enter a vent.
#define XENO_DEFAULT_VENT_EXIT_TIME 2 SECONDS //Standard time for a xeno to exit a vent.
#define XENO_DEFAULT_ACID_PUDDLE_DAMAGE 14 //Standard damage dealt by acid puddles
#define XENO_ACID_WELL_FILL_TIME 2 SECONDS //How long it takes to add a charge to an acid pool
#define XENO_ACID_WELL_FILL_COST 150 //Cost in plasma to apply a charge to an acid pool
#define XENO_ACID_WELL_MAX_CHARGES 5 //Maximum number of charges for the acid well

#define HIVE_CAN_HIJACK (1<<0)
#define HIVE_CAN_COLLAPSE_FROM_SILO (1<<1)

#define XENO_PULL_CHARGE_TIME 2 SECONDS
#define XENO_SLOWDOWN_REGEN 0.4
#define QUEEN_DEATH_TIMER 5 MINUTES
#define XENO_DEADHUMAN_DRAG_SLOWDOWN 2
#define XENO_EXPLOSION_RESIST_3_MODIFIER 0.25 //multiplies top level explosive damage by this amount.

#define KING_SUMMON_TIMER_DURATION 5 MINUTES

#define SPIT_UPGRADE_BONUS(Xenomorph) (( max(0,Xenomorph.upgrade_as_number()) * 0.15 )) //increase damage by 15% per upgrade level; compensates for the loss of insane attack speed.

#define PLASMA_TRANSFER_AMOUNT 100

#define XENO_NEURO_AMOUNT_RECURRING 5
#define XENO_NEURO_CHANNEL_TIME 0.25 SECONDS

#define XENO_HEALTH_ALERT_TRIGGER_PERCENT 0.25 //If a xeno is damaged while its current hit points are less than this percent of its maximum, we send out an alert to the hive
#define XENO_HEALTH_ALERT_TRIGGER_THRESHOLD 50 //If a xeno is damaged while its current hit points are less than this amount, we send out an alert to the hive
#define XENO_HEALTH_ALERT_COOLDOWN 60 SECONDS //The cooldown on these xeno damage alerts
#define XENO_SILO_HEALTH_ALERT_COOLDOWN 30 SECONDS //The cooldown on these xeno damage alerts
#define XENO_HEALTH_ALERT_POINTER_DURATION 6 SECONDS //How long the alert directional pointer lasts.
#define XENO_RALLYING_POINTER_DURATION 15 SECONDS //How long the rally hive pointer lasts
#define XENO_SILO_DAMAGE_POINTER_DURATION 10 SECONDS //How long the alert directional pointer lasts when silos are damaged
#define XENO_SILO_DETECTION_COOLDOWN 1 MINUTES
#define XENO_SILO_DETECTION_RANGE 10//How far silos can detect hostiles

#define XENO_PARALYZE_NORMALIZATION_MULTIPLIER 5 //Multiplies an input to normalize xeno paralyze duration times.
#define XENO_STUN_NORMALIZATION_MULTIPLIER 2 //Multiplies an input to normalize xeno stun duration times.

#define CANNOT_HOLD_EGGS 0
#define CAN_HOLD_TWO_HANDS 1
#define CAN_HOLD_ONE_HAND 2

#define CASTE_INNATE_HEALING (1<<0) // Xenomorphs heal outside of weeds. Larvas, for example.
#define CASTE_FIRE_IMMUNE (1<<1)
#define CASTE_EVOLUTION_ALLOWED (1<<2)
#define CASTE_IS_INTELLIGENT (1<<3) // A hive leader or able to use more human controls
#define CASTE_DO_NOT_ALERT_LOW_LIFE (1<<4) //Doesn't alert the hive when at low life, and is quieter when dying
#define CASTE_HIDE_IN_STATUS (1<<5)
#define CASTE_QUICK_HEAL_STANDING (1<<6) // Xenomorphs heal standing same if they were resting.
#define CASTE_INNATE_PLASMA_REGEN (1<<7) // Xenos get full plasma regardless if they are on weeds or not
#define CASTE_ACID_BLOOD (1<<8) //The acid blood effect which damages humans near xenos that take damage
#define CASTE_IS_STRONG (1<<9)//can tear open acided walls without being big
#define CASTE_IS_BUILDER (1<<10) //whether we are classified as a builder caste
#define CASTE_IS_A_MINION (1<<11) //That's a dumb ai
#define CASTE_PLASMADRAIN_IMMUNE (1<<12)

#define CASTE_CAN_HOLD_FACEHUGGERS (1<<0)
#define CASTE_CAN_VENT_CRAWL (1<<1)
#define CASTE_CAN_BE_QUEEN_HEALED (1<<2)
#define CASTE_CAN_BE_GIVEN_PLASMA (1<<3)
#define CASTE_CAN_BE_LEADER (1<<4)
#define CASTE_CAN_HEAL_WITHOUT_QUEEN (1<<5) // Xenomorphs can heal even without a queen on the same z level
#define CASTE_CAN_HOLD_JELLY (1<<6)//whether we can hold fireproof jelly in our hands
#define CASTE_CAN_CORRUPT_GENERATOR (1<<7) //Can corrupt a generator
#define CASTE_CAN_BECOME_KING (1<<8) //Can be choose to become a king
#define CASTE_CAN_RIDE_CRUSHER (1<<9) //Can ride a crusher

#define HIVE_STATUS_SHOW_EMPTY (1<<0)
#define HIVE_STATUS_COMPACT_MODE (1<<1)
#define HIVE_STATUS_SHOW_GENERAL (1<<2)
#define HIVE_STATUS_SHOW_POPULATION (1<<3)
#define HIVE_STATUS_SHOW_XENO_LIST (1<<4)
#define HIVE_STATUS_SHOW_STRUCTURES (1<<5)
#define HIVE_STATUS_DEFAULTS (HIVE_STATUS_SHOW_EMPTY | HIVE_STATUS_SHOW_GENERAL | HIVE_STATUS_SHOW_POPULATION | HIVE_STATUS_SHOW_XENO_LIST | HIVE_STATUS_SHOW_STRUCTURES)

//Charge-Crush
#define CHARGE_OFF 0
#define CHARGE_BUILDINGUP 1
#define CHARGE_ON 2
#define CHARGE_MAX 3

// Xeno charge types
#define CHARGE_TYPE_SMALL 1
#define CHARGE_TYPE_MEDIUM 2
#define CHARGE_TYPE_LARGE 3
#define CHARGE_TYPE_MASSIVE 4

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
#define HANDLE_STEALTH_CHECK 1
#define HANDLE_SNEAK_ATTACK_CHECK 3
#define HUNTER_SNEAK_SLASH_ARMOR_PEN 0.8 //1 - this value = the actual penetration
#define HUNTER_SNEAK_ATTACK_RUN_DELAY 2 SECONDS
#define HUNTER_SNEAKATTACK_MAX_MULTIPLIER 2.0
#define HUNTER_SNEAKATTACK_RUN_REDUCTION 0.2
#define HUNTER_SNEAKATTACK_WALK_INCREASE 1
#define HUNTER_SNEAKATTACK_MULTI_RECOVER_DELAY 10
#define HUNTER_PSYCHIC_TRACE_COOLDOWN 5 SECONDS //Cooldown of the Hunter's Psychic Trace, and duration of its arrow
#define HUNTER_SILENCE_STAGGER_STACKS 1 //Silence imposes this many stagger stacks
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
#define RAV_CHARGESTRENGTH 2
#define RAV_CHARGEDISTANCE 4
#define RAV_CHARGE_TYPE 3

#define RAVAGER_ENDURE_DURATION				10 SECONDS
#define RAVAGER_ENDURE_DURATION_WARNING		0.7
#define RAVAGER_ENDURE_HP_LIMIT				-100

#define RAVAGER_RAGE_DURATION							10 SECONDS
#define RAVAGER_RAGE_WARNING							0.7
#define RAVAGER_RAGE_POWER_MULTIPLIER					0.5 //How much we multiply our % of missing HP by to determine Rage Power
#define RAVAGER_RAGE_MIN_HEALTH_THRESHOLD				0.5 //The maximum % of HP we can have to trigger Rage
#define RAVAGER_RAGE_SUPER_RAGE_THRESHOLD				0.5 //The minimum amount of Rage Power we need to trigger the bonus Rage effects
#define RAVAGER_RAGE_ENDURE_INCREASE_PER_SLASH			2 SECONDS //The amount of time each slash during Super Rage increases Endure's duration

#define VAMPIRISM_MOB_DURATION 45 SECONDS

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
#define GORGER_REJUVENATE_DURATION -1
#define GORGER_REJUVENATE_COST 20
#define GORGER_REJUVENATE_SLOWDOWN 6
#define GORGER_REJUVENATE_HEAL 0.05 //in %
#define GORGER_REJUVENATE_THRESHOLD 0.10 //in %
#define GORGER_PSYCHIC_LINK_CHANNEL 10 SECONDS
#define GORGER_PSYCHIC_LINK_RANGE 15
#define GORGER_PSYCHIC_LINK_REDIRECT 0.5 //in %
#define GORGER_PSYCHIC_LINK_MIN_HEALTH 0.2 //in %
#define GORGER_CARNAGE_HEAL 0.2
#define GORGER_CARNAGE_MOVEMENT -0.5
#define GORGER_FEAST_DURATION -1 // lasts indefinitely, self-cancelled when insufficient plasma left

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

//Drone defines
#define DRONE_HEAL_RANGE 1
#define AUTO_WEEDING_MIN_DIST 4 //How far the xeno must be from the last spot to auto weed
#define RESIN_SELF_TIME 2 SECONDS //Time it takes to apply resin jelly on themselves
#define RESIN_OTHER_TIME 1 SECONDS //Time it takes to apply resin jelly to other xenos

//Boiler defines
#define BOILER_LUMINOSITY_BASE 0
#define BOILER_LUMINOSITY_BASE_COLOR LIGHT_COLOR_GREEN
#define BOILER_LUMINOSITY_AMMO 1 //don't set this to 0. How much each 'piece' of ammo in reserve glows by.
#define BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR LIGHT_COLOR_YELLOW
#define BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR LIGHT_COLOR_GREEN

//Hivelord defines
#define HIVELORD_TUNNEL_DISMANTLE_TIME 3 SECONDS
#define HIVELORD_TUNNEL_MIN_TRAVEL_TIME 2 SECONDS
#define HIVELORD_TUNNEL_SMALL_MAX_TRAVEL_TIME 4 SECONDS
#define HIVELORD_TUNNEL_LARGE_MAX_TRAVEL_TIME 6 SECONDS
#define HIVELORD_TUNNEL_DIG_TIME 10 SECONDS
#define HIVELORD_TUNNEL_SET_LIMIT 8
#define HIVELORD_HEAL_RANGE 3
#define HIVELORD_HEALING_INFUSION_DURATION 60 SECONDS
#define HIVELORD_HEALING_INFUSION_TICKS 10

//Shrike defines

#define SHRIKE_FLAG_PAIN_HUD_ON (1<<0)
#define SHRIKE_CURE_HEAL_MULTIPLIER 10
#define SHRIKE_HEAL_RANGE 3

//Drone defines

//Runner defines
#define RUNNER_EVASION_DURATION 2 SECONDS //How long Evasion lasts.
#define RUNNER_EVASION_RUN_DELAY 0.5 SECONDS //If the time since the Runner last moved is equal to or greater than this, its Evasion ends.
#define RUNNER_EVASION_COOLDOWN_REFRESH_THRESHOLD 120 //If we dodge this much damage times our streak count plus 1 while evading, refresh the cooldown of Evasion.

//Wraith defines

#define WRAITH_BLINK_DRAG_NONFRIENDLY_MULTIPLIER 20 //The amount we multiply the cooldown by when we teleport while dragging a non-friendly target
#define WRAITH_BLINK_DRAG_FRIENDLY_MULTIPLIER 4 //The amount we multiply the cooldown by when we teleport while dragging a friendly target
#define WRAITH_BLINK_RANGE 3

#define WRAITH_BANISH_BASE_DURATION 10 SECONDS
#define WRAITH_BANISH_RANGE 3
#define WRAITH_BANISH_NONFRIENDLY_LIVING_MULTIPLIER 0.5
#define WRAITH_BANISH_VERY_SHORT_MULTIPLIER 0.3

#define WRAITH_TELEPORT_DEBUFF_STAGGER_STACKS 2 //Stagger and slow stacks applied to adjacent living hostiles before/after a teleport
#define WRAITH_TELEPORT_DEBUFF_SLOWDOWN_STACKS 3 //Stagger and slow stacks applied to adjacent living hostiles before/after a teleport

//Warrior defines

#define WARRIOR_COMBO_THRESHOLD 2 //After how many abilities should warrior get an empowered cast (2 meaning the 3rd one is empowered)
#define WARRIOR_COMBO_FADEOUT_TIME 10 SECONDS //How much time does it take for a combo to completely disappear

//Larva defines
#define LARVA_VENT_CRAWL_TIME 1 SECONDS //Larva can crawl into vents fast

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

#define ALPHA_SQUAD_REBEL "alpha_squad_rebel"
#define BRAVO_SQUAD_REBEL "bravo_squad_rebel"
#define CHARLIE_SQUAD_REBEL "charlie_squad_rebel"
#define DELTA_SQUAD_REBEL "delta_squad_rebel"

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

#define UPDATEHEALTH(MOB) (addtimer(CALLBACK(MOB, /mob/living.proc/updatehealth), 1, TIMER_UNIQUE))

#define GRAB_PIXEL_SHIFT_PASSIVE 6
#define GRAB_PIXEL_SHIFT_AGGRESSIVE 12
#define GRAB_PIXEL_SHIFT_NECK 16

#define HUMAN_CARRY_SLOWDOWN 0.35


// =============================
// Hallucinations - health hud screws for carbon mobs
#define SCREWYHUD_NONE 0
#define SCREWYHUD_CRIT 1
#define SCREWYHUD_DEAD 2
#define SCREWYHUD_HEALTHY 3

//do_mob() flags
#define IGNORE_LOC_CHANGE (1<<0)
#define IGNORE_HAND (1<<1)

#define TIER_ONE_YOUNG_THRESHOLD 60
#define TIER_ONE_MATURE_THRESHOLD 120
#define TIER_ONE_ELDER_THRESHOLD 240
#define TIER_ONE_ANCIENT_THRESHOLD 240

#define TIER_TWO_YOUNG_THRESHOLD 120
#define TIER_TWO_MATURE_THRESHOLD 240
#define TIER_TWO_ELDER_THRESHOLD 480
#define TIER_TWO_ANCIENT_THRESHOLD 240

#define TIER_THREE_YOUNG_THRESHOLD 250
#define TIER_THREE_MATURE_THRESHOLD 500
#define TIER_THREE_ELDER_THRESHOLD 1000
#define TIER_THREE_ANCIENT_THRESHOLD 100
