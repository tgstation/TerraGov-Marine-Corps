/obj/effect/ai_node/spawner/xeno
	name = "Xeno AI spawner"

//////Generic xeno spawners
////////Tier ones

/obj/effect/ai_node/spawner/xeno/runnergang	// RUNNNER GANG RUNNER GANG
	spawntypes = /mob/living/carbon/xenomorph/runner/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/defender
	spawntypes = /mob/living/carbon/xenomorph/defender/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/sentinel
	spawntypes = /mob/living/carbon/xenomorph/sentinel/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/drone
	spawntypes = /mob/living/carbon/xenomorph/drone/ai
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
	spawntypes = /mob/living/carbon/xenomorph/spitter/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/warrior
	spawntypes = /mob/living/carbon/xenomorph/warrior/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/hivelord
	spawntypes = /mob/living/carbon/xenomorph/hivelord/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/hunter
	spawntypes = /mob/living/carbon/xenomorph/hunter/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/tiertwos
	spawntypes = list(/mob/living/carbon/xenomorph/hunter/ai, /mob/living/carbon/xenomorph/warrior/ai, /mob/living/carbon/xenomorph/spitter/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

////////////////////Tier 3s

/obj/effect/ai_node/spawner/xeno/ravager
	spawntypes = /mob/living/carbon/xenomorph/ravager/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/boiler
	spawntypes = /mob/living/carbon/xenomorph/boiler/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/praetorian
	spawntypes = /mob/living/carbon/xenomorph/praetorian/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/obj/effect/ai_node/spawner/xeno/crusher
	spawntypes = /mob/living/carbon/xenomorph/crusher/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10


/obj/effect/ai_node/spawner/xeno/tierthrees
	spawntypes = list(/mob/living/carbon/xenomorph/crusher/ai, /mob/living/carbon/xenomorph/praetorian/ai, /mob/living/carbon/xenomorph/boiler/ai, /mob/living/carbon/xenomorph/ravager/ai)
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/////////////Tier 4s

/obj/effect/ai_node/spawner/xeno/queen
	spawntypes = /mob/living/carbon/xenomorph/queen/ai
	spawnamount = 4
	spawndelay = 10 SECONDS
	maxamount = 10

/particles/xeno_drool
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "rectangle_long"
	width = 100
	height = 100
	count = 5
	spawning = 1
	lifespan = 10
	fade = 25
	position = generator(GEN_BOX, list(-16, 32), list(16, 32), NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.2), list(0, 0.2))
	gravity = list(0, -1)

/obj/effect/ai_node/spawner/xeno/drone/ambush
	spawntypes = /mob/living/carbon/xenomorph/drone/ai
	spawnamount = 3
	spawndelay = 30 SECONDS
	maxamount = 10
	use_postspawn = TRUE
	icon_state = "invis"
	invisibility = 0

/obj/effect/ai_node/spawner/Initialize()
	. = ..()
	particles = new /particles/xeno_drool

/obj/effect/ai_node/spawner/xeno/drone/ambush/postspawn(list/squad)
	playsound(loc, 'sound/effects/alien_ambush.ogg', 75, TRUE)
	for(var/mob/living/carbon/xenomorph/drone/ai/xeno AS in squad)
		xeno.pixel_y = 45
		xeno.alpha = 50
		animate(xeno, 0.4 SECONDS, pixel_y = 0, alpha = 255)
