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
#define AMMO_IGNORE_ARMOR	1024
#define AMMO_IGNORE_RESIST	2048
#define AMMO_BALLISTIC		4096
*/

/datum/ammo
	var/name 		= "generic bullet"
	var/icon 		= 'icons/obj/projectiles.dmi'
	var/icon_state 	= "bullet"
	var/ping 		= "ping_b" //The icon that is displayed when the bullet bounces off something.
	var/sound_hit //When it deals damage.
	var/sound_armor //When it's blocked by human armor.
	var/sound_miss //When it misses someone.
	var/sound_bounce //When it bounces off something.

	var/iff_signal			= 0 //PLACEHOLDER. Bullets that can skip friendlies will call for this.
	var/accuracy 			= 0 //This is added to the bullet's base accuracy.
	var/accuracy_var_low	= 0 //How much the accuracy varies when fired.
	var/accuracy_var_high	= 0
	var/accurate_range 		= 0 //For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though.
	var/max_range 			= 0 //This will de-increment a counter on the bullet.
	var/scatter  			= 0 //How much the ammo scatters when burst fired, added to gun scatter, along with other mods.
	var/damage 				= 0 //This is the base damage of the bullet as it is fired.
	var/damage_var_low		= 0 //Same as with accuracy variance.
	var/damage_var_high		= 0
	var/damage_bleed 		= 0 //How much damage the bullet loses per turf traveled.
	var/damage_type 		= BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/penetration			= 0 //How much armor it ignores before calculations take place.
	var/shrapnel_chance 	= 0 //The % chance it will imbed in a human.
	var/shell_speed 		= 0 //How fast the projectile moves.
	var/bonus_projectiles_type //the type path of the extra projectiles
	var/bonus_projectiles_amount 	= 0 //How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together.
	var/debilitate[]		= null //stun,knockdown,knockout,irradiate,stutter,eyeblur,drowsy,agony

	New()
		accuracy 			= config.min_hit_accuracy //This is added to the bullet's base accuracy.
		accuracy_var_low	= config.min_proj_variance //How much the accuracy varies when fired.
		accuracy_var_high	= config.min_proj_variance
		accurate_range 		= config.close_shell_range //For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though.
		max_range 			= config.norm_shell_range //This will de-increment a counter on the bullet.
		damage_var_low		= config.min_proj_variance //Same as with accuracy variance.
		damage_var_high		= config.min_proj_variance
		damage_bleed 		= config.reg_damage_bleed //How much damage the bullet loses per turf traveled.
		shell_speed 		= config.slow_shell_speed //How fast the projectile moves.

	var/flags_ammo_behavior = AMMO_REGULAR //Nothing special about it.

	proc/do_at_half_range(obj/item/projectile/P)
		return

	proc/do_at_max_range(obj/item/projectile/P)
		return

	proc/on_shield_block(mob/M, obj/item/projectile/P) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
		return

	proc/on_hit_turf(turf/T, obj/item/projectile/P) //Special effects when hitting dense turfs.
		return

	proc/on_hit_mob(mob/M, obj/item/projectile/P) //Special effects when hitting mobs.
		return

	proc/on_hit_obj(obj/O, obj/item/projectile/P) //Special effects when hitting objects.
		return

	proc/knockback(mob/M, obj/item/projectile/P)
		if(!M || M == P.firer) return
		if(P.distance_travelled > 2 || M.lying) shake_camera(M, 2, 1) //Two tiles away or more, basically.

		else //One tile away or less.
			shake_camera(M, 3, 4)
			if(isliving(M)) //This is pretty ugly, but what can you do.
				if(isXeno(M))
					var/mob/living/carbon/Xenomorph/target = M
					if(target.mob_size == MOB_SIZE_BIG) return //Big xenos are not affected.
					target.apply_effects(0,1) //Smaller ones just get shaken.
					target << "<span class='xenodanger'>You are shaken by the sudden impact!</span>"
				else
					if(!isYautja(M)) //Not predators.
						var/mob/living/target = M
						target.apply_effects(1,2) //Humans get stunned a bit.
						target << "<span class='highdanger'>The blast knocks you off your feet!</span>"
			step_away(M,P)

	proc/burst(atom/target, obj/item/projectile/P, damage_type = BRUTE)
		if(!target || !P) return
		for(var/mob/living/carbon/M in orange(1,target))
			if(P.firer == M)
				continue
			M.visible_message("<span class='danger'>[M] is hit by backlash from \a [P.name]!</span>","[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You are hit by backlash from \a </b>[P.name]</b>!</span>")
			M.apply_damage(rand(5,P.damage/2),damage_type)

	proc/fire_bonus_projectiles(obj/item/projectile/original_P)
		set waitfor = 0
		var/i
		for(i = 0 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
			var/scatter_x = rand(-1,1)
			var/scatter_y = rand(-1,1)
			var/turf/new_target = locate(original_P.target_turf.x + round(scatter_x),original_P.target_turf.y + round(scatter_y),original_P.target_turf.z)
			if(!istype(new_target) || isnull(new_target)) continue	//If we didn't find anything, make another pass.
			var/obj/item/projectile/P = rnew(/obj/item/projectile, original_P.shot_from)
			P.generate_bullet(ammo_list[bonus_projectiles_type]) //No bonus damage or anything.
			P.original = new_target
			P.fire_at(new_target,original_P.firer,original_P.shot_from,P.ammo.max_range,P.ammo.shell_speed) //Fire!

	//This is sort of a workaround for now. There are better ways of doing this ~N.
	proc/stun_living(mob/living/target, obj/item/projectile/P) //Taser proc to stun folks.
		if(istype(target))
			if( isYautja(target) || isXeno(target) ) return //Not on aliens.
			if(target.mind && target.mind.special_role)
				switch(target.mind.special_role) //Switches are still better than evaluating this twice.
					if("IRON BEARS") //These antags can shrug off tasers so they are not shut down.
						target.apply_effects(1,1) //Barely affected.
						return
					if("UPP") //These antags can shrug off tasers so they are not shut down.
						target.apply_effects(1,1) //Barely affected.
						return
					if("DEATH SQUAD")
						target.apply_effects(0,1) //Almost unaffacted.
						return
			target.apply_effects(12,20)

	proc/drop_flame(turf/T) // ~Art updated fire 20JAN17
		if(!istype(T)) return
		if(locate(/obj/flamer_fire) in T) return
		new /obj/flamer_fire(T, 20, 20)


/*
//================================================
					Default Ammo
//================================================
*/
//Only when things screw up do we use this as a placeholder.
/datum/ammo/bullet
	name = "default bullet"
	icon_state = "bullet"
	flags_ammo_behavior = AMMO_BALLISTIC
	sound_hit 	 = "ballistic_hit"
	sound_armor  = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"

	New()
		..()
		damage = config.base_hit_damage
		shrapnel_chance = config.low_shrapnel_chance
		shell_speed = config.super_shell_speed

/*
//================================================
					Pistol Ammo
//================================================
*/

/datum/ammo/bullet/pistol
	name = "pistol bullet"
	New()
		..()
		damage = config.mlow_hit_damage
		accuracy = -config.low_hit_accuracy

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"

/datum/ammo/bullet/pistol/tranq
	name = "tranq bullet"
	debilitate = list(0,2,0,0,5,3,20,0)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	New()
		..()
		accuracy = -config.med_hit_accuracy
		shrapnel_chance = config.high_shrapnel_chance

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"
	New()
		..()
		accuracy = config.low_hit_accuracy
		penetration= config.med_armor_penetration
		shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	New()
		..()
		accuracy = -config.med_hit_accuracy
		accuracy_var_low = config.med_proj_variance
		damage = config.lmed_hit_damage
		penetration= config.min_armor_penetration
		shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	New()
		..()
		accuracy = config.med_hit_accuracy
		damage = config.mlow_hit_damage

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	debilitate = list(0,0,0,0,0,0,0,2)
	New()
		..()
		accuracy = config.med_hit_accuracy
		damage = config.med_hit_damage
		penetration= config.low_armor_penetration
		shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/mankey
	name = "live monkey"
	icon_state = "monkey1"
	ping = null //no bounce off.
	damage_type = BURN
	debilitate = list(4,4,0,0,0,0,0,0)
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR
	New()
		..()
		damage = config.min_hit_damage
		damage_var_high = config.high_proj_variance
		shell_speed = config.reg_shell_speed

	on_hit_mob(mob/M,obj/item/projectile/P)
		if(P && P.loc && !M.stat && !istype(M,/mob/living/carbon/monkey))
			P.visible_message("<span class='danger'>The [src] chimpers furiously!</span>")
			new /mob/living/carbon/monkey(P.loc)

/*
//================================================
					Revolver Ammo
//================================================
*/

/datum/ammo/bullet/revolver
	name = "revolver bullet"
	debilitate = list(1,0,0,0,0,0,0,0)
	New()
		..()
		accuracy = -config.med_hit_accuracy
		damage = config.lmed_hit_damage
		penetration= config.min_armor_penetration

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"
	New()
		..()
		damage = config.low_hit_damage

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	shrapnel_chance = 0
	damage_bleed = 0
	New()
		..()
		accuracy = config.med_hit_accuracy
		accurate_range = config.short_shell_range
		scatter = -config.low_scatter_value
		damage = config.low_hit_damage
		penetration = -config.mlow_armor_penetration

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	New()
		..()
		damage = config.med_hit_damage
		penetration= config.min_armor_penetration
		accuracy = -config.med_hit_accuracy

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	debilitate = list(0,2,0,0,0,1,0,0)
	New()
		..()
		accuracy_var_high = config.max_proj_variance
		damage = config.hmed_hit_damage
		damage_var_low = config.low_proj_variance
		damage_var_high = config.med_proj_variance
		penetration= config.mlow_armor_penetration

/*
//================================================
					SMG Ammo
//================================================
*/

/datum/ammo/bullet/smg
	name = "submachinegun bullet"
	New()
		..()
		accuracy_var_low = config.med_proj_variance
		accuracy_var_high = config.med_proj_variance
		damage = config.low_hit_damage
		damage_var_low = config.med_proj_variance
		damage_var_high = config.high_proj_variance
		accurate_range = config.close_shell_range

/datum/ammo/bullet/smg/ap
	name = "armor-piercing submachinegun bullet"
	New()
		..()
		scatter = config.min_scatter_value
		damage = config.mlow_hit_damage
		penetration= config.med_armor_penetration

/*
//================================================
					Rifle Ammo
//================================================
*/

/datum/ammo/bullet/rifle
	name = "rifle bullet"
	New()
		..()
		accurate_range = config.short_shell_range
		damage = config.lmed_hit_damage

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"
	New()
		..()
		accuracy = config.hmed_hit_accuracy
		penetration = config.med_armor_penetration

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	New()
		..()
		accuracy = -config.low_hit_accuracy

/datum/ammo/bullet/rifle/marksman
	name = "A19 high velocity bullet"
	shrapnel_chance = 0
	damage_bleed = 0
	New()
		..()
		damage = config.hmed_hit_damage
		accuracy = config.hmed_hit_accuracy
		scatter = -config.low_scatter_value
		penetration= config.low_armor_penetration
		shell_speed = config.fast_shell_speed

/datum/ammo/bullet/rifle/mar40
	name = "heavy rifle bullet"
	New()
		..()
		accuracy = -config.low_hit_accuracy
		damage = config.med_hit_damage
		penetration= -config.mlow_armor_penetration

/*
//================================================
					Shotgun Ammo
//================================================
*/

/datum/ammo/bullet/shotgun

/datum/ammo/bullet/shotgun/slug
	name = "shotgun slug"
	New()
		..()
		max_range = config.short_shell_range
		damage = config.hmed_hit_damage
		penetration= config.low_armor_penetration

	on_hit_mob(mob/M,obj/item/projectile/P)
		knockback(M,P)



/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	icon_state = "beanbag"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_IGNORE_RESIST
	New()
		..()
		max_range = config.short_shell_range
		shrapnel_chance = 0
		accuracy = config.med_hit_accuracy
		shell_speed = config.fast_shell_speed

	on_hit_mob(mob/M, obj/item/projectile/P)
		if(!M || M == P.firer) return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.name == "Human") //no effect on synths or preds.
				if(H.mind && H.mind.special_role)
					H.apply_effects(0,1) //ineffective against antags.
				else
					H.apply_effects(4,6)
			shake_camera(H, 2, 1)


/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	damage_type = BURN
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	New()
		..()
		accuracy = -config.low_hit_accuracy
		max_range = config.short_shell_range
		damage = config.med_hit_damage
		penetration= config.min_armor_penetration

	on_hit_mob(mob/M,obj/item/projectile/P)
		burst(get_turf(M),P,damage_type)
		knockback(M,P)

	on_hit_obj(obj/O,obj/item/projectile/P)
		burst(get_turf(P),P,damage_type)

	on_hit_turf(turf/T,obj/item/projectile/P)
		burst(get_turf(T),P,damage_type)

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	icon_state = "buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread

	New()
		..()
		accuracy_var_low = config.high_proj_variance
		accuracy_var_high = config.high_proj_variance
		accurate_range = config.min_shell_range
		max_range = config.close_shell_range
		damage = config.max_hit_damage
		damage_var_low = -config.med_proj_variance
		damage_var_high = config.med_proj_variance
		damage_bleed = config.buckshot_damage_bleed
		penetration	= -config.mlow_armor_penetration
		bonus_projectiles_amount = config.low_proj_extra
		shell_speed = config.reg_shell_speed

	on_hit_mob(mob/M,obj/item/projectile/P)
		knockback(M,P)


//buckshot variant only used by the masterkey shotgun attachment.
/datum/ammo/bullet/shotgun/buckshot/masterkey
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread/masterkey

	New()
		..()
		damage = config.high_hit_damage



/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"
	New()
		..()
		accuracy_var_low = config.high_proj_variance
		accuracy_var_high = config.high_proj_variance
		accurate_range = config.min_shell_range
		max_range = config.close_shell_range
		damage = config.med_hit_damage
		damage_var_low = -config.med_proj_variance
		damage_var_high = config.med_proj_variance
		damage_bleed = config.extra_damage_bleed
		shell_speed = config.reg_shell_speed

/datum/ammo/bullet/shotgun/spread/masterkey
	New()
		..()
		damage = config.low_hit_damage


/*
//================================================
					Sniper Ammo
//================================================
*/

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	damage_bleed = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_SKIPS_HUMANS
	New()
		..()
		accuracy = config.med_hit_accuracy
		accurate_range = config.min_shell_range
		max_range = config.max_shell_range
		scatter = -config.med_scatter_value
		damage = config.mhigh_hit_damage
		penetration= config.mhigh_armor_penetration
		shell_speed = config.ultra_shell_speed

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary sniper bullet"
	accuracy = 0
	damage_type = BURN
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SNIPER|AMMO_SKIPS_HUMANS
	New()
		..()
		accuracy_var_high = config.med_proj_variance
		max_range = config.norm_shell_range
		scatter = config.low_scatter_value
		damage = config.hmed_hit_damage
		penetration= config.low_armor_penetration

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	New()
		..()
		accuracy = -config.low_hit_accuracy
		max_range = config.norm_shell_range
		scatter = config.low_scatter_value
		damage = config.hmed_hit_damage
		damage_var_high = config.low_proj_variance
		penetration= -config.min_armor_penetration

	on_hit_mob(mob/M,obj/item/projectile/P)
		burst(get_turf(M),P,damage_type)

/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"
	New()
		..()
		accuracy = config.max_hit_accuracy
		damage = config.super_hit_damage
		shell_speed = config.ultra_shell_speed + 1

/*
//================================================
					Special Ammo
//================================================
*/

/datum/ammo/bullet/smartgun
	name = "smartgun bullet"
	icon_state = "redbullet" //Red bullets to indicate friendly fire restriction
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS
	New()
		..()
		accuracy = config.max_hit_accuracy
		accurate_range = config.short_shell_range
		damage = config.low_hit_damage
		penetration= config.mlow_armor_penetration

/datum/ammo/bullet/smartgun/lethal
	flags_ammo_behavior = AMMO_BALLISTIC
	icon_state 	= "bullet"
	New()
		..()
		damage = config.lmed_hit_damage
		penetration= config.low_armor_penetration

/datum/ammo/bullet/smartgun/dirty
	name = "irradiated smartgun bullet"
	iff_signal = ACCESS_IFF_PMC
	debilitate = list(0,0,0,3,0,0,0,1)
	New()
		..()
		shrapnel_chance = config.max_shrapnel_chance

/datum/ammo/bullet/smartgun/dirty/lethal
	flags_ammo_behavior = AMMO_BALLISTIC
	icon_state 	= "bullet"
	New()
		..()
		damage = config.lmed_hit_damage
		penetration= config.med_armor_penetration

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	icon_state 	= "redbullet" //Red bullets to indicate friendly fire restriction
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS
	New()
		..()
		accurate_range = config.short_shell_range
		max_range = config.short_shell_range
		damage = config.med_hit_damage
		penetration= config.mlow_armor_penetration
		accuracy = config.high_hit_accuracy

/datum/ammo/bullet/turret/dumb
	icon_state 	= "bullet"
	iff_signal = 0

/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state 	= "bullet" // Keeping it bog standard with the turret but allows it to be changed. Had to remove IFF so you have to watch out.
	New()
		..()
		accurate_range = config.short_shell_range
		max_range = config.norm_shell_range //Bump the range since view distance got bumped too.
		damage = config.low_hit_damage
		penetration= config.mhigh_armor_penetration //Bumped the penetration to serve a different role from sentries, MGs are a bit more offensive
		accuracy = config.high_hit_accuracy

/datum/ammo/bullet/minigun
	name = "minigun bullet"
	New()
		..()
		accuracy = -config.low_hit_accuracy
		accuracy_var_low = config.low_proj_variance
		accuracy_var_high = config.low_proj_variance
		accurate_range = config.short_shell_range
		damage = config.med_hit_damage
		penetration= config.low_armor_penetration
		shrapnel_chance = config.med_shrapnel_chance

/*
//================================================
					Rocket Ammo
//================================================
*/

/datum/ammo/rocket
	name = "high explosive rocket"
	icon_state = "missile"
	ping = null //no bounce off.
	sound_bounce	= "rocket_bounce"
	damage_bleed = 0
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET
	New()
		..()
		accuracy = config.low_hit_accuracy
		accurate_range = config.norm_shell_range
		max_range = config.long_shell_range
		damage = config.min_hit_damage
		shell_speed = config.slow_shell_speed

	on_hit_mob(mob/M, obj/item/projectile/P)
		explosion(get_turf(M), -1, 1, 4, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, get_turf(M))
		smoke.start()

	on_hit_obj(obj/O, obj/item/projectile/P)
		explosion(get_turf(O), -1, 1, 4, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, get_turf(O))
		smoke.start()

	on_hit_turf(turf/T, obj/item/projectile/P)
		explosion(T,  -1, 1, 4, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, T)
		smoke.start()

	do_at_max_range(obj/item/projectile/P)
		explosion(get_turf(P),  -1, 1, 4, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, get_turf(P))
		smoke.start()

/datum/ammo/rocket/ap
	name = "anti-armor rocket"
	damage_bleed = 0
	flags_ammo_behavior = AMMO_ROCKET
	New()
		..()
		accuracy = -config.min_hit_accuracy
		accuracy_var_low = config.med_proj_variance
		accurate_range = config.short_shell_range
		max_range = config.norm_shell_range
		damage = config.ultra_hit_damage
		penetration= config.max_armor_penetration

	on_hit_mob(mob/M, obj/item/projectile/P)
		explosion(get_turf(M), -1, 1, 2, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, get_turf(M))
		smoke.start()

	on_hit_obj(obj/O, obj/item/projectile/P)
		explosion(get_turf(O), -1, 1, 2, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, get_turf(O))
		smoke.start()

	on_hit_turf(turf/T, obj/item/projectile/P)
		explosion(T,  -1, 1, 2, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, T)
		smoke.start()

	do_at_max_range(obj/item/projectile/P)
		explosion(get_turf(P),  -1, 1, 2, 5)
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, get_turf(P))
		smoke.start()

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_INCENDIARY
	damage_type = BURN
	New()
		..()
		accuracy_var_low = config.med_proj_variance
		accurate_range = config.short_shell_range
		damage = config.super_hit_damage
		max_range = config.norm_shell_range

	drop_flame(turf/T)
		if(!istype(T)) return
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(6, 0, T)
		smoke.start()
		if(locate(/obj/flamer_fire) in T) return
		new /obj/flamer_fire(T, pick(15, 20, 25, 30))

		for(var/mob/living/carbon/M in range(3, T))
			if(istype(M,/mob/living/carbon/Xenomorph))
				if(M:fire_immune) continue

			if(M.stat == DEAD) continue
			M.adjust_fire_stacks(rand(5, 25))
			M.IgniteMob()
			M.visible_message("<span class='danger'>[M] bursts into flames!</span>","[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You burst into flames!</span>")

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_flame(get_turf(M))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_flame(get_turf(O))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_flame(T)

	do_at_max_range(obj/item/projectile/P)
		drop_flame(get_turf(P))

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	flags_ammo_behavior = AMMO_ROCKET
	New()
		..()
		damage = config.ultra_hit_damage
		max_range = config.long_shell_range

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_flame(get_turf(M))
		explosion(P.loc,  -1, 2, 4, 5)

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_flame(get_turf(O))
		explosion(P.loc,  -1, 2, 4, 5)

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_flame(T)
		explosion(P.loc,  -1, 2, 4, 5)

	do_at_max_range(obj/item/projectile/P)
		drop_flame(get_turf(P))
		explosion(P.loc,  -1, 2, 4, 5)

/*
//================================================
					Energy Ammo
//================================================
*/

/datum/ammo/energy
	ping = null //no bounce off. We can have one later.
	sound_hit 	 	= "energy_hit"
	sound_miss		= "energy_miss"
	sound_bounce	= "energy_bounce"

	damage_type = BURN
	flags_ammo_behavior = AMMO_ENERGY
	New()
		..()
		accuracy = config.hmed_hit_accuracy

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_ARMOR
	New()
		..()
		accurate_range 	= config.near_shell_range
		max_range 		= config.near_shell_range

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	damage_type = OXY
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST //Not that ignoring will do much right now.

	on_hit_mob(mob/M, obj/item/projectile/P)
		stun_living(M,P)

/datum/ammo/energy/yautja
	New()
		..()
		accurate_range = config.short_shell_range
		shell_speed = config.fast_shell_speed

/datum/ammo/energy/yautja/caster/bolt
	name = "plasma bolt"
	icon_state = "ion"
	debilitate = list(2,2,0,0,0,1,0,0)
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST
	New()
		..()
		damage = config.base_hit_damage

/datum/ammo/energy/yautja/caster/blast
	name = "plasma blast"
	icon_state = "pulse1"
	New()
		..()
		damage = config.low_hit_damage
		shell_speed = config.ultra_shell_speed

/datum/ammo/energy/yautja/caster/sphere
	name = "plasma eradication sphere"
	icon_state = "bluespace"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_EXPLOSIVE
	New()
		..()
		damage = config.lmed_hit_damage
		shell_speed = config.super_shell_speed

	on_hit_mob(mob/M,obj/item/projectile/P)
		explosion(get_turf(P.loc), -1, -1, 2, 2)

	on_hit_turf(turf/T,obj/item/projectile/P)
		explosion(T, -1, -1, 2, 2)

	on_hit_obj(obj/O,obj/item/projectile/P)
		explosion(get_turf(P.loc), -1, -1, 2, 2)

/datum/ammo/energy/yautja/rifle
	New()
		..()
		damage = config.base_hit_damage

	on_hit_mob(mob/M,obj/item/projectile/P)
		if(P.damage > 25)
			knockback(M,P)
			playsound(M.loc, 'sound/weapons/pulse.ogg', 25, 1)

	on_hit_turf(turf/T,obj/item/projectile/P)
		if(P.damage > 25)
			explosion(T, -1, -1, 2, -1)

	on_hit_obj(obj/O,obj/item/projectile/P)
		if(P.damage > 25)
			explosion(get_turf(P), -1, -1, 2, -1)

/datum/ammo/energy/yautja/rifle/bolt
	name = "plasma rifle bolt"
	icon_state = "ion"
	debilitate = list(0,2,0,0,0,0,0,0)
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST

/datum/ammo/energy/yautja/rifle/blast
	name = "plasma rifle blast"
	icon_state = "bluespace"
	New()
		..()
		shell_speed = config.super_shell_speed

/*
//================================================
					Xeno Spits
//================================================
*/
/datum/ammo/xeno
	icon_state = "toxin"
	ping = "ping_x"
	damage_type = TOX
	flags_ammo_behavior = AMMO_XENO_ACID
	New()
		..()
		accuracy = config.med_hit_accuracy
		accuracy_var_low = config.low_proj_variance
		accuracy_var_high = config.low_proj_variance
		max_range = config.short_shell_range

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	damage_bleed = 0
	debilitate = list(1,2,0,0,0,0,0,0)
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_IGNORE_RESIST
	New()
		..()
		shell_speed = config.reg_shell_speed
		max_range = config.close_shell_range

/datum/ammo/xeno/toxin/medium //Spitter
	name = "neurotoxic spatter"
	debilitate = list(2,3,0,0,1,2,0,0)
	New()
		..()
		shell_speed = config.fast_shell_speed
		accuracy_var_low = config.high_proj_variance
		accuracy_var_high = config.high_proj_variance

/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	debilitate = list(3,4,0,0,3,5,0,0)

/datum/ammo/xeno/sticky
	name = "sticky resin spit"
	flags_ammo_behavior = AMMO_SKIPS_ALIENS

	New()
		..()
		shell_speed = config.fast_shell_speed
		accuracy_var_high = config.max_proj_variance
		max_range = config.max_shell_range

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_resin(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_resin(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_resin(T)

	do_at_max_range(obj/item/projectile/P)
		drop_resin(get_turf(P))

	proc/drop_resin(turf/T)
		do_sticky_splatter(T)
		for(var/tempdir in CARDINAL_ALL_DIRS)
			do_sticky_splatter(get_step(T, tempdir))

	proc/do_sticky_splatter(turf/T)
		if(T.density) return

		for(var/obj/O in T.contents)
			if(istype(O, /obj/effect/alien/resin/sticky))
				return

			if(O.density) //We can't grow if something dense is here
				return

		new /obj/effect/alien/resin/sticky/thin(T)



/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "neurotoxin"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	damage_type = BURN
	New()
		..()
		damage = config.mlow_hit_damage
		shell_speed = config.reg_shell_speed

	on_shield_block(mob/M, obj/item/projectile/P)
		burst(M,P,damage_type)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	New()
		..()
		damage = config.low_hit_damage
		damage_var_low = config.low_proj_variance
		damage_var_high = config.med_proj_variance
		shell_speed = config.fast_shell_speed

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	New()
		..()
		damage = config.med_hit_damage
		damage_var_low = config.med_proj_variance
		damage_var_high = config.high_proj_variance

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "acid"
	ping = "ping_x"
	debilitate = list(19,21,0,0,11,12,0,0)
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_IGNORE_RESIST
	New()
		..()
		accuracy_var_high = config.max_proj_variance
		max_range = config.long_shell_range

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_nade(T)

	do_at_max_range(obj/item/projectile/P)
		drop_nade(get_turf(P))

	proc/drop_nade(turf/T)
		var/obj/item/weapon/grenade/xeno_weaken/G = new (T)
		G.visible_message("<span class='danger'>A glob of gas falls from the sky!</span>")
		G.prime()

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	debilitate = list(1,1,0,0,1,1,0,0)
	flags_ammo_behavior = AMMO_XENO_ACID|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_IGNORE_ARMOR|AMMO_INCENDIARY
	New()
		..()
		damage = config.med_hit_damage
		damage_var_high = config.max_proj_variance
		damage_type = BURN

	on_shield_block(mob/M, obj/item/projectile/P)
		burst(M,P,damage_type)

	drop_nade(turf/T)
		var/obj/item/weapon/grenade/xeno/G = new (T)
		G.visible_message("<span class='danger'>A glob of acid falls from the sky!</span>")
		G.prime()

/*
//================================================
					Misc Ammo
//================================================
*/

/datum/ammo/alloy_spike
	name = "alloy spike"
	ping = "ping_s"
	icon_state = "MSpearFlight"
	sound_hit 	 	= "alloy_hit"
	sound_armor	 	= "alloy_armor"
	sound_bounce	= "alloy_bounce"
	New()
		..()
		accuracy = config.max_hit_accuracy
		accurate_range = config.short_shell_range
		max_range = config.short_shell_range
		damage = config.lmed_hit_damage
		penetration= config.high_armor_penetration
		shrapnel_chance = config.max_shrapnel_chance

/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR
	New()
		..()
		max_range = config.close_shell_range
		damage = config.med_hit_damage

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
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY
	New()
		..()
		damage = config.min_hit_damage
		accuracy = config.med_hit_accuracy
		max_range = config.short_shell_range

	on_hit_mob(mob/M,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_obj(obj/O,obj/item/projectile/P)
		drop_nade(get_turf(P))

	on_hit_turf(turf/T,obj/item/projectile/P)
		drop_nade(T)

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