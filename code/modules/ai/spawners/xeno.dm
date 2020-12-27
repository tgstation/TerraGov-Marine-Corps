/obj/effect/ai_node/spawner/xeno
	name = "Xeno AI spawner"

/obj/effect/ai_node/spawner/xeno/runnergang	// RUNNNER GANG RUNNER GANG
	spawntypes = /mob/living/carbon/xenomorph/runner/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/tierones
	spawntypes = list(/mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/sentinel/ai, /mob/living/carbon/xenomorph/defender/ai, /mob/living/carbon/xenomorph/drone/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10
