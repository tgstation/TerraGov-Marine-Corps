/*
//================================================
					Smartgun Ammo
//================================================
*/

/datum/ammo/bullet/smartmachinegun
	name = "smartmachinegun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 12
	damage = 20
	penetration = 15
	sundering = 2

/datum/ammo/bullet/smart_minigun
	name = "smartminigun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun_minigun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	accurate_range = 12
	damage = 10
	penetration = 25
	sundering = 1
	damage_falloff = 0.1

/datum/ammo/bullet/smarttargetrifle
	name = "smart marksman bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 40
	max_range = 40
	penetration = 30
	sundering = 5
	shell_speed = 4
	damage_falloff = 0.5
	accurate_range = 25
	accurate_range_min = 3

/datum/ammo/bullet/cupola
	name = "cupola bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_IFF
	accurate_range = 12
	damage = 30
	penetration = 10
	sundering = 1

/datum/ammo/bullet/spottingrifle
	name = "smart spotting bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "spotrifle"
	hud_state_empty = "smartgun_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 50
	max_range = 40
	penetration = 25
	sundering = 5
	shell_speed = 4

/datum/ammo/bullet/spottingrifle/highimpact
	name = "smart high-impact spotting bullet"
	hud_state = "spotrifle_impact"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1 SECONDS, slowdown = 1, max_range = 12)

/datum/ammo/bullet/spottingrifle/heavyrubber
	name = "smart heavy-rubber spotting bullet"
	hud_state = "spotrifle_rubber"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/heavyrubber/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1 SECONDS, slowdown = 1, max_range = 12)

/datum/ammo/bullet/spottingrifle/plasmaloss
	name = "smart tanglefoot spotting bullet"
	hud_state = "spotrifle_plasmaloss"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/plasmaloss/on_hit_mob(mob/living/victim, obj/projectile/proj)
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/X = victim
		X.use_plasma(20 + 0.2 * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit) // This is draining 20%+20 flat per hit.

/datum/ammo/bullet/spottingrifle/tungsten
	name = "smart tungsten spotting bullet"
	hud_state = "spotrifle_tungsten"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/tungsten/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, knockback = 3, max_range = 12)

/datum/ammo/bullet/spottingrifle/flak
	name = "smart flak spotting bullet"
	hud_state = "spotrifle_flak"
	damage = 60
	sundering = 0.5
	airburst_multiplier = 0.5

/datum/ammo/bullet/spottingrifle/flak/on_hit_mob(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/spottingrifle/incendiary
	name = "smart incendiary spotting  bullet"
	hud_state = "spotrifle_incend"
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage_type = BURN
	damage = 10
	sundering = 0.5
