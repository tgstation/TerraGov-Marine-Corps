/*
//================================================
					Rocket Ammo
//================================================
*/

/datum/ammo/rocket
	name = "high explosive rocket"
	icon_state = "missile"
	hud_state = "rocket_he"
	hud_state_empty = "rocket_empty"
	ping = null //no bounce off.
	sound_bounce = SFX_ROCKET_BOUNCE
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG
	armor_type = BOMB
	damage_falloff = 0
	shell_speed = 2
	accuracy = 40
	accurate_range = 20
	max_range = 14
	damage = 200
	penetration = 100
	sundering = 100
	bullet_color = LIGHT_COLOR_FIRE
	barricade_clear_distance = 2

/datum/ammo/rocket/drop_nade(turf/T)
	explosion(T, 0, 4, 6, 0, 2, explosion_cause=src)

/datum/ammo/rocket/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/target_turf = get_turf(target_mob)
	staggerstun(target_mob, proj, max_range, knockback = 1, hard_size_threshold = 3)
	drop_nade(target_turf)

/datum/ammo/rocket/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/rocket/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/rocket/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/rocket/he
	name = "high explosive rocket"
	icon_state = "rocket_he"
	hud_state = "rocket_he"
	accurate_range = 20
	max_range = 14
	damage = 200
	penetration = 75
	sundering = 50

/datum/ammo/rocket/he/unguided
	damage = 100
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG // We want this one to specifically go over onscreen range.

/datum/ammo/rocket/he/unguided/drop_nade(turf/T)
	explosion(T, 0, 7, 0, 0, 2, throw_range = 4, explosion_cause=src)

/datum/ammo/rocket/ap
	name = "kinetic penetrator"
	icon_state = "rocket_ap"
	hud_state = "rocket_ap"
	damage = 340
	accurate_range = 15
	penetration = 200
	sundering = 0

/datum/ammo/rocket/ap/drop_nade(turf/T)
	explosion(T, flash_range = 1, explosion_cause=src)

/datum/ammo/rocket/ltb
	name = "cannon round"
	icon_state = "ltb"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	accurate_range = 15
	max_range = 40
	penetration = 50
	damage = 200
	hud_state = "bigshell_he"
	sundering = 20
	barricade_clear_distance = 4

/datum/ammo/rocket/ltb/drop_nade(turf/T)
	explosion(T, 0, 2, 5, 0, 3, explosion_cause=src)

/datum/ammo/rocket/ltb/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/target_turf = get_turf(target_mob)
	if(!isxeno(target_mob))
		if(!(target_mob.status_flags & GODMODE))
			target_mob.gib()
	else
		staggerstun(target_mob, proj, max_range, knockback = 1, hard_size_threshold = 3)
	drop_nade(target_turf)

/datum/ammo/rocket/ltb/heavy/drop_nade(turf/target_turf)
	explosion(target_turf, 1, 4, 6, 0, 3, explosion_cause=src)

/datum/ammo/rocket/heavy_isg
	name = "8.8cm round"
	icon_state = "heavyrr"
	hud_state = "bigshell_he"
	hud_state_empty = "shell_empty"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG|AMMO_TARGET_TURF
	damage = 100
	penetration = 200
	max_range = 30
	shell_speed = 0.75
	accurate_range = 21
	handful_amount = 1

/datum/ammo/rocket/heavy_isg/drop_nade(turf/T)
	explosion(T, 0, 7, 8, 12, explosion_cause=src)

/datum/ammo/rocket/heavy_isg/unguided
	hud_state = "bigshell_he_unguided"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG

/datum/ammo/bullet/heavy_isg_apfds
	name = "8.8cm APFDS round"
	icon_state = "apfds"
	hud_state = "bigshell_apfds"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	damage = 275
	penetration = 75
	shell_speed = 7
	accurate_range = 24
	max_range = 35

/datum/ammo/bullet/isg_apfds/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	proj.proj_max_range -= 5

/datum/ammo/bullet/isg_apfds/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	proj.proj_max_range -= 2
	staggerstun(target_mob, proj, max_range = 20, slowdown = 0.5)
	shake_camera(target_mob, 0.3 SECONDS, 3)

/datum/ammo/bullet/isg_apfds/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	proj.proj_max_range -= 5

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	icon_state = "rocket_wp"
	hud_state = "rocket_fire"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG|AMMO_INCENDIARY|AMMO_TARGET_TURF
	armor_type = FIRE
	damage_type = BURN
	accuracy_variation = 7
	accurate_range = 15
	damage = 200
	penetration = 75
	max_range = 20
	sundering = 100
	///The radius for the non explosion effects
	var/effect_radius = 3

/datum/ammo/rocket/wp/drop_nade(turf/T)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(effect_radius, T, 27, 27, 27, 17)

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	hud_state = "rocket_thermobaric"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	damage = 40
	penetration = 25
	max_range = 30
	sundering = 2

	///The smoke system that the WP gas uses to spread.
	var/datum/effect_system/smoke_spread/smoke_system

/datum/ammo/rocket/wp/quad/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/phosphorus()

/datum/ammo/rocket/wp/quad/drop_nade(turf/T)
	set_smoke()
	smoke_system.set_up(effect_radius, T)
	smoke_system.start()
	smoke_system = null
	T.visible_message(span_danger("The rocket explodes into white gas!") )
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(effect_radius, T, 27, 27, 27, 17)

/datum/ammo/rocket/wp/quad/som
	name = "white phosphorous RPG"
	hud_state = "rpg_fire"
	icon_state = "rpg_incendiary"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	effect_radius = 5

/datum/ammo/rocket/wp/quad/ds
	name = "super thermobaric rocket"
	hud_state = "rocket_thermobaric"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	damage = 200
	penetration = 75
	max_range = 30
	sundering = 100

/datum/ammo/rocket/wp/unguided
	damage = 100
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG|AMMO_INCENDIARY
	effect_radius = 5

/datum/ammo/rocket/recoilless
	name = "high explosive shell"
	icon_state = "recoilless_rifle_he"
	hud_state = "shell_he"
	hud_state_empty = "shell_empty"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG
	armor_type = BOMB
	damage_falloff = 0
	shell_speed = 2
	accurate_range = 20
	max_range = 30
	damage = 100
	penetration = 50
	sundering = 50

/datum/ammo/rocket/recoilless/drop_nade(turf/T)
	explosion(T, 0, 3, 4, 0, 2, explosion_cause=src)

/datum/ammo/rocket/recoilless/heat
	name = "HEAT shell"
	icon_state = "recoilless_rifle_heat"
	hud_state = "shell_heat"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	damage = 200
	penetration = 100
	sundering = 0

/datum/ammo/rocket/recoilless/heat/drop_nade(turf/T)
	explosion(T, flash_range = 1, explosion_cause=src)

/datum/ammo/rocket/recoilless/heat/mech //for anti mech use in HvH
	name = "HEAM shell"
	accuracy = -10 //Not designed for anti human use
	scatter = 16
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG|AMMO_UNWIELDY

/datum/ammo/rocket/recoilless/heat/mech/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(get_turf(target_obj))
	if(isvehicle(target_obj) || ishitbox(target_obj))
		proj.damage *= 3 //this is specifically designed to hurt vehicles

/datum/ammo/rocket/recoilless/heat/mech/drop_nade(turf/T)
	explosion(T, 0, 1, 0, 0, 1, explosion_cause=src)

/datum/ammo/rocket/recoilless/light
	name = "light explosive shell"
	icon_state = "recoilless_rifle_le"
	hud_state = "shell_le"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG //We want this to specifically go farther than onscreen range.
	accurate_range = 15
	max_range = 20
	damage = 75
	penetration = 50
	sundering = 25

/datum/ammo/rocket/recoilless/light/drop_nade(turf/T)
	explosion(T, 0, 1, 8, 0, 1, explosion_cause=src)

/datum/ammo/rocket/recoilless/chemical
	name = "low velocity chemical shell"
	icon_state = "recoilless_rifle_smoke"
	hud_state = "shell_le"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	accurate_range = 21
	max_range = 21
	damage = 10
	penetration = 0
	sundering = 0
	/// Smoke type created when projectile detonates.
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	/// Radius this smoke will encompass on detonation.
	var/smokeradius = 7

/datum/ammo/rocket/recoilless/chemical/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(smokeradius, T, rand(5,9))
	smoke.start()
	explosion(T, flash_range = 1, explosion_cause=src)

/datum/ammo/rocket/recoilless/chemical/cloak
	name = "low velocity chemical shell"
	icon_state = "recoilless_rifle_cloak"
	hud_state = "shell_cloak"
	smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/rocket/recoilless/chemical/plasmaloss
	name = "low velocity chemical shell"
	icon_state = "recoilless_rifle_tanglefoot"
	hud_state = "shell_tanglefoot"
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/rocket/recoilless/chemical/harmgas/vsd
	name = "high velocity chemical shell"
	icon_state = "rpg_rad"
	hud_state = "rpg_rad"
	smoketype = /datum/effect_system/smoke_spread/vyacheslav

/datum/ammo/rocket/recoilless/low_impact
	name = "low impact explosive shell"
	icon_state = "recoilless_rifle_le"
	hud_state = "shell_le"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG //We want this to specifically go farther than onscreen range.
	accurate_range = 15
	max_range = 20
	damage = 75
	penetration = 15
	sundering = 25

/datum/ammo/rocket/recoilless/low_impact/drop_nade(turf/T)
	explosion(T, 0, 1, 8, 0, 2, explosion_cause=src)

/datum/ammo/rocket/oneuse
	name = "explosive rocket"
	damage = 100
	penetration = 50
	sundering = 25
	max_range = 30

/datum/ammo/rocket/som
	name = "high explosive RPG"
	icon_state = "rpg_he"
	hud_state = "rpg_he"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	accurate_range = 15
	max_range = 20
	damage = 80
	penetration = 20
	sundering = 20

/datum/ammo/rocket/som/drop_nade(turf/T)
	explosion(T, 0, 3, 6, 0, 2, explosion_cause=src)

/datum/ammo/rocket/som/light
	name = "low impact RPG"
	icon_state = "rpg_le"
	hud_state = "rpg_le"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	accurate_range = 15
	damage = 60
	penetration = 10

/datum/ammo/rocket/som/light/drop_nade(turf/T)
	explosion(T, 0, 2, 7, 0, 2, explosion_cause=src)

/datum/ammo/rocket/som/thermobaric
	name = "thermobaric RPG"
	icon_state = "rpg_thermobaric"
	hud_state = "rpg_thermobaric"
	damage = 30

/datum/ammo/rocket/som/thermobaric/drop_nade(turf/T)
	explosion(T, 0, 4, 5, 0, 4, 4, explosion_cause=src)

/datum/ammo/rocket/som/heat //Anti tank, or mech
	name = "HEAT RPG"
	icon_state = "rpg_heat"
	hud_state = "rpg_heat"
	damage = 200
	penetration = 100
	sundering = 0
	accuracy = -10 //Not designed for anti human use
	scatter = 7
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG|AMMO_UNWIELDY

/datum/ammo/rocket/som/heat/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(get_turf(target_obj))
	if(isvehicle(target_obj) || ishitbox(target_obj))
		proj.damage *= 3 //this is specifically designed to hurt vehicles

/datum/ammo/rocket/som/heat/drop_nade(turf/T)
	explosion(T, 0, 1, 0, 0, 1, explosion_cause=src)

/datum/ammo/rocket/som/rad
	name = "irrad RPG"
	icon_state = "rpg_rad"
	hud_state = "rpg_rad"
	damage = 50
	penetration = 10
	///Base strength of the rad effects
	var/rad_strength = 20
	///Range for the maximum rad effects
	var/inner_range = 3
	///Range for the moderate rad effects
	var/mid_range = 5
	///Range for the minimal rad effects
	var/outer_range = 8

/datum/ammo/rocket/som/rad/drop_nade(turf/T)
	playsound(T, 'sound/effects/portal_opening.ogg', 50, 1)
	for(var/mob/living/victim in hearers(outer_range, T))
		var/strength
		var/sound_level
		if(get_dist(victim, T) <= inner_range)
			strength = rad_strength
			sound_level = 4
		else if(get_dist(victim, T) <= mid_range)
			strength = rad_strength * 0.7
			sound_level = 3
		else
			strength = rad_strength * 0.3
			sound_level = 2

		strength = victim.modify_by_armor(strength, BIO, 25)
		victim.apply_radiation(strength, sound_level)

	explosion(T, weak_impact_range = 4, explosion_cause=src)

/datum/ammo/rocket/atgun_shell
	name = "high explosive ballistic cap shell"
	icon_state = "atgun"
	hud_state = "shell_heat"
	hud_state_empty = "shell_empty"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG|AMMO_PASS_THROUGH_TURF
	shell_speed = 2
	damage = 90
	penetration = 30
	sundering = 25
	max_range = 30
	handful_amount = 1

/datum/ammo/rocket/atgun_shell/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 0, 2, explosion_cause=src)

/datum/ammo/rocket/atgun_shell/on_hit_turf(turf/target_turf, atom/movable/projectile/proj) //no explosion every time it hits a turf
	proj.proj_max_range -= 10

/datum/ammo/rocket/atgun_shell/apcr
	name = "tungsten penetrator"
	hud_state = "shell_apcr"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	damage = 200
	penetration = 70
	sundering = 25

/datum/ammo/rocket/atgun_shell/apcr/drop_nade(turf/T)
	explosion(T, flash_range = 1, explosion_cause=src)

/datum/ammo/rocket/atgun_shell/apcr/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/target_turf = get_turf(target_mob)
	staggerstun(target_mob, proj, max_range = 20, stagger = 1 SECONDS, slowdown = 0.5, knockback = 2, hard_size_threshold = 3)
	drop_nade(target_turf)
	proj.proj_max_range -= 5
	shake_camera(target_mob, 0.2 SECONDS, 2)

/datum/ammo/rocket/atgun_shell/apcr/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	proj.proj_max_range -= 5

/datum/ammo/rocket/atgun_shell/apcr/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	proj.proj_max_range -= 5

/datum/ammo/rocket/atgun_shell/he
	name = "low velocity high explosive shell"
	hud_state = "shell_he"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG
	damage = 50
	penetration = 50
	sundering = 35

/datum/ammo/rocket/atgun_shell/he/drop_nade(turf/T)
	explosion(T, 0, 3, 5, explosion_cause=src)

/datum/ammo/rocket/atgun_shell/he/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step(target_turf, proj) : target_turf)

/datum/ammo/rocket/atgun_shell/beehive
	name = "beehive shell"
	hud_state = "shell_le"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG
	shell_speed = 3
	damage = 30
	penetration = 30
	sundering = 5
	bonus_projectiles_type = /datum/ammo/bullet/atgun_spread
	bonus_projectiles_scatter = 8
	var/bonus_projectile_quantity = 10

/datum/ammo/rocket/atgun_shell/beehive/drop_nade(turf/T)
	explosion(T, flash_range = 1, explosion_cause=src)

/datum/ammo/rocket/atgun_shell/beehive/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_mob, proj)
	staggerstun(target_mob, proj, slowdown = 0.2, knockback = 1)
	drop_nade(det_turf)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_mob), loc_override = det_turf)

/datum/ammo/rocket/atgun_shell/beehive/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_obj, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_obj), loc_override = det_turf)

/datum/ammo/rocket/atgun_shell/beehive/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/rocket/atgun_shell/beehive/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	var/turf/det_turf = get_step_towards(target_turf, proj)
	playsound(det_turf, SFX_EXPLOSION_MICRO, 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, Get_Angle(proj.starting_turf, target_turf), loc_override = det_turf)

/datum/ammo/rocket/atgun_shell/beehive/incend
	name = "napalm shell"
	hud_state = "shell_heat"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG
	shell_speed = 3
	bonus_projectiles_type = /datum/ammo/bullet/atgun_spread/incendiary

/datum/ammo/bullet/tank_apfds
	name = "8.8cm APFDS round"
	icon_state = "apfds"
	hud_state = "bigshell_apfds"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_BETTER_COVER_RNG|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	damage = 300
	penetration = 75
	shell_speed = 4
	accurate_range = 24
	max_range = 30
	on_pierce_multiplier = 0.85
	barricade_clear_distance = 4

/datum/ammo/bullet/tank_apfds/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	proj.proj_max_range -= 10

/datum/ammo/bullet/tank_apfds/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	proj.proj_max_range -= 2
	if(ishuman(target_mob) && !(target_mob.status_flags & GODMODE) && prob(35))
		target_mob.gib()
		return
	shake_camera(target_mob, 0.3 SECONDS, 3)


/datum/ammo/bullet/tank_apfds/on_hit_obj(obj/target_object, atom/movable/projectile/proj)
	if(!isvehicle(target_object) && !ishitbox(target_object))
		proj.proj_max_range -= 5
		return
	proj.proj_max_range = 0 //we don't penetrate past a vehicle
	proj.damage *= 2.2

/datum/ammo/rocket/homing
	name = "homing HE rocket"
	damage = 0
	penetration = 0
	max_range = 20
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_BETTER_COVER_RNG|AMMO_SPECIAL_PROCESS
	shell_speed = 0.3
	///If the projectile is pointing at the target with a variance of this number, we don't readjust the angle
	var/angle_precision = 5
	///Number in degrees that the projectile will change during each process
	var/turn_rate = 5

/datum/ammo/rocket/homing/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 4, 1, explosion_cause=src)

/datum/ammo/rocket/homing/ammo_process(atom/movable/projectile/proj, damage)
	if(QDELETED(proj.original_target))
		return
	var/angle_to_target = Get_Angle(get_turf(proj), get_turf(proj.original_target)) //angle uses pixel offsets so we check turfs instead
	if((proj.dir_angle >= angle_to_target - angle_precision) && (proj.dir_angle <= angle_to_target + angle_precision))
		return
	proj.dir_angle = clamp(angle_to_target, proj.dir_angle - turn_rate, proj.dir_angle + turn_rate)
	proj.x_offset = round(sin(proj.dir_angle), 0.01)
	proj.y_offset = round(cos(proj.dir_angle), 0.01)
	var/matrix/rotate = matrix()
	rotate.Turn(proj.dir_angle)
	animate(proj, transform = rotate, time = SSprojectiles.wait)

/datum/ammo/rocket/homing/microrocket /// this is basically a tgmc version of the above
	name = "homing HE microrocket"
	shell_speed = 0.3
	damage = 75
	penetration = 40
	sundering = 5
	turn_rate = 10

/datum/ammo/rocket/homing/microrocket/drop_nade(turf/T)
	explosion(T, 0, 0, 0, 4, 1, explosion_cause=src)

/datum/ammo/rocket/homing/microrocket/mech
	name = "homing mech HE microrocket"
	shell_speed = 0.4
	damage = 5
	penetration = 20
	sundering = 3
	turn_rate = 10

/datum/ammo/rocket/homing/microrocket/mech/drop_nade(turf/T)
	explosion(T, 0, 0, 0, 2, 1, explosion_cause=src)

/datum/ammo/rocket/homing/tow
	name = "TOW-III missile"
	icon_state = "rocket_he"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_SPECIAL_PROCESS|AMMO_IFF
	shell_speed = 0.3
	turn_rate = 10
	damage = 60
	penetration = 30
	sundering = 10
	max_range = 30

/datum/ammo/rocket/homing/tow/drop_nade(turf/T)
	explosion(T, 0, 0, 4, 0, 2, explosion_cause=src)

/datum/ammo/rocket/coilgun
	name = "kinetic penetrator"
	icon_state = "tank_coilgun"
	hud_state = "rocket_ap"
	hud_state_empty = "rocket_empty"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	armor_type = BULLET
	damage_falloff = 2
	shell_speed = 3
	accuracy = 10
	accurate_range = 20
	max_range = 40
	damage = 300
	penetration = 50
	sundering = 10
	bullet_color = LIGHT_COLOR_TUNGSTEN
	barricade_clear_distance = 4

/datum/ammo/rocket/coilgun/drop_nade(turf/T)
	explosion(T, 0, 3, 5, 0, 2, explosion_cause=src)

/datum/ammo/rocket/coilgun/holder //only used for tankside effect checks
	ammo_behavior_flags = AMMO_ENERGY

/datum/ammo/rocket/coilgun/low
	shell_speed = 2
	damage = 150
	penetration = 40
	sundering = 5

/datum/ammo/rocket/coilgun/low/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 4, explosion_cause=src)

/datum/ammo/rocket/coilgun/high
	damage_falloff = 0
	shell_speed = 4
	damage = 450
	penetration = 70
	sundering = 20
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG|AMMO_PASS_THROUGH_MOB

/datum/ammo/rocket/coilgun/high/drop_nade(turf/T)
	explosion(T, 1, 4, 5, 6, 2, explosion_cause=src)

/datum/ammo/rocket/coilgun/high/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	if(ishuman(target_mob) && prob(50)) //it only has AMMO_PASS_THROUGH_MOB so it can keep going if it gibs a mob
		if(!(target_mob.status_flags & GODMODE))
			target_mob.gib()
		proj.proj_max_range -= 5
		return
	proj.proj_max_range = 0
	staggerstun(target_mob, proj, max_range, knockback = 1, hard_size_threshold = 3)

/datum/ammo/rocket/icc_lowvel_heat
	name = "Low Velocity HEAT shell"
	icon_state = "recoilless_rifle_heat"
	hud_state = "shell_heat"
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG
	shell_speed = 1
	damage = 180
	penetration = 100
	sundering = 0

/datum/ammo/rocket/icc_lowvel_heat/drop_nade(turf/T)
	explosion(T, flash_range = 1, explosion_cause=src)

/datum/ammo/rocket/icc_lowvel_high_explosive
	name = "Low Velocity HE shell"
	damage = 50
	penetration = 100
	sundering = 10
	ammo_behavior_flags = AMMO_BETTER_COVER_RNG // We want this to specifically go over onscreen range.
	shell_speed = 1

/datum/ammo/rocket/icc_lowvel_high_explosive/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 0, 2, explosion_cause=src)
