/datum/ammo/xeno/void_rift
	name = "void orb"
	icon = 'icons/Xeno/96x144.dmi' // This sucks major ass because proj code is based on 32x32 and this obviously isn't 32x32.
	icon_state = "void_projectile"
	ammo_behavior_flags = AMMO_XENO|AMMO_TARGET_TURF|AMMO_SKIPS_ALIENS|AMMO_SPECIAL_PROCESS
	max_range = 10
	bullet_color = COLOR_GRAY

/datum/ammo/xeno/void_rift/on_hit_mob(mob/target_mob, obj/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/xeno/void_rift/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/xeno/void_rift/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/void_rift/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/xeno/void_rift/drop_nade(turf/T)
	new /obj/effect/temp_visual/dragon/void_explosion(T)
	for(var/turf/filled_turf AS in filled_turfs(T, 1, include_edge = TRUE, pass_flags_checked = PASS_GLASS|PASS_PROJECTILE))
		for(var/mob/living/carbon/human/affected_human in filled_turf)
			if(isxeno(affected_human) || affected_human.stat == DEAD)
				continue
			affected_human.apply_damage(100, BURN, blocked = BIO, updating_health = TRUE, penetration = 30)
			affected_human.apply_status_effect(STATUS_EFFECT_PLAGUE)
	playsound(T, 'sound/effects/alien/dragon/void_explosion.ogg', 50, 1)

/datum/ammo/xeno/void_rift/ammo_process(obj/projectile/proj, damage)
	if(isxeno(proj.original_target)) // This is our way of saying, "just do nothing instead because we don't want constant cheap_get_humans_near loops".
		return
	if(QDELETED(proj.original_target) || !ishuman(proj.original_target))
		proj.original_target = get_acceptable_target(proj)
		return
	var/mob/living/carbon/human/human_target = proj.original_target
	if(human_target.stat == DEAD)
		return
	var/angle_to_target = Get_Angle(get_turf(proj), get_turf(proj.original_target))
	if((proj.dir_angle >= angle_to_target - 5) && (proj.dir_angle <= angle_to_target + 5))
		return
	proj.dir_angle = clamp(angle_to_target, proj.dir_angle - 30, proj.dir_angle + 30)
	proj.x_offset = round(sin(proj.dir_angle), 0.01)
	proj.y_offset = round(cos(proj.dir_angle), 0.01)
	var/matrix/rotate = matrix()
	rotate.Turn(proj.dir_angle)
	animate(proj, transform = rotate, time = SSprojectiles.wait)

/datum/ammo/xeno/void_rift/proc/get_acceptable_target(obj/projectile/proj)
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
	return closest_human ? closest_human : proj.firer
