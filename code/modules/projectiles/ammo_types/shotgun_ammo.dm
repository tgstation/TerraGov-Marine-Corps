/*
//================================================
					Shotgun Ammo
//================================================
*/

/datum/ammo/bullet/shotgun
	hud_state_empty = "shotgun_empty"
	shell_speed = 2
	handful_amount = 5


/datum/ammo/bullet/shotgun/slug
	name = "shotgun slug"
	handful_icon_state = "shotgun slug"
	hud_state = "shotgun_slug"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 3
	max_range = 15
	damage = 100
	penetration = 20
	sundering = 7.5

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 2 SECONDS, knockback = 1, slowdown = 2)


/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	handful_icon_state = "beanbag slug"
	icon_state = "beanbag"
	hud_state = "shotgun_beanbag"
	ammo_behavior_flags = AMMO_BALLISTIC
	damage = 15
	max_range = 15
	shrapnel_chance = 0
	accuracy = 5

/datum/ammo/bullet/shotgun/beanbag/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 4 SECONDS, knockback = 1, slowdown = 2, hard_size_threshold = 1)

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	handful_icon_state = "incendiary slug"
	hud_state = "shotgun_fire"
	damage_type = BRUTE
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	max_range = 15
	damage = 70
	penetration = 15
	sundering = 2
	bullet_color = COLOR_TAN_ORANGE

/datum/ammo/bullet/shotgun/incendiary/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, knockback = 2, slowdown = 1)

/datum/ammo/bullet/shotgun/flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	ammo_behavior_flags = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/flechette/flechette_spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 3
	accuracy_var_low = 8
	accuracy_var_high = 8
	max_range = 15
	damage = 50
	damage_falloff = 0.5
	penetration = 15
	sundering = 7

/datum/ammo/bullet/shotgun/flechette/flechette_spread
	name = "additional flechette"
	damage = 40
	sundering = 5

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread
	bonus_projectiles_amount = 5
	bonus_projectiles_scatter = 4
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 40
	damage_falloff = 4

/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 2 SECONDS, knockback = 2, slowdown = 0.5, max_range = 3)

/datum/ammo/bullet/hefa_buckshot
	name = "hefa fragment"
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	shrapnel_chance = 15
	damage = 30
	damage_falloff = 3

/datum/ammo/bullet/hefa_buckshot/on_hit_mob(mob/mob_hit, obj/projectile/projectile)
	staggerstun(mob_hit, projectile, knockback = 2, max_range = 4)

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 40
	damage_falloff = 4


/datum/ammo/bullet/shotgun/frag
	name = "shotgun explosive shell"
	handful_icon_state = "shotgun tracker shell"
	hud_state = "shotgun_tracker"
	ammo_behavior_flags = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/frag/frag_spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 6
	accuracy_var_low = 8
	accuracy_var_high = 8
	max_range = 15
	damage = 10
	damage_falloff = 0.5
	penetration = 0

/datum/ammo/bullet/shotgun/frag/drop_nade(turf/T)
	explosion(T, weak_impact_range = 2)

/datum/ammo/bullet/shotgun/frag/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/bullet/shotgun/frag/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : O.loc)

/datum/ammo/bullet/shotgun/frag/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/bullet/shotgun/frag/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/bullet/shotgun/frag/frag_spread
	name = "additional frag shell"
	damage = 5

/datum/ammo/bullet/shotgun/sx16_buckshot
	name = "shotgun buckshot shell" //16 gauge is between 12 and 410 bore.
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/sx16_buckshot/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 10
	accuracy_var_low = 10
	accuracy_var_high = 10
	max_range = 10
	damage = 25
	damage_falloff = 4

/datum/ammo/bullet/shotgun/sx16_buckshot/spread
	name = "additional buckshot"

/datum/ammo/bullet/shotgun/sx16_flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/sx16_flechette/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 8
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 15
	damage = 15
	damage_falloff = 0.5
	penetration = 15

/datum/ammo/bullet/shotgun/sx16_flechette/spread
	name = "additional flechette"

/datum/ammo/bullet/shotgun/sx16_slug
	name = "shotgun slug"
	handful_icon_state = "shotgun slug"
	hud_state = "shotgun_slug"
	shell_speed = 3
	max_range = 15
	damage = 40
	penetration = 20

/datum/ammo/bullet/shotgun/sx16_slug/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, slowdown = 1, knockback = 1)

/datum/ammo/bullet/shotgun/tx15_flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	ammo_behavior_flags = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/tx15_flechette/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 2
	max_range = 15
	damage = 17
	damage_falloff = 0.25
	penetration = 15
	sundering = 1.5

/datum/ammo/bullet/shotgun/tx15_flechette/spread
	name = "additional flechette"

/datum/ammo/bullet/shotgun/tx15_slug
	name = "shotgun slug"
	handful_icon_state = "shotgun slug"
	hud_state = "shotgun_slug"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 3
	max_range = 15
	damage = 60
	penetration = 30
	sundering = 3.5

/datum/ammo/bullet/shotgun/tx15_slug/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, slowdown = 2, knockback = 1)

/datum/ammo/bullet/shotgun/mbx900_buckshot
	name = "light shotgun buckshot shell" // If .410 is the smallest shotgun shell, then...
	handful_icon_state = "light shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/mbx900_buckshot/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 10
	accuracy_var_low = 10
	accuracy_var_high = 10
	max_range = 10
	damage = 50
	damage_falloff = 1

/datum/ammo/bullet/shotgun/mbx900_buckshot/spread
	name = "additional buckshot"
	damage = 40

/datum/ammo/bullet/shotgun/mbx900_sabot
	name = "light shotgun sabot shell"
	handful_icon_state = "light shotgun sabot shell"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_sabot"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 5
	max_range = 30
	damage = 50
	penetration = 40
	sundering = 3

/datum/ammo/bullet/shotgun/mbx900_tracker
	name = "light shotgun tracker round"
	handful_icon_state = "light shotgun tracker round"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_tracker"
	shell_speed = 4
	max_range = 30
	damage = 5
	penetration = 100

/datum/ammo/bullet/shotgun/mbx900_tracker/on_hit_mob(mob/living/victim, obj/projectile/proj)
	victim.AddComponent(/datum/component/dripping, DRIP_ON_TIME, 40 SECONDS, 2 SECONDS)

/datum/ammo/bullet/shotgun/tracker
	name = "shotgun tracker shell"
	handful_icon_state = "shotgun tracker shell"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_tracker"
	shell_speed = 4
	max_range = 30
	damage = 5
	penetration = 100

/datum/ammo/bullet/shotgun/tracker/on_hit_mob(mob/living/victim, obj/projectile/proj)
	victim.AddComponent(/datum/component/dripping, DRIP_ON_TIME, 40 SECONDS, 2 SECONDS)

//I INSERT THE SHELLS IN AN UNKNOWN ORDER
/datum/ammo/bullet/shotgun/blank
	name = "shotgun blank shell"
	handful_icon_state = "shotgun blank shell"
	icon_state = "shotgun_blank"
	hud_state = "shotgun_buckshot" // don't fix this: this is so you can do buckshot roulette
	shell_speed = 0
	max_range = -1
	damage = 0
