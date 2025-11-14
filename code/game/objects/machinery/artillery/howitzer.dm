// The big boy, the Howtizer.

/obj/item/mortar_kit/howitzer
	name = "\improper TA-100Y howitzer"
	desc = "A manual, crew-operated and towable howitzer, will rain down 150mm laserguided and accurate shells on any of your foes."
	icon = 'icons/obj/machines/deployable/howitzer.dmi'
	icon_state = "howitzer"
	max_integrity = 400
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE
	w_class = WEIGHT_CLASS_HUGE
	deployable_item = /obj/machinery/deployable/mortar/howitzer

/obj/machinery/deployable/mortar/howitzer
	pixel_x = -16
	anchored = FALSE // You can move this.
	offset_per_turfs = 25
	fire_sound = 'sound/weapons/guns/fire/howitzer_fire.ogg'
	reload_sound = 'sound/weapons/guns/interact/tat36_reload.ogg'
	fall_sound = 'sound/weapons/guns/misc/howitzer_whistle.ogg'
	minimum_range = 20
	allowed_shells = list(
		/obj/item/mortal_shell/howitzer,
		/obj/item/mortal_shell/howitzer/white_phos,
		/obj/item/mortal_shell/howitzer/he,
		/obj/item/mortal_shell/howitzer/incendiary,
		/obj/item/mortal_shell/howitzer/plasmaloss,
		/obj/item/mortal_shell/flare,
	)
	tally_type = TALLY_HOWITZER
	cool_off_time = 10 SECONDS
	reload_time = 1 SECONDS
	max_spread = 8

/obj/machinery/deployable/mortar/howitzer/AltRightClick(mob/living/user)
	if(!Adjacent(user) || user.lying_angle || user.incapacitated() || !ishuman(user))
		return

	if(!anchored)
		anchored = TRUE
		to_chat(user, span_warning("You have anchored the gun to the ground. It may not be moved."))
	else
		anchored = FALSE
		to_chat(user, span_warning("You unanchored the gun from the ground. It may be moved."))


/obj/machinery/deployable/mortar/howitzer/perform_firing_visuals()
	var/particle_type = /particles/howitzer_dust
	switch(dir)
		if(NORTH)
			particle_type = /particles/howitzer_dust/north
		if(SOUTH)
			particle_type = /particles/howitzer_dust/south
		if(EAST)
			particle_type = /particles/howitzer_dust/east
	var/obj/effect/abstract/particle_holder/dust = new(src, particle_type)
	addtimer(VARSET_CALLBACK(dust.particles, count, 0), 5)
	QDEL_IN(dust, 3 SECONDS)

/particles/howitzer_dust
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 150
	height = 200
	count = 40
	spawning = 30
	lifespan = 1 SECONDS
	fade = 1 SECONDS
	fadein = 4
	position = generator(GEN_VECTOR, list(-7, -16), list(-7, -10), NORMAL_RAND)
	velocity = list(25, -1)
	color = "#fbebd3" //coloring in a sorta dark dusty look
	drift = generator(GEN_SPHERE, 0, 1.5, NORMAL_RAND)
	friction = 0.3
	gravity = list(0, 0.55)
	grow = 0.05

/particles/howitzer_dust/east
	velocity = list(-25, -1)
	position = generator(GEN_VECTOR, list(7, -16), list(7, -10), NORMAL_RAND)

/particles/howitzer_dust/north
	velocity =  generator(GEN_VECTOR, list(10, -20), list(-10, -20), SQUARE_RAND)
	position = list(16, -16)

/particles/howitzer_dust/south
	velocity =  generator(GEN_VECTOR, list(10, 20), list(-10, 20), SQUARE_RAND)
	position = list(16, 16)
