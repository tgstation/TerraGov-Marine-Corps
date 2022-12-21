/obj/effect/particle_effect/expl_particles
	name = "fire"
	icon_state = "explosion_particle"
	opacity = FALSE
	anchored = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 2
	light_color = LIGHT_COLOR_LAVA
	light_on = TRUE

/obj/effect/particle_effect/expl_particles/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/particle_effect/expl_particles/LateInitialize()
	INVOKE_ASYNC(src, .proc/expl_particles_spread)

/obj/effect/particle_effect/proc/expl_particles_spread()
	var/direct = pick(GLOB.alldirs)
	var/steps_amt = pick(1;25,2;50,3,4;200)
	for(var/j in 1 to steps_amt)
		step(src, direct)
		sleep(0.1 SECONDS)
	qdel(src)

/datum/effect_system/expl_particles
	number = 10

/datum/effect_system/expl_particles/start()
	for(var/i in 1 to number)
		new /obj/effect/particle_effect/expl_particles(location)

/obj/effect/explosion
	name = "fire"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	opacity = TRUE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	pixel_x = -32
	pixel_y = -32
	light_system = STATIC_LIGHT

/obj/effect/explosion/Initialize(mapload, radius, color)
	. = ..()
	set_light(radius, radius, color)
	QDEL_IN(src, 12.8)

/datum/effect_system/explosion

/datum/effect_system/explosion/set_up(loca)
	if(isturf(loca))
		location = loca
	else
		location = get_turf(loca)

/datum/effect_system/explosion/start(radius, color)
	new/obj/effect/explosion(location, radius, color)
	var/datum/effect_system/expl_particles/P = new/datum/effect_system/expl_particles()
	P.set_up(10, 0, location)
	P.start()

/datum/effect_system/explosion/smoke

/datum/effect_system/explosion/smoke/proc/create_smoke()
	var/datum/effect_system/smoke_spread/S = new
	S.set_up(2, location)
	S.start()
/datum/effect_system/explosion/smoke/start()
	. = ..()
	addtimer(CALLBACK(src, .proc/create_smoke), 0.5 SECONDS)
