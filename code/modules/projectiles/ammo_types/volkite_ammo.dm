/*
//================================================
					Volkite Ammo
//================================================
*/

/datum/ammo/energy/volkite
	name = "thermal energy bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_heat"
	hud_state_empty = "battery_empty_flash"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SOUND_PITCH
	bullet_color = COLOR_TAN_ORANGE
	armor_type = ENERGY
	max_range = 14
	accurate_range = 5 //for charger
	shell_speed = 4
	accuracy_variation = 5
	accuracy = 5
	point_blank_range = 2
	damage = 20
	penetration = 10
	sundering = 2
	fire_burst_damage = 15
	deflagrate_multiplier = 1

	//inherited, could use some changes
	ping = "ping_s"
	sound_hit = SFX_ENERGY_HIT
	sound_armor = SFX_BALLISTIC_ARMOR
	sound_miss = SFX_BALLISTIC_MISS
	sound_bounce = SFX_BALLISTIC_BOUNCE

/datum/ammo/energy/volkite/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	deflagrate(target_mob, proj)

/datum/ammo/energy/volkite/medium
	max_range = 25
	accurate_range = 12
	damage = 30
	accuracy_variation = 3
	fire_burst_damage = 20
	deflagrate_multiplier = 0.9

/datum/ammo/energy/volkite/medium/custom
	deflagrate_multiplier = 1.8

/datum/ammo/energy/volkite/heavy
	max_range = 35
	accurate_range = 12
	damage = 25
	fire_burst_damage = 20
	deflagrate_multiplier = 0.9

/datum/ammo/energy/volkite/light
	max_range = 25
	accurate_range = 12
	accuracy_variation = 3
	penetration = 5
	deflagrate_multiplier = 0.9

/datum/ammo/energy/volkite/demi_culverin
	max_range = 18
	accurate_range = 7
	damage = 15
	fire_burst_damage = 15
