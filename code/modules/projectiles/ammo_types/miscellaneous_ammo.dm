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
	accuracy_variation = 10
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

/datum/ammo/bullet/atgun_spread/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/atgun_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/atgun_spread/incendiary/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(target_turf)

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

/datum/ammo/bullet/pepperball/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(isxeno(target_mob))
		var/mob/living/carbon/xenomorph/X = target_mob
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
	sound_hit = SFX_ALLOY_HIT
	sound_armor = SFX_ALLOY_ARMOR
	sound_bounce = SFX_ALLOY_BOUNCE
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

/datum/ammo/flamethrower/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_flame(get_turf(target_mob))

/datum/ammo/flamethrower/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_flame(get_turf(target_obj))

/datum/ammo/flamethrower/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/flamethrower/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/flamethrower/tank_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	flame_radius(2, T)

/datum/ammo/flamethrower/mech_flamer
	damage = 15

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

/datum/ammo/flamethrower/armored_spray // armored vehicle flamer that sprays a visual continual flame
	name = "spraying flames"
	icon_state = "spray_flamer"
	max_range = 7
	shell_speed = 0.3
	damage = 6
	burntime = 0.3 SECONDS

/datum/ammo/flamethrower/sentry // is also a spray
	name = "spraying flames"
	icon_state = "spray_flamer"
	max_range = 7
	shell_speed = 0.3
	damage = 6
	burntime = 0.3 SECONDS

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
	for(var/atom/relevant_atom AS in extinguished_turf)
		if(isfire(relevant_atom))
			qdel(relevant_atom)
			continue
		if(isliving(relevant_atom))
			var/mob/living/caught_mob = relevant_atom
			caught_mob.ExtinguishMob()
	new /obj/effect/temp_visual/dir_setting/water_splash(extinguished_turf, splash_direction)

/datum/ammo/water/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	splash(get_turf(target_mob), proj.dir)

/datum/ammo/water/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	splash(get_turf(target_obj), proj.dir)

/datum/ammo/water/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	splash(get_turf(target_turf), proj.dir)

/datum/ammo/water/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	splash(get_turf(target_turf), proj.dir)

/datum/ammo/rocket/toy
	name = "\improper toy rocket"
	damage = 1

/datum/ammo/rocket/toy/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	to_chat(target_mob, "<font size=6 color=red>NO BUGS</font>")

/datum/ammo/rocket/toy/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	return

/datum/ammo/rocket/toy/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	return

/datum/ammo/rocket/toy/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
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

/datum/ammo/grenade_container/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/grenade_container/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/grenade_container/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/grenade_container/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

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
	ammo_behavior_flags = AMMO_TARGET_TURF
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
