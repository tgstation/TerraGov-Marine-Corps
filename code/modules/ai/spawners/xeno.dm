/obj/effect/ai_node/spawner/xeno
	name = "Xeno AI spawner"

//////Generic xeno spawners
////////Tier ones

/obj/effect/ai_node/spawner/xeno/runnergang	// RUNNNER GANG RUNNER GANG
	spawntypes = list(/mob/living/carbon/xenomorph/runner/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/defender
	spawntypes = list(/mob/living/carbon/xenomorph/defender/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/sentinel
	spawntypes = list(/mob/living/carbon/xenomorph/sentinel/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/drone
	spawntypes = list(/mob/living/carbon/xenomorph/drone/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/tierones
	spawntypes = list(/mob/living/carbon/xenomorph/runner/ai, /mob/living/carbon/xenomorph/sentinel/ai, /mob/living/carbon/xenomorph/defender/ai, /mob/living/carbon/xenomorph/drone/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/////////////Tier twos

/obj/effect/ai_node/spawner/xeno/spitter
	spawntypes = list(/mob/living/carbon/xenomorph/spitter/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/warrior
	spawntypes = list(/mob/living/carbon/xenomorph/warrior/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/hivelord
	spawntypes = list(/mob/living/carbon/xenomorph/hivelord/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/hunter
	spawntypes = list(/mob/living/carbon/xenomorph/hunter/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/tiertwos
	spawntypes = list(/mob/living/carbon/xenomorph/hunter/ai =33, /mob/living/carbon/xenomorph/warrior/ai =33, /mob/living/carbon/xenomorph/spitter/ai =33)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

////////////////////Tier 3s

/obj/effect/ai_node/spawner/xeno/ravager
	spawntypes = list(/mob/living/carbon/xenomorph/ravager/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/boiler
	spawntypes = list(/mob/living/carbon/xenomorph/boiler/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/praetorian
	spawntypes = list(/mob/living/carbon/xenomorph/praetorian/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/crusher
	spawntypes = list(/mob/living/carbon/xenomorph/crusher/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10


/obj/effect/ai_node/spawner/xeno/tierthrees
	spawntypes = list(/mob/living/carbon/xenomorph/crusher/ai =1, /mob/living/carbon/xenomorph/praetorian/ai =1, /mob/living/carbon/xenomorph/boiler/ai =1, /mob/living/carbon/xenomorph/ravager/ai =1)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/////////////Tier 4s

/obj/effect/ai_node/spawner/xeno/queen
	spawntypes = list(/mob/living/carbon/xenomorph/queen/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10
