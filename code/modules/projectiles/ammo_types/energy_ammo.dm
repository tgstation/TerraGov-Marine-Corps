/*
//================================================
					Energy Ammo
//================================================
*/

/datum/ammo/energy
	ping = "ping_s"
	sound_hit 	 = "energy_hit"
	sound_armor = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"

	damage_type = BURN
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SOUND_PITCH
	armor_type = ENERGY
	accuracy = 15 //lasers fly fairly straight
	bullet_color = COLOR_LASER_RED
	barricade_clear_distance = 2

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	ammo_behavior_flags = AMMO_ENERGY
	accurate_range = 10
	max_range = 10
	bullet_color = COLOR_VIBRANT_LIME

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	hud_state = "taser"
	hud_state_empty = "battery_empty"
	damage = 10
	penetration = 100
	damage_type = STAMINA
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SKIPS_ALIENS
	max_range = 15
	accurate_range = 10
	bullet_color = COLOR_VIVID_YELLOW

/datum/ammo/energy/taser/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stun = 20 SECONDS)

/datum/ammo/energy/tesla
	name = "energy ball"
	icon_state = "tesla"
	hud_state = "taser"
	hud_state_empty = "battery_empty"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SPECIAL_PROCESS
	shell_speed = 0.1
	damage = 20
	penetration = 20
	bullet_color = COLOR_TESLA_BLUE

/datum/ammo/energy/tesla/ammo_process(obj/projectile/proj, damage)
	zap_beam(proj, 4, damage)

/datum/ammo/energy/tesla/focused
	ammo_behavior_flags = AMMO_ENERGY|AMMO_SPECIAL_PROCESS|AMMO_IFF
	shell_speed = 0.1
	damage = 10
	penetration = 10
	bullet_color = COLOR_TESLA_BLUE

/datum/ammo/energy/tesla/focused/ammo_process(obj/projectile/proj, damage)
	zap_beam(proj, 3, damage)


/datum/ammo/energy/tesla/on_hit_mob(mob/M,obj/projectile/P)
	if(isxeno(M)) //need 1 second more than the actual effect time
		var/mob/living/carbon/xenomorph/X = M
		X.use_plasma(0.3 * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit) //Drains 30% of max plasma on hit

/datum/ammo/energy/lasburster
	name = "lasburster bolt"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN
	hud_state = "laser_overcharge"
	armor_type = LASER
	damage = 40
	penetration = 5
	max_range = 7
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun
	name = "laser bolt"
	icon_state = "laser"
	hud_state = "laser"
	armor_type = LASER
	ammo_behavior_flags = AMMO_ENERGY
	shell_speed = 4
	accurate_range = 15
	damage = 20
	penetration = 10
	max_range = 30
	accuracy_var_low = 3
	accuracy_var_high = 3
	sundering = 2.5

/datum/ammo/energy/lasgun/M43
	icon_state = "laser2"

/datum/ammo/energy/lasgun/M43/overcharge
	name = "overcharged laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 40
	max_range = 40
	penetration = 50
	sundering = 5

/datum/ammo/energy/lasgun/M43/heat
	name = "microwave heat bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 12 //requires mod with -0.15 multiplier should math out to 10
	penetration = 100 // It's a laser that burns the skin! The fire stacks go threw anyway.
	ammo_behavior_flags = AMMO_ENERGY|AMMO_INCENDIARY
	sundering = 1

/datum/ammo/energy/lasgun/M43/blast
	name = "wide range laser blast"
	icon_state = "heavylaser2"
	hud_state = "laser_spread"
	bonus_projectiles_type = /datum/ammo/energy/lasgun/M43/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 10
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 5
	max_range = 5
	damage = 42
	damage_falloff = 10
	penetration = 0
	sundering = 5

/datum/ammo/energy/lasgun/M43/spread
	name = "additional laser blast"
	icon_state = "laser2"
	shell_speed = 2
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 5
	max_range = 5
	damage = 35
	damage_falloff = 10
	penetration = 0

/datum/ammo/energy/lasgun/M43/disabler
	name = "disabler bolt"
	icon_state = "disablershot"
	hud_state = "laser_disabler"
	damage = 45
	penetration = 0
	damage_type = STAMINA
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/M43/disabler/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1 SECONDS, slowdown = 0.75)

/datum/ammo/energy/lasgun/pulsebolt
	name = "pulse bolt"
	icon_state = "pulse2"
	hud_state = "pulse"
	damage = 45 // this is gotta hurt...
	max_range = 40
	penetration = 100
	sundering = 100
	bullet_color = COLOR_PULSE_BLUE

/datum/ammo/energy/lasgun/M43/practice
	name = "practice laser bolt"
	icon_state = "disablershot"
	hud_state = "laser_disabler"
	damage = 45
	penetration = 0
	damage_type = STAMINA
	ammo_behavior_flags = AMMO_ENERGY
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/M43/practice/on_hit_mob(mob/living/carbon/C, obj/projectile/P)
	if(!istype(C) || C.stat == DEAD || C.issamexenohive(P.firer) )
		return

	if(isnestedhost(C))
		return

	staggerstun(C, P, stagger = 2 SECONDS, slowdown = 1) //Staggers and slows down briefly

	return ..()

// TE Lasers //

/datum/ammo/energy/lasgun/marine
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN
	damage = 20
	penetration = 10
	sundering = 1.5
	max_range = 30
	hitscan_effect_icon = "beam"

/datum/ammo/energy/lasgun/marine/carbine
	sundering = 1
	max_range = 18

/datum/ammo/energy/lasgun/marine/overcharge
	name = "overcharged laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 40
	penetration = 20
	sundering = 2
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun/marine/weakening
	name = "weakening laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 30
	penetration = 10
	sundering = 0
	damage_type = STAMINA
	hitscan_effect_icon = "blue_beam"
	bullet_color = COLOR_DISABLER_BLUE
	///plasma drained per hit
	var/plasma_drain = 25

/datum/ammo/energy/lasgun/marine/weakening/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 6, slowdown = 1)

	if(!isxeno(M))
		return
	var/mob/living/carbon/xenomorph/xeno_victim = M
	xeno_victim.use_plasma(plasma_drain * xeno_victim.xeno_caste.plasma_regen_limit)

/datum/ammo/energy/lasgun/marine/microwave
	name = "microwave laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 20
	penetration = 20
	sundering = 2
	hitscan_effect_icon = "beam_grass"
	bullet_color = LIGHT_COLOR_GREEN
	///number of microwave stacks to apply when hitting mobvs
	var/microwave_stacks = 1

/datum/ammo/energy/lasgun/marine/microwave/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	var/datum/status_effect/stacking/microwave/debuff = living_victim.has_status_effect(STATUS_EFFECT_MICROWAVE)

	if(debuff)
		debuff.add_stacks(microwave_stacks)
	else
		living_victim.apply_status_effect(STATUS_EFFECT_MICROWAVE, microwave_stacks)

/datum/ammo/energy/lasgun/marine/blast
	name = "wide range laser blast"
	icon_state = "heavylaser2"
	hud_state = "laser_spread"
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/blast/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 10
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 8
	damage = 35
	damage_falloff = 8
	penetration = 20
	sundering = 1
	hitscan_effect_icon = "pu_laser"
	bullet_color = LIGHT_COLOR_PURPLE

/datum/ammo/energy/lasgun/marine/blast/spread
	name = "additional laser blast"

/datum/ammo/energy/lasgun/marine/impact
	name = "impact laser blast"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 35
	penetration = 10
	sundering = 0
	hitscan_effect_icon = "pu_laser"
	bullet_color = LIGHT_COLOR_PURPLE

/datum/ammo/energy/lasgun/marine/impact/on_hit_mob(mob/M, obj/projectile/proj)
	var/knockback_dist = round(LERP(3, 1, proj.distance_travelled / 6), 1)
	staggerstun(M, proj, max_range = 6, knockback = knockback_dist)

/datum/ammo/energy/lasgun/marine/cripple
	name = "impact laser blast"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 20
	penetration = 10
	sundering = 0
	hitscan_effect_icon = "blue_beam"
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/cripple/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, slowdown = 1.5)

/datum/ammo/energy/lasgun/marine/autolaser
	name = "machine laser bolt"
	damage = 18
	penetration = 15
	sundering = 1

/datum/ammo/energy/lasgun/marine/autolaser/burst
	name = "burst machine laser bolt"
	hud_state = "laser_efficiency"
	damage = 12

/datum/ammo/energy/lasgun/marine/autolaser/charge
	name = "charged machine laser bolt"
	hud_state = "laser_efficiency"
	damage = 50
	penetration = 30
	sundering = 3
	hitscan_effect_icon = "beam_heavy"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOB

/datum/ammo/energy/lasgun/marine/autolaser/charge/on_hit_turf(turf/T, obj/projectile/proj)
	if(istype(T, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = T
		wall_victim.take_damage(proj.damage, proj.damtype, proj.armor_type)

/datum/ammo/energy/lasgun/marine/autolaser/melting
	name = "melting machine laser bolt"
	hud_state = "laser_efficiency"
	damage = 15
	penetration = 20
	sundering = 0
	hitscan_effect_icon = "beam_solar"
	bullet_color = LIGHT_COLOR_YELLOW
	///number of melting stacks to apply when hitting mobs
	var/melt_stacks = 2

/datum/ammo/energy/lasgun/marine/autolaser/melting/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	var/datum/status_effect/stacking/melting/debuff = living_victim.has_status_effect(STATUS_EFFECT_MELTING)

	if(debuff)
		debuff.add_stacks(melt_stacks)
	else
		living_victim.apply_status_effect(STATUS_EFFECT_MELTING, melt_stacks)

/datum/ammo/energy/lasgun/marine/sniper
	name = "sniper laser bolt"
	hud_state = "laser_sniper"
	damage = 60
	penetration = 30
	accurate_range_min = 5
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 5
	max_range = 40
	damage_falloff = 0
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun/marine/sniper_heat
	name = "sniper heat bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 40
	penetration = 10
	accurate_range_min = 5
	ammo_behavior_flags = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 1
	hitscan_effect_icon = "u_laser_beam"
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/shatter
	name = "sniper shattering bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 40
	penetration = 30
	accurate_range_min = 5
	sundering = 10
	hitscan_effect_icon = "pu_laser"
	bullet_color = LIGHT_COLOR_PURPLE
	///shatter effection duration when hitting mobs
	var/shatter_duration = 5 SECONDS

/datum/ammo/energy/lasgun/marine/shatter/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)

/datum/ammo/energy/lasgun/marine/shatter/heavy_laser
	sundering = 1
	accurate_range_min = 0

/datum/ammo/energy/lasgun/marine/ricochet
	name = "sniper laser bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 100
	penetration = 30
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 1
	hitscan_effect_icon = "u_laser_beam"
	bonus_projectiles_scatter = 0
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/ricochet/one
	damage = 80
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet

/datum/ammo/energy/lasgun/marine/ricochet/two
	damage = 65
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet/one

/datum/ammo/energy/lasgun/marine/ricochet/three
	damage = 50
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet/two

/datum/ammo/energy/lasgun/marine/ricochet/four
	damage = 40
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet/three

/datum/ammo/energy/lasgun/marine/ricochet/on_hit_turf(turf/T, obj/projectile/proj)
	reflect(T, proj, 5)

/datum/ammo/energy/lasgun/marine/ricochet/on_hit_obj(obj/O, obj/projectile/proj)
	reflect(get_turf(O), proj, 5)

/datum/ammo/energy/lasgun/marine/pistol
	name = "pistol laser bolt"
	damage = 20
	penetration = 5
	sundering = 1
	hitscan_effect_icon = "beam_particle"
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/pistol/disabler
	name = "disabler bolt"
	icon_state = "disablershot"
	hud_state = "laser_disabler"
	damage = 70
	penetration = 0
	damage_type = STAMINA
	hitscan_effect_icon = "beam_stun"
	bullet_color = LIGHT_COLOR_YELLOW

/datum/ammo/energy/lasgun/marine/pistol/heat
	name = "microwave heat bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 20
	shell_speed = 2.5
	penetration = 10
	ammo_behavior_flags = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_HITSCAN
	sundering = 0.5
	hitscan_effect_icon = "beam_incen"
	bullet_color = COLOR_LASER_RED

/datum/ammo/energy/lasgun/pistol/disabler/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1 SECONDS, slowdown = 0.75)

/datum/ammo/energy/lasgun/marine/xray
	name = "xray heat bolt"
	hud_state = "laser_xray"
	icon_state = "u_laser"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_HITSCAN
	damage = 25
	penetration = 5
	sundering = 1
	max_range = 15
	hitscan_effect_icon = "u_laser_beam"

/datum/ammo/energy/lasgun/marine/xray/piercing
	name = "xray piercing bolt"
	icon_state = "xray"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_HITSCAN|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	damage = 25
	penetration = 100
	max_range = 10
	hitscan_effect_icon = "xray_beam"

/datum/ammo/energy/lasgun/marine/heavy_laser
	ammo_behavior_flags = AMMO_TARGET_TURF|AMMO_SNIPER|AMMO_ENERGY|AMMO_HITSCAN|AMMO_INCENDIARY
	hud_state = "laser_overcharge"
	damage = 60
	penetration = 10
	sundering = 1
	max_range = 30
	hitscan_effect_icon = "beam_incen"

/datum/ammo/energy/lasgun/marine/heavy_laser/drop_nade(turf/T, radius = 1)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(radius, T, 3, 3, 3, 3)

/datum/ammo/energy/lasgun/marine/heavy_laser/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/energy/lasgun/marine/heavy_laser/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? get_step_towards(O, P) : O, P)

/datum/ammo/energy/lasgun/marine/heavy_laser/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T)

/datum/ammo/energy/lasgun/marine/heavy_laser/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T)

/datum/ammo/energy/plasma
	name = "superheated plasma"
	icon_state = "plasma_small"
	hud_state = "plasma"
	hud_state_empty = "battery_empty"
	armor_type = ENERGY
	bullet_color = COLOR_DISABLER_BLUE
	ammo_behavior_flags = AMMO_ENERGY
	shell_speed = 3

/datum/ammo/energy/plasma/rifle_standard
	damage = 25
	penetration = 20
	sundering = 0.75

/datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_big"
	hud_state = "plasma_blast"
	ammo_behavior_flags = AMMO_ENERGY|AMMO_PASS_THROUGH_MOB
	damage = 40
	penetration = 30
	sundering = 2
	damage_falloff = 0.5
	accurate_range = 25

/datum/ammo/energy/plasma/rifle_marksman/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return
	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, 2 SECONDS)

/datum/ammo/energy/plasma/blast
	name = "plasma blast"
	icon_state = "plasma_ball_small"
	hud_state = "plasma_blast"
	damage = 30
	penetration = 10
	sundering = 2
	damage_falloff = 0.5
	accurate_range = 5
	max_range = 12

/datum/ammo/energy/plasma/blast/drop_nade(turf/T)
	explosion(T, weak_impact_range = 3, color = COLOR_DISABLER_BLUE)

/datum/ammo/energy/plasma/blast/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : O.loc)

/datum/ammo/energy/plasma/blast/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/energy/plasma/blast/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/energy/plasma/blast/on_hit_mob(mob/M, obj/projectile/proj)
	drop_nade(M.loc)

/datum/ammo/energy/plasma/blast/melting
	damage = 40
	sundering = 3
	damage_falloff = 0.5
	accurate_range = 7
	///Number of melting stacks to apply
	var/melting_stacks = 2

/datum/ammo/energy/plasma/blast/melting/drop_nade(turf/T)
	explosion(T, weak_impact_range = 4, color = COLOR_DISABLER_BLUE)
	for(var/mob/living/living_victim in viewers(3, T)) //normally using viewers wouldn't work due to darkness and smoke both blocking vision. However explosions clear both temporarily so we avoid this issue.
		var/datum/status_effect/stacking/melting/debuff = living_victim.has_status_effect(STATUS_EFFECT_MELTING)
		if(debuff)
			debuff.add_stacks(melting_stacks)
		else
			living_victim.apply_status_effect(STATUS_EFFECT_MELTING, melting_stacks)

/datum/ammo/energy/plasma/blast/shatter
	damage = 40
	sundering = 3
	damage_falloff = 0.5
	accurate_range = 9
	ammo_behavior_flags = AMMO_ENERGY

/datum/ammo/energy/plasma/blast/shatter/drop_nade(turf/T)
	explosion(T, light_impact_range = 2, weak_impact_range = 5, throw_range = 0, color = COLOR_DISABLER_BLUE)
	for(var/mob/living/living_victim in viewers(3, T))
		living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, 5 SECONDS)

/datum/ammo/energy/plasma/blast/incendiary
	name = "plasma glob"
	damage = 30
	ammo_behavior_flags = AMMO_ENERGY|AMMO_INCENDIARY
	shell_speed = 2
	icon_state = "plasma_big"
	hud_state = "flame"

/datum/ammo/energy/plasma/blast/incendiary/drop_nade(turf/T)
	flame_radius(2, T, burn_duration = 9, colour = "blue")
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

#define PLASMA_CANNON_INNER_STAGGERSTUN_RANGE 3
#define PLASMA_CANNON_STAGGERSTUN_RANGE 9
#define PLASMA_CANNON_STAGGER_DURATION 3 SECONDS
#define PLASMA_CANNON_SHATTER_DURATION 5 SECONDS
/datum/ammo/energy/plasma/cannon_heavy
	name = "plasma heavy glob"
	icon_state = "plasma_ball_big"
	hud_state = "plasma_sphere"
	damage = 60
	penetration = 40
	sundering = 10

/datum/ammo/energy/plasma/cannon_heavy/on_hit_mob(mob/M, obj/projectile/proj)
	var/damage_mult = 1
	switch(M.mob_size)
		if(MOB_SIZE_BIG)
			damage_mult = 2
		if(MOB_SIZE_XENO)
			damage_mult = 1.5

	proj.damage *= damage_mult
	if(!isliving(M))
		return
	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, PLASMA_CANNON_SHATTER_DURATION)
	staggerstun(living_victim, proj, PLASMA_CANNON_INNER_STAGGERSTUN_RANGE, weaken = 0.5 SECONDS, knockback = 1, hard_size_threshold = 1)
	staggerstun(living_victim, proj, PLASMA_CANNON_STAGGERSTUN_RANGE, stagger = PLASMA_CANNON_STAGGER_DURATION, slowdown = 2, knockback = 1, hard_size_threshold = 2)

/datum/ammo/energy/plasma/cannon_heavy/on_hit_obj(obj/O, obj/projectile/proj)
	var/damage_mult = 3
	if(isvehicle(O))
		var/obj/vehicle/vehicle_target = O
		if(ismecha(vehicle_target) || isarmoredvehicle(vehicle_target))
			damage_mult = 4
		if(get_dist_euclidean(proj.starting_turf, vehicle_target) <= PLASMA_CANNON_STAGGERSTUN_RANGE) //staggerstun will fail on tank occupants if we just use staggerstun
			for(var/mob/living/living_victim AS in vehicle_target.occupants)
				living_victim.Stagger(PLASMA_CANNON_STAGGER_DURATION)
				to_chat(living_victim, "You are knocked about by the impact, staggering you!")
	proj.damage *= damage_mult

/datum/ammo/energy/plasma/cannon_heavy/on_hit_turf(turf/T, obj/projectile/proj)
	proj.damage *= 5

#undef PLASMA_CANNON_INNER_STAGGERSTUN_RANGE
#undef PLASMA_CANNON_STAGGERSTUN_RANGE
#undef PLASMA_CANNON_STAGGER_DURATION
#undef PLASMA_CANNON_SHATTER_DURATION

/datum/ammo/energy/plasma/smg_standard
	icon_state = "plasma_ball_small"
	damage = 22
	penetration = 10
	sundering = 0.5

/datum/ammo/energy/plasma/smg_standard/one
	bonus_projectiles_type = /datum/ammo/energy/plasma/smg_standard

/datum/ammo/energy/plasma/smg_standard/two
	bonus_projectiles_type = /datum/ammo/energy/plasma/smg_standard/one

/datum/ammo/energy/plasma/smg_standard/three
	bonus_projectiles_type = /datum/ammo/energy/plasma/smg_standard/two

/datum/ammo/energy/plasma/smg_standard/four
	bonus_projectiles_type = /datum/ammo/energy/plasma/smg_standard/three

/datum/ammo/energy/plasma/smg_standard/on_hit_turf(turf/T, obj/projectile/proj)
	reflect(T, proj, 5)

// Plasma //
/datum/ammo/energy/sectoid_plasma
	name = "plasma bolt"
	icon_state = "pulse2"
	hud_state = "plasma"
	armor_type = LASER
	shell_speed = 4
	accurate_range = 15
	damage = 40
	penetration = 15
	max_range = 30
	accuracy_var_low = 3
	accuracy_var_high = 3

/datum/ammo/energy/plasma_pistol
	name = "ionized plasma bolt"
	icon_state = "overchargedlaser"
	hud_state = "electrothermal"
	hud_state_empty = "electrothermal_empty"
	damage = 40
	max_range = 14
	penetration = 5
	shell_speed = 1.5
	ammo_behavior_flags = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_TARGET_TURF
	bullet_color = LIGHT_COLOR_ELECTRIC_GREEN

	///Fire burn time
	var/heat = 12
	///Fire damage
	var/burn_damage = 9
	///Fire color
	var/fire_color = "green"

/datum/ammo/energy/plasma_pistol/proc/drop_fire(atom/target, obj/projectile/proj)
	var/turf/target_turf = get_turf(target)
	var/burn_mod = 1
	if(istype(target_turf, /turf/closed/wall))
		burn_mod = 3
	target_turf.ignite(heat, burn_damage * burn_mod, fire_color)

	for(var/mob/living/mob_caught in target_turf)
		if(mob_caught.stat == DEAD || mob_caught == target)
			continue
		mob_caught.adjust_fire_stacks(burn_damage)
		mob_caught.IgniteMob()

/datum/ammo/energy/plasma_pistol/on_hit_turf(turf/T, obj/projectile/proj)
	drop_fire(T, proj)

/datum/ammo/energy/plasma_pistol/on_hit_mob(mob/M, obj/projectile/proj)
	drop_fire(M, proj)

/datum/ammo/energy/plasma_pistol/on_hit_obj(obj/O, obj/projectile/proj)
	drop_fire(O, proj)

/datum/ammo/energy/plasma_pistol/do_at_max_range(turf/T, obj/projectile/proj)
	drop_fire(T, proj)
