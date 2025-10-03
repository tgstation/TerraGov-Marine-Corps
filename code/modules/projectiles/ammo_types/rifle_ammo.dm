/*
//================================================
					Rifle Ammo
//================================================
*/

/datum/ammo/bullet/rifle
	name = "rifle bullet"
	hud_state = "rifle"
	hud_state_empty = "rifle_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 12
	damage = 25
	penetration = 5
	sundering = 0.5

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"
	hud_state = "rifle_ap"
	damage = 20
	penetration = 25
	sundering = 3

/datum/ammo/bullet/rifle/hv
	name = "high-velocity rifle bullet"
	hud_state = "hivelo"
	damage = 20
	penetration = 20
	sundering = 0.5

/datum/ammo/bullet/rifle/heavy
	name = "heavy rifle bullet"
	hud_state = "rifle_heavy"
	damage = 30
	penetration = 10
	sundering = 1.25

/datum/ammo/bullet/rifle/heavy/ap
	name = "heavy armor-piercing rifle bullet"
	hud_state = "rifle_ap"
	damage = 25
	penetration = 30
	sundering = 4.5

/datum/ammo/bullet/rifle/repeater
	name = "heavy impact rifle bullet"
	hud_state = "sniper"
	damage = 70
	penetration = 20
	sundering = 1.25

/datum/ammo/bullet/rifle/repeater/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 3, slowdown = 2, stagger = 1 SECONDS)

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	hud_state = "rifle_fire"
	damage_type = BURN
	shrapnel_chance = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	accuracy = -10

/datum/ammo/bullet/rifle/machinegun
	name = "machinegun bullet"
	hud_state = "rifle_heavy"
	damage = 25
	penetration = 10
	sundering = 0.75

/datum/ammo/bullet/rifle/som_machinegun
	name = "machinegun bullet"
	hud_state = "rifle_heavy"
	damage = 28
	penetration = 12.5
	sundering = 1

/datum/ammo/bullet/rifle/som_machinegun/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 20, slowdown = 0.5)

/datum/ammo/bullet/rifle/som_big
	name = "heavy rifle bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0.5
	accurate_range = 18
	max_range = 30
	damage = 60
	penetration = 20
	sundering = 2

/datum/ammo/bullet/rifle/som_big/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 9, slowdown = 0.75)

/datum/ammo/bullet/rifle/som_big/incendiary
	name = "heavy incendiary bullet"
	hud_state = "hivelo_fire"
	damage = 40
	penetration = 10
	sundering = 1
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	bullet_color = LIGHT_COLOR_FIRE

/datum/ammo/bullet/rifle/som_big/incendiary/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

/datum/ammo/bullet/rifle/som_big/anti_armour
	name = "heavy AT bullet"
	hud_state = "hivelo_impact"
	damage = 40
	penetration = 45
	sundering = 8
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOVABLE
	bullet_color = LIGHT_COLOR_BLUE
	on_pierce_multiplier = 0.8

/datum/ammo/bullet/rifle/som_big/anti_armour/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 9, slowdown = 1, stagger = 0.5 SECONDS)
	proj.proj_max_range = 0

/datum/ammo/bullet/rifle/som_big/anti_armour/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	if(!isvehicle(target_obj))
		proj.proj_max_range -= 20 //can shoot through 1 piece of cover
		return
	proj.damage *= 2
	proj.proj_max_range = 0

/datum/ammo/bullet/rifle/tx8
	name = "A19 high velocity bullet"
	icon_state = "bullet_red"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 15
	damage = 40
	penetration = 30
	sundering = 5
	bullet_color = COLOR_SOFT_RED

/datum/ammo/bullet/rifle/tx8/incendiary
	name = "high velocity incendiary bullet"
	hud_state = "hivelo_fire"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_PASS_THROUGH_MOB
	damage = 25
	penetration = 20
	sundering = 2.5
	bullet_color = LIGHT_COLOR_FIRE

/datum/ammo/bullet/rifle/tx8/impact
	name = "high velocity impact bullet"
	hud_state = "hivelo_impact"
	damage = 30
	penetration = 20
	sundering = 6.5

/datum/ammo/bullet/rifle/tx8/impact/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 14, slowdown = 1, knockback = 1)

/datum/ammo/bullet/rifle/mpi_km
	name = "crude heavy rifle bullet"
	hud_state = "rifle_crude"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 30
	penetration = 15
	sundering = 1.75

/datum/ammo/bullet/rifle/standard_dmr
	name = "marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0.5
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER
	accurate_range = 25
	max_range = 40
	damage = 65
	penetration = 17.5
	sundering = 2

/datum/ammo/bullet/rifle/garand
	name = "heavy marksman bullet"
	hud_state = "sniper"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER
	damage = 75
	penetration = 25
	sundering = 1.25

/datum/ammo/bullet/rifle/standard_br
	name = "light marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	penetration = 15
	damage = 32.5
	sundering = 1.25

/datum/ammo/bullet/rifle/icc_confrontationrifle
	name = "armor-piercing heavy rifle bullet"
	hud_state = "rifle_ap"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_SNIPER
	damage = 50
	penetration = 40
	sundering = 3.5
