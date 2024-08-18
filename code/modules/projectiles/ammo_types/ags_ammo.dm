/*
//================================================
					AGS Ammo
//================================================
*/

/datum/ammo/ags_shrapnel
	name = "fragmentation grenade"
	icon_state = "grenade_projectile"
	hud_state = "grenade_frag"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "40mm_grenade"
	handful_amount = 1
	ping = null //no bounce off.
	sound_bounce = SFX_ROCKET_BOUNCE
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_IFF
	armor_type = BOMB
	damage_falloff = 0.5
	shell_speed = 2
	accurate_range = 12
	max_range = 21
	damage = 15
	shrapnel_chance = 0
	bonus_projectiles_type = /datum/ammo/bullet/ags_spread
	bonus_projectiles_scatter = 20
	var/bonus_projectile_quantity = 15


/datum/ammo/ags_shrapnel/on_hit_mob(mob/target_mob, obj/projectile/proj)
	var/turf/det_turf = get_turf(target_mob)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/ags_shrapnel/on_hit_obj(obj/target_obj, obj/projectile/proj)
	var/turf/det_turf = target_obj.allow_pass_flags & PASS_PROJECTILE ? get_step_towards(target_obj, proj) : target_obj.loc
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_obj), loc_override = det_turf)

/datum/ammo/ags_shrapnel/on_hit_turf(turf/target_turf, obj/projectile/proj)
	var/turf/det_turf = target_turf.density ? get_step_towards(target_turf, proj) : target_turf
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/ags_shrapnel/do_at_max_range(turf/target_turf, obj/projectile/proj)
	var/turf/det_turf = target_turf.density ? get_step_towards(target_turf, proj) : target_turf
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/ags_shrapnel/incendiary
	name = "white phosphorous grenade"
	bonus_projectiles_type = /datum/ammo/bullet/ags_spread/incendiary

/datum/ammo/bullet/ags_spread
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

/datum/ammo/bullet/ags_spread/incendiary
	name = "White phosphorous shrapnel"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 20
	penetration = 10
	sundering = 1.5
	damage_falloff = 0

/datum/ammo/bullet/ags_spread/incendiary/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_flame(get_turf(target_mob))

/datum/ammo/bullet/ags_spread/incendiary/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_flame(get_turf(target_obj))

/datum/ammo/bullet/ags_spread/incendiary/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/bullet/ags_spread/incendiary/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_flame(get_turf(target_turf))

/datum/ammo/bullet/ags_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)
