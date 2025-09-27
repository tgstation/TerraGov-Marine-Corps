/*
//================================================
					Mech/mech-related Ammo

	Most of these are just based off existing
	ammo types.
//================================================
*/

/datum/ammo/tx54/mech
	name = "30mm fragmentation grenade"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/mech
	damage = 15
	penetration = 10
	projectile_greyscale_colors = "#4f0303"

/datum/ammo/bullet/tx54_spread/mech
	damage = 15
	penetration = 10
	sundering = 0.5

/datum/ammo/bullet/tx54_spread/mech/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, max_range = 3, slowdown = 0.2)

/*
//================================================
					Mech/mech-related Rockets
//================================================
*/
/datum/ammo/rocket/mech
	name = "large light explosive rocket"
	damage = 10
	penetration = 15
	max_range = 30
	sundering = 15

/datum/ammo/rocket/mech/drop_nade(turf/T)
	explosion(T, 0, 0, 4, 0, 0, explosion_cause=src)

/datum/ammo/rocket/mech/heavy
	name = "large heavy explosive rocket"
	damage = 30
	penetration = 30

/datum/ammo/rocket/mech/heavy/drop_nade(turf/T)
	explosion(T, 0, 2, 4, 0, 0, explosion_cause=src)

/*
//================================================
					Mech/mech-related Bullets
//================================================
*/

/datum/ammo/bullet/minigun/mech
	name = "vulcan bullet"
	damage = 30
	penetration = 10
	sundering = 0.5

/datum/ammo/bullet/sniper/mech
	name = "light anti-tank bullet"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_BETTER_COVER_RNG|AMMO_SNIPER
	damage = 100
	penetration = 35
	sundering = 0
	damage_falloff = 0.3

/datum/ammo/bullet/pistol/mech
	name = "super-heavy pistol bullet"
	hud_state = "pistol_superheavy"
	damage = 45
	penetration = 20
	sundering = 1

/datum/ammo/bullet/pistol/mech/burst
	name = "super-heavy pistol bullet"
	damage = 35
	penetration = 10
	sundering = 0.5
	damage_falloff = 0.4

/datum/ammo/bullet/rifle/mech
	name = "super-heavy rifle bullet"
	damage = 35
	penetration = 10
	sundering = 1
	damage_falloff = 0.2

/datum/ammo/bullet/rifle/mech/burst
	damage = 35
	penetration = 10

/datum/ammo/bullet/rifle/mech/lmg
	damage = 20
	penetration = 20
	damage_falloff = 0.7

/datum/ammo/bullet/smg/mech
	name = "super-heavy submachinegun bullet"
	damage = 25
	sundering = 0.5
	penetration = 5
	damage_falloff = 0.4

/datum/ammo/bullet/shotgun/mech
	name = "super-heavy shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/mech/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 5
	accuracy_variation = 10
	max_range = 10
	sundering = 5
	penetration = 15
	damage = 75
	damage_falloff = 4

/datum/ammo/bullet/shotgun/mech/spread
	name = "super-heavy additional buckshot"
	icon_state = "buckshot"
	max_range = 10
	damage = 60
	sundering = 2.5
	penetration = 15
	damage_falloff = 8

/datum/ammo/bullet/shotgun/mech/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	staggerstun(target_mob, proj, paralyze = 2 SECONDS, stagger = 2 SECONDS, knockback = 2, slowdown = 0.5, max_range = 3)

/datum/ammo/energy/lasgun/marine/mech
	name = "superheated laser bolt"
	damage = 45
	penetration = 20
	sundering = 1
	damage_falloff = 0.5

/datum/ammo/energy/lasgun/marine/mech/burst
	damage = 30
	penetration = 10
	sundering = 0.75
	damage_falloff = 0.6

/datum/ammo/energy/lasgun/marine/mech/smg
	name = "superheated pulsed laser bolt"
	damage = 15
	penetration = 10
	hitscan_effect_icon = "beam_particle"

/datum/ammo/energy/lasgun/marine/mech/lance_strike
	name = "particle lance"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_BETTER_COVER_RNG|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOVABLE|AMMO_PASS_THROUGH_MOB
	damage_type = BRUTE
	damage = 100
	armor_type = MELEE
	penetration = 25
	sundering = 8
	damage_falloff = -12.5 //damage increases per turf crossed
	max_range = 4
	on_pierce_multiplier = 0.5
	hitscan_effect_icon = "lance"

/datum/ammo/energy/lasgun/marine/mech/lance_strike/super
	damage = 120
	damage_falloff = -8
	max_range = 5
