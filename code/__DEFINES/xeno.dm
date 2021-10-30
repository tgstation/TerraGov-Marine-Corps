//Xeno structure flags
#define IGNORE_WEED_REMOVAL (1<<0)

//Weeds define
#define WEED "weed sac"
#define STICKY_WEED "sticky weed sac"
#define RESTING_WEED "resting weed sac"

#define XENO_TURRET_ACID_ICONSTATE "acid_turret"
#define XENO_TURRET_STICKY_ICONSTATE "resin_turret"

//List of weed types
GLOBAL_LIST_INIT(weed_type_list, typecacheof(list(
		/obj/effect/alien/weeds/node,
		/obj/effect/alien/weeds/node/sticky,
		/obj/effect/alien/weeds/node/resting,
		)))

//List of weeds with probability of spawning
GLOBAL_LIST_INIT(weed_prob_list, list(
		/obj/effect/alien/weeds/node = 80,
		/obj/effect/alien/weeds/node/sticky = 5,
		/obj/effect/alien/weeds/node/resting = 10,
		))

//List of weed images
GLOBAL_LIST_INIT(weed_images_list,  list(
		WEED = image('icons/mob/actions.dmi', icon_state = WEED),
		STICKY_WEED = image('icons/mob/actions.dmi', icon_state = STICKY_WEED),
		RESTING_WEED = image('icons/mob/actions.dmi', icon_state = RESTING_WEED),
		))

//List of Defiler toxin types
GLOBAL_LIST_INIT(defiler_toxin_type_list, list(
		/datum/reagent/toxin/xeno_neurotoxin,
		/datum/reagent/toxin/xeno_hemodile,
		/datum/reagent/toxin/xeno_transvitox,
		))

//xeno upgrade flags
///Message the hive when we buy this upgrade
#define UPGRADE_FLAG_MESSAGE_HIVE (1<<0)
#define UPGRADE_FLAG_ONETIME (1<<0)


//xeno primordial defines
#define PRIMORDIAL_QUEEN "Primordial Queen"
#define PRIMORDIAL_SHRIKE "Primordial Shrike"
#define PRIMORDIAL_DEFILER "Primordial Defiler"
#define PRIMORDIAL_SENTINEL "Primordial Sentinel"
#define PRIMORDIAL_RAVAGER "Primordial Ravager"
#define PRIMORDIAL_CRUSHER "Primordial Crusher"
#define PRIMORDIAL_HUNTER "Primordial Hunter"
#define PRIMORDIAL_DEFENDER "Primordial Defender"

GLOBAL_LIST_INIT(xeno_ai_spawnable, list(
	/mob/living/carbon/xenomorph/beetle/ai,
	/mob/living/carbon/xenomorph/mantis/ai,
	/mob/living/carbon/xenomorph/scorpion/ai,
))

