/datum/ammo/xeno/homing_ice_spike
	name = "ice spike"
	icon = 'icons/Xeno/64x64.dmi' // NOTE: This may be too large since it is not 32x32.
	icon_state = "icestorm_projectile"
	damage_type = BURN
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS|AMMO_SPECIAL_PROCESS
	armor_type = FIRE
	damage = 10
	penetration = 30
	max_range = 10
	bullet_color = COLOR_PALE_BLUE_GRAY


/datum/ammo/xeno/homing_ice_spike/on_hit_mob(mob/target_mob, obj/projectile/proj)
	if(!isliving(target_mob))
		return
	playsound(get_turf(target_mob), 'sound/effects/alien/dragon/icestorm_hit.ogg', 50, TRUE)
	var/mob/living/living_mob = target_mob
	living_mob.take_overall_damage(10, BRUTE, FIRE, updating_health = TRUE, penetration = 30)
	living_mob.add_slowdown(1)

/datum/ammo/xeno/homing_ice_spike/ammo_process(obj/projectile/proj, damage)
	if(proj.distance_travelled < 2) // Homing kicks in after some distance, otherwise it will all go to one person.
		return
	if(QDELETED(proj.original_target))
		proj.original_target = get_acceptable_target(proj)
		return
	var/mob/living/carbon/human/human_target = proj.original_target
	if(human_target.stat == DEAD)
		return
	var/angle_to_target = Get_Angle(get_turf(proj), get_turf(proj.original_target)) //angle uses pixel offsets so we check turfs instead
	if((proj.dir_angle >= angle_to_target - 5) && (proj.dir_angle <= angle_to_target + 5))
		return
	proj.dir_angle = clamp(angle_to_target, proj.dir_angle - 30, proj.dir_angle + 30)
	proj.x_offset = round(sin(proj.dir_angle), 0.01)
	proj.y_offset = round(cos(proj.dir_angle), 0.01)
	var/matrix/rotate = matrix()
	rotate.Turn(proj.dir_angle)
	animate(proj, transform = rotate, time = SSprojectiles.wait)

/datum/ammo/xeno/homing_ice_spike/proc/get_acceptable_target(obj/projectile/proj)
	var/mob/living/carbon/human/closest_human
	for(var/mob/living/carbon/human/nearby_human AS in cheap_get_humans_near(proj, 9))
		if(nearby_human.stat == DEAD)
			continue
		if(!line_of_sight(proj, nearby_human, 9))
			continue
		if(!closest_human)
			closest_human = nearby_human
			continue
		if(get_dist(closest_human, proj) > get_dist(nearby_human, proj))
			closest_human = nearby_human
			continue
	return closest_human

/datum/ammo/xeno/miasma_orb
	name = "miasma orb"
	icon_state = "ion"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS
	max_range = 7
	bullet_color = COLOR_GRAY

/datum/ammo/xeno/miasma_orb/drop_nade(turf/T)
	new /obj/effect/temp_visual/dragon/plague(T)
	for(var/turf/filled_turf AS in filled_turfs(T, 2, "square", TRUE, PASS_GLASS|PASS_PROJECTILE))
		if(filled_turf != T)
			new /obj/effect/temp_visual/dragon/plague_mini(filled_turf)
		for(var/mob/living/carbon/human/affected_human in filled_turf)
			if(isxeno(affected_human) || affected_human.stat == DEAD)
				continue
			affected_human.apply_damage(50, BURN, blocked = BIO, updating_health = TRUE)
			affected_human.apply_status_effect(STATUS_EFFECT_PLAGUE)
	playsound(T, 'sound/effects/alien/dragon/miasma_impact.ogg', 50, 1)

/datum/ammo/xeno/miasma_orb/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/xeno/miasma_orb/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/xeno/miasma_orb/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/miasma_orb/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

