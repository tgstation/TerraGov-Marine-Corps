/obj/effect/ai_spawner_node
	name = "AI Spawner Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x6" //xxx 'X' with black borders
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	///Interval for how often the mobs will spawn
	var/spawn_interval = 30	//Once per minute
	///Maximum amount of mobs created by this spawner that can be active
	var/max_mobs_spawned = 10
	///Mob we want to be spawned
	var/mobtospawn = /mob/living/carbon/xenomorph
	///Whether we want all the mobs in the list to be spawned or not
	var/squad_spawner = FALSE

/obj/effect/ai_spawner_node/Initialize()
	. = ..()
	AddComponent(/datum/component/spawner, mobtospawn, spawn_interval,"crawls out of", max_mobs_spawned, squad_spawner)

/**
 * Tier one spawners
 */
/obj/effect/ai_spawner_node/drone
	mobtospawn = /mob/living/carbon/xenomorph/drone/ai

/obj/effect/ai_spawner_node/runner
	mobtospawn = /mob/living/carbon/xenomorph/runner/ai


/**
 * Goonsquad spawners
 */
/obj/effect/ai_spawner_node/group
	squad_spawner = TRUE

/obj/effect/ai_spawner_node/group/runnergang	//RUNNER GANG RUNNER GANG
	mobtospawn = list(/mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/runner/ai)

/obj/effect/ai_spawner_node/group/drone_and_runners
	mobtospawn = list(/mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/drone/ai)
