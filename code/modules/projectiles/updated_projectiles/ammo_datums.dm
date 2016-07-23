//Bitflag defines are in setup.dm. Referenced here.
/*
#define AMMO_REGULAR 		0
#define AMMO_EXPLOSIVE 		1
#define AMMO_XENO_ACID 		2
#define AMMO_XENO_TOX		4
#define AMMO_ENERGY 		8
#define AMMO_ROCKET			16
#define AMMO_SNIPER			32
#define AMMO_INCENDIARY		64
#define AMMO_SKIPS_HUMANS	128
#define AMMO_SKIPS_ALIENS 	256
#define AMMO_IS_SILENCED 	512
#define AMMO_NO_SCATTER 	1024
#define AMMO_IGNORE_ARMOR	2048
#define AMMO_IGNORE_RESIST	4096
*/

//Good to standardize this.
#define NEG_ARMOR_PENETRATION	-10
#define MIN_ARMOR_PENETRATION	10
#define LOW_ARMOR_PENETRATION	20
#define NORM_ARMOR_PENETRATION	30
#define HIGH_ARMOR_PENETRATION	50
#define MAX_ARMOR_PENETRATION	90

/datum/ammo
	var/name = "generic bullet"
	var/icon = 'icons/obj/projectiles.dmi'
	var/icon_state = "bullet"
	var/ping = "ping_b" //The icon that is displayed when the bullet bounces off something.

	var/stun 		= 0
	var/weaken 		= 0
	var/paralyze 	= 0
	var/irradiate 	= 0
	var/stutter 	= 0
	var/eyeblur 	= 0
	var/drowsy 		= 0
	var/agony 		= 0

	var/accuracy 		= 0
	var/accurate_range 	= 7 //After this distance, accuracy suffers badly unless zoomed.
	var/max_range 		= 30 //This will de-increment a counter on the bullet.
	var/damage 			= 0
	var/damage_bleed 	= 1 //How much damage the bullet loses per turf traveled, very high for shotguns. //Not anymore ~N.
	var/damage_type 	= BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/armor_pen 		= 0
	var/shrapnel_chance = 0
	var/shell_speed 	= 1 //This is the default projectile speed: x turfs per 1 second.

	var/bonus_projectiles = 0 //How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together.
	var/ammo_behavior = AMMO_REGULAR //Nothing special about it.

	proc/do_at_half_range(var/obj/item/projectile/P)
		return

	proc/do_at_max_range(var/obj/item/projectile/P)
		return

	proc/on_shield_block(var/mob/M, var/obj/item/projectile/P) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
		return

	proc/on_hit_turf(var/turf/T, var/obj/item/projectile/P) //Special effects when hitting dense turfs.
		return

	proc/on_hit_mob(var/mob/M, var/obj/item/projectile/P) //Special effects when hitting mobs.
		return

	proc/on_hit_obj(var/obj/O, var/obj/item/projectile/P) //Special effects when hitting objects.
		return

	proc/knockback(var/mob/M,var/obj/item/projectile/P)
		if(!M || M == P.firer) return
		if(P.distance_travelled > 2) shake_camera(M, 2, 1) //Two tiles away or more, basically.

		else //One tile away or less.
			shake_camera(M, 3, 4)
			if(isliving(M)) //This is pretty ugly, but what can you do.
				if(isXeno(M))
					var/mob/living/carbon/Xenomorph/target = M
					if(target.big_xeno) return //Big xenos are not affected.
					target.apply_effects(0,1) //Smaller ones just get shaken.
					target << "<span class='xenodanger'>You are shaken by the sudden impact!</span>"
				else
					if(!isYautja(M)) //Not predators.
						var/mob/living/target = M
						target.apply_effects(1,2) //Humans get stunned a bit.
						target << "<span class='highdanger'>The blast knocks you off your feet!</span>"
			step_away(M,P)

	proc/burst(var/atom/target,var/obj/item/projectile/P,var/damage_type = BRUTE)
		if(!target) return
		for(var/mob/living/carbon/M in orange(1,target))
			if(P.firer == M)
				continue
			M.visible_message("<span class='danger'>[M] is hit by backlash from \a [P.name]!</span>","[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You are hit by backlash from \a </b>[P.name]</b>!</span>")
			M.apply_damage(rand(5,P.damage/2),damage_type)

	proc/multiple_projectiles(var/obj/item/projectile/original_P, range, speed)
		set waitfor = 0
		var/i
		for(i = 0 to bonus_projectiles) //Want to run this for the number of bonus projectiles.
			var/scatter_x = rand(-1,1)
			var/scatter_y = rand(-1,1)
			var/turf/new_target = locate(original_P.target_turf.x + round(scatter_x),original_P.target_turf.y + round(scatter_y),original_P.target_turf.z)
			if(!istype(new_target) || isnull(new_target)) continue	//If we didn't find anything, make another pass.
			var/obj/item/projectile/P = rnew(/obj/item/projectile,original_P.shot_from)
			P.ammo = ammo_list["additional buckshot"]
			P.name = P.ammo.name
			P.icon_state = P.ammo.icon_state
			P.damage = P.ammo.damage //These do not benefit from gun accuracy/damage.
			P.accuracy += P.ammo.accuracy
			P.original = new_target
			P.fire_at(new_target,original_P.firer,original_P.shot_from,range,speed) //Fire!

	//This is sort of a workaround for now. There are better ways of doing this ~N.
	proc/stun_living(var/mob/living/target, var/obj/item/projectile/P) //Taser proc to stun folks.
		if(istype(target))
			if( isYautja(target) || isXeno(target) ) return //Not on aliens.
			if(target.mind && target.mind.special_role)
				switch(target.mind.special_role) //Switches are still better than evaluating this twice.
					if("IRON BEARS") //These antags can shrug off tasers so they are not shut down.
						target.apply_effects(1,1) //Barely affected.
						return
					if("DEATH SQUAD")
						target.apply_effects(0,1) //Almost unaffacted.
						return
			target.apply_effects(8,8) //Buffed a bit.

	proc/drop_flame(var/turf/T)
		if(!istype(T)) return
		if(locate(/obj/flamer_fire) in T) return
		var/obj/flamer_fire/F =  new(T)
		processing_objects.Add(F)
		F.firelevel = 20 //mama mia she a hot one!

/*
//================================================
					Default Ammo
//================================================
*/
//Only when things screw up do we use this as a placeholder.
/datum/ammo/bullet
	name = "default bullet"
	damage = 10
	damage_type = BRUTE
	accurate_range = 6
	shrapnel_chance = 10
	icon_state = "bullet"
	shell_speed = 2

/*
//================================================
					Pistol Ammo
//================================================
*/

/datum/ammo/bullet/pistol
	name = "pistol bullet"
	damage = 22
	accuracy = -5 //Not very accurate.

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"
	damage = 15
	accuracy = -5 //Not very accurate.

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	damage = 17
	accuracy = -10
	shrapnel_chance = 50 //50% likely to generate shrapnel on impact.

/datum/ammo/bullet/pistol/ap
	name = "AP pistol bullet"
	damage = 17
	accuracy = 8
	armor_pen = NORM_ARMOR_PENETRATION
	shrapnel_chance = 0

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	damage = 35
	accuracy = -10
	armor_pen = MIN_ARMOR_PENETRATION - 5
	shrapnel_chance = 25

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	damage = 20
	damage_type = BURN
	accuracy = 10
	shrapnel_chance = 0
	ammo_behavior = AMMO_INCENDIARY

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	damage = 30
	accuracy = 15
	shrapnel_chance = 25

/datum/ammo/bullet/pistol/mankey
	name = "live monkey"
	icon_state = "monkey1"
	ping = null //no bounce off.
	shell_speed = 1
	damage_type = BURN
	damage = 10
	stun = 5
	weaken = 3
	ammo_behavior = AMMO_INCENDIARY | AMMO_IGNORE_ARMOR

	on_hit_mob(mob/M,obj/item/projectile/P)
		if(P && P.loc && !M.stat && !istype(M,/mob/living/carbon/monkey))
			P.visible_message("<span class='danger'>The [src] chimpers furiously!</span>")
			new /mob/living/carbon/monkey(P.loc)

/*
//================================================
					SMG Ammo
//================================================
*/

/datum/ammo/bullet/smg
	name = "SMG bullet"
	damage = 25
	accurate_range = 5

/datum/ammo/bullet/smg/ap
	name = "AP SMG bullet"
	damage = 22
	armor_pen = NORM_ARMOR_PENETRATION

/*
//================================================
					Revolver Ammo
//================================================
*/

/datum/ammo/bullet/revolver
	name = "revolver bullet"
	damage = 35
	armor_pen = MIN_ARMOR_PENETRATION - 5
	accuracy = -15
	stun = 1 //Knockdown! Doesn't work on xenos though.

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"
	damage = 25

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	damage = 30
	accuracy = 15
	accurate_range = 8
	stun = 1
	armor_pen = NEG_ARMOR_PENETRATION
	shrapnel_chance = 0
	damage_bleed = 0

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	damage = 45
	armor_pen = MIN_ARMOR_PENETRATION
	accuracy = -10

/*
//================================================
					Rifle Ammo
//================================================
*/

/datum/ammo/bullet/rifle
	name = "rifle bullet"
	damage = 40
	accurate_range = 10

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	damage = 35
	accuracy = -5
	shrapnel_chance = 0
	damage_type = BURN
	ammo_behavior = AMMO_INCENDIARY

/datum/ammo/bullet/rifle/marksman
	name = "marksman rifle bullet"
	damage = 54
	accuracy = 20
	armor_pen = MIN_ARMOR_PENETRATION
	shrapnel_chance = 0
	damage_bleed = 0

/datum/ammo/bullet/rifle/ap
	name = "AP rifle bullet"
	damage = 35
	accuracy = 20
	armor_pen = NORM_ARMOR_PENETRATION - 5

/datum/ammo/bullet/rifle/mar40
	name = "heavy rifle bullet"
	damage = 48
	accuracy = -5
	armor_pen = NEG_ARMOR_PENETRATION + 5

/*
//================================================
					Shotgun Ammo
//================================================
*/

/datum/ammo/bullet/shotgun

/datum/ammo/bullet/shotgun/slug
	name = "shotgun slug"
	damage = 58 //High damage.
	max_range = 12
	armor_pen = LOW_ARMOR_PENETRATION

	on_hit_mob(mob/M,obj/item/projectile/P)
		knockback(M,P)

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	damage = 48 //Less damage than a normal slug, but has burst and burn.
	max_range = 12
	accuracy = -5
	armor_pen = MIN_ARMOR_PENETRATION
	damage_type = BURN
	ammo_behavior = AMMO_INCENDIARY

	on_hit_mob(mob/M,obj/item/projectile/P)
		burst(get_turf(M),P,damage_type)
		knockback(M,P)

	on_hit_obj(obj/O,obj/item/projectile/P)
		burst(get_turf(P),P,damage_type)

	on_hit_turf(turf/T,obj/item/projectile/P)
		burst(get_turf(T),P,damage_type)

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot"
	damage = 90 //Massive damage up close, very quick fallout thereafter.
	damage_bleed = 17 //90 PB, 73, 56, 39, 22, 5 <--- Max range.
	accurate_range = 4
	max_range = 5
	icon_state = "buckshot"
	bonus_projectiles = 2 //Shoots an extra two projectiles in a wide spread.
	shell_speed = 1
	/*
	Point blanking doesn't actually make bonus projectiles, but firing within one turf does.
	2-3 tiles away is the optimal range. 1-2 tiles away also triggers the knockback, and has
	a greater chance of landing bonus projectiles. Anything past 3 tiles will be minimally
	damaged. But then you should probably start using slugs.
	*/
	on_hit_mob(mob/M,obj/item/projectile/P)
		knockback(M,P)

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	damage = 65
	damage_bleed = 16 //49, 33, 17, 1
	accurate_range = 4
	max_range = 4
	icon_state = "buckshot"
	shell_speed = 1


/*
//================================================
					Sniper Ammo
//================================================
*/

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	damage = 80
	accurate_range = 3 //Works in reverse. You have a lower chance to hit if the target is close.
	max_range = 30 //Otherwise, the bullet is fairly accurate even at max range.
	armor_pen = HIGH_ARMOR_PENETRATION
	damage_bleed = 0
	accuracy = 15
	shell_speed = 3
	ammo_behavior = AMMO_NO_SCATTER | AMMO_SNIPER

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary sniper bullet"
	damage = 60
	max_range = 25
	armor_pen = NORM_ARMOR_PENETRATION
	accuracy = 0
	damage_type = BURN
	ammo_behavior = AMMO_NO_SCATTER | AMMO_INCENDIARY | AMMO_SNIPER

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	damage = 55
	max_range = 24
	armor_pen = LOW_ARMOR_PENETRATION - 5
	accuracy = -10

	on_hit_mob(mob/M,obj/item/projectile/P)
		burst(get_turf(M),P,damage_type)

/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"
	damage = 160
	accuracy = 55
	shell_speed = 4

/*
//================================================
					Special Ammo
//================================================
*/

/datum/ammo/bullet/smartgun
	name = "smartgun bullet"
	damage = 28
	armor_pen = MIN_ARMOR_PENETRATION
	accuracy = 50
	ammo_behavior = AMMO_SKIPS_HUMANS

/datum/ammo/bullet/smartgun/dirty //This thing is extremely nasty.
	name = "irradiated smartgun bullet"
	irradiate = 1 //Free rads.
	agony = 1
	damage = 35 // Slightly more damage than regular smartgun.
	armor_pen = NORM_ARMOR_PENETRATION
	shrapnel_chance = 65 // High chance of shrapnel tearing up your insides.
	damage_type = BRUTE
	ammo_behavior = AMMO_REGULAR

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	damage = 50
	armor_pen = MIN_ARMOR_PENETRATION - 5
	accuracy = 25
	max_range = 12
	ammo_behavior = AMMO_SKIPS_HUMANS

/datum/ammo/bullet/minigun
	name = "minigun bullet"
	damage = 50
	armor_pen = MIN_ARMOR_PENETRATION
	accuracy = -5
	shrapnel_chance = 22

/*
//================================================
					Rocket Ammo
//================================================
*/

/datum/ammo/rocket
	name = "high explosive rocket"
	icon_state = "missile"
	ping = null //no bounce off.
	accuracy = 10
	accurate_range = 25
	max_range = 25
	damage = 15
	damage_type = BRUTE  //Bonk!
	shell_speed = 1
	damage_bleed = 0
	ammo_behavior = AMMO_EXPLOSIVE | AMMO_ROCKET

	on_hit_mob(mob/M,obj/item/projectile/P)
		explosion(get_turf(M), -1, 1, 3, 4)

	on_hit_obj(obj/O,obj/item/projectile/P)
		explosion(get_turf(O), -1, 1, 3, 4)

	on_hit_turf(turf/T,obj/item/projectile/P)
		explosion(T,  -1, 1, 3, 4)

	do_at_max_range(obj/item/projectile/P)
		explosion(get_turf(P),  -1, 1, 3, 4)

/datum/ammo/rocket/ap
	name = "anti-armor rocket"
	damage = 160
	damage_type = BRUTE  //Bonk!
	armor_pen = MAX_ARMOR_PENETRATION
	damage_bleed = 0
	ammo_behavior = AMMO_ROCKET

	on_hit_mob(mob/M,obj/item/projectile/P)
		explosion(get_turf(M), -1, 1, 1, 4)

	on_hit_obj(obj/O,obj/item/projectile/P)
		explosion(get_turf(O), -1, 1, 1, 4)

	on_hit_turf(turf/T,obj/item/projectile/P)
		explosion(T,  -1, 1, 1, 4)

	do_at_max_range(obj/item/projectile/P)
		explosion(P.loc,  -1, 1, 1, 4)

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	damage = 90
	damage_type = BURN
	max_range = 18
	ammo_behavior = AMMO_ROCKET | AMMO_INCENDIARY

	drop_flame(var/turf/T)
		if(!istype(T)) return
		if(locate(/obj/flamer_fire) in T) return
		var/obj/flamer_fire/F =  new(T)
		processing_objects.Add(F)
		F.firelevel = pick(15,20,25,30) //mama mia she a hot one!

		for(var/mob/living/carbon/M in range(3,T))
			if(istype(M,/mob/living/carbon/Xenomorph))
				if(M:fire_immune) continue

			if(M.stat == DEAD) continue
			M.adjust_fire_stacks(rand(5,25))
			M.IgniteMob()
			M.visible_message("<span class='danger'>[M] bursts into flames!</span>","[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You burst into flames!</span>")

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_flame(get_turf(M))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_flame(get_turf(O))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_flame(get_turf(T))

	do_at_max_range(obj/item/projectile/P)
		drop_flame(get_turf(P))

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	damage = 200
	max_range = 30
	ammo_behavior = AMMO_ROCKET

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_flame(get_turf(M))
		explosion(P.loc,  -1, 2, 3, 4)

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_flame(get_turf(O))
		explosion(P.loc,  -1, 2, 3, 4)

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_flame(get_turf(T))
		explosion(P.loc,  -1, 2, 3, 4)

	do_at_max_range(obj/item/projectile/P)
		drop_flame(get_turf(P))
		explosion(P.loc,  -1, 2, 3, 4)

/*
//================================================
					Energy Ammo
//================================================
*/

/datum/ammo/energy
	ping = null //no bounce off. We can have one later.
	damage_type = BURN
	ammo_behavior = AMMO_ENERGY

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	ammo_behavior = AMMO_ENERGY | AMMO_IGNORE_ARMOR

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	damage_type = OXY
	ammo_behavior = AMMO_ENERGY | AMMO_IGNORE_RESIST //Not that ignoring will do much right now.

	on_hit_mob(mob/M, obj/item/projectile/P)
		stun_living(M,P)

/datum/ammo/energy/yautja
	accurate_range = 10
	shell_speed = 2

/datum/ammo/energy/yautja/caster/bolt
	name = "plasma bolt"
	icon_state = "ion"
	damage = 5
	stun = 2
	weaken = 2
	ammo_behavior = AMMO_ENERGY | AMMO_IGNORE_RESIST

/datum/ammo/energy/yautja/caster/blast
	name = "plasma blast"
	icon_state = "pulse1"
	damage = 25
	shell_speed = 3

/datum/ammo/energy/yautja/caster/sphere
	name = "plasma eradication sphere"
	icon_state = "bluespace"
	damage = 30
	shell_speed = 4

	on_hit_mob(mob/M,obj/item/projectile/P)
		explosion(get_turf(P.loc), -1, -1, 2, 2)

	on_hit_turf(turf/T,obj/item/projectile/P)
		explosion(T, -1, -1, 2, 2)

	on_hit_obj(obj/O,obj/item/projectile/P)
		explosion(get_turf(P.loc), -1, -1, 2, 2)

/datum/ammo/energy/yautja/rifle
	damage = 10

	on_hit_mob(mob/M,obj/item/projectile/P)
		if(M && !M.stat && P.damage > 25)
			M.Weaken(4)
			step_rand(M)
			playsound(M.loc, 'sound/weapons/pulse.ogg', 70, 1)

	on_hit_turf(turf/T,obj/item/projectile/P)
		if(P.damage > 25)
			explosion(T, -1, -1, 2, -1)

	on_hit_obj(obj/O,obj/item/projectile/P)
		if(P.damage > 25)
			explosion(get_turf(P.loc), -1, -1, 2, -1)

/datum/ammo/energy/yautja/rifle/bolt
	name = "plasma rifle bolt"
	icon_state = "ion"
	weaken = 2
	ammo_behavior = AMMO_ENERGY | AMMO_IGNORE_RESIST

/datum/ammo/energy/yautja/rifle/blast
	name = "plasma rifle blast"
	icon_state = "bluespace"
	shell_speed = 3

/*
//================================================
					Xeno Acids
//================================================
*/
/datum/ammo/xeno
	icon_state = "toxin"
	ping = "ping_x"
	damage_type = TOX
	damage = 0
	accuracy = 10
	shell_speed = 1
	ammo_behavior = AMMO_XENO_ACID | AMMO_SKIPS_ALIENS

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	damage_bleed = 0
	stun = 1
	weaken = 2
	ammo_behavior = AMMO_XENO_TOX | AMMO_SKIPS_ALIENS | AMMO_IGNORE_RESIST

/datum/ammo/xeno/toxin/medium //Spitter
	name = "neurotoxic spatter"
	stun = 2
	weaken = 3
	shell_speed = 2

/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	stun = 3
	weaken = 4

/datum/ammo/xeno/acid
	icon_state = "neurotoxin"
	name = "acid spit"
	damage_type = BURN
	damage = 20

	on_shield_block(mob/M, obj/item/projectile/P)
		burst(M,P,damage_type)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 30
	shell_speed = 2

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	damage = 45

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "acid"
	ping = "ping_x"
	stun = 20
	weaken = 20 //If this bad boy hits you directly, watch out.
	ammo_behavior = AMMO_XENO_TOX | AMMO_SKIPS_ALIENS | AMMO_EXPLOSIVE | AMMO_IGNORE_RESIST

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
		G.visible_message("<span class='danger'>A glob of gas falls from the sky!</span>")
		G.prime()
		return

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	damage = 50
	stun = 1
	weaken = 1
	damage_type = BURN
	ammo_behavior = AMMO_XENO_ACID | AMMO_SKIPS_ALIENS | AMMO_EXPLOSIVE | AMMO_IGNORE_ARMOR | AMMO_INCENDIARY

	on_shield_block(mob/M, obj/item/projectile/P)
		burst(M,P,damage_type)

	drop_nade(turf/T)
		var/obj/item/weapon/grenade/xeno/G = new (T)
		G.visible_message("<span class='danger'>A glob of acid falls from the sky!</span>")
		G.prime()
		return

/*
//================================================
					Misc Ammo
//================================================
*/

/datum/ammo/alloy_spike
	name = "alloy spike"
	ping = "ping_s"
	damage = 40
	icon_state = "MSpearFlight"
	damage_type = BRUTE
	accuracy = 50
	max_range = 12
	accurate_range = 10
	armor_pen = HIGH_ARMOR_PENETRATION
	shrapnel_chance = 68

/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	damage = 50
	damage_type = BURN
	max_range = 5
	ammo_behavior = AMMO_INCENDIARY | AMMO_IGNORE_ARMOR

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_flame(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_flame(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_flame(get_turf(P))

	do_at_max_range(obj/item/projectile/P)
		drop_flame(get_turf(P))

/datum/ammo/flare
	name = "flare"
	ping = null //no bounce off.
	damage = 15
	damage_type = BURN
	accuracy = 15
	max_range = 15
	ammo_behavior = AMMO_INCENDIARY

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
		G.visible_message("<span class='warning'>\A [G] bursts into brilliant light nearby!</span>")
		G.on = 1
		processing_objects += G
		G.icon_state = "flare-on"
		G.damtype = "fire"
		G.SetLuminosity(G.brightness_on)
		return

#undef NEG_ARMOR_PENETRATION
#undef MIN_ARMOR_PENETRATION
#undef LOW_ARMOR_PENETRATION
#undef NORM_ARMOR_PENETRATION
#undef HIGH_ARMOR_PENETRATION
#undef MAX_ARMOR_PENETRATION