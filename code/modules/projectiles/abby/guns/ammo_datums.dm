//Definition for these is in ammunition.dm.

/datum/ammo/bullet
	name = "bullet"
	damage = 5
	damage_type = BRUTE
	accurate_range = 5
	shrapnel_chance = 10
	icon_state = "bullet"
	shell_speed = 2 //Hmmmmmmm.

/datum/ammo/bullet/pistol
	name = "pistol bullet"
	damage = 15
	accuracy = -5 //Not very accurate.

/datum/ammo/bullet/pistol/tiny
	name = ".22 bullet"
	damage = 10
	accuracy = -5 //Not very accurate.

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	damage = 12
	accuracy = -10
	shrapnel_chance = 50 //50% likely to generate shrapnel on impact.

/datum/ammo/bullet/pistol/ap
	name = "AP pistol bullet"
	damage = 12
	accuracy = 8
	armor_pen = 30
	shrapnel_chance = 0

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	damage = 22
	accuracy = -10
	armor_pen = 5
	shrapnel_chance = 25

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	damage = 10
	damage_type = BURN
	accuracy = 10
	shrapnel_chance = 0
	incendiary = 1

/datum/ammo/bullet/pistol/incendiary/vp78
	name = "VP78 round"
	damage = 25

/datum/ammo/bullet/smg
	name = "submachinegun bullet"
	damage = 18

/datum/ammo/bullet/smg/ap
	name = "AP submachinegun bullet"
	damage = 15
	armor_pen = 30

/datum/ammo/bullet/smg/ludicrous
	name = "submachinegun bullet"
	damage = 25
	armor_pen = 30
	accuracy = 12
	shell_speed = 3 //Faster!

/datum/ammo/bullet/revolver
	name = "revolver bullet"
	damage = 26
	armor_pen = 3
	accuracy = -15
	stun = 1 //Knockdown! Doesn't work on xenos though.

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	damage = 20
	accuracy = 15
	stun = 1
	armor_pen = -10
	shrapnel_chance = 0
	damage_bleed = 0

/datum/ammo/bullet/revolver/small
	name = "revolver bullet"
	damage = 15
	armor_pen = 1

/datum/ammo/bullet/revolver/heavy
	damage = 25
	armor_pen = 10
	accuracy = -10
	stun = 1 //Knockdown! Doesn't work on xenos though.

/datum/ammo/bullet/rifle
	name = "rifle bullet"
	damage = 20

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	damage = 18
	incendiary = 1
	accuracy = -5
	shrapnel_chance = 0
	armor_pen = 15

/datum/ammo/bullet/rifle/marksman
	name = "marksman rifle bullet"
	damage = 22
	accuracy = 20
	armor_pen = 10
	shrapnel_chance = 0
	damage_bleed = 0
	shell_speed = 3

/datum/ammo/bullet/rifle/mar40
	damage = 24
	accuracy = -5
	armor_pen = -5

//Slugs.
/datum/ammo/bullet/shotgun
	name = "shotgun slug"
	damage = 50
	damage_bleed = 7 //Loses 7 damage every turf.
	accurate_range = 4
	max_range = 12
	casing_type = "/obj/item/ammo_casing/shotgun"
	shell_speed = 1

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	damage = 30
	damage_bleed = 5 //Loses 7 damage every turf.
	accurate_range = 4
	max_range = 12
	casing_type = "/obj/item/ammo_casing/shotgun/red"
	incendiary = 1

/datum/ammo/bullet/shotgun/buckshot
	name = "buckshot"
	damage = 15
	damage_bleed = 5 //Loses 5 damage every turf.
	accurate_range = 4
	max_range = 4
	icon_state = "buckshot"
	casing_type = "/obj/item/ammo_casing/shotgun/green"
	bonus_projectiles = 4

	do_at_max_range(obj/item/projectile/P)
		burst(get_turf(P),P)
		del(P)

	on_hit_mob(mob/M,obj/item/projectile/P)
		burst(get_turf(M),P)

/obj/effect/buckshot_blast
	name = "buckshot"
	desc = "Like dozens of angry bees!"
	icon_state = "buckshot"
	density = 0
	opacity = 0
	anchored = 1
	layer = MOB_LAYER + 0.2
	mouse_opacity = 0
	force = 0

	New() //Self-deletes pronto. Kinda shitty but. Fuck who cares.
		spawn(5)
			del(src)
			return

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	damage = 75
	accurate_range = 20
	max_range = 30
	armor_pen = 50
	accuracy = 25
	shell_speed = 3

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary shell"
	damage = 58
	accurate_range = 15
	max_range = 25
	armor_pen = 30
	accuracy = 0
	incendiary = 1

/datum/ammo/bullet/sniper/flak
	name = "flak shell"
	damage = 45
	accurate_range = 12
	max_range = 24
	armor_pen = 5
	accuracy = -10

	on_hit_mob(mob/M,obj/item/projectile/P)
		burst(get_turf(M),P,"flak")

/datum/ammo/bullet/smartgun
	name = "smartgun bullet"
	damage = 22
	skips_marines = 1
	armor_pen = 5
	accuracy = 50
	accurate_range = 6

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	damage = 0
	ignores_armor = 1
	stun = 5
	weaken = 5
	damage_type = OXY

/datum/ammo/energy/yautja/light_plasma
	name = "plasma bolt"
	icon_state = "ion"
	damage = 5
	ignores_armor = 1
	damage_type = BURN
	stun = 3
	weaken = 3

/datum/ammo/energy/yautja/medium_plasma
	name = "plasma blast"
	icon_state = "pulse1"
	damage = 30
	damage_type = BURN

/datum/ammo/energy/yautja/heavy_plasma
	name = "plasma eradication sphere"
	icon_state = "bluespace"
	damage = 30
	damage_type = BURN

	on_hit_mob(mob/M,obj/item/projectile/P)
		explosion(get_turf(P.loc), -1, -1, 2, 2)

	on_hit_turf(turf/T,obj/item/projectile/P)
		explosion(T, -1, -1, 2, 2)

	on_hit_obj(obj/O,obj/item/projectile/P)
		explosion(get_turf(P.loc), -1, -1, 2, 2)

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	damage = 45
	skips_marines = 1
	armor_pen = 15
	accuracy = 50
	accurate_range = 15
	max_range = 10

/datum/ammo/energy/emitter
	name = "emitter bolt"
	icon_state = "emitter"
	damage = 40
	ignores_armor = 1
	damage_type = BURN

/datum/ammo/xeno/spit
	name = "acid spit"
	icon_state = "toxin"
	damage = 0
	ignores_armor = 1
	damage_type = TOX
	accuracy = 50
	skips_xenos = 1
	stun = 2
	weaken = 2
	shell_speed = 1

/datum/ammo/xeno/spit/burny
	name = "corrosive spit"
	icon_state = "neurotoxin"
	damage = 25
	ignores_armor = 0
	damage_type = BURN
	skips_xenos = 1
	shell_speed = 1

/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	damage = 50
	damage_type = BURN
	ignores_armor = 1
	shell_speed = 1
	incendiary = 1
	max_range = 5

	proc/drop_flame(var/turf/T)
		if(!istype(T)) return
		if(locate(/obj/flamer_fire) in T) return
		var/obj/flamer_fire/F =  new(T)
		processing_objects.Add(F)
		F.firelevel = 20 //mama mia she a hot one!

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_flame(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_flame(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_flame(get_turf(P))

	do_at_max_range(obj/item/projectile/P)
		drop_flame(get_turf(P))

//all of my keks, i give them to you
/datum/ammo/bullet/pistol/mankey
	name = "monkey"
	icon_state = "monkey1"
	incendiary = 1
	shell_speed = 1
	ignores_armor = 1
	damage_type = TOX
	damage = 10
	stun = 5
	weaken = 3

	on_hit_mob(mob/M,obj/item/projectile/P)
		if(P && P.loc) P.visible_message("\The [src] chimpers furiously!")
		new /mob/living/carbon/monkey(P.loc)

/datum/ammo/boiler_gas
	name = "glob"
	icon_state = "acid"
	incendiary = 1
	shell_speed = 1
	ignores_armor = 1
	skips_xenos = 1
	damage_type = TOX
	damage = 1
	stun = 20
	weaken = 20 //If this bad boy hits you directly, watch out.

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_nade(get_turf(P))

	do_at_max_range(obj/item/projectile/P)
		drop_nade(get_turf(P))

	proc/drop_nade(var/turf/T)
		var/obj/item/weapon/grenade/xeno_weaken/G = new (T)
		G.visible_message("\green <B>A glob of acid falls from the sky!</b>")
		G.prime()
		return

/datum/ammo/boiler_gas/corrosive
	damage = 50
	stun = 1
	weaken = 1

	drop_nade(turf/T)
		var/obj/item/weapon/grenade/xeno/G = new (T)
		G.visible_message("\green <B>A glob of acid falls from the sky!</b>")
		G.prime()
		return

/datum/ammo/flare
	name = "flare"
	damage = 15
	damage_type = BURN
	incendiary = 1
	accuracy = 15
	max_range = 15

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_nade(get_turf(P))

	do_at_max_range(obj/item/projectile/P)
		drop_nade(get_turf(P))

	proc/drop_nade(var/turf/T)
		var/obj/item/device/flashlight/flare/G = new (T)
		G.visible_message("\blue <B>A [G] falls from the sky!</b>")
		G.on = 1
		processing_objects += G
		return