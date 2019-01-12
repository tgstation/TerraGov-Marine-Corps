
///***GRENADES***///
/obj/item/explosive/grenade/frag
	name = "\improper M40 HEDP grenade"
	desc = "A small, but deceptively strong fragmentation grenade that has been phasing out the M15 Fragmentation Grenades. Capable of being loaded in the M92 Launcher, or thrown by hand."
	icon_state = "grenade"
	det_time = 40
	item_state = "grenade"
	underslug_launchable = TRUE

/obj/item/explosive/grenade/frag/prime()
	spawn(0)
		explosion(loc, -1, -1, 3)
		qdel(src)
	return

/obj/item/explosive/grenade/frag/flamer_fire_act()
	var/turf/T = loc
	qdel(src)
	explosion(T, -1, -1, 3)



/obj/item/explosive/grenade/frag/training
	name = "M07 training grenade"
	desc = "A harmless reusable version of the M40 HEDP, used for training. Capable of being loaded in the M92 Launcher, or thrown by hand."
	icon_state = "training_grenade"
	item_state = "grenade"
	hud_state = "grenade_dummy"
	dangerous = FALSE

/obj/item/explosive/grenade/frag/training/prime()
	spawn(0)
		playsound(loc, 'sound/items/detector.ogg', 80, 0, 7)
		active = 0 //so we can reuse it
		overlays.Cut()
		icon_state = initial(icon_state)
		det_time = initial(det_time) //these can be modified when fired by UGL
		throw_range = initial(throw_range)


/obj/item/explosive/grenade/frag/training/flamer_fire_act()
	return



/obj/item/explosive/grenade/frag/PMC
	desc = "A fragmentation grenade produced for private security firms. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_pmc"
	item_state = "grenade_ex"
	hud_state = "grenade_frag"
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/PMC/prime()
	spawn(0)
		explosion(loc, -1, -1, 4)
		qdel(src)
	return


/obj/item/explosive/grenade/frag/m15
	name = "\improper M15 fragmentation grenade"
	desc = "An outdated TGMC Fragmentation Grenade. With decades of service in the TGMC, the old M15 Fragmentation Grenade is slowly being replaced with the slightly safer M40 HEDP. It is set to detonate in 4 seconds."
	icon_state = "grenade_ex"
	item_state = "grenade_ex"
	hud_state = "grenade_frag"
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/m15/prime()
	spawn(0)
		explosion(loc, -1, -1, 4)
		qdel(src)
	return


/obj/item/explosive/grenade/frag/stick
	name = "\improper Webley Mk15 stick grenade"
	desc = "A fragmentation grenade produced in the colonies, most commonly using old designs and schematics. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_stick"
	item_state = "grenade_stick"
	hud_state = "greande_frag"
	force = 10
	w_class = 2
	throwforce = 15
	throw_speed = 2
	throw_range = 7
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/stick/prime()
	spawn(0)
		explosion(src.loc,-1,-1,3)
		del(src)
	return


/obj/item/explosive/grenade/frag/upp
	name = "\improper Type 5 shrapnel grenade"
	desc = "A fragmentation grenade found within the ranks of the UPP. Designed to explode into shrapnel and rupture the bodies of opponents. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_upp"
	item_state = "grenade_upp"
	hud_state = "greande_frag"
	throw_speed = 2
	throw_range = 6
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/upp/prime()
	spawn(0)
		explosion(src.loc,-1,-1,3)
		del(src)
	return


/obj/item/explosive/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon_state = "grenade_fire"
	det_time = 40
	item_state = "grenade_fire"
	hud_state = "grenade_fire"
	underslug_launchable = TRUE

/obj/item/explosive/grenade/incendiary/prime()
	spawn(0)
		flame_radius(2, get_turf(src))
		playsound(src.loc, 'sound/weapons/gun_flamethrower2.ogg', 35, 1, 4)
		qdel(src)
	return


proc/flame_radius(radius = 1, turf/T, burn_intensity = 25, burn_duration = 25, burn_damage = 25, fire_stacks = 15, int_var = 0.5, dur_var = 0.5, colour = "red") //~Art updated fire.
	if(!T || !isturf(T))
		return
	radius = CLAMP(radius, 1, 7) //Sterilize inputs
	int_var = CLAMP(int_var, 0.1,0.5)
	dur_var = CLAMP(int_var, 0.1,0.5)
	fire_stacks = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )
	burn_damage = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )
	for(var/obj/flamer_fire/F in range(radius,T)) // No stacking flames!
		qdel(F)
	new /obj/flamer_fire(T, rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)) + rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)), rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)) + rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)), colour, radius, burn_damage, fire_stacks) //Gaussian.


/obj/item/explosive/grenade/incendiary/molotov
	name = "\improper improvised firebomb"
	desc = "A potent, improvised firebomb, coupled with a pinch of gunpowder. Cheap, very effective, and deadly in confined spaces. Commonly found in the hands of rebels and terrorists. It can be difficult to predict how many seconds you have before it goes off, so be careful. Chances are, it might explode in your face."
	icon_state = "molotov"
	item_state = "molotov"
	arm_sound = 'sound/items/Welder2.ogg'
	underslug_launchable = FALSE

/obj/item/explosive/grenade/incendiary/molotov/New()
	det_time = rand(10,40)//Adds some risk to using this thing.
	return ..()

/obj/item/explosive/grenade/incendiary/molotov/prime()
	spawn(0)
		playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 35, 1, 4)
		flame_radius(2, get_turf(src))
		playsound(src.loc, 'sound/weapons/gun_flamethrower2.ogg', 30, 1, 4)
		qdel(src)
	return


/obj/item/explosive/grenade/smokebomb
	name = "\improper M40 HSDP smoke grenade"
	desc = "The M40 HSDP is a small, but powerful smoke grenade. Based off the same platform as the M40 HEDP. It is set to detonate in 2 seconds."
	icon_state = "grenade_smoke"
	det_time = 20
	item_state = "grenade_smoke"
	hud_state = "grenade_smoke"
	underslug_launchable = TRUE
	dangerous = FALSE
	var/datum/effect_system/smoke_spread/bad/smoke

/obj/item/explosive/grenade/smokebomb/New()
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/bad
	smoke.attach(src)

/obj/item/explosive/grenade/smokebomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(3, 0, usr.loc, null, 6)
	smoke.start()
	qdel(src)


/obj/item/explosive/grenade/cloakbomb
	name = "\improper M40-2 SCDP smoke grenade"
	desc = "A sophisticated version of the M40 HSDP with an improved smoke screen payload, currently being field-tested in the TGMC. It's set to detonate in 2 seconds."
	icon_state = "grenade_cloak"
	det_time = 20
	item_state = "grenade_cloak"
	hud_state = "grenade_hide"
	dangerous = FALSE
	underslug_launchable = TRUE
	var/datum/effect_system/smoke_spread/tactical/smoke

/obj/item/explosive/grenade/cloakbomb/New()
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/tactical
	smoke.attach(src)

/obj/item/explosive/grenade/cloakbomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(3, 0, usr.loc, null, 7)
	smoke.start()
	qdel(src)


/obj/item/explosive/grenade/phosphorus
	name = "\improper M40 HPDP grenade"
	desc = "The M40 HPDP is a small, but powerful phosphorus grenade. It is set to detonate in 2 seconds."
	icon_state = "grenade_phos"
	det_time = 20
	item_state = "grenade_phos"
	hud_state = "grenade_hide"
	underslug_launchable = TRUE
	var/datum/effect_system/smoke_spread/phosphorus/smoke
	dangerous = 1

/obj/item/explosive/grenade/phosphorus/New()
	. = ..()
	smoke = new /datum/effect_system/smoke_spread/phosphorus
	smoke.attach(src)

/obj/item/explosive/grenade/phosphorus/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(3, 0, usr.loc)
	smoke.start()
	qdel(src)


/obj/item/explosive/grenade/phosphorus/upp
	name = "\improper Type 8 WP grenade"
	desc = "A deadly gas grenade found within the ranks of the UPP. Designed to spill white phosporus on the target. It explodes 2 seconds after the pin has been pulled."
	icon_state = "grenade_upp_wp"
	item_state = "grenade_upp_wp"