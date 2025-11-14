/*
//================================================
					Revolver Ammo
//================================================
*/

/datum/ammo/bullet/revolver
	name = "revolver bullet"
	hud_state = "revolver"
	hud_state_empty = "revolver_empty"
	handful_amount = 7
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 45
	penetration = 10
	sundering = 3

/datum/ammo/bullet/revolver/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, stagger = 2 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/revolver/tp44
	name = "standard revolver bullet"
	damage = 40
	penetration = 15
	sundering = 1

/datum/ammo/bullet/revolver/tp44/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, knockback = 1)

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"
	hud_state = "revolver_small"
	damage = 30

/datum/ammo/bullet/revolver/small/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5)

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	damage = 30
	penetration = 10

/datum/ammo/bullet/revolver/judge
	name = "oversized revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	damage = 70
	penetration = 10

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	hud_state = "revolver_heavy"
	damage = 50
	penetration = 5
	accuracy = -10

/datum/ammo/bullet/revolver/heavy/incen
	name = "incendiary heavy revolver bullet"
	ammo_behavior_flags = AMMO_INCENDIARY|AMMO_BALLISTIC


/datum/ammo/bullet/revolver/t76
	name = "magnum bullet"
	handful_amount = 5
	damage = 100
	penetration = 40
	sundering = 0.5

/datum/ammo/bullet/revolver/t76/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, knockback = 1)

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	hud_state = "revolver_impact"
	handful_amount = 6
	damage = 50
	penetration = 20
	sundering = 3

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 2 SECONDS, slowdown = 1, knockback = 1)

/datum/ammo/bullet/revolver/ricochet
	bonus_projectiles_type = /datum/ammo/bullet/revolver/small
	bonus_projectiles_scatter = 0

/datum/ammo/bullet/revolver/ricochet/one
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet

/datum/ammo/bullet/revolver/ricochet/two
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/one

/datum/ammo/bullet/revolver/ricochet/three
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/two

/datum/ammo/bullet/revolver/ricochet/four
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/three

/datum/ammo/bullet/revolver/ricochet/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5)

/datum/ammo/bullet/revolver/ricochet/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	reflect(target_turf, proj, 10)
