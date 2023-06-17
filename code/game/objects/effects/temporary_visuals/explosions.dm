/particles/explosion_smoke
	icon = 'icons/effects/96x96.dmi'
	icon_state = "smoker"
	width = 1000
	height = 1000
	count = 75
	spawning = 75
	lifespan = 1 SECONDS
	fade = 35
	color = generator(GEN_NUM, 0, 1)
	velocity = generator(GEN_CIRCLE, 17, 17)
	drift = generator(GEN_CIRCLE, 0, 1, NORMAL_RAND)
	spin = generator(GEN_NUM, -20, 20)
	friction = generator(GEN_NUM, 0.1, 0.5)
	gravity = list(1, 2)
	scale = 0.25
	grow = 0.15

/particles/smoke_wave
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	width = 750
	height = 750
	count = 50
	spawning = 50
	lifespan = 15
	fade = 25
	color = COLOR_BROWN
	velocity = generator(GEN_CIRCLE, 15, 15)
	spin = generator(GEN_NUM, -20, 20)
	scale = generator(GEN_VECTOR, list(1, 1), list(2, 2))
	grow = 0.1

/particles/debris_falling
	icon = 'icons/effects/particles/generic_particles.dmi'
	icon_state = "watersplash"
	width = 500
	height = 500
	count = 15
	spawning = 5
	lifespan = 10
	fade = 5
	position = generator(GEN_SPHERE, 165, 165)
	color = COLOR_BROWN
	velocity = list(0, 8)
	grow = generator(GEN_VECTOR, list(0, 0.25), list(0, 0.25))
	gravity = list(0, -2)

/obj/effect/temp_visual/explosion
	name = "boom"
	icon = 'icons/effects/explosion.dmi'
	icon_state = "explosion"
	light_system = STATIC_LIGHT
	duration = 20
	var/overlay_pixel_x = -16
	var/overlay_pixel_y = -16
	///smoke wave particle holder
	var/obj/effect/abstract/particle_holder/smoke_wave
	///explosion smoke particle holder
	var/obj/effect/abstract/particle_holder/explosion_smoke
	///falling debris particle holder
	var/obj/effect/abstract/particle_holder/falling_debris

/obj/effect/temp_visual/explosion/Initialize(mapload, radius, color)
	. = ..()
	set_light(radius, radius, color)
	var/image/I = image(icon, src, icon_state, 10, overlay_pixel_x, overlay_pixel_y)
	var/matrix/rotate = matrix()
	rotate.Turn(rand(0, 359))
	I.transform = rotate
	overlays += I //we use an overlay so the explosion and light source are both in the correct location
	icon_state = null
	smoke_wave = new(src, /particles/smoke_wave)
	explosion_smoke = new(src, /particles/explosion_smoke)
	explosion_smoke.layer = layer + 0.1
	falling_debris = new(src, /particles/debris_falling)
	addtimer(VARSET_CALLBACK(smoke_wave.particles, count, 0), 5)
	QDEL_IN(smoke_wave, 15)
	addtimer(VARSET_CALLBACK(explosion_smoke.particles, count, 0), 5)
	QDEL_IN(explosion_smoke, 1 SECONDS)
	addtimer(VARSET_CALLBACK(falling_debris.particles, count, 0), 10)
	QDEL_IN(falling_debris, 2 SECONDS)

/obj/effect/temp_visual/explosion/medium
	name = "explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "explosion"
	duration = 20
	overlay_pixel_x = -32
	overlay_pixel_y = -32
