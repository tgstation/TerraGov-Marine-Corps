/*
//================================================
					Pistol Ammo
//================================================
*/

/datum/ammo/bullet/pistol
	name = "pistol bullet"
	hud_state = "pistol"
	hud_state_empty = "pistol_empty"
	ammo_behavior_flags = AMMO_BALLISTIC
	shell_speed = 3.5
	damage = 20
	penetration = 5
	accurate_range = 5
	sundering = 1

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"
	hud_state = "pistol_light"
	damage = 15
	penetration = 5
	sundering = 0.5

/datum/ammo/bullet/pistol/tiny/ap
	name = "light pistol bullet"
	hud_state = "pistol_lightap"
	damage = 22.5
	penetration = 15 //So it can actually hurt something.
	sundering = 0.5
	damage_falloff = 1.5


/datum/ammo/bullet/pistol/tranq
	name = "tranq bullet"
	hud_state = "pistol_tranq"
	armor_type = "bullet"
	damage = 80 //should knock enemies down on multiple shots.
	penetration = 20
	damage_type = STAMINA
	shell_speed = 3.3
	shrapnel_chance = 0.2

/datum/ammo/bullet/pistol/tranq/on_hit_mob(mob/target_mob, obj/projectile/proj)
	if(iscarbon(target_mob))
		var/mob/living/carbon/carbon_victim = target_mob
		carbon_victim.reagents.add_reagent(/datum/reagent/toxin/sleeptoxin, rand(3,5), no_overdose = TRUE)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	hud_state = "pistol_hollow"
	accuracy = -10
	shrapnel_chance = 45
	sundering = 2

/datum/ammo/bullet/pistol/hollow/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, stagger = 2 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"
	hud_state = "pistol_ap"
	damage = 20
	penetration = 10
	shrapnel_chance = 15
	sundering = 1.5

/datum/ammo/bullet/pistol/vsd_ap
	name = "armor-piercing pistol bullet"
	hud_state = "pistol_ap"
	damage = 25
	penetration = 15
	shrapnel_chance = 25
	sundering = 1.5

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	hud_state = "pistol_heavy"
	damage = 30
	penetration = 5
	shrapnel_chance = 25
	sundering = 2.15

/datum/ammo/bullet/pistol/heavy/ap
	name = "heavy armor-penetrating pistol bullet"
	hud_state = "pistol_ap"
	damage = 30
	penetration = 10
	sundering = 2

/datum/ammo/bullet/pistol/superheavy
	name = "high impact pistol bullet"
	hud_state = "pistol_superheavy"
	damage = 45
	penetration = 15
	sundering = 3
	damage_falloff = 0.75

/datum/ammo/bullet/pistol/superheavy/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, stagger = 0.5 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/superheavy/derringer
	handful_amount = 2
	handful_icon_state = "derringer"

/datum/ammo/bullet/pistol/superheavy/derringer/on_hit_mob(mob/target_mob, obj/projectile/proj)
	staggerstun(target_mob, proj, slowdown = 0.5)

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	hud_state = "pistol_fire"
	damage_type = BURN
	shrapnel_chance = 0
	ammo_behavior_flags = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 20

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	hud_state = "pistol_squash"
	accuracy = 5
	damage = 32
	penetration = 10
	shrapnel_chance = 25
	sundering = 2

/datum/ammo/bullet/pistol/mankey
	name = "live monkey"
	icon_state = "monkey1"
	hud_state = "monkey"
	hud_state_empty = "monkey_empty"
	ping = null //no bounce off.
	damage_type = BURN
	ammo_behavior_flags = AMMO_INCENDIARY
	shell_speed = 2
	damage = 15


/datum/ammo/bullet/pistol/mankey/on_hit_mob(mob/target_mob, obj/projectile/proj)
	if(!target_mob.stat && !ismonkey(target_mob))
		proj.visible_message(span_danger("The [src] chimpers furiously!"))
		new /mob/living/carbon/human/species/monkey(proj.loc)
