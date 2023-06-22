/obj/item/explosive/grenade/training
	name = "M07 training grenade"
	desc = "A harmless reusable version of the M40 HEDP, used for training. Capable of being loaded in the any grenade launcher, or thrown by hand."
	icon_state = "training_grenade"
	item_state = "training_grenade"
	hud_state = "grenade_dummy"
	dangerous = FALSE
	icon_state_mini = "grenade_white"

/obj/item/explosive/grenade/training/prime()
	playsound(loc, 'sound/items/detector.ogg', 80, 0, 7)
	active = FALSE //so we can reuse it
	overlays.Cut()
	icon_state = initial(icon_state)
	det_time = initial(det_time) //these can be modified when fired by UGL
	throw_range = initial(throw_range)


/obj/item/explosive/grenade/training/flamer_fire_act(burnlevel)
	return



/obj/item/explosive/grenade/pmc
	desc = "A fragmentation grenade produced for private security firms. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_pmc"
	item_state = "grenade_pmc"
	hud_state = "grenade_frag"
	icon_state_mini = "grenade_red_white"
	light_impact_range = 5

/obj/item/explosive/grenade/m15
	name = "\improper M15 fragmentation grenade"
	desc = "An outdated TGMC fragmentation grenade. With decades of service in the TGMC, the old M15 Fragmentation Grenade is slowly being replaced with the slightly safer M40 HEDP. It is set to detonate in 4 seconds."
	icon_state = "grenade_ex"
	item_state = "grenade_ex"
	hud_state = "grenade_frag"
	icon_state_mini = "grenade_yellow"
	light_impact_range = 5

/obj/item/explosive/grenade/stick
	name = "\improper Webley Mk15 stick grenade"
	desc = "A fragmentation grenade produced in the colonies, most commonly using old designs and schematics. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_stick"
	item_state = "grenade_stick"
	hud_state = "grenade_frag"
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 15

/obj/item/explosive/grenade/upp
	name = "\improper Type 5 shrapnel grenade"
	desc = "A fragmentation grenade found within the ranks of the USL. Designed to explode into shrapnel and rupture the bodies of opponents. It explodes 3 seconds after the pin has been pulled."
	icon_state = "grenade_upp"
	item_state = "grenade_upp"
	hud_state = "greande_frag"
	throw_speed = 2
	throw_range = 6

/obj/item/explosive/grenade/som
	name = "\improper S30 HE grenade"
	desc = "A reliable high explosive grenade utilised by SOM forces. Designed for hand or grenade launcher use."
	icon_state = "grenade_som"
	item_state = "grenade_som"

/obj/item/explosive/grenade/sectoid
	name = "alien bomb"
	desc = "An odd, squishy, organ-like grenade. It will explode 3 seconds after squeezing it."
	icon_state = "alien_grenade"
	item_state = "alien_grenade"
	hud_state = "grenade_frag"
	light_impact_range = 6

/obj/item/explosive/grenade/sticky
	name = "\improper M40 adhesive charge grenade"
	desc = "Designed for use against various fast moving drones, this grenade will adhere to its target before detonating. It's fuse is set to 5 seconds."
	icon_state = "grenade_sticky"
	item_state = "grenade_sticky"
	det_time = 5 SECONDS
	light_impact_range = 3
	///Current atom this grenade is attached to, used to remove the overlay.
	var/atom/stuck_to
	///Current image overlay applied to stuck_to, used to remove the overlay after detonation.
	var/image/saved_overlay

/obj/item/explosive/grenade/sticky/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(!active || stuck_to || isturf(hit_atom))
		return TRUE
	var/image/stuck_overlay = image(icon, hit_atom, initial(icon_state) + "_stuck")
	stuck_overlay.pixel_x = rand(-5, 5)
	stuck_overlay.pixel_y = rand(-7, 7)
	hit_atom.add_overlay(stuck_overlay)
	forceMove(hit_atom)
	saved_overlay = stuck_overlay
	stuck_to = hit_atom
	RegisterSignal(stuck_to, COMSIG_PARENT_QDELETING, PROC_REF(clean_refs))

/obj/item/explosive/grenade/sticky/prime()
	if(stuck_to)
		clean_refs()
	return ..()

/obj/item/explosive/grenade/sticky/launched_det_time()
	det_time -= 1 SECONDS

///Cleans references to prevent hard deletes.
/obj/item/explosive/grenade/sticky/proc/clean_refs()
	stuck_to.cut_overlay(saved_overlay)
	SIGNAL_HANDLER
	UnregisterSignal(stuck_to, COMSIG_PARENT_QDELETING)
	stuck_to = null
	saved_overlay = null

/obj/item/explosive/grenade/sticky/trailblazer
	name = "\improper M45 Trailblazer grenade"
	desc = "Capsule based grenade that sticks to sufficiently hard surfaces, causing a trail of air combustable gel to form. It is set to detonate in 5 seconds."
	icon_state = "grenade_sticky_fire"
	item_state = "grenade_sticky_fire"
	det_time = 5 SECONDS
	light_impact_range = 1

/obj/item/explosive/grenade/sticky/trailblazer/prime()
	flame_radius(0.5, get_turf(src))
	playsound(loc, "incendiary_explosion", 35)
	if(stuck_to)
		clean_refs()
	qdel(src)

/obj/item/explosive/grenade/sticky/trailblazer/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(.)
		return
	RegisterSignal(stuck_to, COMSIG_MOVABLE_MOVED, PROC_REF(make_fire))
	var/turf/T = get_turf(src)
	T.ignite(25, 25)

///causes fire tiles underneath target when stuck_to
/obj/item/explosive/grenade/sticky/trailblazer/proc/make_fire(datum/source, old_loc, movement_dir, forced, old_locs)
	SIGNAL_HANDLER
	var/turf/T = get_turf(src)
	T.ignite(25, 25)

/obj/item/explosive/grenade/sticky/trailblazer/clean_refs()
	stuck_to.cut_overlay(saved_overlay)
	UnregisterSignal(stuck_to, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/item/explosive/grenade/incendiary
	name = "\improper M40 HIDP incendiary grenade"
	desc = "The M40 HIDP is a small, but deceptively strong incendiary grenade. It is set to detonate in 4 seconds."
	icon_state = "grenade_fire"
	item_state = "grenade_fire"
	det_time = 4 SECONDS
	hud_state = "grenade_fire"
	icon_state_mini = "grenade_orange"

/obj/item/explosive/grenade/incendiary/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, "incendiary_explosion", 35)
	qdel(src)


/proc/flame_radius(radius = 1, turf/epicenter, burn_intensity = 25, burn_duration = 25, burn_damage = 25, fire_stacks = 15, int_var = 0.5, dur_var = 0.5, colour = "red") //~Art updated fire.
	if(!isturf(epicenter))
		CRASH("flame_radius used without a valid turf parameter")
	radius = clamp(radius, 1, 50) //Sanitize inputs
	int_var = clamp(int_var, 0.1,0.5)
	dur_var = clamp(int_var, 0.1,0.5)
	fire_stacks = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )
	burn_damage = rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) ) + rand(burn_damage*(0.5-int_var),burn_damage*(0.5+int_var) )

	for(var/t in filled_turfs(epicenter, radius, "circle", air_pass = TRUE))
		var/turf/turf_to_flame = t
		turf_to_flame.ignite(rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)) + rand(burn_intensity*(0.5-int_var), burn_intensity*(0.5+int_var)), rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)) + rand(burn_duration*(0.5-int_var), burn_duration*(0.5-int_var)), colour, burn_damage, fire_stacks)

/obj/item/explosive/grenade/incendiary/som
	name = "\improper S30-I incendiary grenade"
	desc = "A reliable incendiary grenade utilised by SOM forces. Based off the S30 platform shared by most SOM grenades. Designed for hand or grenade launcher use."
	icon_state = "grenade_fire_som"
	item_state = "grenade_fire_som"

/obj/item/explosive/grenade/incendiary/molotov
	name = "improvised firebomb"
	desc = "A potent, improvised firebomb, coupled with a pinch of gunpowder. Cheap, very effective, and deadly in confined spaces. Commonly found in the hands of rebels and terrorists. It can be difficult to predict how many seconds you have before it goes off, so be careful. Chances are, it might explode in your face."
	icon_state = "molotov"
	item_state = "molotov"
	arm_sound = 'sound/items/welder2.ogg'

/obj/item/explosive/grenade/incendiary/molotov/Initialize(mapload)
	. = ..()
	det_time = rand(1 SECONDS, 4 SECONDS)//Adds some risk to using this thing.

/obj/item/explosive/grenade/incendiary/molotov/prime()
	flame_radius(2, get_turf(src))
	playsound(loc, "molotov", 35)
	qdel(src)

/obj/item/explosive/grenade/ags
	name = "\improper AGLS-37 HEDP grenade"
	desc = "A small tiny smart grenade, it is about to blow up in your face, unless you found it inert. Otherwise a pretty normal grenade, other than it is somehow in a primeable state."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/items/grenade.dmi'
	icon_state = "ags_grenade"
	item_state = "ags_grenade"
	det_time = 2 SECONDS
	light_impact_range = 3


/obj/item/explosive/grenade/smokebomb
	name = "\improper M40 HSDP smoke grenade"
	desc = "The M40 HSDP is a small, but powerful smoke grenade. Based off the same platform as the M40 HEDP. It is set to detonate in 2 seconds."
	icon_state = "grenade_smoke"
	item_state = "grenade_smoke"
	det_time = 2 SECONDS
	hud_state = "grenade_smoke"
	dangerous = FALSE
	icon_state_mini = "grenade_blue"
	/// smoke type created when the grenade is primed
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke grenade will encompass
	var/smokeradius = 7
	///The duration of the smoke
	var/smoke_duration = 11

/obj/item/explosive/grenade/smokebomb/prime()
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(loc, 'sound/effects/smoke_bomb.ogg', 25, TRUE)
	smoke.set_up(smokeradius, loc, smoke_duration)
	smoke.start()
	qdel(src)

/obj/item/explosive/grenade/smokebomb/som
	name = "\improper S30-S smoke grenade"
	desc = "The S30-S is a small, but powerful smoke grenade. Based off the S30 platform shared by most SOM grenades. It is set to detonate in 2 seconds."
	icon_state = "grenade_smoke_som"
	item_state = "grenade_smoke_som"

///chemical grenades

//neuro xeno nade
/obj/item/explosive/grenade/smokebomb/neuro
	name = "\improper M40-N Neurotoxin smoke grenade"
	desc = "A smoke grenade containing a concentrated neurotoxin developed by Nanotrasen, supposedly derived from xenomorphs. Banned in some sectors as a chemical weapon, but classed as a less lethal riot control tool by the TGMC."
	icon_state = "grenade_neuro"
	item_state = "grenade_neuro"
	hud_state = "grenade_neuro"
	det_time = 4 SECONDS
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/xeno/neuro/medium
	smokeradius = 6

/obj/item/explosive/grenade/smokebomb/acid
	name = "\improper M40-A Acid smoke grenade"
	desc = "A grenade set to release a cloud of extremely acidic smoke developed by Nanotrasen, supposedly derived from xenomorphs. Has a shiny acid resistant shell. Its use is considered a warcrime under several treaties, none of which Terra Gov is a signatory to."
	icon_state = "grenade_acid"
	item_state = "grenade_acid"
	hud_state = "grenade_acid"
	det_time = 4 SECONDS
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/xeno/acid
	smokeradius = 5

/obj/item/explosive/grenade/smokebomb/satrapine
	name = "satrapine smoke grenade"
	desc = "A smoke grenade containing a nerve agent that can debilitate victims with severe pain, while purging common painkillers. Employed heavily by the SOM."
	icon_state = "grenade_nerve"
	item_state = "grenade_nerve"
	hud_state = "grenade_nerve"
	det_time = 4 SECONDS
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/satrapine
	smokeradius = 6

/obj/item/explosive/grenade/smokebomb/cloak
	name = "\improper M40-2 SCDP smoke grenade"
	desc = "A sophisticated version of the M40 HSDP with a slighty improved smoke screen payload. It's set to detonate in 2 seconds."
	icon_state = "grenade_cloak"
	item_state = "grenade_cloak"
	hud_state = "grenade_hide"
	icon_state_mini = "grenade_green"
	smoketype = /datum/effect_system/smoke_spread/tactical

/obj/item/explosive/grenade/smokebomb/drain
	name = "\improper M40-T smoke grenade"
	desc = "The M40-T is a small, but powerful Tanglefoot grenade, designed to remove plasma with minimal side effects. Based off the same platform as the M40 HEDP. It is set to detonate in 6 seconds."
	icon_state = "grenade_pgas"
	item_state = "grenade_pgas"
	hud_state = "grenade_drain"
	det_time = 6 SECONDS
	icon_state_mini = "grenade_blue"
	dangerous = TRUE
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/obj/item/explosive/grenade/phosphorus
	name = "\improper M40 HPDP grenade"
	desc = "The M40 HPDP is a small, but powerful phosphorus grenade. It is set to detonate in 2 seconds."
	icon_state = "grenade_phos"
	item_state = "grenade_phos"
	det_time = 2 SECONDS
	hud_state = "grenade_hide"
	var/datum/effect_system/smoke_spread/phosphorus/smoke
	icon_state_mini = "grenade_cyan"

/obj/item/explosive/grenade/phosphorus/Initialize(mapload)
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
	arm_sound = 'sound/weapons/armbombpin_1.ogg'

/obj/item/explosive/grenade/impact
	name = "\improper M40 IMDP grenade"
	desc = "A high explosive contact detonation munition utilizing the standard DP canister chassis. Has a focused blast specialized for door breaching and combating emplacements and light armoured vehicles. WARNING: Handthrowing does not result in sufficient force to trigger impact detonators."
	icon_state = "grenade_impact"
	item_state = "grenade_impact"
	hud_state = "grenade_frag"
	det_time = 4 SECONDS
	dangerous = TRUE
	icon_state_mini = "grenade_blue_white"
	light_impact_range = 3

/obj/item/explosive/grenade/impact/throw_impact(atom/hit_atom, speed)
	. = ..()
	if(launched && active && !istype(hit_atom, /turf/open)) //Only contact det if active, we actually hit something, and we're fired from a grenade launcher.
		explosion(loc, light_impact_range = 1, flash_range = 2)
		qdel(src)
