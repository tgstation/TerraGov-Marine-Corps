/*
//================================================
					Mortar Ammo
//================================================
*/

/datum/ammo/mortar
	name = "80mm shell"
	icon_state = "mortar"
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 0.75
	damage = 0
	penetration = 0
	sundering = 0
	accuracy = 1000
	max_range = 1000
	ping = null
	bullet_color = COLOR_VERY_SOFT_YELLOW

/datum/ammo/mortar/drop_nade(turf/T)
	explosion(T, 1, 2, 5, 0, 3, explosion_cause=src)

/datum/ammo/mortar/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf)

/datum/ammo/mortar/incend/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 0, 7, throw_range = 0, explosion_cause=src)
	flame_radius(4, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/smoke
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/mortar/smoke/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 1, 0, 0, throw_range = 0, explosion_cause=src)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, T, 11)
	smoke.start()

/datum/ammo/mortar/smoke/plasmaloss
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/flare/drop_nade(turf/T)
	new /obj/effect/temp_visual/above_flare(T)
	playsound(T, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4)

/datum/ammo/mortar/howi
	name = "150mm shell"
	icon_state = "howi"

/datum/ammo/mortar/howi/drop_nade(turf/T)
	explosion(T, 1, 6, 7, 0, 12, explosion_cause=src)

/datum/ammo/mortar/howi/incend/drop_nade(turf/T)
	explosion(T, 0, 3, 0, 0, 0, 3, throw_range = 0, explosion_cause=src)
	flame_radius(5, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/smoke/howi
	name = "150mm shell"
	icon_state = "howi"

/datum/ammo/mortar/smoke/howi/wp
	smoketype = /datum/effect_system/smoke_spread/phosphorus

/datum/ammo/mortar/smoke/howi/wp/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 1, 0, 0, throw_range = 0, explosion_cause=src)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, T, 7)
	smoke.start()
	flame_radius(4, T)
	flame_radius(1, T, burn_intensity = 75, burn_duration = 45, burn_damage = 15, fire_stacks = 75)

/datum/ammo/mortar/smoke/howi/plasmaloss
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/smoke/howi/plasmaloss/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 5, 0, 0, throw_range = 0, explosion_cause=src)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, T, 11)
	smoke.start()

/datum/ammo/mortar/rocket
	name = "rocket"
	icon_state = "rocket"
	shell_speed = 1.5

/datum/ammo/mortar/rocket/drop_nade(turf/T)
	explosion(T, 1, 2, 5, 0, 3, explosion_cause=src)

/datum/ammo/mortar/rocket/incend/drop_nade(turf/T)
	explosion(T, 0, 3, 0, 0, 3, throw_range = 0, explosion_cause=src)
	flame_radius(5, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/rocket/minelayer/drop_nade(turf/T)
	var/obj/item/explosive/mine/mine = new /obj/item/explosive/mine(T)
	mine.deploy_mine(null, TGMC_LOYALIST_IFF)

/datum/ammo/mortar/rocket/smoke
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/mortar/rocket/smoke/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 1, 0, 3, throw_range = 0, explosion_cause=src)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, T, 11)
	smoke.start()

/datum/ammo/mortar/rocket/mlrs
	shell_speed = 2.5

/datum/ammo/mortar/rocket/mlrs/drop_nade(turf/T)
	explosion(T, 0, 0, 4, 0, 2, explosion_cause=src)

/datum/ammo/mortar/rocket/mlrs/incendiary/drop_nade(turf/T)
	explosion(T, 0, 0, 2, 0, 2, explosion_cause=src)
	flame_radius(3, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/rocket/smoke/mlrs
	shell_speed = 2.5
	smoketype = /datum/effect_system/smoke_spread/mustard

/datum/ammo/mortar/rocket/smoke/mlrs/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 2, 0, 0, throw_range = 0, explosion_cause=src)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(5, T, 6)
	smoke.start()

/datum/ammo/mortar/rocket/smoke/mlrs/cloak
	smoketype = /datum/effect_system/smoke_spread/tactical
