/*
//================================================
					10ga Microrail Shells
					"Micronades"
//================================================
*/

/datum/ammo/bullet/micro_rail
	hud_state_empty = "grenade_empty_flash"
	handful_icon_state = "micro_grenade_airburst"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 2
	handful_amount = 3
	max_range = 3 //failure to detonate if the target is too close
	damage = 15
	bonus_projectiles_scatter = 12
	///How many bonus projectiles to generate. New var so it doesn't trigger on firing
	var/bonus_projectile_quantity = 5

/datum/ammo/bullet/micro_rail/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, det_turf, 1)
	smoke.start()
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

//piercing scatter shot
/datum/ammo/bullet/micro_rail/airburst
	name = "micro grenade"
	handful_icon_state = "micro_grenade_airburst"
	hud_state = "grenade_airburst"
	bonus_projectiles_type = /datum/ammo/bullet/micro_rail_spread

//incendiary piercing scatter shot
/datum/ammo/bullet/micro_rail/dragonbreath
	name = "micro grenade"
	handful_icon_state = "micro_grenade_incendiary"
	hud_state = "grenade_fire"
	bonus_projectiles_type = /datum/ammo/bullet/micro_rail_spread/incendiary

//cluster grenade. Bomblets explode in a rough cone pattern
/datum/ammo/bullet/micro_rail/cluster
	name = "micro grenade"
	handful_icon_state = "micro_grenade_cluster"
	hud_state = "grenade_he"
	bonus_projectiles_type = /datum/ammo/micro_rail_cluster
	bonus_projectile_quantity = 7

//creates a literal smokescreen
/datum/ammo/bullet/micro_rail/smoke_burst
	name = "micro grenade"
	handful_icon_state = "micro_grenade_smoke"
	hud_state = "grenade_smoke"
	bonus_projectiles_type = /datum/ammo/smoke_burst
	bonus_projectiles_scatter = 20

/datum/ammo/bullet/micro_rail/smoke_burst/tank
	max_range = 3
	bonus_projectiles_type = /datum/ammo/smoke_burst/tank
	bonus_projectile_quantity = 5
	bonus_projectiles_scatter = 30

/datum/ammo/bullet/micro_rail/smoke_burst/tank
	max_range = 3
	bonus_projectiles_type = /datum/ammo/smoke_burst/tank
	bonus_projectile_quantity = 5
	bonus_projectiles_scatter = 30

//submunitions for micro grenades
/datum/ammo/bullet/micro_rail_spread
	name = "Shrapnel"
	icon_state = "flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB
	accuracy_variation = 5
	damage = 20
	penetration = 20
	sundering = 3
	damage_falloff = 1
	max_range = 7
	shell_speed = 3

/datum/ammo/bullet/micro_rail_spread/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 1 SECONDS, slowdown = 0.5)

/datum/ammo/bullet/micro_rail_spread/incendiary
	name = "incendiary flechette"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 15
	penetration = 5
	sundering = 1.5
	max_range = 6

/datum/ammo/bullet/micro_rail_spread/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 0.4 SECONDS, slowdown = 0.2)

/datum/ammo/bullet/micro_rail_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/micro_rail_spread/incendiary/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	if(prob(40))
		drop_flame(target_turf)

/datum/ammo/micro_rail_cluster
	name = "bomblet"
	icon_state = "bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_LEAVE_TURF
	sound_hit = SFX_BALLISTIC_HIT
	sound_armor = SFX_BALLISTIC_ARMOR
	sound_miss = SFX_BALLISTIC_MISS
	sound_bounce = SFX_BALLISTIC_BOUNCE
	shell_speed = 2
	damage = 5
	accuracy = -60 //stop you from just emptying all the bomblets into one guys face for big damage
	shrapnel_chance = 0
	max_range = 6
	bullet_color = COLOR_VERY_SOFT_YELLOW
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread
	///Total damage applied to victims by the exploding bomblet
	var/explosion_damage = 20
	///Amount of stagger applied by the exploding bomblet
	var/stagger_amount = 2 SECONDS
	///Amount of slowdown applied by the exploding bomblet
	var/slow_amount = 1
	///range of bomblet explosion
	var/explosion_range = 2

///handles the actual bomblet detonation
/datum/ammo/micro_rail_cluster/proc/detonate(turf/T, atom/movable/projectile/proj)
	playsound(T, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(0, T, rand(1,2))
	smoke.start()

	var/list/turf/target_turfs = generate_cone(T, explosion_range, -1, 359, 0, pass_flags_checked = PASS_AIR)
	for(var/turf/target_turf AS in target_turfs)
		for(var/target in target_turf)
			if(isliving(target))
				var/mob/living/living_target = target
				living_target.visible_message(span_danger("[living_target] is hit by the bomblet blast!"),
					isxeno(living_target) ? span_xenodanger("We are hit by the bomblet blast!") : span_userdanger("you are hit by the bomblet blast!"))
				living_target.apply_damages(explosion_damage * 0.5, explosion_damage * 0.5, 0, 0, 0, blocked = BOMB, updating_health = TRUE, attacker = proj.firer)
				staggerstun(living_target, proj, stagger = stagger_amount, slowdown = slow_amount)
			else if(isobj(target))
				var/obj/obj_victim = target
				obj_victim.take_damage(explosion_damage, BRUTE, BOMB)

/datum/ammo/micro_rail_cluster/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	///chance to detonate early, scales with distance and capped, to avoid lots of immediate detonations, and nothing reach max range respectively.
	var/detonate_probability = min(proj.distance_travelled * 4, 16)
	if(prob(detonate_probability))
		proj.proj_max_range = proj.distance_travelled

/datum/ammo/micro_rail_cluster/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	detonate(get_turf(target_mob), proj)

/datum/ammo/micro_rail_cluster/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	detonate(get_turf(target_obj), proj)

/datum/ammo/micro_rail_cluster/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	detonate(target_turf.density ? proj.loc : target_turf, proj)

/datum/ammo/micro_rail_cluster/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	detonate(target_turf.density ? proj.loc : target_turf, proj)

/datum/ammo/smoke_burst
	name = "micro smoke canister"
	icon_state = "bullet"
	ammo_behavior_flags = AMMO_BALLISTIC
	sound_hit = SFX_BALLISTIC_HIT
	sound_armor = SFX_BALLISTIC_ARMOR
	sound_miss = SFX_BALLISTIC_MISS
	sound_bounce = SFX_BALLISTIC_BOUNCE
	shell_speed = 2
	damage = 5
	shrapnel_chance = 0
	max_range = 6
	bullet_color = COLOR_VERY_SOFT_YELLOW
	/// smoke type created when the projectile detonates
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke will encompass
	var/smokeradius = 1

/datum/ammo/smoke_burst/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(smokeradius, T, rand(5,9))
	smoke.start()

/datum/ammo/smoke_burst/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/smoke_burst/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(target_obj.allow_pass_flags & PASS_PROJECTILE ? get_step_towards(target_obj, proj) : get_turf(target_obj))

/datum/ammo/smoke_burst/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/smoke_burst/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/smoke_burst/tank
	max_range = 7
	smokeradius = 2
