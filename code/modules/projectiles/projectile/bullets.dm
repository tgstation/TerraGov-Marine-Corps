/obj/item/projectile/bullet
	name = "bullet"
	icon_state = "bullet"
	damage = 60
	damage_type = BRUTE
	nodamage = 0
	flag = "bullet"
	embed = 1
	sharp = 1

	on_hit(var/atom/target, var/blocked = 0)
		if (..(target, blocked))
			var/mob/living/L = target
			if(damage > 60)
				shake_camera(L, 3, 2)

/obj/item/projectile/bullet/weakbullet // "rubber" bullets
	damage = 10
	agony = 40
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/weakbullet/beanbag		//because beanbags are not bullets
	name = "beanbag"
	damage = 20
	agony = 60
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/weakbullet/rubber
	name = "rubber bullet"

/obj/item/projectile/bullet/midbullet
	damage = 20

/obj/item/projectile/bullet/midbullet2
	damage = 25

/obj/item/projectile/bullet/suffocationbullet//How does this even work?
	name = "co bullet"
	damage = 20
	damage_type = OXY


/obj/item/projectile/bullet/cyanideround
	name = "poison bullet"
	damage = 40
	damage_type = TOX


/obj/item/projectile/bullet/burstbullet//I think this one needs something for the on hit
	name = "exploding bullet"
	damage = 20
	embed = 0
	edge = 1


/obj/item/projectile/bullet/stunshot
	name = "stunshot"
	damage = 5
	agony = 80
	stutter = 10
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/a762
	damage = 42

/obj/item/projectile/bullet/chameleon
	damage = 1 // stop trying to murderbone with a fake gun dumbass!!!
	embed = 0 // nope

/obj/item/projectile/bullet/incendiary
	damage = 5
	damage_type = BURN
	embed = 0
	sharp = 0

/obj/item/projectile/bullet/incendiary/on_hit(var/atom/target, var/blocked = 0)
		if(istype(target, /mob/living/carbon))
				var/mob/living/carbon/M = target
				M.adjust_fire_stacks(rand(5,10))
				M.IgniteMob()

/obj/item/projectile/bullet/incendiary/shell/Move()
	..()
//	if(prob(80))
		//var/turf/location = get_turf(src)
 		//new/obj/effect/effect/fire(location)

/obj/item/projectile/bullet/incendiary/shell