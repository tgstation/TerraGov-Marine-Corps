/datum/ammo/xeno/fireball
	name = "fireball"
	icon_state = "xeno_fireball"
	damage = 50
	max_range = 5
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	bullet_color = null

/datum/ammo/xeno/fireball/on_hit_mob(mob/target, obj/projectile/projectile)
	drop_flame(target)

/datum/ammo/xeno/fireball/on_hit_obj(obj/target, obj/projectile/proj)
	. = ..()
	drop_flame(target)

/datum/ammo/xeno/fireball/on_hit_turf(turf/target, obj/projectile/proj)
	. = ..()
	drop_flame(target.density ? proj : target)

/datum/ammo/xeno/fireball/do_at_max_range(turf/target, obj/projectile/proj)
	. = ..()
	drop_flame(target.density ? proj : target)

/datum/ammo/xeno/fireball/drop_flame(atom/target_atom)
	new /obj/effect/temp_visual/xeno_fireball_explosion(get_turf(target_atom))
	for(var/turf/affecting AS in RANGE_TURFS(1, target_atom))
		new /obj/fire/melting_fire(affecting)
		for(var/mob/living/carbon/fired in affecting)
			fired.take_overall_damage(PYROGEN_FIREBALL_AOE_DAMAGE, BURN, ACID, FALSE, FALSE, TRUE, 0, , max_limbs = 2)
