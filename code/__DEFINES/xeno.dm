//Xeno structure flags
#define IGNORE_WEED_REMOVAL (1<<0)

//Weeds define
#define SPEED_WEED "speed weed sac"
#define STICKY_WEED "sticky weed sac"
#define RESTING_WEED "resting weed sac"
#define BARBED_WEED "barbed weed sac"

//List of weed types
GLOBAL_LIST_INIT(weed_type_list, typecacheof(list(
		/obj/effect/alien/weeds/node/speed,
		/obj/effect/alien/weeds/node/resting,
		/obj/effect/alien/weeds/node/barbed,
		)))

//List of weeds with probability of spawning
GLOBAL_LIST_INIT(weed_prob_list, list(
		/obj/effect/alien/weeds/node/speed = 80,
		/obj/effect/alien/weeds/node/resting = 10,
		/obj/effect/alien/weeds/node/barbed = 10,
		))

//List of weed images
GLOBAL_LIST_INIT(weed_images_list,  list(
		SPEED_WEED = image('icons/mob/actions.dmi', icon_state = SPEED_WEED),
		RESTING_WEED = image('icons/mob/actions.dmi', icon_state = RESTING_WEED),
		BARBED_WEED = image('icons/mob/actions.dmi', icon_state = BARBED_WEED),
		))

//List of Defiler toxin types
GLOBAL_LIST_INIT(defiler_toxin_type_list, list(
		/datum/reagent/toxin/xeno_neurotoxin,
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		))
