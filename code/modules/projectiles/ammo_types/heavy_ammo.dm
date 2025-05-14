/*
//================================================
					Heavy Ammo
	Includes minigun/railgun/flak/mounted etc
//================================================
*/

/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state = "bullet" // Keeping it bog standard with the turret but allows it to be changed.
	ammo_behavior_flags = AMMO_BALLISTIC
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	accurate_range = 12
	damage = 40 //Reduced damage due to vastly increased mobility
	penetration = 40 //Reduced penetration due to vastly increased mobility
	accuracy = 5
	barricade_clear_distance = 2
	sundering = 5

/datum/ammo/bullet/minigun
	name = "minigun bullet"
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accuracy_var_low = 3
	accuracy_var_high = 3
	accurate_range = 5
	damage = 25
	penetration = 15
	shrapnel_chance = 25
	sundering = 2.5

/datum/ammo/bullet/minigun_light
	name = "minigun bullet"
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	accurate_range = 6
	damage = 16
	penetration = 15
	shrapnel_chance = 15
	sundering = 1.5


/datum/ammo/bullet/minigun/ltaap
	name = "chaingun bullet"
	damage = 15
	penetration = 20
	sundering = 1
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_IFF
	damage_falloff = 1
	accurate_range = 7
	accuracy = 10
	barricade_clear_distance = 4

/datum/ammo/bullet/auto_cannon
	name = "autocannon high-velocity bullet"
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	accurate_range_min = 6
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 30
	penetration = 50
	sundering = 1
	max_range = 35
	///Bonus flat damage to walls, balanced around resin walls.
	var/autocannon_wall_bonus = 50

/datum/ammo/bullet/auto_cannon/on_hit_turf(turf/target_turf, obj/projectile/proj)
	proj.proj_max_range -= 20

	if(istype(target_turf, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = target_turf
		wall_victim.take_damage(autocannon_wall_bonus, proj.damtype, proj.armor_type)

/datum/ammo/bullet/auto_cannon/on_hit_mob(mob/target_mob, obj/projectile/proj)
	proj.proj_max_range -= 5
	staggerstun(target_mob, proj, max_range = 20, slowdown = 1)

/datum/ammo/bullet/auto_cannon/on_hit_obj(obj/target_obj, obj/projectile/proj)
	proj.proj_max_range -= 5

/datum/ammo/bullet/auto_cannon/flak
	name = "autocannon smart-detonating bullet"
	hud_state = "sniper_flak"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_TARGET_TURF
	damage = 50
	penetration = 30
	sundering = 5
	max_range = 30
	airburst_multiplier = 1
	autocannon_wall_bonus = 25

/datum/ammo/bullet/auto_cannon/flak/on_hit_mob(mob/target_mob, obj/projectile/proj)
	airburst(target_mob, proj)

/datum/ammo/bullet/auto_cannon/do_at_max_range(turf/target_turf, obj/projectile/proj)
	airburst(target_turf, proj)

/datum/ammo/bullet/auto_cannon/anti_tank
	name = "autocannon solid-shot bullet"
	hud_state = "railgun_hvap"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_TARGET_TURF
	damage = 35
	penetration = 35
	autocannon_wall_bonus = 100

/datum/ammo/bullet/railgun
	name = "armor piercing railgun slug"
	hud_state = "railgun_ap"
	icon_state = "blue_bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 20
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.75

/datum/ammo/bullet/railgun/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, weaken = 2 SECONDS, stagger = 4 SECONDS, slowdown = 2, knockback = 2)

/datum/ammo/bullet/railgun/on_hit_turf(turf/target_turf, obj/projectile/proj)
	proj.proj_max_range -= 3

/datum/ammo/bullet/railgun/hvap
	name = "high velocity railgun slug"
	hud_state = "railgun_hvap"
	shell_speed = 5
	max_range = 21
	damage = 100
	penetration = 30
	sundering = 50

/datum/ammo/bullet/railgun/hvap/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, stagger = 2 SECONDS, knockback = 3)

/datum/ammo/bullet/railgun/smart
	name = "smart armor piercing railgun slug"
	hud_state = "railgun_smart"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE|AMMO_IFF
	damage = 100
	penetration = 20
	sundering = 20

/datum/ammo/bullet/railgun/smart/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, stagger = 3 SECONDS, slowdown = 3)

/datum/ammo/bullet/apfsds
	name = "\improper APFSDS round"
	hud_state = "alloy_spike"
	icon_state = "blue_bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOVABLE|AMMO_UNWIELDY
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 0
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85

/datum/ammo/bullet/apfsds/on_hit_obj(obj/target_obj, obj/projectile/proj)
	if(ishitbox(target_obj) || ismecha(target_obj) || isarmoredvehicle(target_obj))
		proj.damage *= 1.5
		proj.proj_max_range = 0

/datum/ammo/bullet/coilgun // ICC coilgun
	name = "high-velocity tungsten slug"
	hud_state = "railgun_ap"
	icon_state = "blue_bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 5
	max_range = 31
	damage = 70
	penetration = 35
	sundering = 5
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85

/datum/ammo/bullet/coilgun/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, weaken = 0.2 SECONDS, slowdown = 1, knockback = 3)


// SARDEN

/datum/ammo/bullet/sarden
	name = "heavy autocannon armor piercing"
	hud_state = "alloy_spike"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 40
	penetration = 40
	sundering = 3.5

/datum/ammo/bullet/sarden/high_explosive
	name = "heavy autocannon high explosive"
	hud_state = "alloy_spike"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 25
	penetration = 30
	sundering = 0.5
	max_range = 21

/datum/ammo/bullet/sarden/high_explosive/drop_nade(turf/T)
	explosion(T, light_impact_range = 2, weak_impact_range = 4)

/datum/ammo/bullet/sarden/high_explosive/on_hit_mob(mob/target_mob, obj/projectile/proj)
	var/target_turf = get_turf(target_mob)
	staggerstun(target_mob, proj, src.max_range, knockback = 1, hard_size_threshold = 3)
	drop_nade(target_turf)

/datum/ammo/bullet/sarden/high_explosive/on_hit_obj(obj/target_obj, obj/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/bullet/sarden/high_explosive/on_hit_turf(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/bullet/sarden/high_explosive/do_at_max_range(turf/target_turf, obj/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)
