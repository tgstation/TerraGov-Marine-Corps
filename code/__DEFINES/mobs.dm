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

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define POCKET_STRIP_DELAY 20

#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.

//Life variables
#define CARBON_BREATH_DELAY 2 // The interval in life ticks between breathe()

///The amount of damage you'll take per tick when you can't breath. Default value is 1
#define CARBON_CRIT_MAX_OXYLOSS (round(SSmobs.wait/5, 0.1))
///the amount of oxyloss recovery per successful breath tick.
#define CARBON_RECOVERY_OXYLOSS -5

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
#define PARALYZE "paralyze"
#define STAGGER "stagger"
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
#define IS_SYNTHETIC (1<<12)
#define NO_STAMINA (1<<13)
#define DETACHABLE_HEAD (1<<14)
#define USES_ALIEN_WEAPONS (1<<15)
#define NO_DAMAGE_OVERLAY (1<<16)
#define HEALTH_HUD_ALWAYS_DEAD (1<<17)
#define PARALYSE_RESISTANT (1<<18)
#define ROBOTIC_LIMBS (1<<19)
#define GREYSCALE_BLOOD (1<<20)
#define IS_INSULATED (1<<21)

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
#define LASER_LAYER 29 //For sniper targeting laser
#define MOTH_WINGS_LAYER 28
#define MUTATIONS_LAYER 27
#define DAMAGE_LAYER 26
#define UNIFORM_LAYER 25
#define TAIL_LAYER 24 //bs12 specific. this hack is probably gonna come back to haunt me
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
#define TARGETED_LAYER 2 //for target sprites when held at gun point, and holo cards.
#define FIRE_LAYER 1 //If you're on fire

#define TOTAL_LAYERS 29

#define MOTH_WINGS_BEHIND_LAYER 1

#define TOTAL_UNDERLAYS 1

#define ANTI_CHAINSTUN_TICKS 2

#define BASE_GRAB_SLOWDOWN 3 //Slowdown called by /mob/setGrabState(newstate) in mob.dm when grabbing a target aggressively.

///Stamina exhaustion

#define LIVING_STAMINA_EXHAUSTION_COOLDOWN 10 SECONDS //Amount of time between 0 stamina exhaustion events
#define STAMINA_EXHAUSTION_STAGGER_DURATION 10 SECONDS //Amount of stagger applied on stamina exhaustion events
#define STAMINA_EXHAUSTION_DEBUFF_STACKS 6 //Amount of slow and eyeblur stacks applied on stamina exhaustion events


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

#define XENO_PULL_CHARGE_TIME 2 SECONDS
#define XENO_SLOWDOWN_REGEN 0.4

#define XENO_DEADHUMAN_DRAG_SLOWDOWN 2
#define XENO_EXPLOSION_GIB_THRESHOLD 0.95 //if your effective bomb armour is less than 5, devestating explosions will gib xenos

#define KING_SUMMON_TIMER_DURATION 5 MINUTES

#define SPIT_UPGRADE_BONUS(Xenomorph) (Xenomorph.upgrade_as_number() ?  0.6 : 0.45 ) //Primo damage increase

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
#define XENO_HIVEMIND_DETECTION_RANGE 10 //How far out (in tiles) can the hivemind detect hostiles
#define XENO_HIVEMIND_DETECTION_COOLDOWN 1 MINUTES

#define XENO_PARALYZE_NORMALIZATION_MULTIPLIER 5 //Multiplies an input to normalize xeno paralyze duration times.
#define XENO_STUN_NORMALIZATION_MULTIPLIER 2 //Multiplies an input to normalize xeno stun duration times.

#define CANNOT_HOLD_EGGS 0
#define CAN_HOLD_TWO_HANDS 1
#define CAN_HOLD_ONE_HAND 2

//TODO a lot of caste and caste_can flags should just be traits using caste_traits instead
#define CASTE_INNATE_HEALING (1<<0) // Xenomorphs heal outside of weeds. Larvas, for example.
#define CASTE_FIRE_IMMUNE (1<<1) //Are we immune to fire
#define CASTE_EVOLUTION_ALLOWED (1<<2) //If we're allowed to evolve (also affects the gain of evo points)
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
#define CASTE_NOT_IN_BIOSCAN (1<<13) // xenos with this flag aren't registered towards bioscan
#define CASTE_DO_NOT_ANNOUNCE_DEATH (1<<14) // xenos with this flag wont be announced to hive when dying
#define CASTE_STAGGER_RESISTANT (1<<15) //Resistant to some forms of stagger, such as projectiles
#define CASTE_HAS_WOUND_MASK (1<<16) //uses an alpha mask for wounded states

// Xeno defines that affect evolution, considering making a new var for these
#define CASTE_LEADER_TYPE (1<<16) //Whether we are a leader type caste, such as the queen, shrike or ?king?, and is affected by queen ban and playtime restrictions
#define CASTE_CANNOT_EVOLVE_IN_CAPTIVITY (1<<17) //Whether we cannot evolve in the research lab
#define CASTE_REQUIRES_FREE_TILE (1<<18) //Whether we require a free tile to evolve
#define CASTE_INSTANT_EVOLUTION (1<<19) //Whether we require no evolution progress to evolve to this caste

#define CASTE_CAN_HOLD_FACEHUGGERS (1<<0)
#define CASTE_CAN_BE_QUEEN_HEALED (1<<1)
#define CASTE_CAN_BE_GIVEN_PLASMA (1<<2)
#define CASTE_CAN_BE_LEADER (1<<3)
#define CASTE_CAN_HEAL_WITHOUT_QUEEN (1<<4) // Xenomorphs can heal even without a queen on the same z level
#define CASTE_CAN_HOLD_JELLY (1<<5)//whether we can hold fireproof jelly in our hands
#define CASTE_CAN_CORRUPT_GENERATOR (1<<6) //Can corrupt a generator
#define CASTE_CAN_RIDE_CRUSHER (1<<7) //Can ride a crusher

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
#define HUNTER_SNEAK_SLASH_ARMOR_PEN 20 //bonus AP
#define HUNTER_SNEAK_ATTACK_RUN_DELAY 2 SECONDS
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
#define BANELING_CHARGE_MAX 2
#define BANELING_CHARGE_GAIN_TIME 240 SECONDS
#define BANELING_CHARGE_RESPAWN_TIME 30 SECONDS
/// Not specified in seconds because it causes smoke to last almost four times as long if done so
#define BANELING_SMOKE_DURATION 4

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

#define WRAITH_BLINK_DRAG_NONFRIENDLY_MULTIPLIER 20 //The amount we multiply the cooldown by when we teleport while dragging a non-friendly target
#define WRAITH_BLINK_DRAG_FRIENDLY_MULTIPLIER 4 //The amount we multiply the cooldown by when we teleport while dragging a friendly target
#define WRAITH_BLINK_RANGE 3

#define WRAITH_BANISH_BASE_DURATION 10 SECONDS
#define WRAITH_BANISH_NONFRIENDLY_LIVING_MULTIPLIER 0.5
#define WRAITH_BANISH_VERY_SHORT_MULTIPLIER 0.3

#define WRAITH_TELEPORT_DEBUFF_STAGGER_STACKS 2 SECONDS //Stagger and slow stacks applied to adjacent living hostiles before/after a teleport
#define WRAITH_TELEPORT_DEBUFF_SLOWDOWN_STACKS 3 //Stagger and slow stacks applied to adjacent living hostiles before/after a teleport

//Warrior defines

#define WARRIOR_COMBO_THRESHOLD 2 //After how many abilities should warrior get an empowered cast (2 meaning the 3rd one is empowered)
#define WARRIOR_COMBO_FADEOUT_TIME 10 SECONDS //How much time does it take for a combo to completely disappear

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

#define TIER_ONE_THRESHOLD 420

#define TIER_TWO_THRESHOLD 840

#define TIER_THREE_THRESHOLD 1750


// Pheromones and buff orders

#define AURA_XENO_RECOVERY "Recovery"
#define AURA_XENO_WARDING "Warding"
#define AURA_XENO_FRENZY "Frenzy"

#define AURA_HUMAN_MOVE "move"
#define AURA_HUMAN_HOLD "hold"
#define AURA_HUMAN_FOCUS "focus"

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
