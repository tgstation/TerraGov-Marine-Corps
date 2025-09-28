//Xeno structure flags
#define IGNORE_WEED_REMOVAL (1<<0)
#define HAS_OVERLAY (1<<1)
#define CRITICAL_STRUCTURE (1<<2)
#define DEPART_DESTRUCTION_IMMUNE (1<<3)
///Structure will warn when hostiles are nearby
#define XENO_STRUCT_WARNING_RADIUS (1<<4)
///Structure will warn when damaged
#define XENO_STRUCT_DAMAGE_ALERT (1<<5)

//Weeds defines
#define WEED "weed sac"
#define STICKY_WEED "sticky weed sac"
#define RESTING_WEED "resting weed sac"
#define AUTOMATIC_WEEDING "repeating"

#define XENO_TURRET_ACID_ICONSTATE "acid_turret"
#define XENO_TURRET_STICKY_ICONSTATE "resin_turret"

//Plant defines
#define HEAL_PLANT "life fruit"
#define ARMOR_PLANT "hard fruit"
#define PLASMA_PLANT "power fruit"
#define STEALTH_PLANT "night shade"
#define STEALTH_PLANT_PASSIVE_CAMOUFLAGE_ALPHA 64

//Resin defines
#define RESIN_WALL "resin wall"
#define STICKY_RESIN "sticky resin"
#define RESIN_DOOR "resin door"

//Special resin defines
#define BULLETPROOF_WALL "bulletproof resin wall"
#define FIREPROOF_WALL "fireproof resin wall"
#define HARDY_WALL "hardy resin wall"

//Xeno reagents defines
#define DEFILER_NEUROTOXIN "Neurotoxin"
#define DEFILER_HEMODILE "Hemodile"
#define DEFILER_TRANSVITOX "Transvitox"
#define DEFILER_OZELOMELYN "Ozelomelyn"

//Baneling specific reagent define
#define BANELING_ACID "Sulphuric acid"

#define TRAP_HUGGER "hugger"
#define TRAP_SMOKE_NEURO "neurotoxin gas"
#define TRAP_SMOKE_ACID "acid gas"
#define TRAP_ACID_WEAK "weak acid"
#define TRAP_ACID_NORMAL "acid"
#define TRAP_ACID_STRONG "strong acid"

//Xeno acid strength defines
#define WEAK_ACID_STRENGTH 0.016
#define REGULAR_ACID_STRENGTH 0.04
#define STRONG_ACID_STRENGTH 0.1

#define PUPPET_RECALL "recall puppet"
#define PUPPET_SEEK_CLOSEST "seeking closest and attack order" //not xeno-usable
#define PUPPET_ATTACK "seek and attack order"

//List of weed types
GLOBAL_LIST_INIT(weed_type_list, typecacheof(list(
	/obj/alien/weeds/node,
	/obj/alien/weeds/node/sticky,
	/obj/alien/weeds/node/resting,
)))

//List of weeds with probability of spawning
GLOBAL_LIST_INIT(weed_prob_list, list(
	/obj/alien/weeds/node = 5,
	/obj/alien/weeds/node/sticky = 85,
	/obj/alien/weeds/node/resting = 10,
))

//List of weed images
GLOBAL_LIST_INIT(weed_images_list, list(
	WEED = image('icons/Xeno/actions/construction.dmi', icon_state = WEED),
	STICKY_WEED = image('icons/Xeno/actions/construction.dmi', icon_state = STICKY_WEED),
	RESTING_WEED = image('icons/Xeno/actions/construction.dmi', icon_state = RESTING_WEED),
	AUTOMATIC_WEEDING = image('icons/Xeno/actions/general.dmi', icon_state = AUTOMATIC_WEEDING)
))

//List of pheromone images
GLOBAL_LIST_INIT(pheromone_images_list, list(
	AURA_XENO_RECOVERY = image('icons/Xeno/actions/general.dmi', icon_state = AURA_XENO_RECOVERY),
	AURA_XENO_WARDING = image('icons/Xeno/actions/general.dmi', icon_state = AURA_XENO_WARDING),
	AURA_XENO_FRENZY = image('icons/Xeno/actions/general.dmi', icon_state = AURA_XENO_FRENZY),
))

//List of Defiler toxin types available for selection
GLOBAL_LIST_INIT(defiler_toxin_type_list, list(
	/datum/reagent/toxin/xeno_neurotoxin,
	/datum/reagent/toxin/xeno_hemodile,
	/datum/reagent/toxin/xeno_transvitox,
	/datum/reagent/toxin/xeno_ozelomelyn,
))

//List of toxins improving defile's damage
GLOBAL_LIST_INIT(defiler_toxins_typecache_list, typecacheof(list(
	/datum/reagent/toxin/xeno_ozelomelyn,
	/datum/reagent/toxin/xeno_hemodile,
	/datum/reagent/toxin/xeno_transvitox,
	/datum/reagent/toxin/xeno_neurotoxin,
	/datum/reagent/toxin/xeno_sanguinal,
	/datum/status_effect/stacking/intoxicated,
)))

//List of Baneling chemical types available for selection
GLOBAL_LIST_INIT(baneling_chem_type_list, list(
	/datum/reagent/toxin/xeno_neurotoxin,
	/datum/reagent/toxin/acid,
))

//List of plant types
GLOBAL_LIST_INIT(plant_type_list, list(
	/obj/structure/xeno/plant/heal_fruit,
	/obj/structure/xeno/plant/armor_fruit,
	/obj/structure/xeno/plant/plasma_fruit,
	/obj/structure/xeno/plant/stealth_plant
))

//List of plant images
GLOBAL_LIST_INIT(plant_images_list, list(
	HEAL_PLANT = image('icons/Xeno/plants.dmi', icon_state = "heal_fruit"),
	ARMOR_PLANT = image('icons/Xeno/plants.dmi', icon_state = "armor_fruit"),
	PLASMA_PLANT = image('icons/Xeno/plants.dmi', icon_state = "plasma_fruit"),
	STEALTH_PLANT = image('icons/Xeno/plants.dmi', icon_state = "stealth_plant")
))

//List of resin structure images
GLOBAL_LIST_INIT(resin_images_list, list(
	RESIN_WALL = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_WALL),
	BULLETPROOF_WALL = image('icons/Xeno/actions/construction.dmi', icon_state = BULLETPROOF_WALL),
	FIREPROOF_WALL = image('icons/Xeno/actions/construction.dmi', icon_state = FIREPROOF_WALL),
	HARDY_WALL = image('icons/Xeno/actions/construction.dmi', icon_state = HARDY_WALL),
	STICKY_RESIN = image('icons/Xeno/actions/construction.dmi', icon_state = STICKY_RESIN),
	RESIN_DOOR = image('icons/Xeno/actions/construction.dmi', icon_state = RESIN_DOOR),
))

//List of puppeteer pheromone images
GLOBAL_LIST_INIT(puppeteer_phero_images_list, list(
	AURA_XENO_BLESSFURY = image('icons/Xeno/actions/puppeteer.dmi', icon_state = "Fury"),
	AURA_XENO_BLESSWARDING = image('icons/Xeno/actions/puppeteer.dmi', icon_state = "Warding"),
	AURA_XENO_BLESSFRENZY = image('icons/Xeno/actions/puppeteer.dmi', icon_state = "Frenzy"),
))

//xeno upgrade flags
///Message the hive when we buy this upgrade
#define UPGRADE_FLAG_MESSAGE_HIVE (1<<0)
#define UPGRADE_FLAG_ONETIME (1<<1)
#define UPGRADE_FLAG_USES_TACTICAL (1<<2)

GLOBAL_LIST_INIT(xeno_ai_spawnable, list(
	/mob/living/carbon/xenomorph/beetle/ai,
	/mob/living/carbon/xenomorph/mantis/ai,
	/mob/living/carbon/xenomorph/scorpion/ai,
	/mob/living/carbon/xenomorph/nymph/ai,
	/mob/living/carbon/xenomorph/baneling/ai,
))

///Heals a xeno, respecting different types of damage
#define HEAL_XENO_DAMAGE(xeno, amount, passive) do { \
	var/fire_loss = xeno.getFireLoss(); \
	if(fire_loss) { \
		var/fire_heal = min(fire_loss, amount); \
		amount -= fire_heal;\
		xeno.adjustFireLoss(-fire_heal, TRUE, passive); \
	} \
	var/brute_loss = xeno.getBruteLoss(); \
	if(brute_loss) { \
		var/brute_heal = min(brute_loss, amount); \
		amount -= brute_heal; \
		xeno.adjustBruteLoss(-brute_heal, TRUE, passive); \
	} \
} while(FALSE)

/// Used by the is_valid_for_resin_structure proc.
/// 0 is considered valid , anything thats not 0 is false
/// Simply not allowed by the area to build
#define NO_ERROR 0
#define ERROR_JUST_NO 1
#define ERROR_NOT_ALLOWED 2
/// No weeds here, but it is weedable
#define ERROR_NO_WEED 3
/// Area is not weedable
#define ERROR_CANT_WEED 4
/// Gamemode-fog prevents spawn-building
#define ERROR_FOG 5
/// Blocked by a xeno
#define ERROR_BLOCKER 6
/// No adjaecent wall or door tile
#define ERROR_NO_SUPPORT 7
/// Failed to other blockers such as egg, power plant , coocon , traps
#define ERROR_CONSTRUCT 8

#define WEED_REQUIRES_LOS (1<<0)
#define WEED_TAKES_TIME (1<<1)
#define WEED_COSTS_QB_POINTS (1<<2)
#define WEED_USES_PLASMA (1<<3)
#define WEED_NOTIFY (1<<4) // secrete resin message on building

#define PUPPET_WITHER_RANGE 15

///Number of icon states to show health and plasma on the side UI buttons
#define XENO_HUD_ICON_BUCKETS 16

/// Life runs every 2 seconds, but we don't want to multiply all healing by 2 due to seconds_per_tick
#define XENO_PER_SECOND_LIFE_MOD 0.5

//How long the alert directional pointer lasts when structures are damaged
#define XENO_STRUCTURE_DAMAGE_POINTER_DURATION 10 SECONDS
///How frequently the damage alert can go off
#define XENO_STRUCTURE_HEALTH_ALERT_COOLDOWN 30 SECONDS
///How frequently the proximity alert can go off
#define XENO_STRUCTURE_DETECTION_COOLDOWN 30 SECONDS
///Proxy detection radius
#define XENO_STRUCTURE_DETECTION_RANGE 10
