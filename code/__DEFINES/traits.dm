#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target.status_traits) { \
			target.status_traits = list(); \
			_L = target.status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait)); \
		} else { \
			_L = target.status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait)); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L && _L[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait)); \
			}; \
			if (!length(_L)) { \
				target.status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target.status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target.status_traits = null\
			};\
		}\
	} while (0)
#define HAS_TRAIT(target, trait) (target.status_traits ? (target.status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (source in target.status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target.status_traits ?\
		(target.status_traits[trait] ?\
			((source in target.status_traits[trait]) && (length(target.status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target.status_traits ? (target.status_traits[trait] ? (length(target.status_traits[trait] - source) > 0) : FALSE) : FALSE)

// common trait
#define TRAIT_GENERIC "generic"
#define INNATE_TRAIT "innate"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define SLEEPER_TRAIT "sleeper"
#define STASIS_BAG_TRAIT "stasis_bag"
#define SPECIES_TRAIT "species" // /datum/species innate trait
#define CRYOPOD_TRAIT "cryopod"
#define XENO_TRAIT "xeno"
#define ARMOR_TRAIT "armor"
#define STAT_TRAIT "stat"
#define NECKGRAB_TRAIT "neckgrab"
#define RESTING_TRAIT "resting"
#define BUCKLE_TRAIT "buckle"
#define THROW_TRAIT "throw"
#define FORTIFY_TRAIT "fortify" //Defender fortify ability.
#define CREST_DEFENSE_TRAIT "crestdefense"
#define TRAIT_STASIS "stasis"//Subject to the stasis effect
#define ENDURE_TRAIT "endure" //Ravager Endure ability.
#define RAGE_TRAIT "rage" //Ravager Rage ability.
#define UNMANNED_VEHICLE "unmanned"
#define STEALTH_TRAIT "stealth" //From hunter stealth
#define REVIVE_TO_CRIT_TRAIT "revive_to_crit"
#define GUN_TRAIT "gun" //Traits related to guns
#define ZOMBIE_TRAIT "zombie"
#define BULLET_ACT_TRAIT "bullet act" //Traits related to projectiles
#define PORTAL_TRAIT "portal"
#define OPTABLE_TRAIT "optable"
#define TIMESHIFT_TRAIT "timeshift"
#define BRAIN_TRAIT "brain"
/// Trait from a reagent of the given name
#define REAGENT_TRAIT(reagent) reagent.name
/// inherited from riding vehicles
#define VEHICLE_TRAIT "vehicle"

//added b grilling a food
#define TRAIT_FOOD_GRILLED "food_grilled"

//mob traits
#define TRAIT_BURROWED "burrowed" // Burrows the xeno
#define TRAIT_KNOCKEDOUT "knockedout" //Forces the user to stay unconscious.
#define TRAIT_INCAPACITATED "incapacitated"
#define TRAIT_FLOORED "floored" //User is forced to the ground on a prone position.
#define TRAIT_IMMOBILE "immobile" //User is unable to move by its own volition.
#define TRAIT_IS_RESURRECTING "resurrecting"
#define TRAIT_PSY_LINKED "psy_linked"
#define TRAIT_TIME_SHIFTED "time_shifted"
#define TRAIT_LEASHED "leashed"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
#define TRAIT_STUNIMMUNE "stun_immunity"
#define TRAIT_FIRERESISTANT "fire_resistant" // Won't catch on fire
#define TRAIT_BATONIMMUNE "baton_immunity"
#define TRAIT_SLEEPIMMUNE "sleep_immunity"
#define TRAIT_FLASHBANGIMMUNE "flashbang_immunity"
#define TRAIT_FAKEDEATH "fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_LEGLESS "legless" //Has lost all the appendages needed to stay standing up.
#define TRAIT_NOPLASMAREGEN "noplasmaregen"//xeno plasma wont recharge
#define TRAIT_UNDEFIBBABLE "undefibbable"//human can't be revived
#define TRAIT_HEALING_INFUSION "healing_infusion"//greatly improves natural healing for xenos
#define TRAIT_PSY_DRAINED "psy_drained"//mob was drained of life force by a xenos
#define TRAIT_RESEARCHED "researched" // Whether the thing has been researched/probed
#define TRAIT_STAGGERIMMUNE	"stagger_immunity" //Immunity to stagger
#define TRAIT_SLOWDOWNIMMUNE "slowdown_immunity" //Immunity to slowdown
#define TRAIT_SEE_IN_DARK "see_in_dark" //Able to see in dark
#define TRAIT_MUTED "muted" //target is mute and can't speak
#define TRAIT_TURRET_HIDDEN "turret_hidden" //target gets passed over by turrets choosing a victim
#define TRAIT_MOB_ICON_UPDATE_BLOCKED "icon_blocked" //target should not update its icon_state
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive" //target is hearing sensitive
#define TRAIT_DROOLING "drooling" //target is drooling
///Prevent mob from being ignited due to IgniteMob()
#define TRAIT_NON_FLAMMABLE "non-flammable"
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE "cant_ride"
///Prevents humans from gaining oxyloss in their handle_breath()
#define TRAIT_IGNORE_SUFFOCATION "ignore_suffocation"
//All the traits for guns
#define TRAIT_GUN_SAFETY "safety"
#define TRAIT_GUN_FLASHLIGHT_ON "light_on"
#define TRAIT_GUN_AUTO_AIM_MODE "auto_aim_mode"
#define TRAIT_GUN_IS_AIMING "aiming"
#define TRAIT_GUN_BURST_FIRING "burst_firing"
#define TRAIT_GUN_SILENCED "silenced"
#define TRAIT_GUN_RELOADING "reloading"

// item traits
#define TRAIT_T_RAY_VISIBLE "t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
// turf traits
#define TRAIT_TURF_BULLET_MANIPULATION "bullet_manipulation" //This tile is doing something to projectile
// projectile traits
#define TRAIT_PROJ_HIT_SOMETHING "hit_something" //If projectile hit something on its path
