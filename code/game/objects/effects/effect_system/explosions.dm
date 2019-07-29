

//reagents explosion system

/datum/effect_system/reagents_explosion
	var/amount 						// TNT equivalent
	var/flashing = 0			// does explosion creates flash effect?
	var/flashing_factor = 0		// factor of how powerful the flash effect relatively to the explosion

	set_up (amt, loc, flash = 0, flash_fact = 0)
		amount = amt
		if(istype(loc, /turf/))
			location = loc
		else
			location = get_turf(loc)

		flashing = flash
		flashing_factor = flash_fact

		return

	start()
		if (amount <= 2)
			new /datum/effect_system/spark_spread(null, location, 2, 1, TRUE)

			for(var/mob/M in viewers(5, location))
				to_chat(M, "<span class='warning'>The solution violently explodes.</span>")
			for(var/mob/living/M in viewers(1, location))
				if (prob (50 * amount))
					to_chat(M, "<span class='warning'>The explosion knocks you down.</span>")
					M.knock_down(rand(1,5))
			return
		else
			var/light = -1
			var/flash = -1

			light = max(-1, amount/8)
			if (flash && flashing_factor) flash = light + 1

			for(var/mob/M in viewers(8, location))
				to_chat(M, "<span class='warning'>The solution violently explodes.</span>")

			explosion(location, -1, -1, light, flash)
			if(light > 0) return TRUE

	proc/holder_damage(var/atom/holder)
		if(holder)
			var/dmglevel = 4

			if (round(amount/8) > 0)
				dmglevel = 1
			else if (round(amount/4) > 0)
				dmglevel = 2
			else if (round(amount/2) > 0)
				dmglevel = 3

			if(dmglevel<4) holder.ex_act(dmglevel)






// EXPLOSION PARTICLES EFFECT


/obj/effect/particle_effect/expl_particles
	name = "explosive particles"
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion_particle"
	opacity = TRUE
	anchored = TRUE
	mouse_opacity = 0

/obj/effect/particle_effect/expl_particles/Initialize()
	. = ..()
	QDEL_IN(src, 1.5 SECONDS)

/datum/effect_system/expl_particles
	number = 10

/datum/effect_system/expl_particles/set_up(n = 10, c = 0, turf/loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect_system/expl_particles/spawn_particle()
	var/obj/effect/particle_effect/expl_particles/expl = new /obj/effect/particle_effect/expl_particles(location)
	var/direct = pick(GLOB.alldirs)
	for(var/i in 1 to pick(1;25,2;50,3,4;200))
		sleep(1) // sleep is fine here this is only invoked ASYNC
		step(expl,direct)

//EXPLOSION EFFECT

/obj/effect/particle_effect/explosion
	name = "explosive particles"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = TRUE
	anchored = TRUE
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/explosion/Initialize()
	. = ..()
	QDEL_IN(src, 1 SECONDS)



//explosion system

/datum/effect_system/explosion
	number = 1

/datum/effect_system/explosion/set_up(n = 1, c = 0, turf/loca)
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect_system/explosion/start()
	new /obj/effect/particle_effect/explosion( location )
	new /datum/effect_system/expl_particles(null, location, 10, 0, TRUE)

	addtimer(CALLBACK_NEW(/datum/effect_system/smoke_spread, list(null, location, rand(0,3), rand(1,3), TRUE)), 0.5 SECONDS)
