/datum/ammo/xeno/fireball
	name = "fireball"
	icon_state = "xeno_fireball"
	damage = 50
	max_range = 5
	damage_type = BURN
	armor_type = FIRE
	ammo_behavior_flags = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_TARGET_TURF
	bullet_color = null

/datum/ammo/xeno/fireball/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_flame(target_mob, proj)

/datum/ammo/xeno/fireball/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	. = ..()
	drop_flame((target_obj.density ? get_step_towards(target_obj, proj) : get_turf(target_obj)), proj)

/datum/ammo/xeno/fireball/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	. = ..()
	drop_flame((target_turf.density ? get_step_towards(target_turf, proj) : target_turf), proj)

/datum/ammo/xeno/fireball/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	. = ..()
	drop_flame((target_turf.density ? get_step_towards(target_turf, proj) : target_turf), proj)

/datum/ammo/xeno/fireball/drop_flame(atom/target_atom, atom/movable/projectile/proj)
	new /obj/effect/temp_visual/xeno_fireball_explosion(get_turf(target_atom))
	for(var/turf/affecting AS in RANGE_TURFS(1, target_atom))
		var/obj/fire/melting_fire/new_fire = new(affecting)
		if(proj.shot_from && isxenopyrogen(proj.shot_from)) // Exclusive to pyrogen, but doesn't hurt to double check.
			new_fire.creator = proj.shot_from
		for(var/atom/movable/fired AS in affecting)
			if(isxeno(fired))
				continue
			if(iscarbon(fired))
				var/mob/living/carbon/carbon_fired = fired
				carbon_fired.take_overall_damage(PYROGEN_FIREBALL_AOE_DAMAGE, BURN, FIRE, FALSE, FALSE, TRUE, 0, , max_limbs = 2)
				var/datum/status_effect/stacking/melting_fire/debuff = carbon_fired.has_status_effect(STATUS_EFFECT_MELTING_FIRE)
				if(debuff)
					debuff.add_stacks(PYROGEN_FIREBALL_MELTING_STACKS, new_fire.creator)
				else
					carbon_fired.apply_status_effect(STATUS_EFFECT_MELTING_FIRE, PYROGEN_FIREBALL_MELTING_STACKS, new_fire.creator)
				continue
			if(ishitbox(fired))
				var/obj/obj_fired = fired
				obj_fired.take_damage(PYROGEN_FIREBALL_VEHICLE_AOE_DAMAGE, BURN, FIRE)
				continue
