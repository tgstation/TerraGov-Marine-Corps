//Resin defines
#define ALIEN_NEST "alien nest"
#define GROWTH_WALL "growth wall"
#define GROWTH_DOOR "growth door"

//Xeno reagents defines
#define DEFILER_ACID "Sulphuric acid"

//Panther tearing tail reagents
#define PANTHER_NEUROTOXIN "Neurotoxin"
#define PANTHER_HEMODILE "Hemodile"
#define PANTHER_TRANSVITOX "Transvitox"
#define PANTHER_OZELOMELYN "Ozelomelyn"
#define PANTHER_SANGUINAL "Sanguinal"

//Forbid
#define MAX_FORBIDEN_CASTES 8

//List of weed images
GLOBAL_LIST_INIT(weed_images_list, list(
		WEED = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = WEED),
		STICKY_WEED = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = STICKY_WEED),
		RESTING_WEED = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = RESTING_WEED),
		AUTOMATIC_WEEDING = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = AUTOMATIC_WEEDING)
		))

//List of pheromone images
GLOBAL_LIST_INIT(pheromone_images_list, list(
		AURA_XENO_RECOVERY = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = AURA_XENO_RECOVERY),
		AURA_XENO_WARDING = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = AURA_XENO_WARDING),
		AURA_XENO_FRENZY = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = AURA_XENO_FRENZY),
		))

//List of plant images
GLOBAL_LIST_INIT(plant_images_list, list(
		HEAL_PLANT = image('modular_RUtgmc/icons/Xeno/plants.dmi', icon_state = "heal_fruit"),
		ARMOR_PLANT = image('modular_RUtgmc/icons/Xeno/plants.dmi', icon_state = "armor_fruit"),
		PLASMA_PLANT = image('modular_RUtgmc/icons/Xeno/plants.dmi', icon_state = "plasma_fruit"),
		STEALTH_PLANT = image('modular_RUtgmc/icons/Xeno/plants.dmi', icon_state = "stealth_plant")
		))

//List of resin structure images
GLOBAL_LIST_INIT(resin_images_list, list(
		RESIN_WALL = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = RESIN_WALL),
		STICKY_RESIN = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = STICKY_RESIN),
		RESIN_DOOR = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = RESIN_DOOR),
		ALIEN_NEST = image('modular_RUtgmc/icons/Xeno/actions.dmi', icon_state = ALIEN_NEST)
		))

GLOBAL_LIST_INIT(panther_toxin_type_list, list(
		/datum/reagent/toxin/xeno_ozelomelyn,
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		/datum/reagent/toxin/xeno_neurotoxin,
		/datum/reagent/toxin/xeno_sanguinal,
		))
