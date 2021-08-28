
///***GRENADES***///
/obj/item/explosive/grenade/frag
	name = "\improper M40 HEDP grenade"
	desc = "A small, but deceptively strong high explosive grenade that has been phasing out the M15 fragmentation grenades. Capable of being loaded in the any grenade launcher, or thrown by hand."
	icon_state = "grenade"
	det_time = 40
	item_state = "grenade"
	underslug_launchable = TRUE
	icon_state_mini = "grenade_red"

/obj/item/explosive/grenade/frag/prime()
	explosion(loc, light_impact_range = 4, small_animation = TRUE)
	qdel(src)

/obj/item/explosive/grenade/frag/flamer_fire_act()
	activate()



/obj/item/explosive/grenade/frag/training
	name = "M07 training grenade"
	desc = "A harmless reusable version of the M40 HEDP, used for training. Capable of being loaded in the any grenade launcher, or thrown by hand."
	icon_state = "training_grenade"
	item_state = "grenade"
	hud_state = "grenade_dummy"
	dangerous = FALSE
	icon_state_mini = "grenade_white"

/obj/item/explosive/grenade/frag/training/prime()
	playsound(loc, 'sound/items/detector.ogg', 80, 0, 7)
	active = FALSE //so we can reuse it
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
	arm_sound = 'sound/weapons/armbombpin.ogg'
	hud_state = "grenade_frag"
	underslug_launchable = FALSE
	icon_state_mini = "grenade_red_white"

/obj/item/explosive/grenade/frag/PMC/prime()
	explosion(loc, light_impact_range = 5, small_animation = TRUE)
	qdel(src)


/obj/item/explosive/grenade/frag/m15
	name = "\improper M15 fragmentation grenade"
	desc = "An outdated TGMC fragmentation grenade. With decades of service in the TGMC, the old M15 Fragmentation Grenade is slowly being replaced with the slightly safer M40 HEDP. It is set to detonate in 4 seconds."
	icon_state = "grenade_ex"
	item_state = "grenade_ex"
	arm_sound = 'sound/weapons/armbombpin.ogg'
	hud_state = "grenade_frag"
	underslug_launchable = FALSE
	icon_state_mini = "grenade_yellow"

/obj/item/explosive/grenade/frag/m15/prime()
	explosion(loc, light_impact_range = 5, small_animation = TRUE)
	qdel(src)


/obj/item/explosive/grenade/frag/stick
	name = "\improper Webley Mk15 stick grenade"
	desc = "A fragmentation grenade produced in the colonies, most commonly using old designs and schematics. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_stick"
	item_state = "grenade_stick"
	arm_sound = 'sound/weapons/armbombpin.ogg'
	hud_state = "greande_frag"
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 15
	throw_speed = 2
	throw_range = 7
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/stick/prime()
	explosion(loc, light_impact_range = 4, small_animation = TRUE)
	qdel(src)


/obj/item/explosive/grenade/frag/upp
	name = "\improper Type 5 shrapnel grenade"
	desc = "A fragmentation grenade found within the ranks of the USL. Designed to explode into shrapnel and rupture the bodies of opponents. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_upp"
	item_state = "grenade_upp"
	arm_sound = 'sound/weapons/armbombpin.ogg'
	hud_state = "greande_frag"
	throw_speed = 2
	throw_range = 6
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/upp/prime()
	explosion(loc, light_impact_range = 4, small_animation = TRUE)
	qdel(src)


/obj/item/explosive/grenade/frag/sectoid
	name = "alien bomb"
	desc = "An odd, squishy, organ-like grenade. It will explode 3 seconds after squeezing it."
	icon_state = "alien_grenade"
	item_state = "grenade_ex"
	hud_state = "grenade_frag"
	underslug_launchable = FALSE

/obj/item/explosive/grenade/frag/sectoid/prime()
	explosion(loc, light_impact_range = 6)// no animation cus space tech and so
	qdel(src)


/obj/item/explosive/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon_state = "grenade_fire"
	det_time = 40
	item_state = "grenade_fire"
	hud_state = "grenade_fire"
	underslug_launchable = TRUE
	icon_state_mini = "grenade_orange"

/obj/item/explosive/grenade/incendiary/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, 'sound/effects/incendiary_explode.ogg', 35, TRUE, 4)
	qdel(src)


/proc/flame_radius(radius = 1, turf/epicenter, burn_intensity = 25, burn_duration = 25, burn_damage = 25, fire_stacks = 15, int_var = 0.5, dur_var = 0.5, colour = "red") //~Art updated fire.
	if(!isturf(epicenter))
		CRASH("flame_radius used without a valid turf parameter")
	radius = clamp(radius, 1, 50) //Sanitize inputs
	int_var = clamp(int_var, 0.1,0.5)
	dur_var = clamp(int_var, 0.1,0.5)
	fire_stacks = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )
	burn_damage = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )

	for(var/t in filled_turfs(epicenter, radius, "circle"))
		var/turf/turf_to_flame = t
		turf_to_flame.ignite(rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)) + rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)), rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)) + rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)), colour, burn_damage, fire_stacks)


/obj/item/explosive/grenade/incendiary/molotov
	name = "\improper improvised firebomb"
	desc = "A potent, improvised firebomb, coupled with a pinch of gunpowder. Cheap, very effective, and deadly in confined spaces. Commonly found in the hands of rebels and terrorists. It can be difficult to predict how many seconds you have before it goes off, so be careful. Chances are, it might explode in your face."
	icon_state = "molotov"
	item_state = "molotov"
	arm_sound = 'sound/items/welder2.ogg'
	underslug_launchable = FALSE

/obj/item/explosive/grenade/incendiary/molotov/Initialize()
	. = ..()
	det_time = rand(10,40)//Adds some risk to using this thing.

/obj/item/explosive/grenade/incendiary/molotov/prime()
	playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 35, TRUE, 4)
	flame_radius(2, get_turf(src))
	playsound(loc, 'sound/effects/incendiary_explode.ogg', 30, TRUE, 4)
	qdel(src)


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
	icon_state_mini = "grenade_blue"

/obj/item/explosive/grenade/smokebomb/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/smokebomb/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/explosive/grenade/smokebomb/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(7, loc, 11)
	smoke.start()
	qdel(src)


/obj/item/explosive/grenade/cloakbomb
	name = "\improper M40-2 SCDP smoke grenade"
	desc = "A sophisticated version of the M40 HSDP with a slighty improved smoke screen payload. It's set to detonate in 2 seconds."
	icon_state = "grenade_cloak"
	det_time = 20
	item_state = "grenade_cloak"
	hud_state = "grenade_hide"
	dangerous = FALSE
	underslug_launchable = TRUE
	var/datum/effect_system/smoke_spread/tactical/smoke
	icon_state_mini = "grenade_green"

/obj/item/explosive/grenade/cloakbomb/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/cloakbomb/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(7, loc, 11)
	smoke.start()
	qdel(src)

/obj/item/explosive/grenade/drainbomb
	name = "\improper M40-T smoke grenade"
	desc = "The M40-T is a small, but powerful Tanglefoot grenade, designed to remove plasma with minimal side effects. Based off the same platform as the M40 HEDP. It is set to detonate in 6 seconds."
	icon_state = "grenade_pgas"
	det_time = 60
	item_state = "grenade_pgas"
	underslug_launchable = TRUE
	var/datum/effect_system/smoke_spread/plasmaloss/smoke
	icon_state_mini = "grenade_blue"

/obj/item/explosive/grenade/drainbomb/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/drainbomb/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(7, loc, 11)
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
	icon_state_mini = "grenade_cyan"

/obj/item/explosive/grenade/phosphorus/Initialize()
	. = ..()
	smoke = new(src)

/obj/item/explosive/grenade/phosphorus/Destroy()
	QDEL_NULL(smoke)
	return ..()

/obj/item/explosive/grenade/phosphorus/prime()
	playsound(loc, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, loc, 7)
	smoke.start()
	flame_radius(4, get_turf(src))
	flame_radius(1, get_turf(src), burn_intensity = 45, burn_duration = 75, burn_damage = 15, fire_stacks = 75)	//The closer to the middle you are the more it hurts
	qdel(src)

/obj/item/explosive/grenade/phosphorus/upp
	name = "\improper Type 8 WP grenade"
	desc = "A deadly gas grenade found within the ranks of the USL. Designed to spill white phosphorus on the target. It explodes 2 seconds after the pin has been pulled."
	icon_state = "grenade_upp_wp"
	item_state = "grenade_upp_wp"
	arm_sound = 'sound/weapons/armbombpin.ogg'

/obj/item/explosive/grenade/impact
	name = "\improper M40 IMDP grenade"
	desc = "A high explosive contact detonation munition utilizing the standard DP canister chassis. Has a focused blast specialized for door breaching and combating emplacements and light armoured vehicles. WARNING: Handthrowing does not result in sufficient force to trigger impact detonators."
	icon_state = "grenade_impact"
	item_state = "grenade_impact"
	hud_state = "grenade_frag"
	det_time = 40
	dangerous = TRUE
	underslug_launchable = TRUE
	icon_state_mini = "grenade_blue_white"

/obj/item/explosive/grenade/impact/prime()
	explosion(loc, light_impact_range = 3)
	qdel(src)

/obj/item/explosive/grenade/impact/flamer_fire_act()
	explosion(loc, light_impact_range = 3)
	qdel(src)

/obj/item/explosive/grenade/impact/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(launched && active && !istype(hit_atom, /turf/open)) //Only contact det if active, we actually hit something, and we're fired from a grenade launcher.
		explosion(loc, light_impact_range = 1, flash_range = 2)
		qdel(src)


/obj/item/explosive/grenade/flare
	name = "\improper M40 FLDP grenade"
	desc = "A TGMC standard issue flare utilizing the standard DP canister chassis. Capable of being loaded in any grenade launcher, or thrown by hand."
	icon_state = "flare_grenade"
	det_time = 0
	throwforce = 1
	dangerous = FALSE
	underslug_launchable = TRUE
	w_class = WEIGHT_CLASS_SMALL
	hud_state = "grenade_frag"
	light_system = MOVABLE_LIGHT
	light_range = 6
	light_color = LIGHT_COLOR_FLARE
	var/fuel = 0
	var/lower_fuel_limit = 800
	var/upper_fuel_limit = 1000

/obj/item/explosive/grenade/flare/Initialize()
	. = ..()
	fuel = rand(lower_fuel_limit, upper_fuel_limit) // Sorry for changing this so much but I keep under-estimating how long X number of ticks last in seconds.

/obj/item/explosive/grenade/flare/flamer_fire_act()
	if(!fuel) //it's out of fuel, an empty shell.
		return
	if(!active)
		turn_on()

/obj/item/explosive/grenade/flare/Destroy()
	turn_off()
	return ..()

/obj/item/explosive/grenade/flare/process()
	fuel = max(fuel - 1, 0)
	if(!fuel || !active)
		turn_off()

/obj/item/explosive/grenade/flare/proc/turn_off()
	active = FALSE
	fuel = 0
	heat = 0
	item_fire_stacks = 0
	force = initial(force)
	damtype = initial(damtype)
	update_brightness()
	icon_state = "[initial(icon_state)]_empty" // override icon state set by update_brightness
	STOP_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/proc/turn_on()
	active = TRUE
	force = 5
	throwforce = 10
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)
	item_fire_stacks = 5
	heat = 1500
	damtype = BURN
	update_brightness()
	playsound(src,'sound/items/flare.ogg', 15, 1)
	START_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/attack_self(mob/user)

	// Usual checks
	if(!fuel)
		to_chat(user, span_notice("It's out of fuel."))
		return
	if(active)
		return

	// All good, turn it on.
	user.visible_message(span_notice("[user] activates the flare."), span_notice("You depress the ignition button, activating it!"))
	turn_on(user)
	if(iscarbon(user))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/item/explosive/grenade/flare/activate(mob/user)
	if(!active)
		turn_on(user)

/obj/item/explosive/grenade/flare/on/Initialize()
	. = ..()
	active = TRUE
	heat = 1500
	update_brightness()
	force = 5
	throwforce = 10
	ENABLE_BITFIELD(resistance_flags, ON_FIRE)
	item_fire_stacks = 5
	damtype = BURN
	START_PROCESSING(SSobj, src)

/obj/item/explosive/grenade/flare/proc/update_brightness()
	if(active && fuel > 0)
		icon_state = "[initial(icon_state)]_active"
		set_light_on(TRUE)
	else
		icon_state = initial(icon_state)
		set_light_on(FALSE)

/obj/item/explosive/grenade/flare/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(!active)
		return

	if(isliving(hit_atom))
		var/mob/living/L = hit_atom

		var/target_zone = check_zone(L.zone_selected)
		if(!target_zone || rand(40))
			target_zone = "chest"
		if(launched && CHECK_BITFIELD(resistance_flags, ON_FIRE))
			var/armor_block = L.run_armor_check(target_zone, "fire")
			L.apply_damage(rand(throwforce*0.75,throwforce*1.25), BURN, target_zone, armor_block, updating_health = TRUE) //Do more damage if launched from a proper launcher and active

	// Flares instantly burn out nodes when thrown at them.
	var/obj/effect/alien/weeds/node/N = locate() in loc
	if(N)
		qdel(N)
		turn_off()

/obj/item/explosive/grenade/flare/cas
	name = "\improper M50 CFDP signal flare"
	desc = "A TGMC signal flare utilizing the standard DP canister chassis. Capable of being loaded in any grenade launcher, or thrown by hand. When activated, provides a target for CAS pilots."
	icon_state = "cas_flare_grenade"
	hud_state = "grenade_frag"
	lower_fuel_limit = 25
	upper_fuel_limit = 30
	light_power = 3
	light_color = LIGHT_COLOR_GREEN
	var/datum/squad/user_squad
	var/obj/effect/overlay/temp/laser_target/cas/target

/obj/item/explosive/grenade/flare/cas/turn_on(mob/living/carbon/human/user)
	. = ..()
	if(user.assigned_squad)
		user_squad = user.assigned_squad
	var/turf/TU = get_turf(src)
	if(!istype(TU))
		return
	if(is_ground_level(TU.z))
		target = new(src, name, user_squad)//da lazer is stored in the grenade

/obj/item/explosive/grenade/flare/cas/process()
	. = ..()
	var/turf/TU = get_turf(src)
	if(is_ground_level(TU.z))
		if(!target && active)
			target = new(src, name, user_squad)

/obj/item/explosive/grenade/flare/cas/turn_off()
	QDEL_NULL(target)
	return ..()
