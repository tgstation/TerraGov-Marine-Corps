//Bitflag defines are in setup.dm. Referenced here.
/*
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

#define DEBUG_STAGGER_SLOWDOWN	0

/datum/ammo
	var/name 		= "generic bullet"
	var/icon 		= 'icons/obj/items/projectiles.dmi'
	var/icon_state 	= "bullet"
	var/ping 		= "ping_b" //The icon that is displayed when the bullet bounces off something.
	var/sound_hit //When it deals damage.
	var/sound_armor //When it's blocked by human armor.
	var/sound_miss //When it misses someone.
	var/sound_bounce //When it bounces off something.

	var/iff_signal					= 0 		// PLACEHOLDER. Bullets that can skip friendlies will call for this
	var/accuracy 					= 0 		// This is added to the bullet's base accuracy
	var/accuracy_var_low			= 0 		// How much the accuracy varies when fired
	var/accuracy_var_high			= 0
	var/accurate_range 				= 0 		// For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though
	var/accurate_range_min 			= 0			// Snipers use this to simulate poor accuracy at close ranges
	var/point_blank_range			= 0			// Weapons will get a large accuracy buff at this short range
	var/max_range 					= 0 		// This will de-increment a counter on the bullet
	var/scatter  					= 0 		// How much the ammo scatters when burst fired, added to gun scatter, along with other mods
	var/damage 						= 0 		// This is the base damage of the bullet as it is fired
	var/damage_var_low				= 0 		// Same as with accuracy variance
	var/damage_var_high				= 0
	var/damage_falloff 				= 0 		// How much damage the bullet loses per turf traveled
	var/damage_type 				= BRUTE 	// BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/penetration					= 0 		// How much armor it ignores before calculations take place
	var/shrapnel_chance 			= 0 		// The % chance it will imbed in a human
	var/shell_speed 				= 0 		// How fast the projectile moves
	var/bonus_projectiles_type 					// Type path of the extra projectiles
	var/bonus_projectiles_amount 	= 0 		// How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together
	var/debilitate[]				= null 		// Stun,knockdown,knockout,irradiate,stutter,eyeblur,drowsy,agony

	New()
		accuracy 			= config.min_hit_accuracy 	// This is added to the bullet's base accuracy.
		accuracy_var_low	= config.min_proj_variance 	// How much the accuracy varies when fired.
		accuracy_var_high	= config.min_proj_variance
		accurate_range 		= config.close_shell_range 	// For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though.
		max_range 			= config.norm_shell_range 	// This will de-increment a counter on the bullet.
		damage_var_low		= config.min_proj_variance 	// Same as with accuracy variance.
		damage_var_high		= config.min_proj_variance
		damage_falloff 		= config.reg_damage_falloff 	// How much damage the bullet loses per turf traveled.
		shell_speed 		= config.slow_shell_speed 	// How fast the projectile moves.

	var/flags_ammo_behavior = NOFLAGS

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

	proc/knockback(mob/M, obj/item/projectile/P, var/max_range = 2)
		if(!M || M == P.firer)
			return
		if(P.distance_travelled > max_range || M.lying) shake_camera(M, 2, 1) //Three tiles away or more, basically.

		else //Two tiles away or less.
			shake_camera(M, 3, 4)
			if(isliving(M)) //This is pretty ugly, but what can you do.
				if(isXeno(M))
					var/mob/living/carbon/Xenomorph/target = M
					if(target.mob_size == MOB_SIZE_BIG)
						return //Big xenos are not affected.
					target.apply_effects(0,1) //Smaller ones just get shaken.
					to_chat(target, "<span class='xenodanger'>You are shaken by the sudden impact!</span>")
				else
					if(!isYautja(M)) //Not predators.
						var/mob/living/target = M
						target.apply_effects(1,2) //Humans get stunned a bit.
						to_chat(target, "<span class='highdanger'>The blast knocks you off your feet!</span>")
			step_away(M,P)

	proc/staggerstun(mob/M, obj/item/projectile/P, var/max_range = 2, var/stun = 0, var/weaken = 1, var/stagger = 2, var/slowdown = 1, var/knockback = 1, var/size_threshold = 2, var/shake = 1)
		if(!M || M == P.firer)
			return
		if(shake && (P.distance_travelled > max_range || M.lying))
			shake_camera(M, shake+1, shake)
			return
		if(!isliving(M) || (isYautja(M) && size_threshold < 4) || (M.mob_size == MOB_SIZE_BIG && size_threshold < 3) || (isXeno(M) && size_threshold < 2) || ( ishuman(M) && size_threshold < 1))
			return
		if(shake)
			shake_camera(M, shake+2, shake+3)
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/target = M
			target.apply_effects(stun,weaken)
			#if DEBUG_STAGGER_SLOWDOWN
			to_chat(world, "<span class='debuginfo'>Damage: Initial stagger is: <b>[target.stagger]</b></span>")
			#endif
			target.adjust_stagger(stagger)
			#if DEBUG_STAGGER_SLOWDOWN
			to_chat(world, "<span class='debuginfo'>Damage: Final stagger is: <b>[target.stagger]</b></span>")
			#endif
			#if DEBUG_STAGGER_SLOWDOWN
			to_chat(world, "<span class='debuginfo'>Damage: Initial slowdown is: <b>[target.slowdown]</b></span>")
			#endif
			target.add_slowdown(slowdown)
			#if DEBUG_STAGGER_SLOWDOWN
			to_chat(world, "<span class='debuginfo'>Damage: Final slowdown is: <b>[target.slowdown]</b></span>")
			#endif
			to_chat(target, "<span class='xenodanger'>You are shaken by the sudden impact!</span>")
		else
			var/mob/living/target = M
			target.apply_effects(stun,weaken)
			to_chat(target, "<span class='highdanger'>The blast knocks you off your feet!</span>")
		for(var/i=0, i<knockback, i++)
			step_away(M,P)

	proc/burst(atom/target, obj/item/projectile/P, damage_type = BRUTE)
		if(!target || !P)
			return
		for(var/mob/living/carbon/M in orange(1,target))
			if(P.firer == M)
				continue
			M.visible_message("<span class='danger'>[M] is hit by backlash from \a [P.name]!</span>","[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You are hit by backlash from \a </b>[P.name]</b>!</span>")
			M.apply_damage(rand(5,P.damage/2),damage_type)

	proc/fire_bonus_projectiles(obj/item/projectile/original_P)
		set waitfor = 0
		var/i
		for(i = 1 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
			var/obj/item/projectile/P = rnew(/obj/item/projectile, original_P.shot_from)
			P.generate_bullet(ammo_list[bonus_projectiles_type]) //No bonus damage or anything.
			var/turf/new_target = null
			if(prob(P.scatter))
				var/scatter_x = rand(-1,1)
				var/scatter_y = rand(-1,1)
				new_target = locate(original_P.target_turf.x + round(scatter_x),original_P.target_turf.y + round(scatter_y),original_P.target_turf.z)
				if(!istype(new_target) || isnull(new_target))
					continue	//If we didn't find anything, make another pass.
				P.original = new_target
			P.accuracy = round(P.accuracy * original_P.accuracy/initial(original_P.accuracy)) //if the gun changes the accuracy of the main projectile, it also affects the bonus ones.
			if(!new_target)
				new_target = original_P.target_turf
			P.fire_at(new_target,original_P.firer,original_P.shot_from,P.ammo.max_range,P.ammo.shell_speed) //Fire!

	//This is sort of a workaround for now. There are better ways of doing this ~N.
	proc/stun_living(mob/living/target, obj/item/projectile/P) //Taser proc to stun folks.
		if(istype(target))
			if( isYautja(target) || isXeno(target) )
				return //Not on aliens.
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
		if(!istype(T))
			return
		if(locate(/obj/flamer_fire) in T)
			return
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
	point_blank_range = 2
	accurate_range_min = 0

/datum/ammo/bullet/New()
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

/datum/ammo/bullet/pistol/New()
	..()
	damage = config.low_hit_damage
	accuracy = -config.low_hit_accuracy

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"

/datum/ammo/bullet/pistol/tranq
	name = "tranq bullet"
	debilitate = list(0,2,0,0,5,3,20,0)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"

/datum/ammo/bullet/pistol/hollow/New()
	..()
	accuracy = -config.med_hit_accuracy
	shrapnel_chance = config.high_shrapnel_chance

/datum/ammo/bullet/pistol/hollow/on_hit_mob(mob/M,obj/item/projectile/P)
	staggerstun(M, P, config.close_shell_range, 0, 0, 1, 0.5, 0)

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"

/datum/ammo/bullet/pistol/ap/New()
	..()
	damage = config.mlow_hit_damage
	accuracy = config.low_hit_accuracy
	penetration= config.med_armor_penetration
	shrapnel_chance = config.med_shrapnel_chance

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"

/datum/ammo/bullet/pistol/heavy/New()
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

/datum/ammo/bullet/pistol/incendiary/New()
	..()
	accuracy = config.med_hit_accuracy
	damage = config.llow_hit_damage

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	debilitate = list(0,0,0,0,0,0,0,2)

/datum/ammo/bullet/pistol/squash/New()
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

/datum/ammo/bullet/pistol/mankey/New()
	..()
	damage = config.min_hit_damage
	damage_var_high = config.high_proj_variance
	shell_speed = config.reg_shell_speed

/datum/ammo/bullet/pistol/mankey/on_hit_mob(mob/M,obj/item/projectile/P)
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

/datum/ammo/bullet/revolver/New()
	..()
	accuracy = -config.med_hit_accuracy
	damage = config.lmed_hit_damage
	penetration= config.min_armor_penetration

/datum/ammo/bullet/revolver/on_hit_mob(mob/M,obj/item/projectile/P)
	staggerstun(M, P, config.close_shell_range, 0, 0, 1, 0.5, 0)

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"

/datum/ammo/bullet/revolver/small/New()
	..()
	damage = config.low_hit_damage

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	shrapnel_chance = 0
	damage_falloff = 0

/datum/ammo/bullet/revolver/marksman/New()
	..()
	accuracy = config.med_hit_accuracy
	accurate_range = config.short_shell_range
	scatter = -config.low_scatter_value
	damage = config.low_hit_damage
	penetration = config.mlow_armor_penetration

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"

/datum/ammo/bullet/revolver/heavy/New()
	..()
	damage = config.med_hit_damage
	penetration= config.min_armor_penetration
	accuracy = -config.med_hit_accuracy

/datum/ammo/bullet/revolver/heavy/on_hit_mob(mob/M,obj/item/projectile/P)
	staggerstun(M, P, config.close_shell_range, 0, 0, 1, 0.5, 0)

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"

/datum/ammo/bullet/revolver/highimpact/New()
	..()
	accuracy_var_high = config.max_proj_variance
	damage = config.hmed_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.med_proj_variance
	penetration= config.mlow_armor_penetration

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/M,obj/item/projectile/P)
	staggerstun(M, P, config.close_shell_range, 0, 1, 2, 2)

/*
//================================================
					SMG Ammo
//================================================
*/

/datum/ammo/bullet/smg
	name = "submachinegun bullet"

/datum/ammo/bullet/smg/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	damage = config.low_hit_damage
	damage_var_low = config.med_proj_variance
	damage_var_high = config.high_proj_variance
	accurate_range = config.close_shell_range
	damage_falloff = config.smg_damage_falloff

/datum/ammo/bullet/smg/ap
	name = "armor-piercing submachinegun bullet"

/datum/ammo/bullet/smg/ap/New()
	..()
	scatter = config.min_scatter_value
	damage = config.llow_hit_damage
	penetration= config.med_armor_penetration

/datum/ammo/bullet/smg/ppsh
	name = "submachinegun light bullet"

/datum/ammo/bullet/smg/ppsh/New()
	..()
	damage = config.low_hit_damage
	penetration= -config.min_armor_penetration
	accuracy = -config.low_hit_accuracy

/*
//================================================
					Rifle Ammo
//================================================
*/

/datum/ammo/bullet/rifle
	name = "rifle bullet"

/datum/ammo/bullet/rifle/New()
	..()
	accurate_range = config.short_shell_range
	damage = config.lmed_hit_damage
	penetration = config.mlow_armor_penetration

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"

/datum/ammo/bullet/rifle/ap/New()
	..()
	damage = config.hlow_hit_damage
	penetration = config.high_armor_penetration

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/rifle/incendiary/New()
	..()
	accuracy = -config.low_hit_accuracy

/datum/ammo/bullet/rifle/m4ra
	name = "A19 high velocity bullet"
	shrapnel_chance = 0
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC
	accurate_range_min = 6

/datum/ammo/bullet/rifle/m4ra/New()
	..()
	damage = config.hmed_hit_damage
	scatter = -config.low_scatter_value
	penetration= config.med_armor_penetration
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/rifle/m4ra/incendiary
	name = "A19 high velocity incendiary bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/rifle/m4ra/incendiary/New()
	..()
	damage = config.hmed_hit_damage
	accuracy = config.hmed_hit_accuracy
	scatter = -config.low_scatter_value
	penetration= config.low_armor_penetration
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/rifle/m4ra/impact
	name = "A19 high velocity impact bullet"
	flags_ammo_behavior = AMMO_BALLISTIC

/datum/ammo/bullet/rifle/m4ra/impact/New()
	..()
	damage = config.hmed_hit_damage
	accuracy = -config.low_hit_accuracy
	scatter = -config.low_scatter_value
	penetration= config.low_armor_penetration
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/rifle/m4ra/impact/on_hit_mob(mob/M, obj/item/projectile/P)
	knockback(M, P, config.max_shell_range)

/datum/ammo/bullet/rifle/mar40
	name = "heavy rifle bullet"

/datum/ammo/bullet/rifle/mar40/New()
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

/datum/ammo/bullet/shotgun/slug/New()
	..()
	max_range = config.short_shell_range
	damage = config.high_hit_damage
	penetration= config.low_armor_penetration

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/M,obj/item/projectile/P)
	staggerstun(M, P, config.close_shell_range, 0, 1, 2, 2)


/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	icon_state = "beanbag"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_IGNORE_RESIST

/datum/ammo/bullet/shotgun/beanbag/New()
	..()
	max_range = config.short_shell_range
	shrapnel_chance = 0
	accuracy = config.med_hit_accuracy
	shell_speed = config.fast_shell_speed

/datum/ammo/bullet/shotgun/beanbag/on_hit_mob(mob/M, obj/item/projectile/P)
	if(!M || M == P.firer)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species.name == "Human") //no effect on synths or preds.
			if(H.mind && H.mind.special_role)
				H.apply_effects(0,1) //ineffective against antags.
			else
				H.apply_effects(6,8)
		shake_camera(H, 2, 1)

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	damage_type = BURN
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY

/datum/ammo/bullet/shotgun/incendiary/New()
	..()
	accuracy = -config.low_hit_accuracy
	max_range = config.short_shell_range
	damage = config.med_hit_damage
	penetration= config.min_armor_penetration

/datum/ammo/bullet/shotgun/incendiary/on_hit_mob(mob/M,obj/item/projectile/P)
	burst(get_turf(M),P,damage_type)
	knockback(M,P)

/datum/ammo/bullet/shotgun/incendiary/on_hit_obj(obj/O,obj/item/projectile/P)
	burst(get_turf(P),P,damage_type)

/datum/ammo/bullet/shotgun/incendiary/on_hit_turf(turf/T,obj/item/projectile/P)
	burst(get_turf(T),P,damage_type)


/datum/ammo/bullet/shotgun/flechette
	name = "shotgun flechette shell"
	icon_state = "flechette"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/flechette_spread

/datum/ammo/bullet/shotgun/flechette/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	max_range = config.short_shell_range
	damage = config.hlow_hit_damage
	damage_var_low = -config.low_proj_variance
	damage_var_high = config.low_proj_variance
	penetration	= config.high_armor_penetration
	bonus_projectiles_amount = config.low_proj_extra

/datum/ammo/bullet/shotgun/flechette_spread
	name = "additional flechette"
	icon_state = "flechette"

/datum/ammo/bullet/shotgun/flechette_spread/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accuracy_var_high = config.med_proj_variance
	max_range = config.short_shell_range
	damage = config.hlow_hit_damage
	damage_var_low = -config.low_proj_variance
	damage_var_high = config.low_proj_variance
	penetration	= config.high_armor_penetration
	scatter = config.max_scatter_value*2 //bonus projectiles run their own scatter chance

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	icon_state = "buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread

/datum/ammo/bullet/shotgun/buckshot/New()
	..()
	accuracy_var_low = config.high_proj_variance
	accuracy_var_high = config.high_proj_variance
	accurate_range = config.min_shell_range
	max_range = config.close_shell_range
	damage = config.max_hit_damage
	damage_var_low = -config.med_proj_variance
	damage_var_high = config.med_proj_variance
	damage_falloff = config.buckshot_damage_falloff
	penetration	= -config.mlow_armor_penetration
	bonus_projectiles_amount = config.low_proj_extra
	shell_speed = config.reg_shell_speed

/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/M,obj/item/projectile/P)
	knockback(M,P)

//buckshot variant only used by the masterkey shotgun attachment.
/datum/ammo/bullet/shotgun/buckshot/masterkey
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread/masterkey

/datum/ammo/bullet/shotgun/buckshot/masterkey/New()
	..()
	damage = config.high_hit_damage

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"

/datum/ammo/bullet/shotgun/spread/New()
	..()
	accuracy_var_low = config.high_proj_variance
	accuracy_var_high = config.high_proj_variance
	accurate_range = config.min_shell_range
	max_range = config.close_shell_range
	damage = config.med_hit_damage
	damage_var_low = -config.med_proj_variance
	damage_var_high = config.med_proj_variance
	damage_falloff = config.buckshot_damage_falloff
	penetration	= -config.mlow_armor_penetration
	shell_speed = config.reg_shell_speed
	scatter = config.max_scatter_value*4 //bonus projectiles run their own scatter chance

/datum/ammo/bullet/shotgun/spread/masterkey/New()
	..()
	damage = config.low_hit_damage


/*
//================================================
					Sniper Ammo
//================================================
*/

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	damage_falloff = 0
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_SKIPS_HUMANS
	accurate_range_min = 10

/datum/ammo/bullet/sniper/New()
	..()
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
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SNIPER|AMMO_SKIPS_HUMANS

/datum/ammo/bullet/sniper/incendiary/New()
	..()
	accuracy_var_high = config.med_proj_variance
	max_range = config.norm_shell_range
	scatter = config.low_scatter_value
	damage = config.hmed_hit_damage
	penetration= config.low_armor_penetration

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	iff_signal = ACCESS_IFF_MARINE

/datum/ammo/bullet/sniper/flak/New()
	..()
	accuracy = -config.low_hit_accuracy
	max_range = config.norm_shell_range
	scatter = config.low_scatter_value
	damage = config.hmed_hit_damage
	damage_var_high = config.low_proj_variance
	penetration= -config.min_armor_penetration

/datum/ammo/bullet/sniper/flak/on_hit_mob(mob/M,obj/item/projectile/P)
	burst(get_turf(M),P,damage_type)

/datum/ammo/bullet/sniper/svd
	name = "crude sniper bullet"
	iff_signal = null

/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"
	iff_signal = ACCESS_IFF_PMC

/datum/ammo/bullet/sniper/elite/New()
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

/datum/ammo/bullet/smartgun/New()
	..()
	accurate_range = config.short_shell_range
	damage = config.low_hit_damage
	penetration= config.mlow_armor_penetration

/datum/ammo/bullet/smartgun/lethal
	flags_ammo_behavior = AMMO_BALLISTIC
	icon_state 	= "bullet"

/datum/ammo/bullet/smartgun/lethal/New()
	..()
	damage = config.lmed_hit_damage
	penetration= config.low_armor_penetration

/datum/ammo/bullet/smartgun/dirty
	name = "irradiated smartgun bullet"
	iff_signal = ACCESS_IFF_PMC
	debilitate = list(0,0,0,3,0,0,0,1)

/datum/ammo/bullet/smartgun/dirty/New()
	..()
	shrapnel_chance = config.max_shrapnel_chance

/datum/ammo/bullet/smartgun/dirty/lethal
	flags_ammo_behavior = AMMO_BALLISTIC
	icon_state 	= "bullet"

/datum/ammo/bullet/smartgun/dirty/lethal/New()
	..()
	damage = config.lmed_hit_damage
	penetration= config.med_armor_penetration

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	icon_state 	= "redbullet" //Red bullets to indicate friendly fire restriction
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS

/datum/ammo/bullet/turret/New()
	..()
	accurate_range = config.short_shell_range
	accuracy_var_low = config.low_proj_variance
	accuracy_var_high = config.low_proj_variance
	max_range = config.short_shell_range
	damage = config.low_hit_damage
	penetration= config.mlow_armor_penetration
	accuracy = -config.low_hit_accuracy

/datum/ammo/bullet/turret/dumb
	icon_state 	= "bullet"
	iff_signal = 0

/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state 	= "bullet" // Keeping it bog standard with the turret but allows it to be changed. Had to remove IFF so you have to watch out.

/datum/ammo/bullet/machinegun/New()
	..()
	accurate_range = config.short_shell_range
	damage = config.med_hit_damage
	penetration= config.mhigh_armor_penetration //Bumped the penetration to serve a different role from sentries, MGs are a bit more offensive
	accuracy = config.med_hit_accuracy

/datum/ammo/bullet/minigun
	name = "minigun bullet"

/datum/ammo/bullet/minigun/New()
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
	damage_falloff = 0
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET
	var/datum/effect_system/smoke_spread/smoke

/datum/ammo/rocket/New()
	..()
	smoke = new()
	accuracy = config.low_hit_accuracy
	accurate_range = config.norm_shell_range
	max_range = config.long_shell_range
	damage = config.min_hit_damage
	shell_speed = config.slow_shell_speed

/datum/ammo/rocket/Dispose()
	cdel(smoke)
	smoke = null
	. = ..()

/datum/ammo/rocket/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), -1, 1, 4, 5)
	smoke.set_up(1, get_turf(M))
	smoke.start()

/datum/ammo/rocket/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(O), -1, 1, 4, 5)
	smoke.set_up(1, get_turf(O))
	smoke.start()

/datum/ammo/rocket/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(T,  -1, 1, 4, 5)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P),  -1, 1, 4, 5)
	smoke.set_up(1, get_turf(P))
	smoke.start()

/datum/ammo/rocket/ap
	name = "anti-armor rocket"
	damage_falloff = 0

/datum/ammo/rocket/ap/New()
	..()
	accuracy = -config.min_hit_accuracy
	accuracy_var_low = config.med_proj_variance
	accurate_range = config.short_shell_range
	max_range = config.norm_shell_range
	damage = config.ultra_hit_damage //lmao tons of hit damage but it's never processed due to the below proc redefinitions
	penetration= config.max_armor_penetration

/datum/ammo/rocket/ap/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), -1, 1, 2, 5)
	smoke.set_up(1, get_turf(M))
	smoke.start()

/datum/ammo/rocket/ap/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(O), -1, 1, 2, 5)
	smoke.set_up(1, get_turf(O))
	smoke.start()

/datum/ammo/rocket/ap/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(T,  -1, 1, 2, 5)
	smoke.set_up(1, T)
	smoke.start()

/datum/ammo/rocket/ap/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P),  -1, 1, 2, 5)
	smoke.set_up(1, get_turf(P))
	smoke.start()

/datum/ammo/rocket/ltb
	name = "cannon round"
	icon_state = "ltb"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET

/datum/ammo/rocket/ltb/New()
	..()
	accuracy = config.med_hit_accuracy
	accurate_range = config.long_shell_range
	max_range = config.max_shell_range
	damage = config.low_hit_damage
	shell_speed = config.fast_shell_speed

/datum/ammo/rocket/ltb/on_hit_mob(mob/M, obj/item/projectile/P)
	explosion(get_turf(M), 1, 1, 5, 6)

/datum/ammo/rocket/ltb/on_hit_obj(obj/O, obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 5, 6)

/datum/ammo/rocket/ltb/on_hit_turf(turf/T, obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 5, 6)

/datum/ammo/rocket/ltb/do_at_max_range(obj/item/projectile/P)
	explosion(get_turf(P), 1, 1, 5, 6)

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_INCENDIARY|AMMO_EXPLOSIVE
	damage_type = BURN
/datum/ammo/rocket/wp/New()
	..()
	accuracy_var_low = config.med_proj_variance
	accurate_range = config.short_shell_range
	damage = config.super_hit_damage
	max_range = config.norm_shell_range

/datum/ammo/rocket/wp/drop_flame(turf/T)
	if(!istype(T))
		return
	smoke.set_up(1, T)
	smoke.start()
	if(locate(/obj/flamer_fire) in T)
		return
	new /obj/flamer_fire(T, pick(15, 20, 25, 30))
	for(var/mob/living/carbon/M in range(3, T))
		if(isXeno(M))
			var/mob/living/carbon/Xenomorph/X = M
			if(X.fire_immune)
				continue
		if(M.stat == DEAD)
			continue
		M.adjust_fire_stacks(rand(5, 25))
		M.IgniteMob()
		M.visible_message("<span class='danger'>[M] bursts into flames!</span>","[isXeno(M)?"<span class='xenodanger'>":"<span class='highdanger'>"]You burst into flames!</span>")

/datum/ammo/rocket/wp/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/rocket/wp/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/rocket/wp/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T)

/datum/ammo/rocket/wp/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	flags_ammo_behavior = AMMO_ROCKET
/datum/ammo/rocket/wp/quad/New()
	..()
	damage = config.ultra_hit_damage
	max_range = config.long_shell_range

/datum/ammo/rocket/wp/quad/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(M))
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/wp/quad/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(O))
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/wp/quad/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(T)
	explosion(P.loc,  -1, 2, 4, 5)

/datum/ammo/rocket/wp/quad/do_at_max_range(obj/item/projectile/P)
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

/datum/ammo/energy/New()
	..()
	accuracy = config.hmed_hit_accuracy

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_ARMOR

/datum/ammo/energy/emitter/New()
	..()
	accurate_range 	= config.near_shell_range
	max_range 		= config.near_shell_range

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	damage_type = OXY
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST //Not that ignoring will do much right now.

/datum/ammo/energy/taser/on_hit_mob(mob/M, obj/item/projectile/P)
	stun_living(M,P)

/datum/ammo/energy/yautja/

/datum/ammo/energy/yautja/New()
	..()
	accurate_range = config.short_shell_range
	shell_speed = config.fast_shell_speed


/datum/ammo/energy/yautja/pistol
	name = "plasma pistol bolt"
	icon_state = "ion"
	flags_ammo_behavior = AMMO_ENERGY
/datum/ammo/energy/yautja/pistol/New()
	..()
	damage = config.lmed_hit_damage
	shell_speed = config.reg_shell_speed

/datum/ammo/energy/yautja/caster/bolt
	name = "plasma bolt"
	icon_state = "ion"
	debilitate = list(2,2,0,0,0,1,0,0)
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_RESIST

/datum/ammo/energy/yautja/caster/bolt/New()
	..()
	damage = config.base_hit_damage

/datum/ammo/energy/yautja/caster/blast
	name = "plasma blast"
	icon_state = "pulse1"

/datum/ammo/energy/yautja/caster/blast/New()
	..()
	damage = config.low_hit_damage
	shell_speed = config.ultra_shell_speed

/datum/ammo/energy/yautja/caster/sphere
	name = "plasma eradication sphere"
	icon_state = "bluespace"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_EXPLOSIVE

/datum/ammo/energy/yautja/caster/sphere/New()
	..()
	damage = config.lmed_hit_damage
	shell_speed = config.super_shell_speed

/datum/ammo/energy/yautja/caster/sphere/on_hit_mob(mob/M,obj/item/projectile/P)
	explosion(get_turf(P.loc), -1, -1, 2, 2)

/datum/ammo/energy/yautja/caster/sphere/on_hit_turf(turf/T,obj/item/projectile/P)
	explosion(T, -1, -1, 2, 2)

/datum/ammo/energy/yautja/caster/sphere/on_hit_obj(obj/O,obj/item/projectile/P)
	explosion(get_turf(P.loc), -1, -1, 2, 2)

/datum/ammo/energy/yautja/rifle

/datum/ammo/energy/yautja/rifle/New()
	..()
	damage = config.base_hit_damage

/datum/ammo/energy/yautja/rifle/on_hit_mob(mob/M,obj/item/projectile/P)
	if(P.damage > 25)
		knockback(M,P)
		playsound(M.loc, 'sound/weapons/pulse.ogg', 25, 1)

/datum/ammo/energy/yautja/rifle/on_hit_turf(turf/T,obj/item/projectile/P)
	if(P.damage > 25)
		explosion(T, -1, -1, 2, -1)

/datum/ammo/energy/yautja/rifle/on_hit_obj(obj/O,obj/item/projectile/P)
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

/datum/ammo/energy/yautja/rifle/blast/New()
	..()
	shell_speed = config.super_shell_speed

/*
//================================================
					Xeno Spits
//================================================
*/
/datum/ammo/xeno
	icon_state = "neurotoxin"
	ping = "ping_x"
	damage_type = TOX
	flags_ammo_behavior = AMMO_XENO_ACID
	var/added_spit_delay = 0 //used to make cooldown of the different spits vary.
	var/spit_cost

/datum/ammo/xeno/New()
	..()
	accuracy = config.med_hit_accuracy
	accuracy_var_low = config.low_proj_variance
	accuracy_var_high = config.low_proj_variance
	max_range = config.short_shell_range

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	damage_falloff = 0
	debilitate = list(1,2,0,0,0,0,0,0)
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_IGNORE_RESIST
	spit_cost = 50

/datum/ammo/xeno/toxin/New()
	..()
	shell_speed = config.reg_shell_speed
	max_range = config.close_shell_range

/datum/ammo/xeno/toxin/medium //Spitter
	name = "neurotoxic spatter"
	debilitate = list(2,3,0,0,1,2,0,0)

/datum/ammo/xeno/toxin/medium/New()
	..()
	shell_speed = config.fast_shell_speed
	accuracy_var_low = config.high_proj_variance
	accuracy_var_high = config.high_proj_variance

/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	debilitate = list(3,4,0,0,3,5,0,0)

/datum/ammo/xeno/toxin/heavy/New()
	..()
	max_range = config.min_shell_range
	shell_speed = config.reg_shell_speed

/datum/ammo/xeno/sticky
	name = "sticky resin spit"
	icon_state = "sticky"
	ping = null
	flags_ammo_behavior = AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE
	added_spit_delay = 5
	spit_cost = 40

/datum/ammo/xeno/sticky/New()
	..()
	shell_speed = config.fast_shell_speed
	accuracy_var_high = config.max_proj_variance
	max_range = config.max_shell_range

/datum/ammo/xeno/sticky/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_resin(T)

/datum/ammo/xeno/sticky/do_at_max_range(obj/item/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/proc/drop_resin(turf/T)
	if(T.density)
		return
	for(var/obj/O in T.contents)
		if(istype(O, /obj/item/clothing/mask/facehugger))
			return
		if(istype(O, /obj/effect/alien/egg))
			return
		if(istype(O, /obj/structure/mineral_door) || istype(O, /obj/effect/alien/resin) || istype(O, /obj/structure/bed))
			return
		if(O.density && !(O.flags_atom & ON_BORDER))
			return
	new /obj/effect/alien/resin/sticky/thin(T)

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	damage_type = BURN
	added_spit_delay = 10
	spit_cost = 100

/datum/ammo/xeno/acid/New()
	..()
	damage = config.llow_hit_damage
	shell_speed = config.reg_shell_speed

/datum/ammo/xeno/acid/on_shield_block(mob/M, obj/item/projectile/P)
	burst(M,P,damage_type)

/datum/ammo/xeno/acid/on_hit_mob(mob/M, obj/item/projectile/P)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.status_flags & XENO_HOST && istype(C.buckled, /obj/structure/bed/nest) || C.stat == DEAD)
			return
	..()

/datum/ammo/xeno/acid/medium
	name = "acid spatter"

/datum/ammo/xeno/acid/medium/New()
	..()
	damage = config.low_hit_damage
	damage_var_low = config.low_proj_variance
	damage_var_high = config.med_proj_variance
	shell_speed = config.fast_shell_speed

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	added_spit_delay = 20

/datum/ammo/xeno/acid/heavy/New()
	..()
	max_range = config.min_shell_range
	damage = config.med_hit_damage
	damage_var_low = config.med_proj_variance
	damage_var_high = config.high_proj_variance
	shell_speed = config.reg_shell_speed

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "boiler_gas2"
	ping = "ping_x"
	debilitate = list(19,21,0,0,11,12,0,0)
	flags_ammo_behavior = AMMO_XENO_TOX|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_IGNORE_RESIST
	var/datum/effect_system/smoke_spread/smoke_system

/datum/ammo/xeno/boiler_gas/New()
	..()
	set_xeno_smoke()
	accuracy_var_high = config.max_proj_variance
	max_range = config.long_shell_range

/datum/ammo/xeno/boiler_gas/Dispose()
	cdel(smoke_system)
	smoke_system = null
	. = ..()

/datum/ammo/xeno/boiler_gas/on_hit_mob(mob/M, obj/item/projectile/P)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.status_flags & XENO_HOST && istype(C.buckled, /obj/structure/bed/nest) || C.stat == DEAD)
			return
	if(isXenoBoiler(P.firer))
		var/mob/living/carbon/Xenomorph/Boiler/B = P.firer
		smoke_system.amount = B.upgrade
	drop_nade(get_turf(P))

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/O, obj/item/projectile/P)
	if(isXenoBoiler(P.firer))
		var/mob/living/carbon/Xenomorph/Boiler/B = P.firer
		smoke_system.amount = B.upgrade
	drop_nade(get_turf(P))

/datum/ammo/xeno/boiler_gas/on_hit_turf(turf/T, obj/item/projectile/P)
	if(isXenoBoiler(P.firer))
		var/mob/living/carbon/Xenomorph/Boiler/B = P.firer
		smoke_system.amount = B.upgrade
	if(T.density && isturf(P.loc))
		drop_nade(P.loc) //we don't want the gas globs to land on dense turfs, they block smoke expansion.
	else
		drop_nade(T)

/datum/ammo/xeno/boiler_gas/do_at_max_range(obj/item/projectile/P)
	if(isXenoBoiler(P.firer))
		var/mob/living/carbon/Xenomorph/Boiler/B = P.firer
		smoke_system.amount = B.upgrade
	drop_nade(get_turf(P))

/datum/ammo/xeno/boiler_gas/proc/set_xeno_smoke(obj/item/projectile/P)
		smoke_system = new /datum/effect_system/smoke_spread/xeno_weaken()

/datum/ammo/xeno/boiler_gas/proc/drop_nade(turf/T)
	smoke_system.set_up(4, 0, T)
	smoke_system.start()
	T.visible_message("<span class='danger'>A glob of acid lands with a splat and explodes into noxious fumes!</span>")

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	icon_state = "boiler_gas"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	debilitate = list(1,1,0,0,1,1,0,0)
	flags_ammo_behavior = AMMO_XENO_ACID|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_IGNORE_ARMOR

/datum/ammo/xeno/boiler_gas/corrosive/New()
	..()
	damage = config.med_hit_damage
	damage_var_high = config.max_proj_variance
	damage_type = BURN

/datum/ammo/xeno/boiler_gas/on_shield_block(mob/M, obj/item/projectile/P)
	burst(M,P,damage_type)

/datum/ammo/xeno/boiler_gas/set_xeno_smoke(obj/item/projectile/P)
	smoke_system = new /datum/effect_system/smoke_spread/xeno_acid()

/datum/ammo/xeno/boiler_gas/drop_nade(turf/T)
	smoke_system.set_up(3, 0, T)
	smoke_system.start()
	T.visible_message("<span class='danger'>A glob of acid lands with a splat and explodes into corrosive bile!</span>")

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

/datum/ammo/alloy_spike/New()
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

/datum/ammo/flamethrower/New()
	..()
	max_range = config.close_shell_range
	damage = config.med_hit_damage

/datum/ammo/flamethrower/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/do_at_max_range(obj/item/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/tank_flamer/drop_flame(var/turf/T)
	if(!istype(T))
		return
	if(locate(/obj/flamer_fire) in T)
		return
	new /obj/flamer_fire(T, 20, 20, fire_spread_amount = 2)

/datum/ammo/flare
	name = "flare"
	ping = null //no bounce off.
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY

/datum/ammo/flare/New()
	..()
	damage = config.min_hit_damage
	accuracy = config.med_hit_accuracy
	max_range = config.short_shell_range

/datum/ammo/flare/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/flare/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/flare/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_nade(T)

/datum/ammo/flare/do_at_max_range(obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/flare/proc/drop_nade(var/turf/T)
	var/obj/item/device/flashlight/flare/G = new (T)
	G.visible_message("<span class='warning'>\A [G] bursts into brilliant light nearby!</span>")
	G.on = 1
	processing_objects += G
	G.icon_state = "flare-on"
	G.damtype = "fire"
	G.SetLuminosity(G.brightness_on)

/datum/ammo/rocket/nobugs
	name = "\improper NO BUGS rocket"
	damage = 1

	on_hit_mob(mob/M,obj/item/projectile/P)
		to_chat(M, "<font size=6 color=red>NO BUGS</font>")

/datum/ammo/rocket/nobugs/on_hit_obj(obj/O,obj/item/projectile/P)
	return

/datum/ammo/rocket/nobugs/on_hit_turf(turf/T,obj/item/projectile/P)
	return

/datum/ammo/rocket/nobugs/do_at_max_range(obj/item/projectile/P)
	return

/datum/ammo/grenade_container
	name = "grenade shell"
	ping = null
	damage_type = BRUTE
	var/nade_type = /obj/item/explosive/grenade/frag
	icon_state = "grenade"

/datum/ammo/grenade_container/New()
	..()
	damage = config.min_hit_damage
	accuracy = config.med_hit_accuracy
	max_range = config.near_shell_range

/datum/ammo/grenade_container/on_hit_mob(mob/M,obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/on_hit_obj(obj/O,obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/on_hit_turf(turf/T,obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/do_at_max_range(obj/item/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/proc/drop_nade(var/turf/T)
	var/obj/item/explosive/grenade/G = new nade_type(T)
	G.visible_message("<span class='warning'>\A [G] lands on [T]!</span>")
	G.det_time = 10
	G.activate()

/datum/ammo/grenade_container/smoke
	name = "smoke grenade shell"
	nade_type = /obj/item/explosive/grenade/smokebomb
	icon_state = "smoke_shell"
