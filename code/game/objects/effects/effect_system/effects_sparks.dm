/////////////////////////////////////////////
//SPARK SYSTEM (like steam system)
// The attach(atom/atom) proc is optional, and can be called to attach the effect
// to something, like the RCD, so then you can just call start() and the sparks
// will always spawn at the items location.
/////////////////////////////////////////////

/atom/proc/spark_act()
	return

/proc/do_sparks(n, c, source)
	// n - number of sparks
	// c - cardinals, bool, do the sparks only move in cardinal directions?
	// source - source of the sparks.

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(n, c, source)
	sparks.autocleanup = TRUE
	sparks.start()


/obj/effect/particle_effect/sparks
	name = "sparks"
	icon = 'icons/effects/64x64.dmi'
	icon_state = "sparks"
	anchored = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.5
	light_color = LIGHT_COLOR_FIRE
	pixel_x = -16
	pixel_y = -16
	layer = ABOVE_LIGHTING_LAYER
	plane = ABOVE_LIGHTING_PLANE


/obj/effect/particle_effect/sparks/Initialize()
	..()
	dir = pick(GLOB.cardinals)
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/sparks/LateInitialize()
	flick(icon_state, src) // replay the animation
//	playsound(src, "sparks", 100, TRUE)
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
		for(var/A in T)
			var/atom/AT = A
			if(!QDELETED(AT) && AT != src)
				AT.spark_act()
	QDEL_IN(src, 20)

/obj/effect/particle_effect/sparks/Destroy()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
		for(var/A in T)
			var/atom/AT = A
			if(!QDELETED(AT) && AT != src)
				AT.spark_act()
	return ..()

/obj/effect/particle_effect/sparks/Move()
	..()
	var/turf/T = loc
	if(isturf(T))
		T.hotspot_expose(1000,100)
		for(var/A in T)
			var/atom/AT = A
			if(!QDELETED(AT) && AT != src)
				AT.spark_act()

/datum/effect_system/spark_spread
	effect_type = /obj/effect/particle_effect/sparks

/datum/effect_system/spark_spread/quantum
	effect_type = /obj/effect/particle_effect/sparks/quantum


//electricity

/obj/effect/particle_effect/sparks/electricity
	name = "lightning"
	icon_state = "electricity"

/obj/effect/particle_effect/sparks/quantum
	name = "quantum sparks"
	icon_state = "quantum_sparks"

/datum/effect_system/lightning_spread
	effect_type = /obj/effect/particle_effect/sparks/electricity
