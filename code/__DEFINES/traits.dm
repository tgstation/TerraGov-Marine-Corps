#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target._status_traits) { \
			target._status_traits = list(); \
			_L = target._status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait)); \
		} else { \
			_L = target._status_traits; \
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
		var/list/_L = target._status_traits; \
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
				target._status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target._status_traits; \
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
				target._status_traits = null\
			};\
		}\
	} while (0)
#define HAS_TRAIT(target, trait) (target._status_traits ? (target._status_traits[trait] ? TRUE : FALSE) : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (target._status_traits ? (target._status_traits[trait] ? (source in target._status_traits[trait]) : FALSE) : FALSE)
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (\
	target._status_traits ?\
		(target._status_traits[trait] ?\
			((source in target._status_traits[trait]) && (length(target._status_traits) == 1))\
			: FALSE)\
		: FALSE)
#define HAS_TRAIT_NOT_FROM(target, trait, source) (target._status_traits ? (target._status_traits[trait] ? (length(target._status_traits[trait] - source) > 0) : FALSE) : FALSE)

// common trait
#define TRAIT_GENERIC "generic"
#define INNATE_TRAIT "innate"
#define ADMIN_TRAIT "admin_trait"
#define ROUNDSTART_TRAIT "roundstart" //cannot be removed without admin intervention
#define SLEEPER_TRAIT "sleeper"
#define STASIS_BAG_TRAIT "stasis_bag"
#define SPECIES_TRAIT "species" // /datum/species innate trait
#define CRYOPOD_TRAIT "cryopod"
#define XENO_TRAIT "xeno"
#define SUPERSOLDIER_TRAIT "supersoldier"
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
#define MECH_VENDOR_TRAIT "mechvendor"
/// Trait applied to tram passengers
#define TRAM_PASSENGER_TRAIT "tram-passenger"
#define STEALTH_TRAIT "stealth" //From hunter stealth
#define REVIVE_TO_CRIT_TRAIT "revive_to_crit"
#define GUN_TRAIT "gun" //Traits related to guns
#define ZOMBIE_TRAIT "zombie"
#define BULLET_ACT_TRAIT "bullet act" //Traits related to projectiles
#define PORTAL_TRAIT "portal"
#define OPTABLE_TRAIT "optable"
#define TIMESHIFT_TRAIT "timeshift"
#define BRAIN_TRAIT "brain"
#define WIDOW_ABILITY_TRAIT "widow_ability_trait"
#define BULL_ABILITY_TRAIT "bull_ability_trait"
#define PSYCHIC_CRUSH_ABILITY_TRAIT "psychic_crush_ability_trait"
#define VORTEX_ABILITY_TRAIT "vortex_ability_trait"
#define PETRIFY_ABILITY_TRAIT "petrify_ability_trait"
#define SHATTERING_ROAR_ABILITY_TRAIT "shattering_roar_ability_trait"
#define ZERO_FORM_BEAM_ABILITY_TRAIT "zero_form_beam_ability_trait"
#define CONQUEROR_ABILITY_TRAIT "conqueror_ability_trait"
#define CONQUEROR_ENDURANCE_TRAIT "conqueror_endurance_trait"
#define CONQUEROR_OBLITERATION_TRAIT "conqueror_obliteration_trait"
#define HEATRAY_BEAM_ABILITY_TRAIT "heatray_ability_trait"
#define DRAGON_ABILITY_TRAIT "dragon_ability_trait"
#define HIVELORD_ABILITY_TRAIT "hivelord_ability_trait"
#define SHRIKE_ABILITY_TRAIT "shrike_ability_trait"
#define VALHALLA_TRAIT "valhalla"
#define WEIGHTBENCH_TRAIT "weightbench"
#define BOILER_ROOTED_TRAIT "boiler_rooted"
#define STRAPPABLE_ITEM_TRAIT "strappable_item"
#define MOUNTED_TRAIT "mounted"
#define VALI_TRAIT "vali"
#define HELDGLOVE_TRAIT "heldglove"
#define SECTOID_TRAIT "sectoid"
#define HUGGER_TRAIT "hugger"
#define PISTOL_LACE_TRAIT "pistol_lace"
#define NIGHT_VISION_GOGGLES_TRAIT "night_vision_goggles"
#define SUBMERGED_TRAIT "submerged_trait"
#define TRAIT_DWARF "dwarf"
#define MOVEMENT_SWAP_TRAIT "movement_swap_trait"
#define MANIFESTED_TRAIT "manifested_trait"
#define HOVERBIKE_TRAIT "hoverbike_trait"
#define BIGBIKE_TRAIT "bigbike_trait"
#define MUTATION_TRAIT "mutation_trait"
/// This trait comes from when a mob is currently typing.
#define CURRENTLY_TYPING_TRAIT "currently_typing"
/// Makes you way too tall. Like just too much, dude, it's kind of creepy. Humanoid only.
#define TRAIT_TOO_TALL "too_tall"
#define TRAIT_FREERUNNING "freerunning"
/// This mob always lands on their feet when they fall, for better or for worse.
#define TRAIT_CATLIKE_GRACE "catlike_grace"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep-together"

#define TRAIT_WARPED_INVISIBLE "warped_invisible"

#define ABSTRACT_ITEM_TRAIT "abstract_item"
/// A trait given by any status effect
#define STATUS_EFFECT_TRAIT "status-effect"
/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"

/// Trait from a reagent of the given name
#define REAGENT_TRAIT(reagent) reagent.name
/// inherited from riding vehicles
#define VEHICLE_TRAIT "vehicle"

///AM is currently submerged
#define TRAIT_SUBMERGED "trait_submerged"
///AM will not be submerged. Trait must ALWAYS be added via the add_nosubmerge_trait proc for correct behavior
#define TRAIT_NOSUBMERGE "trait_nosubmerge"

#define TRAIT_HAS_SPAWNED_MECH "has_spawned_mech"

//added b grilling a food
#define TRAIT_FOOD_GRILLED "food_grilled"

//atom/movable traits
/// Trait that tracks if something has been renamed. Typically holds a REF() to the object itself (AKA src) for wide addition/removal.
#define TRAIT_WAS_RENAMED "was_renamed"
///Lets the movable move freely in the soft-cordon area of transit space, which would otherwise teleport them away just before they got to see the true cordon
#define TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT "free_hyperspace_softcordon_movement"

//mob traits
#define TRAIT_POSSESSING "possessing" // Prevents mob from being taken by ghosts
#define TRAIT_BURROWED "burrowed" // Burrows the xeno
#define TRAIT_KNOCKEDOUT "knockedout" //Forces the user to stay unconscious.
#define TRAIT_STAGGERED "staggered" //damage or ability debuffs
#define TRAIT_INCAPACITATED "incapacitated"
#define TRAIT_FLOORED "floored" //User is forced to the ground on a prone position.
#define TRAIT_IMMOBILE "immobile" //User is unable to move by its own volition.
#define TRAIT_IS_RESURRECTING "resurrecting"
#define TRAIT_ESSENCE_LINKED "essence_linked"
#define TRAIT_PSY_LINKED "psy_linked"
#define TRAIT_TIME_SHIFTED "time_shifted"
#define TRAIT_LEASHED "leashed"
#define TRAIT_CAN_VENTCRAWL "can_ventcrawl"
#define TRAIT_WORKED_OUT "worked_out" //user has a unarmed buff from working out
///Makes no footsteps at all
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps"
/// Prevents a mob from being unbuckled, currently only used to prevent people from falling over on the tram
#define TRAIT_CANNOT_BE_UNBUCKLED "cannot_be_unbuckled"
///quieter footsteps
#define TRAIT_LIGHT_STEP "light_step"
///noisier footsteps
#define TRAIT_HEAVY_STEP "heavy_step"
///indicates this mob was spawned by a corpse spawner
#define TRAIT_MAPSPAWNED "mapspawned"
///Mindmelded with another mob
#define TRAIT_MINDMELDED "mindmelded"
///You swing axe good
#define TRAIT_AXE_EXPERT "axe_expert"
///You swing sword good
#define TRAIT_SWORD_EXPERT "sword_expert"
///Pain reduction light
#define TRAIT_LIGHT_PAIN_RESIST "light_pain_resist"
///Pain reduction medium
#define TRAIT_MEDIUM_PAIN_RESIST "medium_pain_resist"
///is currently riding an armored vehicle
#define TRAIT_TANK_DESANT "tank_desant"
///Builds things better
#define TRAIT_SUPERIOR_BUILDER "superior_builder"
/// Mob has fov applied to it
#define TRAIT_FOV_APPLIED "fov_applied"
/// Expands our FOV by 30 degrees if restricted
#define TRAIT_EXPANDED_FOV "expanded_fov"
///xenos that can disable miners
#define TRAIT_CAN_DISABLE_MINER "can_disable_miner"
///xenos that can tear open holes
#define TRAIT_CAN_TEAR_HOLE "can_tear_hole"
/// Allows xenomorphs to heal without needing to be on weeds.
#define TRAIT_INNATE_HEALING "innate_healing"

///Traits for managing AM pass_flags
#define TRAIT_PASS_LOW_STRUCTURE "pass_low_structure"
#define TRAIT_PASS_GLASS "pass_glass"
#define TRAIT_PASS_GRILLE "pass_grille"
#define TRAIT_PASS_MOB "pass_mob"
#define TRAIT_PASS_DEFENSIVE_STRUCTURE "pass_defensive_structure"
#define TRAIT_PASS_FIRE "pass_fire"
#define TRAIT_PASS_XENO "pass_xeno"
#define TRAIT_PASS_THROW "pass_throw"
#define TRAIT_PASS_PROJECTILE "pass_projectile"
#define TRAIT_PASS_AIR "pass_air"
#define TRAIT_PASS_WALKOVER "pass_walkover"
#define TRAIT_PASS_TANK "pass_tank"

/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
#define TRAIT_STUNIMMUNE "stun_immunity"
#define TRAIT_BATONIMMUNE "baton_immunity"
#define TRAIT_SLEEPIMMUNE "sleep_immunity"
#define TRAIT_FLASHBANGIMMUNE "flashbang_immunity"
#define TRAIT_FAKEDEATH "fakedeath" //Makes the owner appear as dead to most forms of medical examination
#define TRAIT_LEGLESS "legless" //Has lost all the appendages needed to stay standing up.
#define TRAIT_NOPLASMAREGEN "noplasmaregen"//xeno plasma wont recharge
#define TRAIT_UNDEFIBBABLE "undefibbable"//human can't be revived
#define TRAIT_HOLLOW "hollowedout" //examine trait for puppeteer
#define TRAIT_IMMEDIATE_DEFIB "immediate_defib"//immediately revives when defibbed, rather than just healing
#define TRAIT_CRIT_IS_DEATH "crit_is_death" ///instantly causes enough oxy damage to kill the user when they hit critical health
#define TRAIT_HEALING_INFUSION "healing_infusion"//greatly improves natural healing for xenos
#define TRAIT_PSY_DRAINED "psy_drained"//mob was drained of life force by a xenos
#define TRAIT_HIVE_TARGET "hive_target"//mob is targeted for draining by the hive
#define TRAIT_RESEARCHED "researched" // Whether the thing has been researched/probed
#define TRAIT_STAGGERIMMUNE	"stagger_immunity" //Immunity to stagger
#define TRAIT_STAGGER_RESISTANT	"stagger_resistant" //Resistance to certain sources of stagger
#define TRAIT_SLOWDOWNIMMUNE "slowdown_immunity" //Immunity to slowdown
#define TRAIT_EARDAMAGE_IMMUNE "eardmgimmune" //immune to getting deaf through ear dmg
///massively decreases human MANUAL get up time
#define TRAIT_QUICK_GETUP "quick_getup"
#define TRAIT_SEE_IN_DARK "see_in_dark" //Able to see in dark
#define TRAIT_MUTE "mute" //target is mute and can't speak, not to be confused with being muted by an admin
#define TRAIT_TURRET_HIDDEN "turret_hidden" //target gets passed over by turrets choosing a victim
///The target xenomorph's wound overlays won't be visible
#define TRAIT_XENOMORPH_INVISIBLE_BLOOD "invisible_blood"
#define TRAIT_VALHALLA_XENO "valhalla_xeno"
#define TRAIT_BULWARKED_TURF "bulwarked_turf" // turf is affected by bulwark ability
#define TRAIT_RECOVERY_PYLON_TURF "recovery_pylon_turf" // Turf is affected by a recovery pylon.
#define TRAIT_BLOODTHIRSTER "bloodthirster" // xeno has the bloodthirster ability
#define TRAIT_WEB_PULLER "web_puller" // Xenomorph has a special interaction with the Snaring Web structure.

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive" //target is hearing sensitive. Every hearing sensitive atom has this trait

#define TRAIT_HAS_INTERIOR "has_interior" // Used for atoms that have an interior datum
/// Trait given to a mob that is currently thinking (giving off the "thinking" icon), used in an IC context
#define TRAIT_THINKING_IN_CHARACTER "currently_thinking_IC"

#define TRAIT_DROOLING "drooling" //target is drooling
#define TRAIT_INTOXICATION_IMMUNE "intoxication_immune" // Immune to the Intoxication debuff.
#define TRAIT_INTOXICATION_RESISTANT "intoxication_resistant" // Resistant to the Intoxication debuff. Maximum amount of stacks limited.
#define TRAIT_PAIN_IMMUNE "pain_immune" // We don't feel pain.
///Prevent mob from being ignited due to IgniteMob()
#define TRAIT_NON_FLAMMABLE "non-flammable"
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE "cant_ride"
///Prevents humans from gaining oxyloss in their handle_breath()
#define TRAIT_IGNORE_SUFFOCATION "ignore_suffocation"

///climbing a structure
#define TRAIT_IS_CLIMBING "is_climbing"
///reloading a gun
#define TRAIT_IS_RELOADING "is_reloading"
///is removing shrapnel
#define TRAIT_IS_SHRAP_REMOVING "is_shrap_removing"

//All the traits for guns
#define TRAIT_GUN_SAFETY "safety"
#define TRAIT_GUN_FLASHLIGHT_ON "light_on"
#define TRAIT_GUN_AUTO_AIM_MODE "auto_aim_mode"
#define TRAIT_GUN_IS_AIMING "aiming"
#define TRAIT_GUN_BURST_FIRING "burst_firing"
#define TRAIT_GUN_SILENCED "silenced"
#define TRAIT_GUN_RELOADING "reloading"

// item traits
#define TRAIT_NODROP "nodrop" // Cannot be dropped/unequipped at all, only deleted.
#define TRAIT_T_RAY_VISIBLE "t-ray-visible" // Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_STRAPPABLE "strappable"
// turf traits
#define TRAIT_TURF_BULLET_MANIPULATION "bullet_manipulation" //This tile is doing something to projectile
///Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"
// projectile traits
#define TRAIT_PROJ_HIT_SOMETHING "hit_something" //If projectile hit something on its path
//structure traits
#define BENCH_BEING_USED "bench_being_used"

// UI traits
/// Inability to access UI hud elements.
#define TRAIT_UI_BLOCKED "ui_blocked" //if user is blocked from using UI
/// This mob should never close UI even if it doesn't have a client
#define TRAIT_PRESERVE_UI_WITHOUT_CLIENT "preserve_ui_without_client"

//this mech is melee core boosted
#define TRAIT_MELEE_CORE "melee_core"
///stops tanks from being able to ram this mob
#define TRAIT_STOPS_TANK_COLLISION "stops_tanks"

//added to escaped humans
#define TRAIT_HAS_ESCAPED "escaped_marine"
#define TRAIT_HAS_BEEN_TARGETED "been_targeted"

//added to AIs firing railguns
#define TRAIT_IS_FIRING_RAILGUN "firing_railgun"

//regress and caste swap UI
#define TRAIT_CASTE_SWAP "caste_swap"
#define TRAIT_REGRESSING "regressing"
#define TRAIT_STRAIN_SWAP "strain swap"

GLOBAL_LIST_INIT(traits_to_pass_flags, list(
	TRAIT_PASS_LOW_STRUCTURE = PASS_LOW_STRUCTURE,
	TRAIT_PASS_GLASS = PASS_GLASS,
	TRAIT_PASS_GRILLE = PASS_GRILLE,
	TRAIT_PASS_MOB = PASS_MOB,
	TRAIT_PASS_DEFENSIVE_STRUCTURE = PASS_DEFENSIVE_STRUCTURE,
	TRAIT_PASS_FIRE = PASS_FIRE,
	TRAIT_PASS_XENO = PASS_XENO,
	TRAIT_PASS_THROW = PASS_THROW,
	TRAIT_PASS_PROJECTILE = PASS_PROJECTILE,
	TRAIT_PASS_AIR = PASS_AIR,
	TRAIT_PASS_WALKOVER = PASS_WALKOVER,
	TRAIT_PASS_TANK = PASS_TANK,
))
