/obj/effect/ai_spawner_node
	name = "AI Spawner Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x6" //xxx 'X' with black borders
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	///Interval for how often the mobs will spawn
	var/spawn_interval = 100
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

/*	UNCOMMENT THESE AS MORE AIS ARE MERGED
/obj/effect/ai_spawner_node/sentinel
	mobtospawn = /mob/living/carbon/xenomorph/sentinel/ai

/obj/effect/ai_spawner_node/defender
	mobtospawn = /mob/living/carbon/xenomorph/defender/ai

/**
 * Tier two spawners
 */
/obj/effect/ai_spawner_node/hivelord
	mobtospawn = /mob/living/carbon/xenomorph/hivelord/ai

/obj/effect/ai_spawner_node/carrier
	mobtospawn = /mob/living/carbon/xenomorph/carrier/ai

/obj/effect/ai_spawner_node/spitter
	mobtospawn = /mob/living/carbon/xenomorph/spitter/ai

/obj/effect/ai_spawner_node/hunter
	mobtospawn = /mob/living/carbon/xenomorph/hunter/ai

/obj/effect/ai_spawner_node/bull
	mobtospawn = /mob/living/carbon/xenomorph/bull/ai

/obj/effect/ai_spawner_node/warrior
	mobtospawn = /mob/living/carbon/xenomorph/warrior/ai

/**
 * Tier three spawners
 */
/obj/effect/ai_spawner_node/ravager
	mobtospawn = /mob/living/carbon/xenomorph/ravager/ai

/obj/effect/ai_spawner_node/crusher
	mobtospawn = /mob/living/carbon/xenomorph/crusher/ai

/obj/effect/ai_spawner_node/boiler
	mobtospawn = /mob/living/carbon/xenomorph/boiler/ai

/obj/effect/ai_spawner_node/praetorian
	mobtospawn = /mob/living/carbon/xenomorph/praetorian/ai

/obj/effect/ai_spawner_node/defiler
	mobtospawn = /mob/living/carbon/xenomorph/defiler/ai

/obj/effect/ai_spawner_node/shrike
	mobtospawn = /mob/living/carbon/xenomorph/shrike/ai

/obj/effect/ai_spawner_node/queen
	mobtospawn = /mob/living/carbon/xenomorph/queen/ai
*/
/**
 * Goonsquad spawners
 */
/obj/effect/ai_spawner_node/group
	squad_spawner = TRUE

/obj/effect/ai_spawner_node/group/runnergang	//RUNNER GANG RUNNER GANG
	mobtospawn = list(/mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/runner/ai)

/obj/effect/ai_spawner_node/group/drone_and_runners
	mobtospawn = list(/mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/drone/ai)
