/*
//================================================
					Turret Ammo
//================================================
*/

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	icon_state = "bullet_red"
	bullet_color = COLOR_SOFT_RED
	hud_state = "rifle"
	hud_state_empty = "rifle_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 10
	damage = 25
	penetration = 20
	damage_falloff = 0.25

/datum/ammo/bullet/turret/dumb
	icon_state = "bullet"

/datum/ammo/bullet/turret/gauss
	name = "heavy gauss turret slug"
	hud_state = "rifle_heavy"
	damage = 60

/datum/ammo/bullet/turret/mini
	name = "small caliber autocannon bullet"
	damage = 20
	penetration = 20
	ammo_behavior_flags = AMMO_BALLISTIC


/datum/ammo/bullet/turret/sniper
	name = "antimaterial bullet"
	icon_state = "bullet_large_red"
	bullet_color = COLOR_SOFT_RED
	ammo_behavior_flags = AMMO_SNIPER
	accurate_range = 21
	damage = 80
	penetration = 50
	sundering = 5

/datum/ammo/bullet/turret/buckshot
	name = "turret buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/turret/spread
	bonus_projectiles_amount = 6
	bonus_projectiles_scatter = 5
	max_range = 10
	damage = 20
	penetration = 40
	damage_falloff = 1

/datum/ammo/bullet/turret/buckshot/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, knockback = 1, max_range = 4)

/datum/ammo/bullet/turret/spread
	name = "additional buckshot"
	max_range = 10
	damage = 20
	penetration = 40
	damage_falloff = 1

/datum/ammo/flamer
	name = "flame turret glob"
	icon_state = "pulse0"
	hud_state = "flame"
	hud_state_empty = "flame_empty"
	damage_type = BURN
	ammo_behavior_flags = AMMO_INCENDIARY|AMMO_FLAME
	armor_type = FIRE
	damage = 30
	max_range = 7
	bullet_color = LIGHT_COLOR_FIRE

/datum/ammo/flamer/drop_nade(turf/T)
	flame_radius(2, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)


/datum/ammo/flamer/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	drop_nade(get_turf(target_mob))

/datum/ammo/flamer/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	drop_nade(target_obj.density ? get_step_towards(target_obj, proj) : target_obj.loc)

/datum/ammo/flamer/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)

/datum/ammo/flamer/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	drop_nade(target_turf.density ? get_step_towards(target_turf, proj) : target_turf)
