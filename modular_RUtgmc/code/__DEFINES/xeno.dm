//Resin defines
#define ALIEN_NEST "alien nest"

//Defiler light acid
#define DEFILER_ACID "Acid"

//Panther tearing tail reagents
#define PANTHER_NEUROTOXIN "Neurotoxin"
#define PANTHER_HEMODILE "Hemodile"
#define PANTHER_TRANSVITOX "Transvitox"
#define PANTHER_OZELOMELYN "Ozelomelyn"
#define PANTHER_SANGUINAL "Sanguinal"

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
