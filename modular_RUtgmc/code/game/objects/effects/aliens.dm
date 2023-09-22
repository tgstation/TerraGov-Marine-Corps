/obj/effect/xenomorph/spray
	icon = 'modular_RUtgmc/icons/Xeno/Effects.dmi'

/obj/effect/xenomorph/spray/Initialize(mapload, duration = 10 SECONDS, damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE, mob/living/_xeno_owner) //Self-deletes
	. = ..()
	animate(src, duration, alpha = 20)

