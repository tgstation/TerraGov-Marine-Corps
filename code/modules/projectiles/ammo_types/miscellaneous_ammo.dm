/*
//================================================
					Misc Ammo Types

	Ammo types that don't really belong in
	other files.
//================================================
*/

// TAT spread ammo
/datum/ammo/bullet/atgun_spread
	name = "Shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 15
	accuracy_var_high = 5
	max_range = 6
	damage = 30
	penetration = 20
	sundering = 3
	damage_falloff = 0

/datum/ammo/bullet/atgun_spread/incendiary
	name = "incendiary flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 20
	penetration = 10
	sundering = 1.5

/datum/ammo/bullet/atgun_spread/incendiary/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/atgun_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/atgun_spread/incendiary/on_leave_turf(turf/T, obj/projectile/proj)
	drop_flame(T)

/*
//================================================
					Misc Ammo
//================================================
*/

/datum/ammo/bullet/pepperball
	name = "pepperball"
	hud_state = "pepperball"
	hud_state_empty = "pepperball_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 15
	damage_type = STAMINA
	armor_type = BIO
	damage = 70
	penetration = 0
	shrapnel_chance = 0
	///percentage of xenos total plasma to drain when hit by a pepperball
	var/drain_multiplier = 0.05
	///Flat plasma to drain, unaffected by caste plasma amount.
	var/plasma_drain = 25

/datum/ammo/bullet/pepperball/on_hit_mob(mob/living/victim, obj/projectile/proj)
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/X = victim
		if(!(X.xeno_caste.caste_flags & CASTE_PLASMADRAIN_IMMUNE))
			X.use_plasma(drain_multiplier * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit)
			X.use_plasma(plasma_drain)

/datum/ammo/bullet/pepperball/pepperball_mini
	damage = 40
	drain_multiplier = 0.03
	plasma_drain = 15

/datum/ammo/alloy_spike
	name = "alloy spike"
	ping = "ping_s"
	icon_state = "MSpearFlight"
	sound_hit 	 = "alloy_hit"
	sound_armor	 = "alloy_armor"
	sound_bounce = "alloy_bounce"
	armor_type = BULLET
	accuracy = 20
	accurate_range = 15
	max_range = 15
	damage = 40
	penetration = 50
	shrapnel_chance = 75

/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	hud_state = "flame"
	hud_state_empty = "flame_empty"
	damage_type = BURN
	ammo_behavior_flags = AMMO_INCENDIARY|AMMO_FLAME|AMMO_TARGET_TURF
	armor_type = FIRE
	max_range = 7
	damage = 31
	damage_falloff = 0
	incendiary_strength = 30 //Firestacks cap at 20, but that's after armor.
	bullet_color = LIGHT_COLOR_FIRE
	var/fire_color = "red"
	var/burntime = 17
	var/burnlevel = 31

/datum/ammo/flamethrower/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(burntime, burnlevel, fire_color)

/datum/ammo/flamethrower/on_hit_mob(mob/M, obj/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/flamethrower/on_hit_obj(obj/O, obj/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/flamethrower/on_hit_turf(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/flamethrower/do_at_max_range(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/flamethrower/tank_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	flame_radius(2, T)

/datum/ammo/flamethrower/mech_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	flame_radius(1, T)

/datum/ammo/flamethrower/blue
	name = "blue flame"
	hud_state = "flame_blue"
	max_range = 7
	fire_color = "blue"
	burntime = 40
	burnlevel = 46
	bullet_color = COLOR_NAVY

/datum/ammo/water
	name = "water"
	icon_state = "pulse1"
	hud_state = "water"
	hud_state_empty = "water_empty"
	damage = 0
	shell_speed = 1
	damage_type = BURN
	ammo_behavior_flags = AMMO_TARGET_TURF
	bullet_color = null

/datum/ammo/water/proc/splash(turf/extinguished_turf, splash_direction)
	var/obj/flamer_fire/current_fire = locate(/obj/flamer_fire) in extinguished_turf
	if(current_fire)
		qdel(current_fire)
	for(var/mob/living/mob_caught in extinguished_turf)
		mob_caught.ExtinguishMob()
	new /obj/effect/temp_visual/dir_setting/water_splash(extinguished_turf, splash_direction)

/datum/ammo/water/on_hit_mob(mob/M, obj/projectile/P)
	splash(get_turf(M), P.dir)

/datum/ammo/water/on_hit_obj(obj/O, obj/projectile/P)
	splash(get_turf(O), P.dir)

/datum/ammo/water/on_hit_turf(turf/T, obj/projectile/P)
	splash(get_turf(T), P.dir)

/datum/ammo/water/do_at_max_range(turf/T, obj/projectile/P)
	splash(get_turf(T), P.dir)

/datum/ammo/rocket/toy
	name = "\improper toy rocket"
	damage = 1

/datum/ammo/rocket/toy/on_hit_mob(mob/M,obj/projectile/P)
	to_chat(M, "<font size=6 color=red>NO BUGS</font>")

/datum/ammo/rocket/toy/on_hit_obj(obj/O,obj/projectile/P)
	return

/datum/ammo/rocket/toy/on_hit_turf(turf/T,obj/projectile/P)
	return

/datum/ammo/rocket/toy/do_at_max_range(turf/T, obj/projectile/P)
	return

/datum/ammo/grenade_container
	name = "grenade shell"
	ping = null
	damage_type = BRUTE
	var/nade_type = /obj/item/explosive/grenade
	icon_state = "grenade"
	armor_type = BOMB
	damage = 15
	accuracy = 15
	max_range = 10

/datum/ammo/grenade_container/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : O.loc)

/datum/ammo/grenade_container/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/grenade_container/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/grenade_container/drop_nade(turf/T)
	var/obj/item/explosive/grenade/G = new nade_type(T)
	G.visible_message(span_warning("\A [G] lands on [T]!"))
	G.det_time = 10
	G.activate()

/datum/ammo/grenade_container/smoke
	name = "smoke grenade shell"
	nade_type = /obj/item/explosive/grenade/smokebomb
	icon_state = "smoke_shell"

/datum/ammo/grenade_container/ags_grenade
	name = "grenade shell"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_IFF
	icon_state = "grenade_projectile"
	hud_state = "grenade_he"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "40mm_grenade"
	handful_amount = 1
	max_range = 21
	nade_type = /obj/item/explosive/grenade/ags

/datum/ammo/grenade_container/ags_grenade/flare
	hud_state = "grenade_dummy"
	nade_type = /obj/item/explosive/grenade/flare

/datum/ammo/grenade_container/ags_grenade/cloak
	hud_state = "grenade_hide"
	nade_type = /obj/item/explosive/grenade/smokebomb/cloak/ags

/datum/ammo/grenade_container/ags_grenade/tanglefoot
	hud_state = "grenade_drain"
	nade_type = /obj/item/explosive/grenade/smokebomb/drain/agls

//See mine.dm for actual values per mine; bonus projectiles and scatter have to be set here
/datum/ammo/bullet/claymore_shrapnel
	name = "claymore shrapnel"
	icon_state = "flechette"
	damage = 17
	penetration = 15
	sundering = 1	//Low pen to not insta kill armored humans, but high sunder to leave heavily armored benos shredded
	damage_falloff = 0
	shell_speed = 1
	bonus_projectiles_type = /datum/ammo/bullet/claymore_shrapnel/additional
	bonus_projectiles_amount = 10
	bonus_projectiles_scatter = 5
	shrapnel_chance = 80
	accuracy = 100	//It's entirely based on scatter, no need to add RNG accuracy

/datum/ammo/bullet/claymore_shrapnel/additional
	bonus_projectiles_amount = 0

/datum/ammo/bullet/claymore_shrapnel/pmc
	bonus_projectiles_scatter = 3

/datum/ammo/bullet/claymore_shrapnel/nail
	name = "nail"
	damage = 5
	penetration = 5
	sundering = 0.5
	bonus_projectiles_type = /datum/ammo/bullet/claymore_shrapnel/nail/additional
	bonus_projectiles_amount = 40
	bonus_projectiles_scatter = 10
	shrapnel_chance = 100	//Hope marines got their tetanus shots

/datum/ammo/bullet/claymore_shrapnel/nail/additional
	bonus_projectiles_amount = 0

//Generic ammo type to spread mines over an area
/datum/ammo/carpet_mine
	name = "proximity mine payload"
	icon_state = "howi"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 0.75
	damage = 0
	penetration = 0
	sundering = 0
	accuracy = 1000
	max_range = 1000
	ping = null
	bullet_color = COLOR_VERY_SOFT_YELLOW
	///How many mines to deploy
	var/payload_amount = 7
	///How far mines will be dispersed
	var/spread_radius = 7

/datum/ammo/carpet_mine/do_at_max_range(turf/T, obj/projectile/proj)
	//Get a list of turfs around the impact point and shuffle it
	var/list/turf/turfs = shuffle(circle_range_turfs(T, spread_radius))
	//Deploy mines in open turfs until there are none left
	var/amount = payload_amount
	while(amount > 0)
		for(var/turf/turf AS in turfs)
			if(is_blocked_turf(turf))	//Don't put mines anywhere that can't be reached
				turfs.Remove(turf)	//Don't bother with this turf again
				continue

			//Mines don't all pop out at once, little bit of flair
			addtimer(CALLBACK(src, PROC_REF(deploy_animation), turf), rand(1 SECONDS, 5 SECONDS))
			turfs.Remove(turf)	//So we don't put more than one mine on a turf
			break

		amount--

///Separate proc to handle the deployment animation
/datum/ammo/carpet_mine/proc/deploy_animation(turf/T)
	playsound(T, 'sound/items/fultext_deploy.ogg', 25, 1, 7)
	var/obj/item/mine/proximity/mine = new(T)
	var/image/bloon = image('icons/obj/items/fulton_balloon.dmi', mine, "fulton_balloon", pixel_y = 16)
	mine.overlays += bloon

	//So nothing happens to the mine during the animation
	mine.pixel_y = 128
	mine.mouse_opacity = 0
	mine.anchored = TRUE
	ENABLE_BITFIELD(mine.obj_flags, RESIST_ALL)

	var/duration = rand(3 SECONDS, 15 SECONDS)
	mine.add_filter("drop shadow", 2, drop_shadow_filter(color = COLOR_TRANSPARENT_SHADOW, size = 3, y = -128))
	var/shadow_filter = mine.get_filter("drop shadow")
	//Falling animations
	animate(shadow_filter, duration, y = 0, size = 1, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	animate(mine, duration, pixel_y = 0, easing = CIRCULAR_EASING|EASE_OUT, flags = ANIMATION_PARALLEL)
	//Bobbing animations
	animate(time = duration/2, pixel_x = rand(-16, 16), easing = BACK_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(time = duration/2, pixel_x = 0)
	addtimer(CALLBACK(src, PROC_REF(deploy_mine), mine), duration)

///Separate proc to handle mine deployment
/datum/ammo/carpet_mine/proc/deploy_mine(obj/item/mine/mine)
	DISABLE_BITFIELD(mine.obj_flags, RESIST_ALL)
	mine.cut_overlays()
	mine.mouse_opacity = initial(mine.mouse_opacity)
	mine.remove_filter("drop shadow")
	mine.deploy(faction = TGMC_LOYALIST_IFF)
