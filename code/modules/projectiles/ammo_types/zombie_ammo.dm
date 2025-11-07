/datum/ammo/bile_spit
	icon_state = "boiler_neurotoxin"
	ping = "ping_x"
	damage_type = TOX
	ammo_behavior_flags = AMMO_SKIPS_ZOMBIE
	armor_type = BIO
	shell_speed = 1
	accuracy = 20
	accurate_range = 7
	max_range = 12
	bullet_color = COLOR_LIME
	damage = 30

/datum/ammo/bile_spit/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/mob/living/living_target = target_mob
	shake_camera(target_mob, 1, 1)
	living_target.add_slowdown(3)
	living_target.adjust_stagger(3 SECONDS)
	living_target.AdjustConfused(3 SECONDS)
	living_target.blind_eyes(2)
	living_target.adjust_blurriness(4)

	drop_nade(get_turf(target_mob))

/datum/ammo/bile_spit/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	var/turf/target_turf = get_turf(target_obj)
	drop_nade(target_turf.density ? proj.loc : target_turf)

/datum/ammo/bile_spit/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? proj.loc : target_turf)

/datum/ammo/bile_spit/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? proj.loc : target_turf)

/datum/ammo/bile_spit/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/xeno/neuro/light/extinguishing/smoke_system = new
	smoke_system.strength = 1.5
	smoke_system.lifetime = 2
	smoke_system.set_up(3, T)
	smoke_system.start()
