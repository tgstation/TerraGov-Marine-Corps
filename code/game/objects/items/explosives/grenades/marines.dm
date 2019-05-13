
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
	radius = CLAMP(radius, 1, 50) //Sanitize inputs
	int_var = CLAMP(int_var, 0.1,0.5)
	dur_var = CLAMP(int_var, 0.1,0.5)
	fire_stacks = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )
	burn_damage = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )

	for(var/turf/IT in filled_circle_turfs(T,radius))
		IT.ignite(rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)) + rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)), rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)) + rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)), colour, burn_damage, fire_stacks)


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
	smoke = new(src)

/obj/item/explosive/grenade/smokebomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(3, usr.loc, 7)
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
	smoke = new(src)

/obj/item/explosive/grenade/cloakbomb/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(3, usr.loc, 8)
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

/obj/item/explosive/grenade/phosphorus/New()
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/phosphorus/prime()
	playsound(src.loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(3, usr.loc)
	smoke.start()
	qdel(src)


/obj/item/explosive/grenade/phosphorus/upp
	name = "\improper Type 8 WP grenade"
	desc = "A deadly gas grenade found within the ranks of the UPP. Designed to spill white phosporus on the target. It explodes 2 seconds after the pin has been pulled."
	icon_state = "grenade_upp_wp"
	item_state = "grenade_upp_wp"

/obj/item/explosive/grenade/impact
	name = "\improper M40 IMDP grenade"
	desc = "A high explosive contact detonation munition utilizing the standard DP canister chassis. Has a focused blast specialized for door breaching and combating emplacements and light armoured vehicles. WARNING: Handthrowing does not result in sufficient force to trigger impact detonators."
	icon_state = "grenade_impact"
	item_state = "grenade_impact"
	hud_state = "grenade_frag"
	det_time = 40
	dangerous = TRUE
	underslug_launchable = TRUE

/obj/item/explosive/grenade/impact/prime()
	spawn(0)
		explosion(loc, -1, -1, 1, 2)
		qdel(src)
	return

/obj/item/explosive/grenade/impact/flamer_fire_act()
	var/turf/T = loc
	qdel(src)
	explosion(T, -1, -1, 1, 2)

/obj/item/explosive/grenade/impact/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(launched && active && !istype(hit_atom, /turf/open)) //Only contact det if active, we actually hit something, and we're fired from a grenade launcher.
		explosion(loc, -1, -1, 1, 2)
		qdel(src)


/obj/item/explosive/grenade/flare
	name = "\improper M40 FLDP grenade"
	desc = "A TGMC standard issue flare utilizing the standard DP canister chassis. Capable of being loaded in the M92 Launcher, or thrown by hand."
	icon_state = "flare_grenade"
	det_time = 0
	throwforce = 1
	dangerous = FALSE
	underslug_launchable = TRUE
	w_class = 2
	hud_state = "grenade_frag"
	var/fuel = 0

/obj/item/explosive/grenade/flare/New()
	fuel = rand(800, 1000) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.
	return ..()

/obj/item/explosive/grenade/flare/flamer_fire_act()
	if(!active)
		turn_on()

/obj/item/explosive/grenade/flare/Destroy()
	turn_off()
	. = ..()

/obj/item/explosive/grenade/flare/process()
	fuel = max(fuel - 1, 0)
	if(!fuel || !active)
		turn_off()
		if(!fuel)
			icon_state = "[initial(icon_state)]-empty"
		STOP_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/proc/turn_off()
	fuel = 0
	icon_state = "[initial(icon_state)]-empty"
	heat_source = 0
	force = initial(force)
	damtype = initial(damtype)
	if(ismob(loc))
		update_brightness(loc)
	else
		update_brightness(null)
	//message_admins("TOGGLE FLARE LIGHT DEBUG 1: fuel: [fuel] loc: [loc]")
	STOP_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/proc/turn_on()
	active = TRUE
	force = 5
	throwforce = 10
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)
	item_fire_stacks = 5
	heat_source = 1500
	damtype = "fire"
	update_brightness()
	playsound(src,'sound/items/flare.ogg', 15, 1)
	START_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, "<span class='notice'>It's out of fuel.</span>")
		return
	if(active)
		return

	// All good, turn it on.
	user.visible_message("<span class='notice'>[user] activates the flare.</span>", "<span class='notice'>You depress the ignition button, activating it!</span>")
	turn_on(user)

/obj/item/explosive/grenade/flare/activate(mob/user)
	if(!active)
		turn_on(user)

/obj/item/explosive/grenade/flare/on/New()

	. = ..()
	active = TRUE
	heat_source = 1500
	update_brightness()
	force = 5
	throwforce = 10
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)
	item_fire_stacks = 5
	damtype = "fire"
	START_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/proc/update_brightness(mob/user)
	if(!user && ismob(loc))
		user = loc
	if(active && fuel > 0)
		icon_state = "[initial(icon_state)]_active"
		if(loc && loc == user)
			user.SetLuminosity(FLARE_BRIGHTNESS)
			//message_admins("FLARE UPDATE BRIGHTNESS DEBUG: user: [user] light_sources length: [length(user.light_sources)]")
			SetLuminosity(0)
		else if(isturf(loc))
			SetLuminosity(FLARE_BRIGHTNESS)
	else
		icon_state = initial(icon_state)
		if(loc && loc == user)
			user.SetLuminosity(-FLARE_BRIGHTNESS)
		else if(isturf(loc))
			SetLuminosity(0)

/obj/item/explosive/grenade/flare/pickup(mob/user)
	if(active && loc != user)
		user.SetLuminosity(FLARE_BRIGHTNESS)
		SetLuminosity(0)
	return ..()

/obj/item/explosive/grenade/flare/dropped(mob/user)
	if(active && loc != user)
		user.SetLuminosity(-FLARE_BRIGHTNESS)
		SetLuminosity(FLARE_BRIGHTNESS)
	return ..()

/obj/item/explosive/grenade/flare/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(isliving(hit_atom) && active)
		var/mob/living/L = hit_atom

		var/target_zone = check_zone(L.zone_selected)
		if(!target_zone || rand(40))
			target_zone = "chest"
		if(launched && CHECK_BITFIELD(resistance_flags, ON_FIRE))
			var/armor_block = L.run_armor_check(target_zone, "fire")
			L.apply_damage(rand(throwforce*0.75,throwforce*1.25), BURN, target_zone, armor_block) //Do more damage if launched from a proper launcher and active
