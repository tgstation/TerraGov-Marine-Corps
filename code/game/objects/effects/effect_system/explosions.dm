

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
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(2, 1, location)
			s.start()

			for(var/mob/M in viewers(5, location))
				M << "\red The solution violently explodes."
			for(var/mob/M in viewers(1, location))
				if (prob (50 * amount))
					M << "\red The explosion knocks you down."
					M.KnockDown(rand(1,5))
			return
		else
			var/light = -1
			var/flash = -1

			light = max(-1, amount/8)
			if (flash && flashing_factor) flash = light + 1

			for(var/mob/M in viewers(8, location))
				M << "\red The solution violently explodes."

			explosion(location, -1, -1, light, flash)
			if(light > 0) r_TRU

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
	opacity = 1
	anchored = 1
	mouse_opacity = 0

/obj/effect/particle_effect/expl_particles/New()
	..()
	spawn(15)
		cdel(src)

/datum/effect_system/expl_particles
	number = 10

/datum/effect_system/expl_particles/set_up(n = 10, c = 0, turf/loca)
	number = n
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect_system/expl_particles/start()
	var/i = 0
	for(i=0, i<src.number, i++)
		spawn(0)
			var/obj/effect/particle_effect/expl_particles/expl = new /obj/effect/particle_effect/expl_particles(src.location)
			var/direct = pick(alldirs)
			for(i=0, i<pick(1;25,2;50,3,4;200), i++)
				sleep(1)
				step(expl,direct)



//EXPLOSION EFFECT

/obj/effect/particle_effect/explosion
	name = "explosive particles"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = 1
	anchored = 1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32

/obj/effect/particle_effect/explosion/New()
	..()
	spawn(10)
		cdel(src)



//explosion system

/datum/effect_system/explosion
	number = 1

/datum/effect_system/explosion/set_up(n = 1, c = 0, turf/loca)
	if(istype(loca, /turf/)) location = loca
	else location = get_turf(loca)

/datum/effect_system/explosion/start()
	new/obj/effect/particle_effect/explosion( location )
	var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
	P.set_up(10, 0, location)
	P.start()
	spawn(5)
		var/datum/effect_system/smoke_spread/S = new/datum/effect_system/smoke_spread()
		S.set_up(3,0,location,null, 2)
		S.start()
