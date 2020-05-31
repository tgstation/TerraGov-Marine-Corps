#define DEBUG_STAGGER_SLOWDOWN	0

GLOBAL_LIST_INIT(no_sticky_resin, typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/effect/alien/egg, /obj/structure/mineral_door, /obj/effect/alien/resin, /obj/structure/bed/nest))) //For sticky/acid spit

/datum/ammo
	var/name 		= "generic bullet"
	var/icon 		= 'icons/obj/items/projectiles.dmi'
	var/icon_state 	= "bullet"
	var/hud_state   = "unknown"  //Bullet type on the Ammo HUD
	var/hud_state_empty = "unknown"
	var/ping 		= "ping_b" //The icon that is displayed when the bullet bounces off something.
	var/sound_hit //When it deals damage.
	var/sound_armor //When it's blocked by human armor.
	var/sound_miss //When it misses someone.
	var/sound_bounce //When it bounces off something.

	var/iff_signal					= 0 		// PLACEHOLDER. Bullets that can skip friendlies will call for this
	var/accuracy 					= 5 		// This is added to the bullet's base accuracy
	var/accuracy_var_low			= 1 		// How much the accuracy varies when fired
	var/accuracy_var_high			= 1
	var/accurate_range 				= 5 		// For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though
	var/accurate_range_min 			= 0			// Snipers use this to simulate poor accuracy at close ranges
	var/point_blank_range			= 0			// Weapons will get a large accuracy buff at this short range
	var/max_range 					= 20 		// This will de-increment a counter on the bullet
	var/scatter  					= 0 		// How much the ammo scatters when burst fired, added to gun scatter, along with other mods
	var/damage 						= 0 		// This is the base damage of the bullet as it is fired
	var/damage_falloff 				= 1 		// How much damage the bullet loses per turf traveled
	var/damage_type 				= BRUTE 	// BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/penetration					= 0 		// How much armor it ignores before calculations take place
	var/shrapnel_chance 			= 0 		// The % chance it will imbed in a human
	var/shell_speed 				= 2 		// How fast the projectile moves
	var/bonus_projectiles_type 					// Type path of the extra projectiles
	var/bonus_projectiles_amount 	= 0 		// How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together
	var/bonus_projectiles_scatter	= 8			// Degrees scattered per two projectiles, each in a different direction.
	var/barricade_clear_distance	= 1			// How far the bullet can travel before incurring a chance of hitting barricades; normally 1.
	var/armor_type					= "bullet"	// Does this have an override for the armor type the ammo should test? Bullet by default
	var/sundering					= 0 		// How many stacks of sundering to apply to a mob on hit
	var/flags_ammo_behavior = NONE


/datum/ammo/proc/do_at_max_range(obj/projectile/proj)
	return

/datum/ammo/proc/on_shield_block(mob/M, obj/projectile/proj) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
	return

/datum/ammo/proc/on_hit_turf(turf/T, obj/projectile/proj) //Special effects when hitting dense turfs.
	return

/datum/ammo/proc/on_hit_mob(mob/M, obj/projectile/proj) //Special effects when hitting mobs.
	return

/datum/ammo/proc/on_hit_obj(obj/O, obj/projectile/proj) //Special effects when hitting objects.
	return

/datum/ammo/proc/knockback(mob/victim, obj/projectile/proj, max_range = 2)
	if(!victim || victim == proj.firer)
		CRASH("knockback called [victim ? "without a mob target" : "while the mob target was the firer"]")
	if(proj.distance_travelled > max_range || victim.lying_angle) shake_camera(victim, 2, 1) //Three tiles away or more, basically.

	else //Two tiles away or less.
		shake_camera(victim, 3, 4)
		if(isliving(victim)) //This is pretty ugly, but what can you do.
			if(isxeno(victim))
				var/mob/living/carbon/xenomorph/target = victim
				if(target.mob_size == MOB_SIZE_BIG)
					return //Big xenos are not affected.
				target.apply_effects(0, 1) //Smaller ones just get shaken.
				to_chat(target, "<span class='xenodanger'>You are shaken by the sudden impact!</span>")
			else
				var/mob/living/target = victim
				target.apply_effects(1, 2) //Humans get stunned a bit.
				to_chat(target, "<span class='highdanger'>The blast knocks you off your feet!</span>")
		step_away(victim, proj)

/datum/ammo/proc/staggerstun(mob/victim, obj/projectile/proj, max_range = 5, stun = 0, weaken = 0, stagger = 0, slowdown = 0, knockback = 0, shake = TRUE, soft_size_threshold = 3, hard_size_threshold = 2)
	if(!victim || victim == proj.firer)
		CRASH("staggerstun called [victim ? "without a mob target" : "while the mob target was the firer"]")
	if(!isliving(victim))
		return
	if(shake && (proj.distance_travelled > max_range || victim.lying_angle))
		shake_camera(victim, shake + 1, shake)
		return
	var/impact_message = ""
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/xeno_victim = victim
		if(xeno_victim.fortify) //If we're fortified we don't give a shit about staggerstun.
			impact_message += "<span class='xenodanger'>Your fortified stance braces you against the impact.</span>"
			return
		if(xeno_victim.crest_defense) //Crest defense halves all effects, and protects us from the stun.
			impact_message += "<span class='xenodanger'>Your crest protects you against some of the impact.</span>"
			slowdown *= 0.5
			stagger *= 0.5
			stun = 0
	if(shake)
		shake_camera(victim, shake+2, shake+3)
		if(isxeno(victim))
			impact_message += "<span class='xenodanger'>We are shaken by the sudden impact!</span>"
		else
			impact_message += "<span class='warning'>You are shaken by the sudden impact!</span>"

	//Check for and apply hard CC.
	if((victim.mob_size == MOB_SIZE_BIG && hard_size_threshold > 2) || (victim.mob_size == MOB_SIZE_XENO && hard_size_threshold > 1) || (ishuman(victim) && hard_size_threshold > 0))
		var/mob/living/living_victim = victim
		if(!living_victim.IsStun() && !living_victim.IsParalyzed()) //Prevent chain stunning.
			living_victim.apply_effects(stun,weaken)
		if(knockback)
			if(isxeno(victim))
				impact_message += "<span class='xenodanger'>The blast knocks you off your feet!</span>"
			else
				impact_message += "<span class='highdanger'>The blast knocks you off your feet!</span>"
			for(var/i in 1 to knockback)
				step_away(victim, proj)

	//Check for and apply soft CC
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		var/stagger_immune = FALSE
		if(isxeno(carbon_victim))
			var/mob/living/carbon/xenomorph/xeno_victim = victim
			if(isxenoqueen(xeno_victim)) //Stagger too powerful vs the Queen, so she's immune.
				stagger_immune = TRUE
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, "<span class='debuginfo'>Damage: Initial stagger is: <b>[target.stagger]</b></span>")
		#endif
		if(!stagger_immune)
			carbon_victim.adjust_stagger(stagger)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, "<span class='debuginfo'>Damage: Final stagger is: <b>[target.stagger]</b></span>")
		#endif
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, "<span class='debuginfo'>Damage: Initial slowdown is: <b>[target.slowdown]</b></span>")
		#endif
		carbon_victim.add_slowdown(slowdown)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, "<span class='debuginfo'>Damage: Final slowdown is: <b>[target.slowdown]</b></span>")
		#endif
	to_chat(victim, "[impact_message]") //Summarize all the bad shit that happened


/datum/ammo/proc/airburst(atom/target, obj/projectile/proj)
	if(!target || !proj)
		CRASH("airburst() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	for(var/mob/living/carbon/victim in orange(1, target))
		if(proj.firer == victim)
			continue
		victim.visible_message("<span class='danger'>[victim] is hit by backlash from \a [proj.name]!</span>",
			"[isxeno(victim)?"<span class='xenodanger'>We":"<span class='highdanger'>You"] are hit by backlash from \a </b>[proj.name]</b>!</span>")
		var/armor_block = victim.run_armor_check(null, proj.ammo.armor_type)
		victim.apply_damage(proj.damage * 0.1, proj.ammo.damage_type, null, armor_block)
		UPDATEHEALTH(victim)


/datum/ammo/proc/fire_bonus_projectiles(obj/projectile/main_proj, atom/shooter, atom/source, range, speed, angle)
	for(var/i = 1 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
		var/obj/projectile/new_proj = new /obj/projectile(main_proj.loc)
		if(bonus_projectiles_type)
			new_proj.generate_bullet(GLOB.ammo_list[bonus_projectiles_type]) //No bonus damage or anything.
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)
		new_proj.accuracy = round(new_proj.accuracy * main_proj.accuracy/initial(main_proj.accuracy)) //if the gun changes the accuracy of the main projectile, it also affects the bonus ones.

		//Scatter here is how many degrees extra stuff deviate from the main projectile, first two the same amount, one to each side, and from then on the extra pellets keep widening the arc.
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((i % 2) ? (-(i + 1) * 0.5) : (i * 0.5)))
		if(new_angle < 0)
			new_angle += 380
		else if(new_angle > 380)
			new_angle -= 380
		new_proj.fire_at(null, shooter, source, range, speed, new_angle, TRUE) //Angle-based fire. No target.


	//This is sort of a workaround for now. There are better ways of doing this ~N.
/datum/ammo/proc/stun_living(mob/living/target, obj/projectile/proj) //Taser proc to stun folks.
	if(!isliving(target) || isxeno(target))
		return //Not on aliens.
	target.apply_effects(12, 20)


/datum/ammo/proc/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(20, 20)


/datum/ammo/proc/set_smoke()
	return


/datum/ammo/proc/drop_nade(turf/T)
	return


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
	shell_speed = 3
	damage = 10
	shrapnel_chance = 10

/*
//================================================
					Pistol Ammo
//================================================
*/

/datum/ammo/bullet/pistol
	name = "pistol bullet"
	hud_state = "pistol"
	hud_state_empty = "pistol_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 20
	penetration = 5
	accurate_range = 5
	sundering = 2

/datum/ammo/bullet/pistol/tiny
	name = "light pistol bullet"
	hud_state = "pistol_light"

/datum/ammo/bullet/pistol/tranq
	name = "tranq bullet"
	hud_state = "pistol_tranq"
	damage = 25
	damage_type = STAMINA

/datum/ammo/bullet/pistol/tranq/on_hit_mob(mob/victim, obj/projectile/proj)
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents.add_reagent(/datum/reagent/toxin/potassium_chlorophoride, 1)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	hud_state = "pistol_hollow"
	accuracy = -15
	shrapnel_chance = 45

/datum/ammo/bullet/pistol/hollow/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"
	hud_state = "pistol_ap"
	damage = 20
	accuracy = 10
	penetration = 30
	shrapnel_chance = 25

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	hud_state = "pistol_heavy"
	accuracy = -10
	accuracy_var_low = 7
	damage = 35
	penetration = 5
	shrapnel_chance = 25

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	hud_state = "pistol_fire"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	accuracy = 15
	damage = 20

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	hud_state = "pistol_special"
	accuracy = 15
	damage = 32
	penetration = 10
	shrapnel_chance = 25

/datum/ammo/bullet/pistol/mankey
	name = "live monkey"
	icon_state = "monkey1"
	hud_state = "monkey"
	hud_state_empty = "monkey_empty"
	ping = null //no bounce off.
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR
	shell_speed = 2
	damage = 15


/datum/ammo/bullet/pistol/mankey/on_hit_mob(mob/M,obj/projectile/P)
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
	hud_state = "revolver"
	hud_state_empty = "revolver_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 40
	penetration = 10
	sundering = 3

/datum/ammo/bullet/revolver/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"
	hud_state = "revolver_small"
	damage = 30

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	scatter = -15
	damage = 30
	penetration = 10

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	hud_state = "revolver_heavy"
	damage = 50
	penetration = 5
	accuracy = -15

/datum/ammo/bullet/revolver/heavy/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	hud_state = "revolver_impact"
	accuracy_var_high = 10
	damage = 45
	penetration = 15
	sundering = 5

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 2, slowdown = 2, knockback = 1)

/*
//================================================
					SMG Ammo
//================================================
*/

/datum/ammo/bullet/smg
	name = "submachinegun bullet"
	hud_state = "smg"
	hud_state_empty = "smg_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accuracy_var_low = 7
	accuracy_var_high = 7
	damage = 20
	accurate_range = 5
	damage_falloff = 1
	sundering = 0.5
	penetration = 5
	
/datum/ammo/bullet/smg/ap
	name = "armor-piercing submachinegun bullet"
	hud_state = "smg_ap"
	damage = 15
	penetration = 30
	sundering = 3

/*
//================================================
					Rifle Ammo
//================================================
*/

/datum/ammo/bullet/rifle
	name = "rifle bullet"
	hud_state = "rifle"
	hud_state_empty = "rifle_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 15
	damage = 25
	penetration = 5
	sundering = 0.5

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"
	hud_state = "rifle_ap"
	damage = 20
	penetration = 30
	sundering = 3

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	hud_state = "rifle_fire"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	accuracy = -10

/datum/ammo/bullet/rifle/m4ra
	name = "A19 high velocity bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	shrapnel_chance = 0
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range_min = 6
	damage = 40
	penetration = 20
	sundering = 10

/datum/ammo/bullet/rifle/m4ra/incendiary
	name = "A19 high velocity incendiary bullet"
	hud_state = "hivelo_fire"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SUNDERING
	damage = 25
	accuracy = 10
	penetration = 20
	sundering = 2.5

/datum/ammo/bullet/rifle/m4ra/impact
	name = "A19 high velocity impact bullet"
	hud_state = "hivelo_impact"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 25
	penetration = 45
	sundering = 5

/datum/ammo/bullet/rifle/m4ra/impact/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, max_range = 40, stagger = 2, slowdown = 3.5, knockback = 1)

/datum/ammo/bullet/rifle/m4ra/smart
	name = "A19 high velocity smart bullet"
	hud_state = "hivelo_iff"
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	damage = 30
	penetration = 20
	sundering = 3

/datum/ammo/bullet/rifle/ak47
	name = "heavy rifle bullet"
	hud_state = "rifle_heavy"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 30
	penetration = 15
	sundering = 1.75

/datum/ammo/bullet/rifle/standard_dmr
	name = "marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range_min = 0
	accurate_range = 30
	damage = 70
	scatter = -15
	penetration = 15
	sundering = 2.5

/datum/ammo/bullet/rifle/standard_dmr/incendiary
	name = "incendiary marksman bullet"
	hud_state = "hivelo_fire"
	hud_state_empty = "hivelo_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 35
	sundering = 0 // incen doens't have sundering


/*
//================================================
					Shotgun Ammo
//================================================
*/

/datum/ammo/bullet/shotgun
	hud_state_empty = "shotgun_empty"
	shell_speed = 2


/datum/ammo/bullet/shotgun/slug
	name = "shotgun slug"
	hud_state = "shotgun_slug"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	shell_speed = 3
	max_range = 15
	damage = 80
	penetration = 40
	sundering = 7

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 2, slowdown = 4, knockback = 1)


/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	icon_state = "beanbag"
	hud_state = "shotgun_beanbag"
	flags_ammo_behavior = AMMO_BALLISTIC
	max_range = 15
	shrapnel_chance = 0
	accuracy = 15

/datum/ammo/bullet/shotgun/beanbag/on_hit_mob(mob/M, obj/projectile/P)
	if(!M || M == P.firer)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species?.count_human) //no effect on synths
			H.apply_effects(6,8)
		shake_camera(H, 2, 1)

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	hud_state = "shotgun_fire"
	damage_type = BRUTE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SUNDERING
	accuracy = -10
	max_range = 15
	damage = 40
	penetration = 20 
	sundering = 2

/datum/ammo/bullet/shotgun/incendiary/on_hit_mob(mob/victim, obj/projectile/proj)
	airburst(victim, proj)
	knockback(victim, proj)

/datum/ammo/bullet/shotgun/incendiary/on_hit_obj(obj/target_obj, obj/projectile/proj)
	airburst(target_obj, proj)

/datum/ammo/bullet/shotgun/incendiary/on_hit_turf(turf/target_turf, obj/projectile/proj)
	airburst(target_turf, proj)


/datum/ammo/bullet/shotgun/flechette
	name = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/flechette_spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 3
	accuracy_var_low = 8
	accuracy_var_high = 8
	max_range = 15
	damage = 50
	damage_falloff = 0.5
	penetration = 15
	sundering = 3

/datum/ammo/bullet/shotgun/flechette_spread
	name = "additional flechette"
	icon_state = "flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accuracy_var_low = 8
	accuracy_var_high = 8
	max_range = 15
	damage = 40
	damage_falloff = 1
	penetration = 25
	sundering = 2.5

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	flags_ammo_behavior = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread
	bonus_projectiles_amount = 5
	bonus_projectiles_scatter = 10
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 35
	damage_falloff = 4
	penetration = 0


/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/M,obj/projectile/P)
	knockback(M,P)

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"
	shell_speed = 2
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 30
	damage_falloff = 4
	penetration = 0

//buckshot variant only used by the masterkey shotgun attachment.
/datum/ammo/bullet/shotgun/buckshot/masterkey
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread/masterkey
	damage = 25

/datum/ammo/bullet/shotgun/spread/masterkey
	damage = 25

/datum/ammo/bullet/shotgun/sx16_buckshot
	name = "shotgun buckshot shell" //16 gauge is between 12 and 410 bore.
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
	icon_state = "buckshot"
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 10
	damage = 25
	damage_falloff = 4

/datum/ammo/bullet/shotgun/sx16_flechette
	name = "shotgun flechette shell"
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
	icon_state = "flechette"
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 15
	damage = 15
	damage_falloff = 0.5
	penetration = 15

/datum/ammo/bullet/shotgun/sx16_slug
	name = "shotgun slug"
	hud_state = "shotgun_slug"
	shell_speed = 3
	max_range = 15
	damage = 40
	penetration = 20

/datum/ammo/bullet/shotgun/sx16_slug/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, slowdown = 1, knockback = 1)

/datum/ammo/bullet/shotgun/tx15_flechette
	name = "shotgun flechette shell"
	icon_state = "flechette"
	hud_state = "shotgun_flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
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
	icon_state = "flechette"
	max_range = 15
	damage = 17
	damage_falloff = 0.25
	penetration = 15

/datum/ammo/bullet/shotgun/tx15_slug
	name = "shotgun slug"
	hud_state = "shotgun_slug"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	shell_speed = 3
	max_range = 15
	damage = 60
	penetration = 30
	sundering = 3.5

/datum/ammo/bullet/shotgun/tx15_slug/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, slowdown = 2, knockback = 1)

/datum/ammo/bullet/shotgun/mbx900_buckshot
	name = "light shotgun buckshot shell" // If .410 is the smallest shotgun shell, then...
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	flags_ammo_behavior = AMMO_BALLISTIC
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
	icon_state = "buckshot"
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 10
	damage = 40
	damage_falloff = 1

/datum/ammo/bullet/shotgun/mbx900_sabot
	name = "light shotgun sabot shell"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_slug"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	shell_speed = 5
	max_range = 30
	damage = 50
	penetration = 40
	sundering = 3

/datum/ammo/bullet/shotgun/mbx900_tracker
	name = "light shotgun tracker round"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_flechette"
	shell_speed = 4
	max_range = 30
	damage = 5
	penetration = 100

/datum/ammo/bullet/shotgun/mbx900_tracker/on_hit_mob(mob/living/victim, obj/projectile/proj)
	victim.AddComponent(/datum/component/dripping, DRIP_ON_TIME, 40 SECONDS, 2 SECONDS)

/*
//================================================
					Sniper Ammo
//================================================
*/

/datum/ammo/bullet/sniper
	name = "sniper bullet"
	hud_state = "sniper"
	hud_state_empty = "sniper_empty"
	damage_falloff = 0
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	accurate_range_min = 5
	shell_speed = 4
	accurate_range = 30
	max_range = 40
	scatter = -20
	damage = 80
	penetration = 60
	sundering = 15

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary sniper bullet"
	hud_state = "sniper_fire"
	accuracy = 0
	damage_type = BURN
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SNIPER|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	accuracy_var_high = 7
	max_range = 20
	scatter = 15
	damage = 50
	penetration = 20
	sundering = 5

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	hud_state = "sniper_flak"
	iff_signal = ACCESS_IFF_MARINE
	damage = 90
	penetration = 0
	sundering = 25

/datum/ammo/bullet/sniper/flak/on_hit_mob(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/sniper/svd
	name = "crude sniper bullet"
	hud_state = "sniper_crude"
	iff_signal = null
	damage = 75
	penetration = 35

/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"
	hud_state = "sniper_supersonic"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SKIPS_HUMANS
	iff_signal = ACCESS_IFF_MARINE|ACCESS_IFF_PMC
	accuracy = 40
	damage = 150
	sundering = 75

/*
//================================================
					Special Ammo
//================================================
*/

/datum/ammo/bullet/smartgun
	name = "smartgun bullet"
	icon_state = "redbullet" //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	accurate_range = 15
	damage = 20
	scatter = -10
	penetration = 20
	sundering = 1

/datum/ammo/bullet/smartmachinegun
	name = "smartmachinegun bullet"
	icon_state = "redbullet" //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	accurate_range = 15
	damage = 20
	penetration = 15
	sundering = 2

/datum/ammo/bullet/smartgun/lethal
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	icon_state 	= "bullet"
	sundering = 1

/datum/ammo/bullet/smartgun/dirty
	name = "irradiated smartgun bullet"
	hud_state = "smartgun_radioactive"
	iff_signal = ACCESS_IFF_PMC
	shrapnel_chance = 75

/datum/ammo/bullet/smartgun/dirty/on_hit_mob(mob/living/victim, obj/projectile/proj)
	victim.radiation += 3 //Needs a refactor.

/datum/ammo/bullet/smartgun/dirty/lethal
	flags_ammo_behavior = AMMO_BALLISTIC
	icon_state 	= "bullet"
	damage = 40
	penetration = 30

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	icon_state 	= "redbullet" //Red bullets to indicate friendly fire restriction
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	accurate_range = 10
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 40
	penetration = 10
	sundering = 2
	damage_falloff = 0.5 //forgot to add this

/datum/ammo/bullet/turret/dumb
	icon_state 	= "bullet"
	iff_signal = 0

/datum/ammo/bullet/turret/gauss
	name = "gauss turret heavy slug"
	damage = 30
	penetration = 30
	accurate_range = 3
	sundering = 0


/datum/ammo/bullet/turret/mini
	name = "small caliber autocannon bullet"
	damage = 35
	penetration = 10
	sundering = 0


/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state 	= "bullet" // Keeping it bog standard with the turret but allows it to be changed.
	iff_signal = ACCESS_IFF_MARINE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SKIPS_HUMANS|AMMO_SUNDERING
	accurate_range = 15
	damage = 75
	penetration = 75 //Bumped the penetration to serve a different role from sentries, MGs are a bit more offensive
	accuracy = 15
	barricade_clear_distance = 2
	sundering = 20

/datum/ammo/bullet/minigun
	name = "minigun bullet"
	hud_state = "minigun"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accuracy_var_low = 3
	accuracy_var_high = 3
	accurate_range = 5
	damage = 30
	penetration = 15
	shrapnel_chance = 25
	sundering = 1.5

/*
//================================================
					Rocket Ammo
//================================================
*/

/datum/ammo/rocket
	name = "high explosive rocket"
	icon_state = "missile"
	hud_state = "rocket_he"
	hud_state_empty = "rocket_empty"
	ping = null //no bounce off.
	sound_bounce	= "rocket_bounce"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	armor_type = "bomb"
	damage_falloff = 0
	shell_speed = 2
	accuracy = 40
	accurate_range = 20
	max_range = 30
	damage = 200
	penetration = 100
	sundering = 100

/datum/ammo/rocket/drop_nade(turf/T)
	explosion(T, 0, 4, 6, 5)

/datum/ammo/rocket/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/rocket/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))

/datum/ammo/rocket/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T)

/datum/ammo/rocket/do_at_max_range(obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/rocket/ap
	name = "anti-armor rocket"
	hud_state = "rocket_ap"
	damage_falloff = 0
	accurate_range = 15
	penetration = 150
	damage = 325

/datum/ammo/rocket/ap/drop_nade(turf/T)
	explosion(T, flash_range = 1)

/datum/ammo/rocket/ltb
	name = "cannon round"
	icon_state = "ltb"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET
	accuracy = 40
	accurate_range = 15
	max_range = 40
	penetration = 200
	damage = 300

/datum/ammo/rocket/ltb/drop_nade(turf/T)
	explosion(T, 0, 4, 6, 7)

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	hud_state = "rocket_fire"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_INCENDIARY|AMMO_EXPLOSIVE|AMMO_SUNDERING
	armor_type = "fire"
	damage_type = BURN
	accuracy_var_low = 7
	accurate_range = 15
	damage = 200
	penetration = 75
	max_range = 20
	sundering = 100

/datum/ammo/rocket/wp/drop_nade(turf/T, radius = 3)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(radius, T, 27, 27, 27, 17)

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	hud_state = "rocket_thermobaric"
	flags_ammo_behavior = AMMO_ROCKET
	damage = 200
	max_range = 30

/datum/ammo/rocket/wp/quad/drop_nade(turf/T, radius = 3)
	. = ..()
	if(!.)
		return
	explosion(T, 0, 3, 5, 5, throw_range = 0)


/*
//================================================
					Energy Ammo
//================================================
*/

/datum/ammo/energy
	ping = "ping_s"
	sound_hit 	 	= "energy_hit"
	sound_miss		= "energy_miss"
	sound_bounce	= "energy_bounce"

	damage_type = BURN
	flags_ammo_behavior = AMMO_ENERGY
	armor_type = "energy"
	accuracy = 20

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_ARMOR
	accurate_range = 10
	max_range = 10

/datum/ammo/energy/taser
	name = "taser bolt"
	icon_state = "stun"
	hud_state = "taser"
	hud_state_empty = "battery_empty"
	damage_type = OXY
	flags_ammo_behavior = AMMO_ENERGY
	max_range = 15
	accurate_range = 10

/datum/ammo/energy/taser/on_hit_mob(mob/M, obj/projectile/P)
	stun_living(M,P)


/datum/ammo/energy/lasgun
	name = "laser bolt"
	icon_state = "laser"
	hud_state = "laser"
	armor_type = "laser"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING
	shell_speed = 4
	accurate_range = 15
	damage = 25
	penetration = 10
	max_range = 30
	accuracy_var_low = 3
	accuracy_var_high = 3
	sundering = 1

/datum/ammo/energy/lasgun/M43
	icon_state = "laser2"

/datum/ammo/energy/lasgun/M43/overcharge
	name = "overcharged laser bolt"
	icon_state = "heavylaser"
	hud_state = "laser_sniper"
	damage = 42 
	max_range = 40
	penetration = 20
	sundering = 5

/datum/ammo/energy/lasgun/M43/heat
	name = "microwave heat bolt"
	icon_state = "heavylaser"
	hud_state = "laser_heat"
	damage = 12 //requires mod with -0.15 multiplier should math out to 10
	penetration = 100 // It's a laser that burns the skin! The fire stacks go threw anyway. 
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_SUNDERING
	sundering = 1

/datum/ammo/energy/lasgun/M43/blast
	name = "wide range laser blast"
	icon_state = "heavylaser"
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
	sundering = 2.5

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

/datum/ammo/energy/lasgun/pulsebolt
	name = "pulse bolt"
	icon_state = "pulse2"
	hud_state = "pulse"
	damage = 85 // this is gotta hurt...
	max_range = 40
	penetration = 100
	sundering = 100

/datum/ammo/energy/lasgun/M43/practice
	name = "practice laser bolt"
	icon_state = "laser"
	hud_state = "laser"
	damage = 45
	penetration = 0
	damage_type = STAMINA
	flags_ammo_behavior = AMMO_ENERGY

/datum/ammo/energy/lasgun/M43/practice/on_hit_mob(mob/living/carbon/C, obj/projectile/P)
	if(!istype(C) || C.stat == DEAD || C.issamexenohive(P.firer) )
		return

	if(isnestedhost(C))
		return

	staggerstun(C, P, stagger = 1, slowdown = 1) //Staggers and slows down briefly

	return ..()


/datum/ammo/energy/plasma
	name = "plasma bolt"
	icon_state = "pulse2"
	hud_state = "plasma"
	armor_type = "laser"
	shell_speed = 4
	accurate_range = 15
	damage = 40
	penetration = 15
	max_range = 30
	accuracy_var_low = 3
	accuracy_var_high = 3

/*
//================================================
					Xeno Spits
//================================================
*/
/datum/ammo/xeno
	icon_state = "neurotoxin"
	ping = "ping_x"
	damage_type = TOX
	flags_ammo_behavior = AMMO_XENO
	var/added_spit_delay = 0 //used to make cooldown of the different spits vary.
	var/spit_cost = 5
	armor_type = "bio"
	shell_speed = 1
	accuracy = 40
	accurate_range = 15
	max_range = 15
	accuracy_var_low = 3
	accuracy_var_high = 3

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	flags_ammo_behavior = AMMO_XENO
	spit_cost = 50
	added_spit_delay = 5
	damage_type = STAMINA
	accurate_range = 5
	max_range = 10
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 45

/datum/ammo/xeno/toxin/on_hit_mob(mob/living/carbon/C, obj/projectile/P)
	if(!istype(C) || C.stat == DEAD || C.issamexenohive(P.firer) )
		return

	if(isnestedhost(C))
		return

	staggerstun(C, P, stagger = 1, slowdown = 1) //Staggers and slows down briefly

	return ..()

/datum/ammo/xeno/toxin/upgrade1
	damage = 50

/datum/ammo/xeno/toxin/upgrade2
	damage = 55

/datum/ammo/xeno/toxin/upgrade3
	damage = 60


/datum/ammo/xeno/toxin/medium //Queen
	name = "neurotoxic spatter"
	added_spit_delay = 10
	spit_cost = 75
	damage = 55

/datum/ammo/xeno/toxin/medium/upgrade1
	damage = 60

/datum/ammo/xeno/toxin/medium/upgrade2
	damage = 65

/datum/ammo/xeno/toxin/medium/upgrade3
	damage = 70


/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	added_spit_delay = 15
	spit_cost = 100
	damage = 60

/datum/ammo/xeno/toxin/heavy/upgrade1
	damage = 65

/datum/ammo/xeno/toxin/heavy/upgrade2
	damage = 70

/datum/ammo/xeno/toxin/heavy/upgrade3
	damage = 75


/datum/ammo/xeno/sticky
	name = "sticky resin spit"
	icon_state = "sticky"
	ping = null
	flags_ammo_behavior = AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE|AMMO_XENO
	damage_type = STAMINA
	armor_type = "bio"
	spit_cost = 50
	sound_hit = "alien_resin_build2"
	sound_bounce = "alien_resin_build3"
	damage = 20 //minor; this is mostly just to provide confirmation of a hit
	max_range = 40


/datum/ammo/xeno/sticky/on_hit_mob(mob/M,obj/projectile/P)
	drop_resin(get_turf(M))
	if(istype(M,/mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.issamexenohive(P.firer))
			return
		C.add_slowdown(3) //slow em down


/datum/ammo/xeno/sticky/on_hit_obj(obj/O,obj/projectile/P)
	var/turf/T = get_turf(O)
	if(!T)
		T = get_turf(P)
	drop_resin(T)

/datum/ammo/xeno/sticky/on_hit_turf(turf/T,obj/projectile/P)
	if(!T)
		T = get_turf(P)
	drop_resin(T)

/datum/ammo/xeno/sticky/do_at_max_range(obj/projectile/P)
	drop_resin(get_turf(P))

/datum/ammo/xeno/sticky/proc/drop_resin(turf/T)
	if(T.density)
		return

	for(var/obj/O in T.contents)
		if(is_type_in_typecache(O, GLOB.no_sticky_resin))
			return

	new /obj/effect/alien/resin/sticky/thin(T)

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	damage_type = BURN
	added_spit_delay = 5
	spit_cost = 75
	flags_ammo_behavior = AMMO_XENO|AMMO_EXPLOSIVE
	armor_type = "acid"
	damage = 18
	max_range = 8

/datum/ammo/xeno/acid/on_shield_block(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 30

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	added_spit_delay = 8
	spit_cost = 75
	damage = 30

/datum/ammo/xeno/acid/heavy/on_hit_mob(mob/M,obj/projectile/P)
	var/turf/T = get_turf(M)
	if(!T)
		T = get_turf(P)
	drop_nade(T)

/datum/ammo/xeno/acid/heavy/on_hit_obj(obj/O,obj/projectile/P)
	var/turf/T = get_turf(O)
	if(!T)
		T = get_turf(P)
	drop_nade(T)


/datum/ammo/xeno/acid/heavy/on_hit_turf(turf/T,obj/projectile/P)
	if(!T)
		T = get_turf(P)
	drop_nade(T)

/datum/ammo/xeno/acid/heavy/do_at_max_range(obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/xeno/acid/drop_nade(turf/T) //Leaves behind a short lived acid pool; lasts for 1-3 seconds.
	if(T.density)
		return
	new /obj/effect/xenomorph/spray(T, 10)

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "boiler_gas2"
	ping = "ping_x"
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE
	var/datum/effect_system/smoke_spread/xeno/smoke_system
	var/danger_message = "<span class='danger'>A glob of acid lands with a splat and explodes into noxious fumes!</span>"
	armor_type = "bio"
	accuracy_var_high = 10
	max_range = 30

/datum/ammo/xeno/boiler_gas/on_hit_mob(mob/living/victim, obj/projectile/proj)
	drop_nade(get_turf(proj), proj.firer)
	victim.Paralyze(2.1 SECONDS)
	victim.blur_eyes(11)
	victim.adjustDrowsyness(12)

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(P), P.firer)

/datum/ammo/xeno/boiler_gas/on_hit_turf(turf/T, obj/projectile/P)
	var/target = (T.density && isturf(P.loc)) ? P.loc : T
	drop_nade(target, P.firer) //we don't want the gas globs to land on dense turfs, they block smoke expansion.

/datum/ammo/xeno/boiler_gas/do_at_max_range(obj/projectile/P)
	drop_nade(get_turf(P), P.firer)

/datum/ammo/xeno/boiler_gas/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro()

/datum/ammo/xeno/boiler_gas/drop_nade(turf/T, atom/firer, range = 1)
	set_smoke()
	if(isxeno(firer))
		var/mob/living/carbon/xenomorph/X = firer
		smoke_system.strength = X.xeno_caste.bomb_strength
		range = max(2, range + X.upgrade_as_number())
	smoke_system.set_up(range, T)
	smoke_system.start()
	T.visible_message(danger_message)

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	icon_state = "boiler_gas"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE
	armor_type = "acid"
	danger_message = "<span class='danger'>A glob of acid lands with a splat and explodes into corrosive bile!</span>"
	damage = 50
	damage_type = BURN
	penetration = 40

/datum/ammo/xeno/boiler_gas/corrosive/on_hit_mob(mob/living/victim, obj/projectile/proj)
	drop_nade(get_turf(proj), proj.firer)
	victim.Paralyze(0.1 SECONDS)
	victim.blur_eyes(1)
	victim.adjustDrowsyness(1)

/datum/ammo/xeno/boiler_gas/corrosive/on_shield_block(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/boiler_gas/corrosive/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/acid()

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
	armor_type = "bullet"
	accuracy = 40
	accurate_range = 15
	max_range = 15
	damage = 40
	penetration = 50
	shrapnel_chance = 75

/datum/ammo/flamethrower
	name = "flame"
	icon_state = "pulse0"
	hud_state = "flame"
	hud_state_empty = "flame_empty"
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR
	armor_type = "fire"
	max_range = 5
	damage = 50

/datum/ammo/flamethrower/on_hit_mob(mob/M,obj/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/on_hit_obj(obj/O,obj/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/on_hit_turf(turf/T,obj/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/do_at_max_range(obj/projectile/P)
	drop_flame(get_turf(P))

/datum/ammo/flamethrower/tank_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	flame_radius(2, T)

/datum/ammo/flamethrower/green
	name = "green flame"
	hud_state = "flame_green"

/datum/ammo/flamethrower/blue
	name = "blue flame"
	hud_state = "flame_blue"

/datum/ammo/flare
	name = "flare"
	ping = null //no bounce off.
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY
	damage = 15
	accuracy = 15
	max_range = 15

/datum/ammo/flare/on_hit_mob(mob/M,obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/flare/on_hit_obj(obj/O,obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/flare/on_hit_turf(turf/T,obj/projectile/P)
	drop_nade(T)

/datum/ammo/flare/do_at_max_range(obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/flare/drop_nade(turf/T)
	var/obj/item/explosive/grenade/flare/G = new (T)
	G.visible_message("<span class='warning'>\A [G] bursts into brilliant light nearby!</span>")
	G.turn_on()

/datum/ammo/rocket/toy
	name = "\improper toy rocket"
	damage = 1

	on_hit_mob(mob/M,obj/projectile/P)
		to_chat(M, "<font size=6 color=red>NO BUGS</font>")

/datum/ammo/rocket/toy/on_hit_obj(obj/O,obj/projectile/P)
	return

/datum/ammo/rocket/toy/on_hit_turf(turf/T,obj/projectile/P)
	return

/datum/ammo/rocket/toy/do_at_max_range(obj/projectile/P)
	return

/datum/ammo/grenade_container
	name = "grenade shell"
	ping = null
	damage_type = BRUTE
	var/nade_type = /obj/item/explosive/grenade/frag
	icon_state = "grenade"
	armor_type = "bomb"
	damage = 15
	accuracy = 15
	max_range = 10

/datum/ammo/grenade_container/on_hit_mob(mob/M,obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/on_hit_obj(obj/O,obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/on_hit_turf(turf/T,obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/do_at_max_range(obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/drop_nade(turf/T)
	var/obj/item/explosive/grenade/G = new nade_type(T)
	G.visible_message("<span class='warning'>\A [G] lands on [T]!</span>")
	G.det_time = 10
	G.activate()

/datum/ammo/grenade_container/smoke
	name = "smoke grenade shell"
	nade_type = /obj/item/explosive/grenade/smokebomb
	icon_state = "smoke_shell"
