#define DEBUG_STAGGER_SLOWDOWN 0

GLOBAL_LIST_INIT(no_sticky_resin, typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/alien/egg, /obj/structure/mineral_door, /obj/alien/resin, /obj/structure/bed/nest))) //For sticky/acid spit

/datum/ammo
	var/name 		= "generic bullet"
	var/icon 		= 'icons/obj/items/projectiles.dmi'
	var/icon_state 	= "bullet"
	///used in icons/obj/items/ammo for use in generating handful sprites
	var/handful_icon_state = "bullet"
	///how much of this ammo you can carry in a handful
	var/handful_amount = 8
	var/hud_state   = "unknown"  //Bullet type on the Ammo HUD
	var/hud_state_empty = "unknown"
	var/ping 		= "ping_b" //The icon that is displayed when the bullet bounces off something.
	var/sound_hit //When it deals damage.
	var/sound_armor //When it's blocked by human armor.
	var/sound_miss //When it misses someone.
	var/sound_bounce //When it bounces off something.

	var/accuracy 					= 0 		// This is added to the bullet's base accuracy
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
	///how much damage airbursts do to mobs around the target, multiplier of the bullet's damage
	var/airburst_multiplier	= 0.1
	var/flags_ammo_behavior = NONE
	///Determines what color our bullet will be when it flies
	var/bullet_color = COLOR_WHITE
	///If this ammo is hitscan, the icon of beam coming out from the gun
	var/hitscan_effect_icon = "beam"
	///A multiplier applied to piercing projectile, that reduces its damage/penetration/sundering on hit
	var/on_pierce_multiplier = 1
	///greyscale config for the bullet items associated with the ammo
	var/handful_greyscale_config = null
	///greyscale color for the bullet items associated with the ammo
	var/handful_greyscale_colors = null
	///greyscale config for the projectile associated with the ammo
	var/projectile_greyscale_config = null
	///greyscale color for the projectile associated with the ammo
	var/projectile_greyscale_colors = null
	///Multiplier for deflagrate chance
	var/deflagrate_multiplier = 1
	///Flat damage caused if fire_burst is triggered by deflagrate
	var/fire_burst_damage = 10
	///Base fire stacks added on hit if the projectile has AMMO_INCENDIARY
	var/incendiary_strength = 10

/datum/ammo/proc/do_at_max_range(turf/T, obj/projectile/proj)
	return

/datum/ammo/proc/on_shield_block(mob/M, obj/projectile/proj) //Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
	return

/datum/ammo/proc/on_hit_turf(turf/T, obj/projectile/proj) //Special effects when hitting dense turfs.
	return

/datum/ammo/proc/on_hit_mob(mob/M, obj/projectile/proj) //Special effects when hitting mobs.
	return

/datum/ammo/proc/on_hit_obj(obj/O, obj/projectile/proj) //Special effects when hitting objects.
	return

///Special effects for leaving a turf. Only called if the projectile has AMMO_LEAVE_TURF enabled
/datum/ammo/proc/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	return

/datum/ammo/proc/knockback(mob/victim, obj/projectile/proj, max_range = 2)
	if(!victim || victim == proj.firer)
		CRASH("knockback called [victim ? "without a mob target" : "while the mob target was the firer"]")

	else //Two tiles away or less.
		if(isliving(victim)) //This is pretty ugly, but what can you do.
			if(isxeno(victim))
				var/mob/living/carbon/xenomorph/target = victim
				if(target.mob_size == MOB_SIZE_BIG)
					return //Big xenos are not affected.
				target.apply_effects(0, 1) //Smaller ones just get shaken.
				to_chat(target, span_xenodanger("You are shaken by the sudden impact!"))
			else
				var/mob/living/target = victim
				target.apply_effects(1, 2) //Humans get stunned a bit.
				to_chat(target, span_highdanger("The blast knocks you off your feet!"))
		step_away(victim, proj)

/datum/ammo/proc/staggerstun(mob/victim, obj/projectile/proj, max_range = 5, stun = 0, weaken = 0, stagger = 0, slowdown = 0, knockback = 0, shake = 1, soft_size_threshold = 3, hard_size_threshold = 2)
	if(!victim)
		CRASH("staggerstun called without a mob target")
	if(!isliving(victim))
		return
	if(proj.distance_travelled > max_range)
		return
	var/impact_message = ""
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/xeno_victim = victim
		if(xeno_victim.fortify) //If we're fortified we don't give a shit about staggerstun.
			impact_message += span_xenodanger("Your fortified stance braces you against the impact.")
			return

		if(xeno_victim.endure) //Endure allows us to ignore staggerstun.
			impact_message += span_xenodanger("You endure the impact from [proj], shrugging off its effects.")
			return

		if(xeno_victim.crest_defense) //Crest defense halves all effects, and protects us from the stun.
			impact_message += span_xenodanger("Your crest protects you against some of the impact.")
			slowdown *= 0.5
			stagger *= 0.5
			stun = 0
	if(shake)
		if(isxeno(victim))
			impact_message += span_xenodanger("We are shaken by the sudden impact!")
		else
			impact_message += span_warning("You are shaken by the sudden impact!")

	//Check for and apply hard CC.
	if(hard_size_threshold >= victim.mob_size)
		var/mob/living/living_victim = victim
		if(!living_victim.IsStun() && !living_victim.IsParalyzed()) //Prevent chain stunning.
			living_victim.apply_effects(stun,weaken)
		if(knockback)
			if(isxeno(victim))
				impact_message += span_xenodanger("The blast knocks you off your feet!")
			else
				impact_message += span_highdanger("The blast knocks you off your feet!")
			for(var/i in 1 to knockback)
				step_away(victim, proj)

	//Check for and apply soft CC
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Initial stagger is: <b>[target.stagger]</b>"))
		#endif
		if(!isxenoqueen(carbon_victim)) //Stagger too powerful vs the Queen, so she's immune.
			carbon_victim.adjust_stagger(stagger)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Final stagger is: <b>[target.stagger]</b>"))
		#endif
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Initial slowdown is: <b>[target.slowdown]</b>"))
		#endif
		carbon_victim.add_slowdown(slowdown)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Final slowdown is: <b>[target.slowdown]</b>"))
		#endif
	to_chat(victim, "[impact_message]") //Summarize all the bad shit that happened


/datum/ammo/proc/airburst(atom/target, obj/projectile/proj)
	if(!target || !proj)
		CRASH("airburst() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	for(var/mob/living/carbon/victim in orange(1, target))
		if(proj.firer == victim)
			continue
		victim.visible_message(span_danger("[victim] is hit by backlash from \a [proj.name]!"),
			isxeno(victim) ? span_xenodanger("We are hit by backlash from \a </b>[proj.name]</b>!") : span_highdanger("You are hit by backlash from \a </b>[proj.name]</b>!"))
		var/armor_block = victim.get_soft_armor(proj.ammo.armor_type)
		victim.apply_damage(proj.damage * proj.airburst_multiplier, proj.ammo.damage_type, null, armor_block, updating_health = TRUE)

///handles the probability of a projectile hit to trigger fire_burst, based off actual damage done
/datum/ammo/proc/deflagrate(atom/target, obj/projectile/proj)
	if(!target || !proj)
		CRASH("deflagrate() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	if(!istype(target, /mob/living))
		return
	var/effective_damage = max(0, proj.damage - round(proj.distance_travelled * proj.damage_falloff)) //we want to take falloff into account
	if(!effective_damage)
		return
	var/mob/living/victim = target
	var/armor_block = victim.get_soft_armor("fire") //checks fire armour across the victim's whole body
	var/deflagrate_chance = (effective_damage * deflagrate_multiplier * (100 + min(0, proj.penetration - armor_block)) / 100)
	if(prob(deflagrate_chance))
		playsound(target, 'sound/effects/incendiary_explode.ogg', 45, falloff = 5)
		fire_burst(target, proj)

///the actual fireblast triggered by deflagrate
/datum/ammo/proc/fire_burst(atom/target, obj/projectile/proj)
	if(!target || !proj)
		CRASH("fire_burst() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	for(var/mob/living/carbon/victim in range(1, target))
		if(victim == target)
			victim.visible_message(span_danger("[victim] bursts into flames as they are deflagrated by \a [proj.name]!"))
		else
			victim.visible_message(span_danger("[victim] is scorched by [target] as they burst into flames!"),
				isxeno(victim) ? span_xenodanger("We are scorched by [target] as they burst into flames!") : span_highdanger("you are scorched by [target] as they burst into flames!"))
		//Damages the victims, inflicts brief stagger+slow, and ignites
		var/armor_block = victim.get_soft_armor("fire") //checks fire armour across the victim's whole body
		victim.apply_damage(fire_burst_damage, BURN, null, armor_block, updating_health = TRUE) //Placeholder damage, will be a ammo var

		staggerstun(victim, proj, 30, stagger = 0.5, slowdown = 0.5, shake = 0)
		victim.adjust_fire_stacks(5)
		victim.IgniteMob()


/datum/ammo/proc/fire_bonus_projectiles(obj/projectile/main_proj, atom/shooter, atom/source, range, speed, angle, target)
	var/effect_icon = ""
	var/proj_type = /obj/projectile
	if(istype(main_proj, /obj/projectile/hitscan))
		proj_type = /obj/projectile/hitscan
		var/obj/projectile/hitscan/main_proj_hitscan = main_proj
		effect_icon = main_proj_hitscan.effect_icon
	for(var/i = 1 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
		var/obj/projectile/new_proj = new proj_type(main_proj.loc, effect_icon)
		if(bonus_projectiles_type)
			new_proj.generate_bullet(bonus_projectiles_type)
			var/obj/item/weapon/gun/g = source
			if(source) //Check for the source so we don't runtime if we have bonus projectiles from a non-gun source like a Spitter
				new_proj.damage *= g.damage_mult //Bonus or reduced damage based on damage modifiers on the gun.
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)
		new_proj.accuracy = round(new_proj.accuracy * main_proj.accuracy/initial(main_proj.accuracy)) //if the gun changes the accuracy of the main projectile, it also affects the bonus ones.

		if(isgun(source))
			var/obj/item/weapon/gun/gun = source
			gun.apply_gun_modifiers(new_proj, target, shooter)

		//Scatter here is how many degrees extra stuff deviate from the main projectile, first two the same amount, one to each side, and from then on the extra pellets keep widening the arc.
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((i % 2) ? (-(i + 1) * 0.5) : (i * 0.5)))
		if(new_angle < 0)
			new_angle += 360
		else if(new_angle > 360)
			new_angle -= 360
		new_proj.fire_at(shooter.Adjacent(target) ? target : null, main_proj.firer, source, range, speed, new_angle, TRUE) //Angle-based fire. No target.

/// A variant of Fire_bonus_projectiles without fixed scatter and no link between gun and bonus_projectile accuracy
/datum/ammo/proc/fire_directionalburst(obj/projectile/main_proj, atom/shooter, atom/source, range, speed, angle, target)
	var/effect_icon = ""
	var/proj_type = /obj/projectile
	if(istype(main_proj, /obj/projectile/hitscan))
		proj_type = /obj/projectile/hitscan
		var/obj/projectile/hitscan/main_proj_hitscan = main_proj
		effect_icon = main_proj_hitscan.effect_icon
	for(var/i = 1 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
		var/obj/projectile/new_proj = new proj_type(main_proj.loc, effect_icon)
		if(bonus_projectiles_type)
			new_proj.generate_bullet(bonus_projectiles_type)
			if(isgun(source)) //Check for the source so we don't runtime if we have bonus projectiles from a non-gun source like a Spitter
				var/obj/item/weapon/gun/gun = source
				new_proj.damage *= gun.damage_mult //Bonus or reduced damage based on damage modifiers on the gun.
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)

		///Scatter here is how many degrees extra stuff deviate from the main projectile's firing angle. Fully randomised with no 45 degree cap like normal bullets
		var/f = (i-1)
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((f % 2) ? (-(f + 1) * 0.5) : (f * 0.5)))
		if(new_angle < 0)
			new_angle += 360
		if(new_angle > 360)
			new_angle -= 360
		new_proj.fire_at(shooter.Adjacent(target) ? target : null, main_proj.loc, source, range, speed, new_angle, TRUE) //Angle-based fire. No target.

/datum/ammo/proc/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(20, 20)


/datum/ammo/proc/set_smoke()
	return


/datum/ammo/proc/drop_nade(turf/T)
	return

///called on projectile process() when SPECIAL_PROCESS flag is active
/datum/ammo/proc/ammo_process(obj/projectile/proj, damage)
	CRASH("ammo_process called with unimplemented process!")



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
	bullet_color = COLOR_VERY_SOFT_YELLOW

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
	damage = 25
	damage_type = STAMINA

/datum/ammo/bullet/pistol/tranq/on_hit_mob(mob/victim, obj/projectile/proj)
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents.add_reagent(/datum/reagent/toxin/potassium_chlorophoride, 1)

/datum/ammo/bullet/pistol/hollow
	name = "hollowpoint pistol bullet"
	hud_state = "pistol_hollow"
	accuracy = -10
	shrapnel_chance = 45
	sundering = 2

/datum/ammo/bullet/pistol/hollow/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"
	hud_state = "pistol_ap"
	damage = 20
	penetration = 12.5
	shrapnel_chance = 25
	sundering = 2

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	hud_state = "pistol_heavy"
	damage = 30
	penetration = 5
	shrapnel_chance = 25
	sundering = 2.15

/datum/ammo/bullet/pistol/superheavy
	name = "high impact pistol bullet"
	hud_state = "pistol_hollow"
	damage = 45
	penetration = 15
	sundering = 3.5

/datum/ammo/bullet/pistol/superheavy/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1, slowdown = 1, shake = 0)

/datum/ammo/bullet/pistol/superheavy/derringer
	handful_amount = 2
	handful_icon_state = "derringer"

/datum/ammo/bullet/pistol/mech
	name = "super-heavy pistol bullet"
	damage = 40
	penetration = 15
	sundering = 1

/datum/ammo/bullet/pistol/mech/burst
	name = "super-heavy pistol bullet"
	damage = 35
	penetration = 10
	sundering = 0.5

/datum/ammo/bullet/pistol/incendiary
	name = "incendiary pistol bullet"
	hud_state = "pistol_fire"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 20

/datum/ammo/bullet/pistol/squash
	name = "squash-head pistol bullet"
	hud_state = "pistol_special"
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
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_IGNORE_ARMOR
	shell_speed = 2
	damage = 15


/datum/ammo/bullet/pistol/mankey/on_hit_mob(mob/M, obj/projectile/P)
	if(!M.stat && !ismonkey(M))
		P.visible_message(span_danger("The [src] chimpers furiously!"))
		new /mob/living/carbon/human/species/monkey(P.loc)

/*
//================================================
					Revolver Ammo
//================================================
*/

/datum/ammo/bullet/revolver
	name = "revolver bullet"
	hud_state = "revolver"
	hud_state_empty = "revolver_empty"
	handful_amount = 7
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 45
	penetration = 10
	sundering = 3

/datum/ammo/bullet/revolver/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1, slowdown = 0.5, knockback = 1)

datum/ammo/bullet/revolver/tp44
	name = "standard revolver bullet"
	damage = 30
	penetration = 20
	sundering = 1.5

/datum/ammo/bullet/revolver/tp44/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 0, slowdown = 0.5, knockback = 1, shake = 0)

/datum/ammo/bullet/revolver/small
	name = "small revolver bullet"
	hud_state = "revolver_small"
	damage = 30

/datum/ammo/bullet/revolver/small/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, slowdown = 0.5)

/datum/ammo/bullet/revolver/marksman
	name = "slimline revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	damage = 30
	penetration = 10

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	hud_state = "revolver_heavy"
	damage = 50
	penetration = 5
	accuracy = -10

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	hud_state = "revolver_impact"
	handful_amount = 6
	damage = 50
	penetration = 20
	sundering = 3

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 1, slowdown = 1, knockback = 1, shake = 0.5)

/datum/ammo/bullet/revolver/ricochet
	bonus_projectiles_type = /datum/ammo/bullet/revolver/small

/datum/ammo/bullet/revolver/ricochet/one
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet

/datum/ammo/bullet/revolver/ricochet/two
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/one

/datum/ammo/bullet/revolver/ricochet/three
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/two

/datum/ammo/bullet/revolver/ricochet/four
	bonus_projectiles_type = /datum/ammo/bullet/revolver/ricochet/three

/datum/ammo/bullet/revolver/ricochet/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, slowdown = 0.5)

/datum/ammo/bullet/revolver/ricochet/on_hit_turf(turf/T, obj/projectile/proj)
	. = ..()
	var/ricochet_angle = 360 - Get_Angle(proj.firer, T)

	// Check for the neightbour tile
	var/rico_dir_check
	switch(ricochet_angle)
		if(-INFINITY to 45)
			rico_dir_check = EAST
		if(46 to 135)
			rico_dir_check = ricochet_angle > 90 ? SOUTH : NORTH
		if(136 to 225)
			rico_dir_check = ricochet_angle > 180 ? WEST : EAST
		if(126 to 315)
			rico_dir_check = ricochet_angle > 270 ? NORTH : SOUTH
		if(316 to INFINITY)
			rico_dir_check = WEST

	var/turf/next_turf = get_step(T, rico_dir_check)
	if(next_turf.density)
		ricochet_angle += 180

	bonus_projectiles_amount = 1
	fire_bonus_projectiles(proj, proj.firer, proj.shot_from, proj.proj_max_range, proj.projectile_speed, ricochet_angle)
	bonus_projectiles_amount = 0


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
	accurate_range = 4
	damage_falloff = 1
	sundering = 0.5
	penetration = 5

/datum/ammo/bullet/smg/ap
	name = "armor-piercing submachinegun bullet"
	hud_state = "smg_ap"
	damage = 15
	penetration = 30
	sundering = 3

/datum/ammo/bullet/smg/incendiary
	name = "incendiary submachinegun bullet"
	hud_state = "smg_fire"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 18
	penetration = 0


/datum/ammo/bullet/smg/mech
	name = "super-heavy submachinegun bullet"
	damage = 20
	sundering = 0.25
	penetration = 10

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
	accurate_range = 12
	damage = 25
	penetration = 5
	sundering = 0.5

/datum/ammo/bullet/rifle/ap
	name = "armor-piercing rifle bullet"
	hud_state = "rifle_ap"
	damage = 20
	penetration = 30
	sundering = 3

/datum/ammo/bullet/rifle/hv
	name = "high-velocity rifle bullet"
	hud_state = "hivelo"
	damage = 20
	penetration = 20
	sundering = 1.25

/datum/ammo/bullet/rifle/heavy
	name = "heavy rifle bullet"
	hud_state = "hivelo"
	damage = 30
	penetration = 10
	sundering = 1.25

/datum/ammo/bullet/rifle/repeater
	name = "heavy impact rifle bullet"
	hud_state = "revolver_heavy"
	damage = 70
	penetration = 20
	sundering = 1.25

/datum/ammo/bullet/rifle/repeater/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, max_range = 3, slowdown = 2, stagger = 1, shake = 0.5)

/datum/ammo/bullet/rifle/incendiary
	name = "incendiary rifle bullet"
	hud_state = "rifle_fire"
	damage_type = BURN
	shrapnel_chance = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	accuracy = -10

/datum/ammo/bullet/rifle/machinegun
	name = "machinegun bullet"
	hud_state = "rifle_heavy"
	damage = 20
	penetration = 10

/datum/ammo/bullet/rifle/tx8
	name = "A19 high velocity bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	shrapnel_chance = 0
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 15
	accurate_range_min = 6
	damage = 40
	penetration = 20
	sundering = 10

/datum/ammo/bullet/rifle/tx8/incendiary
	name = "high velocity incendiary bullet"
	hud_state = "hivelo_fire"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SUNDERING
	damage = 25
	accuracy = -10
	penetration = 20
	sundering = 2.5

/datum/ammo/bullet/rifle/tx8/impact
	name = "high velocity impact bullet"
	hud_state = "hivelo_impact"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOVABLE
	damage = 25
	penetration = 30
	sundering = 5

/datum/ammo/bullet/rifle/tx8/impact/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, max_range = 20, slowdown = 1, shake = 0)

/datum/ammo/bullet/rifle/mpi_km
	name = "crude heavy rifle bullet"
	hud_state = "rifle_heavy"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 30
	penetration = 15
	sundering = 1.75

/datum/ammo/bullet/rifle/standard_dmr
	name = "marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0.5
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 25
	accurate_range_min = 6
	max_range = 40
	damage = 65
	penetration = 15
	sundering = 2

/datum/ammo/bullet/rifle/standard_br
	name = "light marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	penetration = 15
	damage = 32.5
	sundering = 1.25

/datum/ammo/bullet/rifle/standard_br/incendiary
	name = "incendiary light marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 25
	sundering = 0
	accuracy = -10

/datum/ammo/bullet/rifle/standard_dmr/incendiary
	name = "incendiary marksman bullet"
	hud_state = "hivelo_fire"
	hud_state_empty = "hivelo_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 35
	sundering = 0 // incen doens't have sundering
	accuracy = -10

/datum/ammo/bullet/rifle/mech
	name = "super-heavy rifle bullet"
	damage = 25
	penetration = 15
	sundering = 0.5
	damage_falloff = 0.8

/datum/ammo/bullet/rifle/mech/burst
	damage = 30
	penetration = 10

/datum/ammo/bullet/rifle/mech/lmg
	damage = 20
	penetration = 20
	damage_falloff = 0.7

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
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	shell_speed = 3
	max_range = 15
	damage = 100
	penetration = 20
	sundering = 7.5

/datum/ammo/bullet/shotgun/slug/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 2, knockback = 1, slowdown = 2)


/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	handful_icon_state = "beanbag slug"
	icon_state = "beanbag"
	hud_state = "shotgun_beanbag"
	flags_ammo_behavior = AMMO_BALLISTIC
	max_range = 15
	shrapnel_chance = 0
	accuracy = 5

/datum/ammo/bullet/shotgun/beanbag/on_hit_mob(mob/M, obj/projectile/P)
	if(!M || M == P.firer)
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.species?.count_human) //no effect on synths
			H.apply_effects(6,8)

/datum/ammo/bullet/shotgun/incendiary
	name = "incendiary slug"
	handful_icon_state = "incendiary slug"
	hud_state = "shotgun_fire"
	damage_type = BRUTE
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SUNDERING
	max_range = 15
	damage = 70
	penetration = 15
	sundering = 2
	bullet_color = COLOR_TAN_ORANGE

/datum/ammo/bullet/shotgun/incendiary/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, shake = 0, knockback = 2, slowdown = 1)

/datum/ammo/bullet/shotgun/flechette
	name = "shotgun flechette shell"
	handful_icon_state = "shotgun flechette shell"
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
	sundering = 7

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
	sundering = 5

/datum/ammo/bullet/shotgun/buckshot
	name = "shotgun buckshot shell"
	handful_icon_state = "shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	flags_ammo_behavior = AMMO_BALLISTIC
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/spread
	bonus_projectiles_amount = 5
	bonus_projectiles_scatter = 4
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 40
	damage_falloff = 4
	penetration = 0


/datum/ammo/bullet/shotgun/buckshot/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 1, knockback = 2, slowdown = 0.5, max_range = 3)

/datum/ammo/bullet/shotgun/spread
	name = "additional buckshot"
	icon_state = "buckshot"
	shell_speed = 2
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 3
	max_range = 10
	damage = 40
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
	icon_state = "buckshot"
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 10
	damage = 25
	damage_falloff = 4

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
	icon_state = "flechette"
	accuracy_var_low = 7
	accuracy_var_high = 7
	max_range = 15
	damage = 15
	damage_falloff = 0.5
	penetration = 15

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
	handful_icon_state = "shotgun slug"
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
	handful_icon_state = "light shotgun buckshot shell"
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
	handful_icon_state = "light shotgun sabot shell"
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
	handful_icon_state = "light shotgun tracker round"
	icon_state = "shotgun_slug"
	hud_state = "shotgun_flechette"
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
	hud_state = "shotgun_flechette"
	shell_speed = 4
	max_range = 30
	damage = 5
	penetration = 100

/datum/ammo/bullet/shotgun/tracker/on_hit_mob(mob/living/victim, obj/projectile/proj)
	victim.AddComponent(/datum/component/dripping, DRIP_ON_TIME, 40 SECONDS, 2 SECONDS)


/datum/ammo/bullet/shotgun/mech
	name = "super-heavy shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/mech/spread
	bonus_projectiles_amount = 4
	bonus_projectiles_scatter = 10
	accuracy_var_low = 10
	accuracy_var_high = 10
	max_range = 10
	damage = 60
	damage_falloff = 4

/datum/ammo/bullet/shotgun/mech/spread
	name = "super-heavy additional buckshot"
	icon_state = "buckshot"
	max_range = 10
	damage = 50
	damage_falloff = 4

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
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SNIPER|AMMO_SUNDERING
	accurate_range_min = 7
	shell_speed = 4
	accurate_range = 30
	max_range = 40
	damage = 90
	penetration = 50
	sundering = 15

/datum/ammo/bullet/sniper/incendiary
	name = "incendiary sniper bullet"
	hud_state = "sniper_fire"
	accuracy = 0
	damage_type = BURN
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SNIPER|AMMO_SUNDERING
	accuracy_var_high = 7
	max_range = 20
	damage = 50
	penetration = 20
	sundering = 5

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	hud_state = "sniper_flak"
	damage = 90
	penetration = 0
	sundering = 25
	airburst_multiplier	= 0.2

/datum/ammo/bullet/sniper/flak/on_hit_mob(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/sniper/svd
	name = "crude sniper bullet"
	handful_icon_state = "crude sniper bullet"
	hud_state = "sniper_crude"
	handful_amount = 5
	damage = 75
	penetration = 35
	sundering = 15

/datum/ammo/bullet/sniper/martini
	name = "crude heavy sniper bullet"
	handful_icon_state = "crude heavy sniper bullet"
	hud_state = "sniper_crude"
	handful_amount = 5
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 120
	penetration = 20
	sundering = 10

/datum/ammo/bullet/sniper/martini/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 1, knockback = 2, slowdown = 0.5, max_range = 5)

/datum/ammo/bullet/sniper/elite
	name = "supersonic sniper bullet"
	hud_state = "sniper_supersonic"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accuracy = 20
	damage = 100
	penetration = 60
	sundering = 50

/datum/ammo/bullet/sniper/pfc
	name = "high caliber rifle bullet"
	hud_state = "minigun"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER
	damage = 80
	penetration = 30
	sundering = 7.5
	damage_falloff = 0.25

/datum/ammo/bullet/sniper/pfc/flak
	name = "high caliber flak rifle bullet"
	hud_state = "sniper_supersonic"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER
	damage = 40
	penetration = 10
	sundering = 10
	damage_falloff = 0.25

/datum/ammo/bullet/sniper/pfc/flak/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, knockback = 4, slowdown = 1.5, stagger = 1, max_range = 17)


/datum/ammo/bullet/sniper/auto
	name = "high caliber rifle bullet"
	hud_state = "minigun"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER
	damage = 50
	penetration = 30
	sundering = 2
	damage_falloff = 0.25

/datum/ammo/bullet/sniper/mech
	name = "light anti-tank bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER|AMMO_IFF
	damage = 100
	penetration = 35
	sundering = 5
	damage_falloff = 0.3

/*
//================================================
					Special Ammo
//================================================
*/

/datum/ammo/bullet/smartmachinegun
	name = "smartmachinegun bullet"
	icon_state = "redbullet" //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 12
	damage = 20
	penetration = 15
	sundering = 2

/datum/ammo/bullet/smart_minigun
	name = "smartminigun bullet"
	icon_state = "redbullet" //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 12
	damage = 10
	penetration = 15
	sundering = 1

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	icon_state = "redbullet"
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SENTRY
	accurate_range = 10
	damage = 25
	penetration = 20
	damage_falloff = 0.25

/datum/ammo/bullet/turret/dumb
	icon_state = "bullet"

/datum/ammo/bullet/turret/gauss
	name = "heavy gauss turret slug"
	damage = 60

/datum/ammo/bullet/turret/mini
	name = "small caliber autocannon bullet"
	damage = 20
	penetration = 20
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SENTRY


/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state 	= "bullet" // Keeping it bog standard with the turret but allows it to be changed.
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	hud_state   = "smartgun"
	hud_state_empty = "smartgun_empty"
	accurate_range = 12
	damage = 40 //Reduced damage due to vastly increased mobility
	penetration = 40 //Reduced penetration due to vastly increased mobility
	accuracy = 5
	barricade_clear_distance = 2
	sundering = 5

/datum/ammo/bullet/minigun
	name = "minigun bullet"
	hud_state = "minigun"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accuracy_var_low = 3
	accuracy_var_high = 3
	accurate_range = 5
	damage = 25
	penetration = 15
	shrapnel_chance = 25
	sundering = 2.5

/datum/ammo/bullet/minigun/mech
	name = "vulcan bullet"
	damage = 30
	penetration = 20
	sundering = 0.5

/datum/ammo/bullet/dual_cannon
	name = "dualcannon bullet"
	hud_state = "minigun"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	accuracy_var_low = 3
	accuracy_var_high = 3
	accurate_range = 5
	damage = 25
	penetration = 100
	sundering = 7
	max_range = 30

/datum/ammo/bullet/dual_cannon/on_hit_turf(turf/T, obj/projectile/P)
	P.proj_max_range -= 20

/datum/ammo/bullet/dual_cannon/on_hit_mob(mob/M, obj/projectile/P)
	P.proj_max_range -= 15

/datum/ammo/bullet/dual_cannon/on_hit_obj(obj/O, obj/projectile/P)
	P.proj_max_range -= 10

/datum/ammo/bullet/railgun
	name = "armor piercing railgun slug"
	hud_state = "alloy_spike"
	icon_state 	= "blue_bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 20
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85

/datum/ammo/bullet/railgun/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, weaken = 1, stagger = 3, slowdown = 2, knockback = 2, shake = 0)

/datum/ammo/bullet/railgun/hvap
	name = "high velocity railgun slug"
	shell_speed = 5
	max_range = 21
	damage = 100
	penetration = 30
	sundering = 100

/datum/ammo/bullet/railgun/hvap/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, stagger = 2, knockback = 3, shake = 0)

/datum/ammo/bullet/railgun/smart
	name = "smart armor piercing railgun slug"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE|AMMO_IFF
	damage = 75
	penetration = 20
	sundering = 50

/datum/ammo/bullet/railgun/smart/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, stagger = 3, slowdown = 3, shake = 0)

/datum/ammo/bullet/apfsds
	name = "\improper APFSDS round"
	hud_state = "alloy_spike"
	icon_state 	= "blue_bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 20
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85

/datum/ammo/tx54
	name = "20mm airburst grenade"
	icon_state = "20mm_flight"
	hud_state = "grenade_airburst"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "20mm_airburst"
	handful_amount = 3
	ping = null //no bounce off.
	sound_bounce	= "rocket_bounce"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	armor_type = "bomb"
	damage_falloff = 0.5
	shell_speed = 2
	accurate_range = 12
	max_range = 15
	damage = 12			//impact damage from a grenade to the dome
	penetration = 0
	sundering = 0
	shrapnel_chance = 0
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread
	bonus_projectiles_scatter = 10

	handful_greyscale_config = /datum/greyscale_config/ammo
	handful_greyscale_colors = "#3ab0c9"

	projectile_greyscale_config = /datum/greyscale_config/projectile
	projectile_greyscale_colors = "#3ab0c9"

/datum/ammo/tx54/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, stagger = 0, slowdown = 0.5, knockback = 1, shake = 0)
	bonus_projectiles_amount = 7
	playsound(proj, sound(get_sfx("explosion_small")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, 4, 3, Get_Angle(proj.firer, M) )
	bonus_projectiles_amount = 0

/datum/ammo/tx54/on_hit_obj(obj/O, obj/projectile/proj)
	bonus_projectiles_amount = 7
	playsound(proj, sound(get_sfx("explosion_small")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, 4, 3, Get_Angle(proj.firer, O) )
	bonus_projectiles_amount = 0

/datum/ammo/tx54/on_hit_turf(turf/T, obj/projectile/proj)
	bonus_projectiles_amount = 7
	playsound(proj, sound(get_sfx("explosion_small")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, 4, 3, Get_Angle(proj.firer, T) )
	bonus_projectiles_amount = 0

/datum/ammo/tx54/do_at_max_range(turf/T, obj/projectile/proj)
	bonus_projectiles_amount = 7
	playsound(proj, sound(get_sfx("explosion_small")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, 4, 3, Get_Angle(proj.firer, get_turf(proj)) )
	bonus_projectiles_amount = 0

/datum/ammo/tx54/incendiary
	name = "20mm incendiary grenade"
	hud_state = "grenade_fire"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/incendiary
	bullet_color = LIGHT_COLOR_FIRE
	handful_greyscale_colors = "#fa7923"
	projectile_greyscale_colors = "#fa7923"

/datum/ammo/bullet/tx54_spread
	name = "Shrapnel"
	icon_state = "flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 5
	accuracy_var_high = 5
	max_range = 4
	damage = 20
	penetration = 20
	sundering = 3
	damage_falloff = 0

/datum/ammo/bullet/tx54_spread/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 3, stagger = 0.3, slowdown = 0.3, shake = 0)

/datum/ammo/bullet/tx54_spread/incendiary
	name = "incendiary flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 15
	penetration = 10
	sundering = 1.5

/datum/ammo/bullet/tx54_spread/incendiary/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/tx54_spread/incendiary/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	drop_flame(T)

/datum/ammo/tx54/he
	name = "20mm HE grenade"
	hud_state = "grenade_he"
	bonus_projectiles_type = null
	max_range = 12
	handful_greyscale_colors = "#b02323"
	projectile_greyscale_colors = "#b02323"

/datum/ammo/tx54/he/drop_nade(turf/T)
	explosion(T, 0, 0, 2, 2)

/datum/ammo/tx54/he/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/tx54/he/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))

/datum/ammo/tx54/he/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/tx54/he/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/tx54/mech
	name = "30mm fragmentation grenade"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/mech
	damage = 30
	penetration = 20
	projectile_greyscale_colors = "#4f0303"

/datum/ammo/bullet/tx54_spread/mech
	damage = 20
	penetration = 10
	sundering = 1

//10-gauge Micro rail shells - aka micronades
/datum/ammo/bullet/micro_rail
	hud_state_empty = "grenade_empty_flash"
	handful_icon_state = "micro_grenade_airburst"
	flags_ammo_behavior = AMMO_BALLISTIC
	shell_speed = 2
	handful_amount = 3
	max_range = 3 //failure to detonate if the target is too close
	damage = 15
	bonus_projectiles_scatter = 12
	///How many bonus projectiles to generate. New var so it doesn't trigger on firing
	var/bonus_projectile_quantity = 5
	///Max range for the bonus projectiles
	var/bonus_projectile_range = 7
	///projectile speed for the bonus projectiles
	var/bonus_projectile_speed = 3

/datum/ammo/bullet/micro_rail/do_at_max_range(turf/T, obj/projectile/proj)
	bonus_projectiles_amount = bonus_projectile_quantity
	playsound(proj, sound(get_sfx("explosion_small")), 30, falloff = 5)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, get_turf(proj), 1)
	smoke.start()
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_range, bonus_projectile_speed, Get_Angle(proj.firer, get_turf(proj)) )
	bonus_projectiles_amount = 0

//piercing scatter shot
/datum/ammo/bullet/micro_rail/airburst
	name = "micro grenade"
	handful_icon_state = "micro_grenade_airburst"
	hud_state = "grenade_airburst"
	bonus_projectiles_type = /datum/ammo/bullet/micro_rail_spread

//incendiary piercing scatter shot
/datum/ammo/bullet/micro_rail/dragonbreath
	name = "micro grenade"
	handful_icon_state = "micro_grenade_incendiary"
	hud_state = "grenade_fire"
	bonus_projectiles_type = /datum/ammo/bullet/micro_rail_spread/incendiary
	bonus_projectile_range = 6

//cluster grenade. Bomblets explode in a rough cone pattern
/datum/ammo/bullet/micro_rail/cluster
	name = "micro grenade"
	handful_icon_state = "micro_grenade_cluster"
	hud_state = "grenade_he"
	bonus_projectiles_type = /datum/ammo/micro_rail_cluster
	bonus_projectile_quantity = 7
	bonus_projectile_range = 6
	bonus_projectile_speed = 2

//creates a literal smokescreen
/datum/ammo/bullet/micro_rail/smoke_burst
	name = "micro grenade"
	handful_icon_state = "micro_grenade_smoke"
	hud_state = "grenade_smoke"
	bonus_projectiles_type = /datum/ammo/smoke_burst
	bonus_projectiles_scatter = 20
	bonus_projectile_range = 6
	bonus_projectile_speed = 2

//submunitions for micro grenades
/datum/ammo/bullet/micro_rail_spread
	name = "Shrapnel"
	icon_state = "flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 5
	accuracy_var_high = 5
	max_range = 7
	damage = 20
	penetration = 20
	sundering = 3
	damage_falloff = 1

/datum/ammo/bullet/micro_rail_spread/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 5, stagger = 0.5, slowdown = 0.5, shake = 0)

/datum/ammo/bullet/micro_rail_spread/incendiary
	name = "incendiary flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 15
	penetration = 5
	sundering = 1.5
	max_range = 6

/datum/ammo/bullet/micro_rail_spread/incendiary/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 5, stagger = 0.2, slowdown = 0.2, shake = 0)

/datum/ammo/bullet/micro_rail_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/micro_rail_spread/incendiary/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	if(prob(40))
		drop_flame(T)

/datum/ammo/micro_rail_cluster
	name = "bomblet"
	icon_state = "bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_LEAVE_TURF
	sound_hit 	 = "ballistic_hit"
	sound_armor  = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"
	shell_speed = 2
	damage = 5
	accuracy = -60 //stop you from just emptying all the bomblets into one guys face for big damage
	shrapnel_chance = 0
	max_range = 6
	bullet_color = COLOR_VERY_SOFT_YELLOW
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread

///handles the actual bomblet detonation
/datum/ammo/micro_rail_cluster/proc/detonate(turf/T, obj/projectile/P)
	playsound(T, sound(get_sfx("explosion_small")), 30, falloff = 5)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(0, T, rand(1,2))
	smoke.start()
	for(var/mob/living/carbon/victim in get_hear(2, T))
		victim.visible_message(span_danger("[victim] is hit by the bomblet blast!"),
			isxeno(victim) ? span_xenodanger("We are hit by the bomblet blast!") : span_highdanger("you are hit by the bomblet blast!"))
		var/armor_block = victim.get_soft_armor("bomb")
		victim.apply_damage(10, BRUTE, null, armor_block, updating_health = FALSE)
		victim.apply_damage(10, BURN, null, armor_block, updating_health = TRUE)
		staggerstun(victim, P, stagger = 1, slowdown = 1)

/datum/ammo/micro_rail_cluster/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	///chance to detonate early, scales with distance and capped, to avoid lots of immediate detonations, and nothing reach max range respectively.
	var/detonate_probability = min(proj.distance_travelled * 4, 16)
	if(prob(detonate_probability))
		proj.proj_max_range = proj.distance_travelled

/datum/ammo/micro_rail_cluster/on_hit_mob(mob/M, obj/projectile/P)
	detonate(get_turf(P), P)

/datum/ammo/micro_rail_cluster/on_hit_obj(obj/O, obj/projectile/P)
	detonate(get_turf(P), P)

/datum/ammo/micro_rail_cluster/on_hit_turf(turf/T, obj/projectile/P)
	detonate(T.density ? P.loc : T, P)

/datum/ammo/micro_rail_cluster/do_at_max_range(turf/T, obj/projectile/P)
	detonate(T.density ? P.loc : T, P)

/datum/ammo/smoke_burst
	name = "micro smoke canister"
	icon_state = "bullet" //PLACEHOLDER
	flags_ammo_behavior = AMMO_BALLISTIC
	sound_hit 	 = "ballistic_hit"
	sound_armor  = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"
	shell_speed = 2
	damage = 5
	shrapnel_chance = 0
	max_range = 6
	bullet_color = COLOR_VERY_SOFT_YELLOW
	/// smoke type created when the projectile detonates
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	///radius this smoke will encompass
	var/smokeradius = 1

/datum/ammo/smoke_burst/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(smokeradius, T, rand(5,9))
	smoke.start()

/datum/ammo/smoke_burst/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/smoke_burst/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/smoke_burst/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/smoke_burst/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

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
	bullet_color = LIGHT_COLOR_FIRE

/datum/ammo/rocket/drop_nade(turf/T)
	explosion(T, 0, 4, 6, 2)

/datum/ammo/rocket/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/rocket/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))

/datum/ammo/rocket/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/rocket/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

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
	accurate_range = 15
	max_range = 40
	penetration = 200
	damage = 300

/datum/ammo/rocket/ltb/drop_nade(turf/T)
	explosion(T, 0, 4, 6, 7)

/datum/ammo/rocket/mech
	name = "large high-explosive rocket"
	damage = 75
	penetration = 50

/datum/ammo/rocket/mech/drop_nade(turf/T)
	explosion(T, 0, 2, 4, 5)

/datum/ammo/rocket/heavy_rr
	name = "75mm round"
	icon_state = "heavyrr"
	hud_state = "shell_he"
	hud_state_empty = "shell_empty"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	accuracy = 40
	accurate_range = 15
	max_range = 40
	shell_speed = 3
	penetration = 200
	damage = 200
	sundering = 50
	handful_amount = 1

/datum/ammo/rocket/heavy_rr/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 4)

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
	//The radius for the non explosion effects
	var/effect_radius = 3

/datum/ammo/rocket/wp/drop_nade(turf/T)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(effect_radius, T, 27, 27, 27, 17)

/datum/ammo/rocket/wp/quad
	name = "thermobaric rocket"
	hud_state = "rocket_thermobaric"
	flags_ammo_behavior = AMMO_ROCKET
	damage = 40
	penetration = 25
	max_range = 30
	sundering = 2

	///The smoke system that the WP gas uses to spread.
	var/datum/effect_system/smoke_spread/smoke_system

/datum/ammo/rocket/wp/quad/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/phosphorus()

/datum/ammo/rocket/wp/quad/drop_nade(turf/T)
	set_smoke()
	smoke_system.set_up(effect_radius, T)
	smoke_system.start()
	smoke_system = null
	T.visible_message(span_danger("The rocket explodes into white gas!") )
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(effect_radius, T, 27, 27, 27, 17)

/datum/ammo/rocket/wp/quad/som
	name = "white phosphorous RPG"
	hud_state = "rpg_fire"
	flags_ammo_behavior = AMMO_ROCKET

/datum/ammo/rocket/wp/quad/ds
	name = "super thermobaric rocket"
	hud_state = "rocket_thermobaric"
	flags_ammo_behavior = AMMO_ROCKET
	damage = 200
	penetration = 75
	max_range = 30
	sundering = 100

/datum/ammo/rocket/recoilless
	name = "high explosive shell"
	icon_state = "shell"
	hud_state = "shell_he"
	hud_state_empty = "shell_empty"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	armor_type = "bomb"
	damage_falloff = 0
	shell_speed = 2
	accurate_range = 20
	max_range = 30
	damage = 100
	penetration = 50
	sundering = 50

/datum/ammo/rocket/recoilless/drop_nade(turf/T)
	explosion(T, 0, 3, 4, 2)

/datum/ammo/rocket/recoilless/heat
	name = "HEAT shell"
	hud_state = "shell_heat"
	damage = 200
	penetration = 100
	sundering = 0

/datum/ammo/rocket/recoilless/heat/drop_nade(turf/T)
	explosion(T, flash_range = 1)

/datum/ammo/rocket/recoilless/light
	name = "light explosive shell"
	hud_state = "shell_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING //We want this to specifically go farther than onscreen range.
	accurate_range = 15
	max_range = 20
	damage = 75
	penetration = 50
	sundering = 25

/datum/ammo/rocket/recoilless/light/drop_nade(turf/T)
	explosion(T, 0, 1, 8, 1)

/datum/ammo/rocket/recoilless/chemical
	name = "low velocity chemical shell"
	hud_state = "shell_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING|AMMO_IFF //We want this to specifically go farther than onscreen range and pass through friendlies.
	accurate_range = 21
	max_range = 21
	damage = 10
	penetration = 0
	sundering = 0
	/// Smoke type created when projectile detonates.
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/bad
	/// Radius this smoke will encompass on detonation.
	var/smokeradius = 7

/datum/ammo/rocket/recoilless/chemical/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(smokeradius, T, rand(5,9))
	smoke.start()
	explosion(T, flash_range = 1)

/datum/ammo/rocket/recoilless/chemical/cloak
	name = "low velocity chemical shell"
	hud_state = "shell_cloak"
	smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/rocket/recoilless/chemical/plasmaloss
	name = "low velocity chemical shell"
	hud_state = "shell_tanglefoot"
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/rocket/recoilless/low_impact
	name = "low impact explosive shell"
	hud_state = "shell_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING //We want this to specifically go farther than onscreen range.
	accurate_range = 15
	max_range = 20
	damage = 75
	penetration = 15
	sundering = 25

/datum/ammo/rocket/recoilless/low_impact/drop_nade(turf/T)
	explosion(T, 0, 1, 8, 2)

/datum/ammo/rocket/oneuse
	name = "explosive rocket"
	damage = 100
	penetration = 100
	sundering = 100

/datum/ammo/rocket/som
	name = "low impact RPG"
	hud_state = "rpg_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING
	accurate_range = 15
	max_range = 20
	damage = 80
	penetration = 20
	sundering = 20

/datum/ammo/rocket/som/drop_nade(turf/T)
	explosion(T, 0, 3, 6, 2)

/datum/ammo/rocket/som/light
	name = "low impact RPG"
	hud_state = "rpg_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING
	accurate_range = 15
	max_range = 20
	damage = 60
	penetration = 10

/datum/ammo/rocket/som/light/drop_nade(turf/T)
	explosion(T, 0, 2, 7, 2)

/datum/ammo/rocket/som/thermobaric
	name = "thermobaric RPG"
	hud_state = "rpg_thermobaric"
	damage = 30

/datum/ammo/rocket/som/thermobaric/drop_nade(turf/T)
	explosion(T, 0, 4, 5, 4, 4)

/datum/ammo/rocket/som/heat //Anti tank, or mech
	name = "HEAT RPG"
	hud_state = "rpg_heat"
	damage = 200
	penetration = 100
	sundering = 0

/datum/ammo/rocket/som/heat/drop_nade(turf/T)
	explosion(T, flash_range = 1)

/datum/ammo/rocket/som/rad
	name = "irrad RPG"
	hud_state = "rpg_rad"
	damage = 50
	penetration = 10
	///Base strength of the rad effects
	var/rad_strength = 25
	///Range for the maximum rad effects
	var/inner_range = 3
	///Range for the moderate rad effects
	var/mid_range = 5
	///Range for the minimal rad effects
	var/outer_range = 8

/datum/ammo/rocket/som/rad/drop_nade(turf/T)
	playsound(T, 'sound/effects/portal_opening.ogg', 50, 1)
	for(var/mob/living/victim in hearers(outer_range, T))
		var/strength
		var/datum/looping_sound/geiger/geiger_counter = new(null, FALSE)
		if(get_dist(victim, T) <= inner_range)
			strength = rad_strength
			geiger_counter.severity = 4
		else if(get_dist(victim, T) <= mid_range)
			strength = rad_strength * 0.7
			geiger_counter.severity = 3
		else
			strength = rad_strength * 0.3
			geiger_counter.severity = 2
		irradiate(victim, strength)
		geiger_counter.start(victim)
	explosion(T, 0, 0, 3, 0)

///Applies the actual rad effects
/datum/ammo/rocket/som/rad/proc/irradiate(mob/living/victim, strength)
	var/rad_penetration = max((100 - victim.get_soft_armor(BIO)) / 100, 0.25)
	var/effective_strength = strength * rad_penetration //strength with rad armor taken into account
	victim.adjustCloneLoss(effective_strength)
	victim.adjustStaminaLoss(effective_strength * 7)
	victim.adjust_stagger(effective_strength / 2)
	victim.add_slowdown(effective_strength / 2)
	victim.blur_eyes(effective_strength) //adds a visual indicator that you've just been irradiated
	victim.adjust_radiation(effective_strength * 20) //Radiation status effect, duration is in deciseconds
	to_chat(victim, span_warning("Your body tingles as you suddenly feel the strength drain from your body!"))

/datum/ammo/rocket/atgun_shell
	name = "high explosive ballistic cap shell"
	icon_state = "atgun"
	hud_state = "shell_heat"
	hud_state_empty = "shell_empty"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF
	shell_speed = 2
	damage = 90
	penetration = 30
	sundering = 10
	handful_amount = 1

/datum/ammo/rocket/atgun_shell/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 2)

/datum/ammo/rocket/atgun_shell/on_hit_turf(turf/T, obj/projectile/P) //no explosion every time it hits a turf
	P.proj_max_range -= 10

/datum/ammo/rocket/atgun_shell/apcr
	name = "tungsten penetrator"
	hud_state = "shell_he"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	damage = 200
	penetration = 40
	sundering = 65

/datum/ammo/rocket/atgun_shell/apcr/drop_nade(turf/T)
	explosion(T, 0, 0, 0, 1)

/datum/ammo/rocket/atgun_shell/apcr/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))
	P.proj_max_range -= 5
	staggerstun(M, P, max_range = 20, stagger = 0.5, slowdown = 0.5, knockback = 2, shake = 1,  hard_size_threshold = 3)

/datum/ammo/rocket/atgun_shell/apcr/on_hit_obj(obj/O, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/rocket/atgun_shell/apcr/on_hit_turf(turf/T, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/rocket/atgun_shell/he
	name = "high velocity high explosive shell"
	hud_state = "shell_he"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	damage = 50
	penetration = 50
	sundering = 25

/datum/ammo/rocket/atgun_shell/he/drop_nade(turf/T)
	explosion(T, 0, 3, 5, 0)

/datum/ammo/rocket/atgun_shell/he/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

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
	accuracy = 15 //lasers fly fairly straight
	bullet_color = COLOR_LASER_RED

/datum/ammo/energy/emitter //Damage is determined in emitter.dm
	name = "emitter bolt"
	icon_state = "emitter"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_IGNORE_ARMOR
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
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SKIPS_ALIENS
	max_range = 15
	accurate_range = 10
	bullet_color = COLOR_VIVID_YELLOW
/datum/ammo/energy/taser/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stun = 10)

/datum/ammo/energy/tesla
	name = "energy ball"
	icon_state = "tesla"
	hud_state = "taser"
	hud_state_empty = "battery_empty"
	flags_ammo_behavior = AMMO_ENERGY|SPECIAL_PROCESS
	shell_speed = 0.1
	damage = 20
	penetration = 20
	bullet_color = COLOR_TESLA_BLUE

/datum/ammo/energy/tesla/ammo_process(obj/projectile/proj, damage)
	zap_beam(proj, 4, damage)

/datum/ammo/energy/tesla/focused
	flags_ammo_behavior = AMMO_ENERGY|SPECIAL_PROCESS|AMMO_IFF
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

/datum/ammo/energy/lasgun
	name = "laser bolt"
	icon_state = "laser"
	hud_state = "laser"
	armor_type = "laser"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING
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
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_SUNDERING
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
	staggerstun(M, P, stagger = 0.5, slowdown = 0.75)

/datum/ammo/energy/lasgun/pulsebolt
	name = "pulse bolt"
	icon_state = "pulse2"
	hud_state = "pulse"
	damage = 90 // this is gotta hurt...
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
	flags_ammo_behavior = AMMO_ENERGY
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/M43/practice/on_hit_mob(mob/living/carbon/C, obj/projectile/P)
	if(!istype(C) || C.stat == DEAD || C.issamexenohive(P.firer) )
		return

	if(isnestedhost(C))
		return

	staggerstun(C, P, stagger = 1, slowdown = 1) //Staggers and slows down briefly

	return ..()

// TE Lasers //

/datum/ammo/energy/lasgun/marine
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN
	damage = 20
	penetration = 10
	sundering = 1
	max_range = 30
	hitscan_effect_icon = "beam"

/datum/ammo/energy/lasgun/marine/overcharge
	name = "overcharged laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 40
	penetration = 20
	sundering = 2
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun/marine/blast
	name = "wide range laser blast"
	icon_state = "heavylaser2"
	hud_state = "laser_spread"
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 5
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 5
	max_range = 8
	damage = 35
	penetration = 20
	sundering = 1
	hitscan_effect_icon = "pu_laser"

/datum/ammo/energy/lasgun/marine/spread
	name = "additional laser blast"
	icon_state = "laser2"
	shell_speed = 2
	accuracy_var_low = 9
	accuracy_var_high = 9
	accurate_range = 5
	max_range = 8
	damage = 35
	penetration = 20
	sundering = 1
	hitscan_effect_icon = "pu_laser"

/datum/ammo/energy/lasgun/marine/autolaser
	name = "machine laser bolt"
	damage = 15
	penetration = 15

/datum/ammo/energy/lasgun/marine/autolaser/efficiency
	name = "efficient machine laser bolt"
	damage = 8.5
	hitscan_effect_icon = "beam_particle"

/datum/ammo/energy/lasgun/marine/sniper
	name = "sniper laser bolt"
	hud_state = "laser_sniper"
	damage = 60
	penetration = 30
	accurate_range_min = 5
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 4
	max_range = 40
	damage_falloff = 0
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun/marine/sniper_heat
	name = "sniper heat bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	shell_speed = 2.5
	damage = 40
	penetration = 0
	accurate_range_min = 5
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 1
	hitscan_effect_icon = "u_laser_beam"

/datum/ammo/energy/lasgun/marine/pistol
	name = "pistol laser bolt"
	damage = 20
	penetration = 5
	hitscan_effect_icon = "beam_particle"

/datum/ammo/energy/lasgun/marine/pistol/disabler
	name = "disabler bolt"
	icon_state = "disablershot"
	hud_state = "laser_disabler"
	damage = 70
	penetration = 0
	damage_type = STAMINA
	hitscan_effect_icon = "stun"

/datum/ammo/energy/lasgun/marine/pistol/heat
	name = "microwave heat bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 20
	shell_speed = 2.5
	penetration = 10
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_SUNDERING|AMMO_HITSCAN
	sundering = 0.5
	hitscan_effect_icon = "beam_incen"

/datum/ammo/energy/lasgun/pistol/disabler/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 0.5, slowdown = 0.75)

/datum/ammo/energy/lasgun/marine/xray
	name = "xray heat bolt"
	icon_state = "u_laser"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_SUNDERING|AMMO_HITSCAN
	damage = 25
	penetration = 5
	sundering = 1
	max_range = 15
	hitscan_effect_icon = "u_laser_beam"

/datum/ammo/energy/lasgun/marine/xray/piercing
	name = "xray piercing bolt"
	icon_state = "xray"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_HITSCAN|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	damage = 25
	penetration = 100
	max_range = 10
	hitscan_effect_icon = "xray_beam"

/datum/ammo/energy/lasgun/marine/heavy_laser
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_INCENDIARY
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
	drop_nade(get_turf(O))

/datum/ammo/energy/lasgun/marine/heavy_laser/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/energy/lasgun/marine/heavy_laser/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/energy/lasgun/marine/mech
	name = "superheated laser bolt"
	damage = 50
	penetration = 20
	sundering = 1
	damage_falloff = 0.5

/datum/ammo/energy/lasgun/marine/mech/burst
	damage = 50
	penetration = 20
	sundering = 0.75
	damage_falloff = 0.6

/datum/ammo/energy/lasgun/marine/mech/smg
	name = "superheated pulsed laser bolt"
	damage = 25
	penetration = 15

// Plasma //
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

/datum/ammo/energy/plasma_pistol
	name = "ionized plasma bolt"
	icon_state = "overchargedlaser"
	hud_state = "electrothermal"
	hud_state_empty = "electrothermal_empty"
	damage = 40
	max_range = 14
	penetration = 5
	shell_speed = 1.5
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_EXPLOSIVE
	bullet_color = COLOR_VIBRANT_LIME

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

//volkite

/datum/ammo/energy/volkite
	name = "thermal energy bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_heat"
	hud_state_empty = "battery_empty_flash"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING
	bullet_color = COLOR_TAN_ORANGE
	armor_type = "energy"
	max_range = 14
	accurate_range = 5 //for charger
	shell_speed = 4
	accuracy_var_low = 5
	accuracy_var_high = 5
	accuracy = 5
	point_blank_range = 2
	damage = 20
	penetration = 10
	sundering = 2
	fire_burst_damage = 15

	//inherited, could use some changes
	ping = "ping_s"
	sound_hit 	 	= "energy_hit"
	sound_miss		= "energy_miss"
	sound_bounce	= "energy_bounce"

/datum/ammo/energy/volkite/on_hit_mob(mob/M,obj/projectile/P)
	deflagrate(M, P)

/datum/ammo/energy/volkite/medium
	max_range = 25
	accurate_range = 12
	damage = 30
	accuracy_var_low = 3
	accuracy_var_high = 3
	fire_burst_damage = 20

/datum/ammo/energy/volkite/heavy
	max_range = 35
	accurate_range = 12
	damage = 25
	fire_burst_damage = 20

/datum/ammo/energy/volkite/light
	max_range = 25
	accurate_range = 12
	accuracy_var_low = 3
	accuracy_var_high = 3
	penetration = 5

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
	bullet_color = COLOR_LIME
	///List of reagents transferred upon spit impact if any
	var/list/datum/reagent/spit_reagents
	///Amount of reagents transferred upon spit impact if any
	var/reagent_transfer_amount
	///Amount of stagger stacks imposed on impact if any
	var/stagger_stacks
	///Amount of slowdown stacks imposed on impact if any
	var/slowdown_stacks
	///These define the reagent transfer strength of the smoke caused by the spit, if any, and its aoe
	var/datum/effect_system/smoke_spread/xeno/smoke_system
	var/smoke_strength
	var/smoke_range

/datum/ammo/xeno/toxin
	name = "neurotoxic spit"
	flags_ammo_behavior = AMMO_XENO|AMMO_EXPLOSIVE|AMMO_SKIPS_ALIENS
	spit_cost = 55
	added_spit_delay = 0
	damage_type = STAMINA
	accurate_range = 5
	max_range = 10
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 40
	stagger_stacks = 1.1
	slowdown_stacks = 1.5
	smoke_strength = 0.5
	smoke_range = 0
	reagent_transfer_amount = 4

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/toxin/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_neurotoxin = reagent_transfer_amount)

/datum/ammo/xeno/toxin/on_hit_mob(mob/living/carbon/C, obj/projectile/P)
	drop_neuro_smoke(get_turf(C))

	if(!istype(C) || C.stat == DEAD || C.issamexenohive(P.firer) )
		return

	if(isnestedhost(C))
		return

	C.adjust_stagger(stagger_stacks) //stagger briefly; useful for support
	C.add_slowdown(slowdown_stacks) //slow em down

	set_reagents()
	var/armor_block = (1 - C.get_soft_armor(armor_type, BODY_ZONE_CHEST) * 0.01) //Check the target's armor mod; default to chest
	for(var/reagent_id in spit_reagents) //modify by armor
		spit_reagents[reagent_id] *= armor_block

	C.reagents.add_reagent_list(spit_reagents) //transfer reagents

	return ..()

/datum/ammo/xeno/toxin/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/T = get_turf(O)
	drop_neuro_smoke(T.density ? P.loc : T)

/datum/ammo/xeno/toxin/on_hit_turf(turf/T, obj/projectile/P)
	drop_neuro_smoke(T.density ? P.loc : T)

/datum/ammo/xeno/toxin/do_at_max_range(turf/T, obj/projectile/P)
	drop_neuro_smoke(T.density ? P.loc : T)

/datum/ammo/xeno/toxin/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro/light()

/datum/ammo/xeno/toxin/proc/drop_neuro_smoke(turf/T)
	if(T.density)
		return

	set_smoke()
	smoke_system.strength = smoke_strength
	smoke_system.set_up(smoke_range, T)
	smoke_system.start()
	smoke_system = null

/datum/ammo/xeno/toxin/upgrade1
	smoke_strength = 0.6
	reagent_transfer_amount = 5

/datum/ammo/xeno/toxin/upgrade2
	smoke_strength = 0.7
	reagent_transfer_amount = 6

/datum/ammo/xeno/toxin/upgrade3
	smoke_strength = 0.75
	reagent_transfer_amount = 6.5


/datum/ammo/xeno/toxin/heavy //Praetorian
	name = "neurotoxic splash"
	added_spit_delay = 0
	spit_cost = 100
	damage = 40
	smoke_strength = 0.9
	reagent_transfer_amount = 8.5

/datum/ammo/xeno/toxin/heavy/upgrade1
	smoke_strength = 0.9
	reagent_transfer_amount = 9

/datum/ammo/xeno/toxin/heavy/upgrade2
	smoke_strength = 0.95
	reagent_transfer_amount = 9.5

/datum/ammo/xeno/toxin/heavy/upgrade3
	smoke_strength = 1
	reagent_transfer_amount = 10


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
	bullet_color = COLOR_PURPLE
	stagger_stacks = 2
	slowdown_stacks = 3


/datum/ammo/xeno/sticky/on_hit_mob(mob/M, obj/projectile/P)
	drop_resin(get_turf(M))
	if(istype(M,/mob/living/carbon))
		var/mob/living/carbon/C = M
		if(C.issamexenohive(P.firer))
			return
		C.adjust_stagger(stagger_stacks) //stagger briefly; useful for support
		C.add_slowdown(slowdown_stacks) //slow em down


/datum/ammo/xeno/sticky/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/T = get_turf(O)
	drop_resin(T.density ? P.loc : T)

/datum/ammo/xeno/sticky/on_hit_turf(turf/T, obj/projectile/P)
	drop_resin(T.density ? P.loc : T)

/datum/ammo/xeno/sticky/do_at_max_range(turf/T, obj/projectile/P)
	drop_resin(T.density ? P.loc : T)

/datum/ammo/xeno/sticky/proc/drop_resin(turf/T)
	if(T.density)
		return

	for(var/obj/O in T.contents)
		if(is_type_in_typecache(O, GLOB.no_sticky_resin))
			return

	new /obj/alien/resin/sticky(T)

/datum/ammo/xeno/sticky/turret
	max_range = 9

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	damage_type = BURN
	added_spit_delay = 5
	spit_cost = 50
	flags_ammo_behavior = AMMO_XENO|AMMO_EXPLOSIVE
	armor_type = "acid"
	damage = 18
	max_range = 8
	bullet_color = COLOR_PALE_GREEN_GRAY
	///Duration of the acid puddles
	var/puddle_duration = 1 SECONDS //Lasts 1-3 seconds
	///Damage dealt by acid puddles
	var/puddle_acid_damage = XENO_DEFAULT_ACID_PUDDLE_DAMAGE

/datum/ammo/xeno/acid/on_shield_block(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 30
	flags_ammo_behavior = AMMO_XENO

/datum/ammo/xeno/acid/auto
	name = "light acid spatter"
	damage = 10
	flags_ammo_behavior = AMMO_XENO
	spit_cost = 25
	added_spit_delay = 0

/datum/ammo/xeno/acid/passthrough
	name = "acid spittle"
	damage = 20
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS

/datum/ammo/xeno/acid/heavy
	name = "acid splash"
	added_spit_delay = 2
	spit_cost = 70
	damage = 30

/datum/ammo/xeno/acid/heavy/turret
	damage = 20
	name = "acid turret splash"
	shell_speed = 2
	max_range = 9

/datum/ammo/xeno/acid/heavy/on_hit_mob(mob/M,obj/projectile/P)
	var/turf/T = get_turf(M)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/on_hit_obj(obj/O,obj/projectile/P)
	var/turf/T = get_turf(O)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/on_hit_turf(turf/T,obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/drop_nade(turf/T) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(T.density)
		return

	new /obj/effect/xenomorph/spray(T, puddle_duration, puddle_acid_damage)


///For the Spitter's Scatterspit ability
/datum/ammo/xeno/acid/heavy/scatter
	damage = 20
	flags_ammo_behavior = AMMO_XENO|AMMO_EXPLOSIVE|AMMO_SKIPS_ALIENS
	bonus_projectiles_type = /datum/ammo/xeno/acid/heavy/scatter
	bonus_projectiles_amount = 6
	bonus_projectiles_scatter = 2
	max_range = 8
	puddle_duration = 1 SECONDS //Lasts 2-4 seconds

/datum/ammo/xeno/boiler_gas
	name = "glob of gas"
	icon_state = "boiler_gas2"
	ping = "ping_x"
	///Key used for icon stuff during bombard ammo selection.
	var/icon_key = BOILER_GLOB_NEURO
	///This text will show up when a boiler selects this ammo. Span proc should be applied when this var is used.
	var/select_text = "We will now fire neurotoxic gas. This is nonlethal."
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE
	var/danger_message = span_danger("A glob of acid lands with a splat and explodes into noxious fumes!")
	armor_type = "bio"
	accuracy_var_high = 10
	max_range = 30
	damage = 50
	damage_type = STAMINA
	damage_falloff = 0
	penetration = 40
	bullet_color = BOILER_LUMINOSITY_AMMO_NEUROTOXIN_COLOR
	reagent_transfer_amount = 30
	///On a direct hit, how long is the target paralyzed?
	var/hit_paralyze_time = 1 SECONDS
	///On a direct hit, how much do the victim's eyes get blurred?
	var/hit_eye_blur = 11
	///On a direct hit, how much drowsyness gets added to the target?
	var/hit_drowsyness = 12
	///Does the gas spread have a fixed range? -1 for no, 0+ for a fixed range. This prevents scaling from caste age.
	var/fixed_spread_range = -1
	///Which type is the smoke we leave on passed tiles, provided the projectile has AMMO_LEAVE_TURF enabled?
	var/passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	///We're going to reuse one smoke spread system repeatedly to cut down on processing.
	var/datum/effect_system/smoke_spread/xeno/trail_spread_system

/datum/ammo/xeno/boiler_gas/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	if(isxeno(firer))
		var/mob/living/carbon/xenomorph/X = firer
		trail_spread_system.strength = X.xeno_caste.bomb_strength
	trail_spread_system.set_up(0, T)
	trail_spread_system.start()

/**
 * Loads a trap with a gas cloud depending on current glob type
 * Called when something with a boiler glob as current ammo interacts with an empty resin trap.
 * * Args:
 * * trap: The trap being loaded
 * * user_xeno: The xeno interacting with the trap
 * * Returns: TRUE on success, FALSE on failure.
**/
/datum/ammo/xeno/boiler_gas/proc/enhance_trap(obj/structure/xeno/trap/trap, mob/living/carbon/xenomorph/user_xeno)
	if(!do_after(user_xeno, 2 SECONDS, TRUE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_NEURO)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/neuro/medium
	trap.smoke.set_up(2, get_turf(trap))
	return TRUE

/datum/ammo/xeno/boiler_gas/New()
	. = ..()
	if((flags_ammo_behavior & AMMO_LEAVE_TURF) && passed_turf_smoke_type)
		trail_spread_system = new passed_turf_smoke_type(only_once = FALSE)

/datum/ammo/xeno/boiler_gas/Destroy()
	if(trail_spread_system)
		QDEL_NULL(trail_spread_system)
	return ..()

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/boiler_gas/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_neurotoxin = reagent_transfer_amount)


/datum/ammo/xeno/boiler_gas/on_hit_mob(mob/living/victim, obj/projectile/proj)
	drop_nade(get_turf(proj), proj.firer)

	if(!istype(victim) || victim.stat == DEAD || victim.issamexenohive(proj.firer))
		return

	victim.Paralyze(hit_paralyze_time)
	victim.blur_eyes(hit_eye_blur)
	victim.adjustDrowsyness(hit_drowsyness)

	if(!reagent_transfer_amount || !iscarbon(victim))
		return

	var/mob/living/carbon/carbon_victim = victim
	set_reagents()
	var/armor_block = (1 - carbon_victim.get_soft_armor(armor_type, BODY_ZONE_CHEST) * 0.01) //Check the target's armor mod; default to chest
	for(var/reagent_id in spit_reagents) //modify by armor
		spit_reagents[reagent_id] *= armor_block

	carbon_victim.reagents.add_reagent_list(spit_reagents) //transfer reagents

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/T = get_turf(O)
	drop_nade(T.density ? P.loc : T, P.firer)

/datum/ammo/xeno/boiler_gas/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T, P.firer) //we don't want the gas globs to land on dense turfs, they block smoke expansion.

/datum/ammo/xeno/boiler_gas/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T, P.firer)

/datum/ammo/xeno/boiler_gas/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/neuro()

/datum/ammo/xeno/boiler_gas/drop_nade(turf/T, atom/firer, range = 1)
	set_smoke()
	if(isxeno(firer))
		var/mob/living/carbon/xenomorph/X = firer
		smoke_system.strength = X.xeno_caste.bomb_strength
		if(fixed_spread_range == -1)
			range = max(2, range + min(X.upgrade_as_number(), 3))
		else
			range = fixed_spread_range
	smoke_system.set_up(range, T)
	smoke_system.start()
	smoke_system = null
	T.visible_message(danger_message)

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	icon_state = "boiler_gas"
	sound_hit 	 = "acid_hit"
	sound_bounce	= "acid_bounce"
	icon_key = BOILER_GLOB_ACID
	select_text = "We will now fire corrosive acid. This is lethal!"
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_EXPLOSIVE
	armor_type = "acid"
	danger_message = span_danger("A glob of acid lands with a splat and explodes into corrosive bile!")
	damage = 50
	damage_type = BURN
	penetration = 40
	bullet_color = BOILER_LUMINOSITY_AMMO_CORROSIVE_COLOR
	hit_paralyze_time = 1 SECONDS
	hit_eye_blur = 1
	hit_drowsyness = 1
	reagent_transfer_amount = 0

/datum/ammo/xeno/boiler_gas/corrosive/enhance_trap(obj/structure/xeno/trap/trap, mob/living/carbon/xenomorph/user_xeno)
	if(!do_after(user_xeno, 3 SECONDS, TRUE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_ACID)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/neuro/medium
	trap.smoke.set_up(1, get_turf(trap))
	return TRUE

/datum/ammo/xeno/boiler_gas/corrosive/on_shield_block(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/xeno/boiler_gas/corrosive/set_smoke()
	smoke_system = new /datum/effect_system/smoke_spread/xeno/acid()

/datum/ammo/xeno/boiler_gas/lance
	name = "pressurized glob of gas"
	icon_key = BOILER_GLOB_NEURO_LANCE
	select_text = "We will now fire a pressurized neurotoxic lance. This is barely nonlethal."
	///As opposed to normal globs, this will pass by the target tile if they hit nothing.
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF
	danger_message = span_danger("A pressurized glob of acid lands with a nasty splat and explodes into noxious fumes!")
	max_range = 40
	damage = 75
	penetration = 60
	reagent_transfer_amount = 55
	passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/neuro/light
	hit_paralyze_time = 2 SECONDS
	hit_eye_blur = 16
	hit_drowsyness = 18
	fixed_spread_range = 2
	accuracy = 100
	accurate_range = 30
	shell_speed = 1.5

/datum/ammo/xeno/boiler_gas/corrosive/lance
	name = "pressurized glob of acid"
	icon_key = BOILER_GLOB_ACID_LANCE
	select_text = "We will now fire a pressurized corrosive lance. This lethal!"
	///As opposed to normal globs, this will pass by the target tile if they hit nothing.
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS|AMMO_LEAVE_TURF
	danger_message = span_danger("A pressurized glob of acid lands with a concerning hissing sound and explodes into corrosive bile!")
	max_range = 40
	damage = 75
	penetration = 60
	passed_turf_smoke_type = /datum/effect_system/smoke_spread/xeno/acid/light
	hit_paralyze_time = 1.5 SECONDS
	hit_eye_blur = 4
	hit_drowsyness = 2
	fixed_spread_range = 2
	accuracy = 100
	accurate_range = 30
	shell_speed = 1.5

/datum/ammo/xeno/hugger
	name = "hugger ammo"
	ping = ""
	flags_ammo_behavior = AMMO_XENO
	damage = 0
	max_range = 6
	shell_speed = 1
	bullet_color = ""
	icon_state = "facehugger"
	///The type of hugger thrown
	var/obj/item/clothing/mask/facehugger/hugger_type = /obj/item/clothing/mask/facehugger

/datum/ammo/xeno/hugger/on_hit_mob(mob/M, obj/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(M))
	hugger.go_idle()

/datum/ammo/xeno/hugger/on_hit_obj(obj/O, obj/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(O))
	hugger.go_idle()

/datum/ammo/xeno/hugger/on_hit_turf(turf/T, obj/projectile/P)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(T.density ? P.loc : T)
	hugger.go_idle()

/datum/ammo/xeno/hugger/do_at_max_range(turf/T, obj/projectile/P)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(T.density ? P.loc : T)
	hugger.go_idle()

/datum/ammo/xeno/hugger/slash
	hugger_type = /obj/item/clothing/mask/facehugger/combat/slash

/datum/ammo/xeno/hugger/neuro
	hugger_type = /obj/item/clothing/mask/facehugger/combat/neuro

/datum/ammo/xeno/hugger/resin
	hugger_type = /obj/item/clothing/mask/facehugger/combat/resin

/datum/ammo/xeno/hugger/acid
	hugger_type = /obj/item/clothing/mask/facehugger/combat/acid

/// For Widows Web Spit Ability
/datum/ammo/xeno/web
	icon_state = "web_spit"
	sound_hit = "snap"
	sound_bounce = "alien_resin_build3"
	damage_type = STAMINA
	bullet_color = COLOR_PURPLE
	flags_ammo_behavior = AMMO_SKIPS_ALIENS
	ping = null
	armor_type = BIO
	accurate_range = 15
	max_range = 15
	///For how long the victim will be blinded
	var/hit_eye_blind = 1
	///How long the victim will be snared for
	var/hit_immobilize = 2 SECONDS
	///How long the victim will be KO'd
	var/hit_weaken = 1
	///List for bodyparts that upon being hit cause the target to become weakened
	var/list/weaken_list = list(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
	///List for bodyparts that upon being hit cause the target to become ensnared
	var/list/snare_list = list(BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT)

/datum/ammo/xeno/web/on_hit_mob(mob/victim, obj/projectile/proj)
	. = ..()
	if(!ishuman(victim))
		return
	playsound(get_turf(victim), sound(get_sfx("snap")), 30, falloff = 5)
	var/mob/living/carbon/human/human_victim = victim
	if(proj.def_zone == BODY_ZONE_HEAD)
		human_victim.blind_eyes(hit_eye_blind)
		human_victim.balloon_alert(human_victim, "The web blinds you!")
	else if(proj.def_zone in weaken_list)
		human_victim.apply_effect(hit_weaken, WEAKEN)
		human_victim.balloon_alert(human_victim, "The web knocks you down!")
	else if(proj.def_zone in snare_list)
		human_victim.Immobilize(hit_immobilize, TRUE)
		human_victim.balloon_alert(human_victim, "The web snares you!")

/datum/ammo/xeno/leash_ball
	icon_state = "widow_snareball"
	ping = "ping_x"
	damage_type = STAMINA
	flags_ammo_behavior = AMMO_SKIPS_ALIENS | AMMO_EXPLOSIVE
	bullet_color = COLOR_PURPLE
	ping = null
	damage = 0
	armor_type = BIO
	shell_speed = 1.5
	accurate_range = 8
	max_range = 8

/datum/ammo/xeno/leash_ball/on_hit_turf(turf/T, obj/projectile/proj)
	drop_leashball(T.density ? proj.loc : T)

/datum/ammo/xeno/leash_ball/on_hit_mob(mob/victim, obj/projectile/proj)
	var/turf/T = get_turf(victim)
	drop_leashball(T.density ? proj.loc : T, proj.firer)

/datum/ammo/xeno/leash_ball/on_hit_obj(obj/O, obj/projectile/proj)
	var/turf/T = get_turf(O)
	if(T.density || (O.density && !O.throwpass))
		T = get_turf(proj)
	drop_leashball(T.density ? proj.loc : T, proj.firer)

/datum/ammo/xeno/leash_ball/do_at_max_range(turf/T, obj/projectile/proj)
	drop_leashball(T.density ? proj.loc : T)


/// This spawns a leash ball and checks if the turf is dense before doing so
/datum/ammo/xeno/leash_ball/proc/drop_leashball(turf/T)
	new /obj/structure/xeno/aoe_leash(get_turf(T))
/*
//================================================
					Misc Ammo
//================================================
*/

/datum/ammo/bullet/pepperball
	name = "pepperball"
	hud_state = "grenade_frag"
	hud_state_empty = "battery_empty"
	flags_ammo_behavior = AMMO_BALLISTIC
	accurate_range = 15
	damage_type = STAMINA
	armor_type = "bio"
	damage = 70
	penetration = 0
	shrapnel_chance = 0
	///percentage of xenos total plasma to drain when hit by a pepperball
	var/drain_multiplier = 0.05
	/// Flat plasma to drain, unaffected by caste plasma amount.
	var/plasma_drain = 25

/datum/ammo/bullet/pepperball/on_hit_mob(mob/living/victim, obj/projectile/proj)
	if(isxeno(victim))
		var/mob/living/carbon/xenomorph/X = victim
		X.use_plasma(drain_multiplier * X.xeno_caste.plasma_max * X.xeno_caste.plasma_regen_limit)
		X.use_plasma(plasma_drain)

/datum/ammo/bullet/pepperball/pepperball_mini
	damage = 40
	drain_multiplier = 0.03
	plasma_drain = 15

/datum/ammo/alloy_spike
	name = "alloy spike"
	ping = "ping_s"
	icon_state = "MSpearFlight"
	sound_hit 	 	= "alloy_hit"
	sound_armor	 	= "alloy_armor"
	sound_bounce	= "alloy_bounce"
	armor_type = BULLET
	accuracy = 20
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
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_FLAME|AMMO_EXPLOSIVE
	armor_type = "fire"
	max_range = 7
	damage = 31
	damage_falloff = 0
	incendiary_strength = 30 //Firestacks cap at 20, but that's after armor.
	bullet_color = LIGHT_COLOR_FIRE
	var/fire_color = "red"
	var/burntime = 17
	var/burnlevel = 31

/datum/ammo/flamethrower/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(burntime, burnlevel, fire_color)

/datum/ammo/flamethrower/on_hit_mob(mob/M, obj/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/flamethrower/on_hit_obj(obj/O, obj/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/flamethrower/on_hit_turf(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/flamethrower/do_at_max_range(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/flamethrower/tank_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	flame_radius(2, T)

/datum/ammo/flamethrower/mech_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	flame_radius(1, T)

/datum/ammo/flamethrower/blue
	name = "blue flame"
	hud_state = "flame_blue"
	max_range = 7
	fire_color = "blue"
	burntime = 40
	burnlevel = 46
	bullet_color = COLOR_NAVY

/datum/ammo/water
	name = "water"
	hud_state = "water"
	hud_state_empty = "water_empty"

/datum/ammo/rocket/toy
	name = "\improper toy rocket"
	damage = 1

/datum/ammo/rocket/toy/on_hit_mob(mob/M,obj/projectile/P)
	to_chat(M, "<font size=6 color=red>NO BUGS</font>")

/datum/ammo/rocket/toy/on_hit_obj(obj/O,obj/projectile/P)
	return

/datum/ammo/rocket/toy/on_hit_turf(turf/T,obj/projectile/P)
	return

/datum/ammo/rocket/toy/do_at_max_range(turf/T, obj/projectile/P)
	return

/datum/ammo/grenade_container
	name = "grenade shell"
	ping = null
	damage_type = BRUTE
	var/nade_type = /obj/item/explosive/grenade
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
	drop_nade(T.density ? P.loc : T)

/datum/ammo/grenade_container/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/grenade_container/drop_nade(turf/T)
	var/obj/item/explosive/grenade/G = new nade_type(T)
	G.visible_message(span_warning("\A [G] lands on [T]!"))
	G.det_time = 10
	G.activate()

/datum/ammo/grenade_container/smoke
	name = "smoke grenade shell"
	nade_type = /obj/item/explosive/grenade/smokebomb
	icon_state = "smoke_shell"
