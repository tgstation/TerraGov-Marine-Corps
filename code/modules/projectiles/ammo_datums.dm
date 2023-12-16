#define DEBUG_STAGGER_SLOWDOWN 0

/*!
 * TODO SPLIT THIS FILE GODDAM
 */

GLOBAL_LIST_INIT(no_sticky_resin, typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/alien/egg, /obj/structure/mineral_door, /obj/alien/resin, /obj/structure/bed/nest))) //For sticky/acid spit

/datum/ammo
	var/name = "generic bullet"
	var/icon = 'icons/obj/items/projectiles.dmi'
	var/icon_state = "bullet"
	///used in icons/obj/items/ammo for use in generating handful sprites
	var/handful_icon_state = "bullet"
	///how much of this ammo you can carry in a handful
	var/handful_amount = 8
	///Bullet type on the Ammo HUD
	var/hud_state = "unknown"
	var/hud_state_empty = "unknown"
	///The icon that is displayed when the bullet bounces off something.
	var/ping = "ping_b"
	///When it deals damage.
	var/sound_hit
	///When it's blocked by human armor.
	var/sound_armor
	///When it misses someone.
	var/sound_miss
	///When it bounces off something.
	var/sound_bounce

	///This is added to the bullet's base accuracy
	var/accuracy = 0
	///How much the accuracy varies when fired
	var/accuracy_var_low = 1
	var/accuracy_var_high = 1
	///For most guns, this is where the bullet dramatically looses accuracy. Not for snipers though
	var/accurate_range = 5
	///Snipers use this to simulate poor accuracy at close ranges
	var/accurate_range_min = 0
	///Weapons will get a large accuracy buff at this short range
	var/point_blank_range = 0
	///This will de-increment a counter on the bullet
	var/max_range = 20
	///How much the ammo scatters when burst fired, added to gun scatter, along with other mods
	var/scatter = 0
	///This is the base damage of the bullet as it is fired
	var/damage = 0
	///How much damage the bullet loses per turf traveled
	var/damage_falloff = 1
	///BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/damage_type = BRUTE
	///How much armor it ignores before calculations take place
	var/penetration = 0
	///The % chance it will imbed in a human
	var/shrapnel_chance = 0
	///How fast the projectile moves
	var/shell_speed = 2
	///Type path of the extra projectiles
	var/bonus_projectiles_type
	///How many extra projectiles it shoots out. Works kind of like firing on burst, but all of the projectiles travel together
	var/bonus_projectiles_amount = 0
	///Degrees scattered per two projectiles, each in a different direction.
	var/bonus_projectiles_scatter = 8
	///How far the bullet can travel before incurring a chance of hitting barricades; normally 1.
	var/barricade_clear_distance = 1
	///Does this have an override for the armor type the ammo should test? Bullet by default
	var/armor_type = "bullet"
	///How many stacks of sundering to apply to a mob on hit
	var/sundering = 0
	///how much damage airbursts do to mobs around the target, multiplier of the bullet's damage
	var/airburst_multiplier = 0.1
	///What kind of behavior the ammo has
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

///Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
/datum/ammo/proc/on_shield_block(mob/M, obj/projectile/proj)
	return

///Special effects when hitting dense turfs.
/datum/ammo/proc/on_hit_turf(turf/T, obj/projectile/proj)
	return

///Special effects when hitting mobs.
/datum/ammo/proc/on_hit_mob(mob/M, obj/projectile/proj)
	return

///Special effects when hitting objects.
/datum/ammo/proc/on_hit_obj(obj/O, obj/projectile/proj)
	return

///Special effects for leaving a turf. Only called if the projectile has AMMO_LEAVE_TURF enabled
/datum/ammo/proc/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	return

///Handles CC application on the victim
/datum/ammo/proc/staggerstun(mob/victim, obj/projectile/proj, max_range = 5, stun = 0, weaken = 0, stagger = 0, slowdown = 0, knockback = 0, soft_size_threshold = 3, hard_size_threshold = 2)
	if(!victim)
		CRASH("staggerstun called without a mob target")
	if(!isliving(victim))
		return
	if(get_dist_euclide(proj.starting_turf, victim) > max_range)
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

	//Check for and apply hard CC.
	if(hard_size_threshold >= victim.mob_size && (stun || weaken || knockback))
		var/mob/living/living_victim = victim
		if(living_victim.IsStun() || living_victim.IsParalyzed()) //Prevent chain stunning.
			stun = 0
			weaken = 0

		if(stun || weaken)
			var/list/stunlist = list(stun, weaken, stagger, slowdown)
			if(SEND_SIGNAL(living_victim, COMSIG_LIVING_PROJECTILE_STUN, stunlist, armor_type, penetration))
				stun = stunlist[1]
				weaken = stunlist[2]
				stagger = stunlist[3]
				slowdown = stunlist[4]
			living_victim.apply_effects(stun,weaken)

		if(knockback)
			if(isxeno(victim))
				impact_message += span_xenodanger("The blast knocks you off your feet!")
			else
				impact_message += span_highdanger("The blast knocks you off your feet!")
			victim.knockback(proj, knockback, 5)

	//Check for and apply soft CC
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Initial stagger is: <b>[target.IsStaggered()]</b>"))
		#endif
		if(!HAS_TRAIT(carbon_victim, TRAIT_STAGGER_RESISTANT)) //Some mobs like the Queen are immune to projectile stagger
			carbon_victim.adjust_stagger(stagger)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Final stagger is: <b>[target.IsStaggered()]</b>"))
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
		victim.apply_damage(proj.damage * proj.airburst_multiplier, proj.ammo.damage_type, blocked = armor_type, updating_health = TRUE)

///handles the probability of a projectile hit to trigger fire_burst, based off actual damage done
/datum/ammo/proc/deflagrate(atom/target, obj/projectile/proj)
	if(!target || !proj)
		CRASH("deflagrate() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	if(!istype(target, /mob/living))
		return

	var/mob/living/victim = target
	var/deflagrate_chance = victim.modify_by_armor(proj.damage - (proj.distance_travelled * proj.damage_falloff), FIRE, proj.penetration) * deflagrate_multiplier
	if(prob(deflagrate_chance))
		new /obj/effect/temp_visual/shockwave(get_turf(victim), 2)
		playsound(target, "incendiary_explosion", 40)
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
		victim.apply_damage(fire_burst_damage, BURN, blocked = FIRE, updating_health = TRUE)

		staggerstun(victim, proj, 30, stagger = 1 SECONDS, slowdown = 0.5)
		victim.adjust_fire_stacks(5)
		victim.IgniteMob()


/datum/ammo/proc/fire_bonus_projectiles(obj/projectile/main_proj, atom/shooter, atom/source, range, speed, angle, target, origin_override)
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
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)

		if(isgun(source))
			var/obj/item/weapon/gun/gun = source
			gun.apply_gun_modifiers(new_proj, target, shooter)

		//Scatter here is how many degrees extra stuff deviate from the main projectile, first two the same amount, one to each side, and from then on the extra pellets keep widening the arc.
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((i % 2) ? (-(i + 1) * 0.5) : (i * 0.5)))
		if(new_angle < 0)
			new_angle += 360
		else if(new_angle > 360)
			new_angle -= 360
		new_proj.fire_at(target, shooter, source, range, speed, new_angle, TRUE, loc_override = origin_override)

///A variant of Fire_bonus_projectiles without fixed scatter and no link between gun and bonus_projectile accuracy
/datum/ammo/proc/fire_directionalburst(obj/projectile/main_proj, atom/shooter, atom/source, projectile_amount, range, speed, angle, target)
	var/effect_icon = ""
	var/proj_type = /obj/projectile
	if(istype(main_proj, /obj/projectile/hitscan))
		proj_type = /obj/projectile/hitscan
		var/obj/projectile/hitscan/main_proj_hitscan = main_proj
		effect_icon = main_proj_hitscan.effect_icon
	for(var/i = 1 to projectile_amount) //Want to run this for the number of bonus projectiles.
		var/obj/projectile/new_proj = new proj_type(main_proj.loc, effect_icon)
		if(bonus_projectiles_type)
			new_proj.generate_bullet(bonus_projectiles_type)
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)

		if(isgun(source))
			var/obj/item/weapon/gun/gun = source
			gun.apply_gun_modifiers(new_proj, target, shooter)

		//Scatter here is how many degrees extra stuff deviate from the main projectile's firing angle. Fully randomised with no 45 degree cap like normal bullets
		var/f = (i-1)
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((f % 2) ? (-(f + 1) * 0.5) : (f * 0.5)))
		if(new_angle < 0)
			new_angle += 360
		if(new_angle > 360)
			new_angle -= 360
		new_proj.fire_at(target, main_proj.loc, source, range, speed, new_angle, TRUE)

/datum/ammo/proc/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(20, 20)


/datum/ammo/proc/set_smoke()
	return


/datum/ammo/proc/drop_nade(turf/T)
	return

///called on projectile process() when AMMO_SPECIAL_PROCESS flag is active
/datum/ammo/proc/ammo_process(obj/projectile/proj, damage)
	CRASH("ammo_process called with unimplemented process!")

///bounces the projectile by creating a new projectile and calculating an angle of reflection
/datum/ammo/proc/reflect(turf/T, obj/projectile/proj, scatter_variance)
	if(!bonus_projectiles_type)
		return

	var/new_range = proj.proj_max_range - proj.distance_travelled
	if(new_range <= 0)
		return

	var/dir_to_proj = get_dir(T, proj)
	if(ISDIAGONALDIR(dir_to_proj))
		var/list/cardinals = list(turn(dir_to_proj, 45), turn(dir_to_proj, -45))
		for(var/direction in cardinals)
			var/turf/turf_to_check = get_step(T, direction)
			if(turf_to_check.density)
				cardinals -= direction
		dir_to_proj = pick(cardinals)

	var/perpendicular_angle = Get_Angle(T, get_step(T, dir_to_proj))
	var/new_angle = (perpendicular_angle + (perpendicular_angle - proj.dir_angle - 180) + rand(-scatter_variance, scatter_variance))

	if(new_angle < -360)
		new_angle += 720 //north is 0 instead of 360
	else if(new_angle < 0)
		new_angle += 360
	else if(new_angle > 360)
		new_angle -= 360

	bonus_projectiles_amount = 1
	fire_bonus_projectiles(proj, T, proj.shot_from, new_range, proj.projectile_speed, new_angle, null, get_step(T, dir_to_proj))
	bonus_projectiles_amount = initial(bonus_projectiles_amount)

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
	sound_armor = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"
	point_blank_range = 2
	accurate_range_min = 0
	shell_speed = 3
	damage = 10
	shrapnel_chance = 10
	bullet_color = COLOR_VERY_SOFT_YELLOW
	barricade_clear_distance = 2

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
	staggerstun(M, P, stagger = 2 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/ap
	name = "armor-piercing pistol bullet"
	hud_state = "pistol_ap"
	damage = 20
	penetration = 12.5
	shrapnel_chance = 15
	sundering = 0.5

/datum/ammo/bullet/pistol/heavy
	name = "heavy pistol bullet"
	hud_state = "pistol_heavy"
	damage = 30
	penetration = 5
	shrapnel_chance = 25
	sundering = 2.15

/datum/ammo/bullet/pistol/superheavy
	name = "high impact pistol bullet"
	hud_state = "pistol_superheavy"
	damage = 45
	penetration = 15
	sundering = 3
	damage_falloff = 0.75

/datum/ammo/bullet/pistol/superheavy/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 0.5 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/pistol/superheavy/derringer
	handful_amount = 2
	handful_icon_state = "derringer"

/datum/ammo/bullet/pistol/superheavy/derringer/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, slowdown = 0.5)

/datum/ammo/bullet/pistol/mech
	name = "super-heavy pistol bullet"
	hud_state = "pistol_superheavy"
	damage = 45
	penetration = 20
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
	staggerstun(M, P, stagger = 2 SECONDS, slowdown = 0.5, knockback = 1)

/datum/ammo/bullet/revolver/tp44
	name = "standard revolver bullet"
	damage = 40
	penetration = 15
	sundering = 1

/datum/ammo/bullet/revolver/tp44/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, knockback = 1)

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

/datum/ammo/bullet/revolver/judge
	name = "oversized revolver bullet"
	hud_state = "revolver_slim"
	shrapnel_chance = 0
	damage_falloff = 0
	accuracy = 15
	accurate_range = 15
	damage = 70
	penetration = 10

/datum/ammo/bullet/revolver/heavy
	name = "heavy revolver bullet"
	hud_state = "revolver_heavy"
	damage = 50
	penetration = 5
	accuracy = -10

/datum/ammo/bullet/revolver/t76
	name = "magnum bullet"
	handful_amount = 5
	damage = 100
	penetration = 40
	sundering = 0.5

/datum/ammo/bullet/revolver/t76/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, knockback = 1)

/datum/ammo/bullet/revolver/highimpact
	name = "high-impact revolver bullet"
	hud_state = "revolver_impact"
	handful_amount = 6
	damage = 50
	penetration = 20
	sundering = 3

/datum/ammo/bullet/revolver/highimpact/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 2 SECONDS, slowdown = 1, knockback = 1)

/datum/ammo/bullet/revolver/ricochet
	bonus_projectiles_type = /datum/ammo/bullet/revolver/small
	bonus_projectiles_scatter = 0

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
	reflect(T, proj, 10)

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

/datum/ammo/bullet/smg/ap/hv
	name = "high velocity armor-piercing submachinegun bullet"
	shell_speed = 4

/datum/ammo/bullet/smg/hollow
	name = "hollow-point submachinegun bullet"
	hud_state = "pistol_squash"
	flags_ammo_behavior = AMMO_BALLISTIC
	damage = 35
	penetration = 0
	damage_falloff = 3
	shrapnel_chance = 45

/datum/ammo/bullet/smg/incendiary
	name = "incendiary submachinegun bullet"
	hud_state = "smg_fire"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage = 18
	penetration = 0

/datum/ammo/bullet/smg/rad
	name = "radioactive submachinegun bullet"
	hud_state = "smg_rad"
	damage = 15
	penetration = 15
	sundering = 1

/datum/ammo/bullet/smg/rad/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return
	var/mob/living/living_victim = M
	if(!prob(living_victim.modify_by_armor(proj.damage, BIO, penetration, proj.def_zone)))
		return
	living_victim.apply_radiation(2, 2)

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
	penetration = 25
	sundering = 3

/datum/ammo/bullet/rifle/hv
	name = "high-velocity rifle bullet"
	hud_state = "hivelo"
	damage = 20
	penetration = 20
	sundering = 1.25

/datum/ammo/bullet/rifle/heavy
	name = "heavy rifle bullet"
	hud_state = "rifle_heavy"
	damage = 30
	penetration = 10
	sundering = 1.25

/datum/ammo/bullet/rifle/repeater
	name = "heavy impact rifle bullet"
	hud_state = "sniper"
	damage = 70
	penetration = 20
	sundering = 1.25

/datum/ammo/bullet/rifle/repeater/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, max_range = 3, slowdown = 2, stagger = 1 SECONDS)

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
	damage = 25
	penetration = 10
	sundering = 0.75

/datum/ammo/bullet/rifle/som_machinegun
	name = "machinegun bullet"
	hud_state = "rifle_heavy"
	damage = 28
	penetration = 12.5
	sundering = 1

/datum/ammo/bullet/rifle/som_machinegun/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, max_range = 20, slowdown = 0.5)

/datum/ammo/bullet/rifle/tx8
	name = "A19 high velocity bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	damage_falloff = 0
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 15
	damage = 40
	penetration = 20
	sundering = 10
	bullet_color = COLOR_SOFT_RED

/datum/ammo/bullet/rifle/tx8/incendiary
	name = "high velocity incendiary bullet"
	hud_state = "hivelo_fire"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	damage = 25
	penetration = 20
	sundering = 2.5
	bullet_color = LIGHT_COLOR_FIRE

/datum/ammo/bullet/rifle/tx8/impact
	name = "high velocity impact bullet"
	hud_state = "hivelo_impact"
	damage = 30
	penetration = 10
	sundering = 12.5

/datum/ammo/bullet/rifle/tx8/impact/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, max_range = 14, slowdown = 1, knockback = 1)

/datum/ammo/bullet/rifle/mpi_km
	name = "crude heavy rifle bullet"
	hud_state = "rifle_crude"
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

/datum/ammo/bullet/rifle/garand
	name = "heavy marksman bullet"
	hud_state = "sniper"
	damage = 75
	penetration = 25
	sundering = 1.25

/datum/ammo/bullet/rifle/standard_br
	name = "light marksman bullet"
	hud_state = "hivelo"
	hud_state_empty = "hivelo_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	penetration = 15
	damage = 32.5
	sundering = 1.25

/datum/ammo/bullet/rifle/icc_confrontationrifle
	name = "armor-piercing heavy rifle bullet"
	hud_state = "rifle_ap"
	damage = 50
	penetration = 40
	sundering = 3.5

/datum/ammo/bullet/rifle/mech
	name = "super-heavy rifle bullet"
	damage = 25
	penetration = 15
	sundering = 0.5
	damage_falloff = 0.8

/datum/ammo/bullet/rifle/mech/burst
	damage = 35
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
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 2 SECONDS, knockback = 1, slowdown = 2)


/datum/ammo/bullet/shotgun/beanbag
	name = "beanbag slug"
	handful_icon_state = "beanbag slug"
	icon_state = "beanbag"
	hud_state = "shotgun_beanbag"
	flags_ammo_behavior = AMMO_BALLISTIC
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
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SUNDERING
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
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
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
	flags_ammo_behavior = AMMO_BALLISTIC
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


/datum/ammo/bullet/shotgun/mech
	name = "super-heavy shotgun buckshot shell"
	icon_state = "buckshot"
	hud_state = "shotgun_buckshot"
	bonus_projectiles_type = /datum/ammo/bullet/shotgun/mech/spread
	bonus_projectiles_amount = 2
	bonus_projectiles_scatter = 5
	accuracy_var_low = 10
	accuracy_var_high = 10
	max_range = 10
	damage = 100
	damage_falloff = 4

/datum/ammo/bullet/shotgun/mech/spread
	name = "super-heavy additional buckshot"
	icon_state = "buckshot"
	max_range = 10
	damage = 75
	damage_falloff = 4

/datum/ammo/bullet/shotgun/mech/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, weaken = 2 SECONDS, stagger = 2 SECONDS, knockback = 2, slowdown = 0.5, max_range = 3)

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
	damage = 70
	penetration = 30
	sundering = 5

/datum/ammo/bullet/sniper/flak
	name = "flak sniper bullet"
	hud_state = "sniper_flak"
	damage = 90
	penetration = 0
	sundering = 15
	airburst_multiplier = 0.5

/datum/ammo/bullet/sniper/flak/on_hit_mob(mob/victim, obj/projectile/proj)
	staggerstun(victim, proj,  max_range = 30, slowdown = 2)
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
	flags_ammo_behavior = AMMO_BALLISTIC
	damage = 120
	penetration = 20
	accurate_range_min = 0
	///shatter effection duration when hitting mobs
	var/shatter_duration = 10 SECONDS

/datum/ammo/bullet/sniper/martini/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)

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
	hud_state = "sniper_heavy"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER
	damage = 80
	penetration = 30
	sundering = 7.5
	damage_falloff = 0.25

/datum/ammo/bullet/sniper/pfc/flak
	name = "high caliber flak rifle bullet"
	hud_state = "sniper_heavy_flak"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER
	damage = 40
	penetration = 10
	sundering = 10
	damage_falloff = 0.25

/datum/ammo/bullet/sniper/pfc/flak/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, knockback = 4, slowdown = 1.5, stagger = 2 SECONDS, max_range = 17)


/datum/ammo/bullet/sniper/auto
	name = "high caliber rifle bullet"
	hud_state = "sniper_auto"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER
	damage = 50
	penetration = 30
	sundering = 2
	damage_falloff = 0.25

/datum/ammo/bullet/sniper/clf_heavyrifle
	name = "high velocity incendiary sniper bullet"
	handful_icon_state = "ptrs"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY|AMMO_SNIPER|AMMO_SUNDERING
	hud_state = "sniper_fire"
	accurate_range_min = 4
	shell_speed = 5
	damage = 120
	penetration = 60
	sundering = 20

/datum/ammo/bullet/sniper/mech
	name = "light anti-tank bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SNIPER|AMMO_IFF
	damage = 100
	penetration = 35
	sundering = 0
	damage_falloff = 0.3

/*
//================================================
					Special Ammo
//================================================
*/

/datum/ammo/bullet/smartmachinegun
	name = "smartmachinegun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	accurate_range = 12
	damage = 20
	penetration = 15
	sundering = 2

/datum/ammo/bullet/smart_minigun
	name = "smartminigun bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "smartgun_minigun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
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
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	damage = 40
	max_range = 40
	penetration = 30
	sundering = 5
	shell_speed = 4
	damage_falloff = 0.5
	accurate_range = 25
	accurate_range_min = 3

/datum/ammo/bullet/spottingrifle
	name = "smart spotting bullet"
	bullet_color = COLOR_SOFT_RED //Red bullets to indicate friendly fire restriction
	hud_state = "spotrifle"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
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
	staggerstun(M, P, stagger = 1, slowdown = 1, max_range = 12)

/datum/ammo/bullet/spottingrifle/heavyrubber
	name = "smart heavy-rubber spotting bullet"
	hud_state = "spotrifle_rubber"
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/spottingrifle/heavyrubber/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, weaken = 1, slowdown = 1, max_range = 12)

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
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_INCENDIARY
	damage_type = BURN
	damage = 10
	sundering = 0.5

/datum/ammo/bullet/turret
	name = "autocannon bullet"
	bullet_color = COLOR_SOFT_RED
	hud_state = "rifle"
	hud_state_empty = "rifle_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_SENTRY
	accurate_range = 10
	damage = 25
	penetration = 20
	damage_falloff = 0.25

/datum/ammo/bullet/turret/dumb
	icon_state = "bullet"

/datum/ammo/bullet/turret/gauss
	name = "heavy gauss turret slug"
	hud_state = "rifle_heavy"
	damage = 60

/datum/ammo/bullet/turret/mini
	name = "small caliber autocannon bullet"
	damage = 20
	penetration = 20
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SENTRY


/datum/ammo/bullet/machinegun //Adding this for the MG Nests (~Art)
	name = "machinegun bullet"
	icon_state = "bullet" // Keeping it bog standard with the turret but allows it to be changed.
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING
	hud_state = "minigun"
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
	hud_state_empty = "smartgun_empty"
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
	penetration = 10
	sundering = 0.5

/datum/ammo/bullet/auto_cannon
	name = "autocannon high-velocity bullet"
	hud_state = "minigun"
	hud_state_empty = "smartgun_empty"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	accurate_range_min = 6
	accuracy_var_low = 3
	accuracy_var_high = 3
	damage = 30
	penetration = 50
	sundering = 1
	max_range = 35
	///Bonus flat damage to walls, balanced around resin walls.
	var/autocannon_wall_bonus = 20

/datum/ammo/bullet/auto_cannon/on_hit_turf(turf/T, obj/projectile/P)
	P.proj_max_range -= 20

	if(istype(T, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = T
		wall_victim.take_damage(autocannon_wall_bonus, P.damtype, P.armor_type)

/datum/ammo/bullet/auto_cannon/on_hit_mob(mob/M, obj/projectile/P)
	P.proj_max_range -= 5
	staggerstun(M, P, max_range = 20, slowdown = 1)

/datum/ammo/bullet/auto_cannon/on_hit_obj(obj/O, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/bullet/auto_cannon/flak
	name = "autocannon smart-detonating bullet"
	hud_state = "sniper_flak"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_EXPLOSIVE
	damage = 50
	penetration = 30
	sundering = 5
	max_range = 30
	airburst_multiplier = 1
	autocannon_wall_bonus = 5

/datum/ammo/bullet/auto_cannon/flak/on_hit_mob(mob/victim, obj/projectile/proj)
	airburst(victim, proj)

/datum/ammo/bullet/auto_cannon/do_at_max_range(turf/T, obj/projectile/proj)
	airburst(T, proj)

/datum/ammo/bullet/railgun
	name = "armor piercing railgun slug"
	hud_state = "railgun_ap"
	icon_state = "blue_bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 20
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85

/datum/ammo/bullet/railgun/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, weaken = 2 SECONDS, stagger = 4 SECONDS, slowdown = 2, knockback = 2)

/datum/ammo/bullet/railgun/hvap
	name = "high velocity railgun slug"
	hud_state = "railgun_hvap"
	shell_speed = 5
	max_range = 21
	damage = 100
	penetration = 30
	sundering = 50

/datum/ammo/bullet/railgun/hvap/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, stagger = 2 SECONDS, knockback = 3)

/datum/ammo/bullet/railgun/smart
	name = "smart armor piercing railgun slug"
	hud_state = "railgun_smart"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE|AMMO_IFF
	damage = 100
	penetration = 20
	sundering = 20

/datum/ammo/bullet/railgun/smart/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, stagger = 3 SECONDS, slowdown = 3)

/datum/ammo/bullet/apfsds
	name = "\improper APFSDS round"
	hud_state = "alloy_spike"
	icon_state = "blue_bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOVABLE|AMMO_UNWIELDY
	shell_speed = 4
	max_range = 14
	damage = 150
	penetration = 100
	sundering = 0
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
	sound_bounce = "rocket_bounce"
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
	///How many
	var/bonus_projectile_quantity = 7

	handful_greyscale_config = /datum/greyscale_config/ammo
	handful_greyscale_colors = COLOR_AMMO_AIRBURST

	projectile_greyscale_config = /datum/greyscale_config/projectile
	projectile_greyscale_colors = COLOR_AMMO_AIRBURST

/datum/ammo/tx54/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, slowdown = 0.5, knockback = 1)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, M) )

/datum/ammo/tx54/on_hit_obj(obj/O, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, O) )

/datum/ammo/tx54/on_hit_turf(turf/T, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, T) )

/datum/ammo/tx54/do_at_max_range(turf/T, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 4, 3, Get_Angle(proj.firer, get_turf(proj)) )

/datum/ammo/tx54/incendiary
	name = "20mm incendiary grenade"
	hud_state = "grenade_fire"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/incendiary
	bullet_color = LIGHT_COLOR_FIRE
	handful_greyscale_colors = COLOR_AMMO_INCENDIARY
	projectile_greyscale_colors = COLOR_AMMO_INCENDIARY

/datum/ammo/tx54/smoke
	name = "20mm tactical smoke grenade"
	hud_state = "grenade_hide"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke
	bonus_projectiles_scatter = 24
	bonus_projectile_quantity = 5
	handful_greyscale_colors = COLOR_AMMO_TACTICAL_SMOKE
	projectile_greyscale_colors = COLOR_AMMO_TACTICAL_SMOKE

/datum/ammo/tx54/smoke/dense
	name = "20mm smoke grenade"
	hud_state = "grenade_smoke"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke/dense
	handful_greyscale_colors = COLOR_AMMO_SMOKE
	projectile_greyscale_colors = COLOR_AMMO_SMOKE

/datum/ammo/tx54/smoke/tangle
	name = "20mm tanglefoot grenade"
	hud_state = "grenade_drain"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/smoke/tangle
	handful_greyscale_colors = COLOR_AMMO_TANGLEFOOT
	projectile_greyscale_colors = COLOR_AMMO_TANGLEFOOT

/datum/ammo/tx54/razor
	name = "20mm razorburn grenade"
	hud_state = "grenade_razor"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/razor
	bonus_projectiles_scatter = 50
	bonus_projectile_quantity = 3
	handful_greyscale_colors = COLOR_AMMO_RAZORBURN
	projectile_greyscale_colors = COLOR_AMMO_RAZORBURN

/datum/ammo/tx54/he
	name = "20mm HE grenade"
	hud_state = "grenade_he"
	bonus_projectiles_type = null
	max_range = 12
	handful_greyscale_colors = COLOR_AMMO_HIGH_EXPLOSIVE
	projectile_greyscale_colors = COLOR_AMMO_HIGH_EXPLOSIVE

/datum/ammo/tx54/he/drop_nade(turf/T)
	explosion(T, 0, 0, 1, 3, 1)

/datum/ammo/tx54/he/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/tx54/he/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))

/datum/ammo/tx54/he/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/tx54/he/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

//The secondary projectiles
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
	staggerstun(M, proj, max_range = 3, stagger = 0.6 SECONDS, slowdown = 0.3)

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

/datum/ammo/bullet/tx54_spread/smoke
	name = "chemical bomblet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_LEAVE_TURF
	max_range = 3
	damage = 5
	penetration = 0
	sundering = 0
	///The smoke type loaded in this ammo
	var/datum/effect_system/smoke_spread/trail_spread_system = /datum/effect_system/smoke_spread/tactical

/datum/ammo/bullet/tx54_spread/smoke/New()
	. = ..()

	trail_spread_system = new trail_spread_system(only_once = FALSE)

/datum/ammo/bullet/tx54_spread/smoke/Destroy()
	if(trail_spread_system)
		QDEL_NULL(trail_spread_system)
	return ..()

/datum/ammo/bullet/tx54_spread/smoke/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/smoke/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	trail_spread_system.set_up(0, T)
	trail_spread_system.start()

/datum/ammo/bullet/tx54_spread/smoke/dense
	trail_spread_system = /datum/effect_system/smoke_spread/bad

/datum/ammo/bullet/tx54_spread/smoke/tangle
	trail_spread_system = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/bullet/tx54_spread/razor
	name = "chemical bomblet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_PASS_THROUGH_MOB|AMMO_LEAVE_TURF
	max_range = 4
	damage = 5
	penetration = 0
	sundering = 0
	///The foam type loaded in this ammo
	var/datum/effect_system/foam_spread/chemical_payload
	///The reagent content of the projectile
	var/datum/reagents/reagent_list

/datum/ammo/bullet/tx54_spread/razor/New()
	. = ..()

	chemical_payload = new
	reagent_list = new
	reagent_list.add_reagent(/datum/reagent/foaming_agent = 1)
	reagent_list.add_reagent(/datum/reagent/toxin/nanites = 7)

/datum/ammo/bullet/tx54_spread/razor/Destroy()
	if(chemical_payload)
		QDEL_NULL(chemical_payload)
	return ..()

/datum/ammo/bullet/tx54_spread/razor/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/tx54_spread/razor/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	chemical_payload.set_up(0, T, reagent_list, RAZOR_FOAM)
	chemical_payload.start()

/datum/ammo/tx54/mech
	name = "30mm fragmentation grenade"
	bonus_projectiles_type = /datum/ammo/bullet/tx54_spread/mech
	damage = 15
	penetration = 10
	projectile_greyscale_colors = "#4f0303"

/datum/ammo/bullet/tx54_spread/mech
	damage = 15
	penetration = 10
	sundering = 0.5

/datum/ammo/bullet/tx54_spread/mech/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 3, slowdown = 0.2)

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
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, get_turf(proj), 1)
	smoke.start()
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(proj.firer, get_turf(proj)) )

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
	staggerstun(M, proj, stagger = 1 SECONDS, slowdown = 0.5)

/datum/ammo/bullet/micro_rail_spread/incendiary
	name = "incendiary flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 15
	penetration = 5
	sundering = 1.5
	max_range = 6

/datum/ammo/bullet/micro_rail_spread/incendiary/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, stagger = 0.4 SECONDS, slowdown = 0.2)

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
	sound_armor = "ballistic_armor"
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
	///Total damage applied to victims by the exploding bomblet
	var/explosion_damage = 20
	///Amount of stagger applied by the exploding bomblet
	var/stagger_amount = 2 SECONDS
	///Amount of slowdown applied by the exploding bomblet
	var/slow_amount = 1
	///range of bomblet explosion
	var/explosion_range = 2

///handles the actual bomblet detonation
/datum/ammo/micro_rail_cluster/proc/detonate(turf/T, obj/projectile/P)
	playsound(T, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	smoke.set_up(0, T, rand(1,2))
	smoke.start()

	var/list/turf/target_turfs = generate_true_cone(T, explosion_range, -1, 359, 0, air_pass = TRUE)
	for(var/turf/target_turf AS in target_turfs)
		for(var/target in target_turf)
			if(isliving(target))
				var/mob/living/living_target = target
				living_target.visible_message(span_danger("[living_target] is hit by the bomblet blast!"),
					isxeno(living_target) ? span_xenodanger("We are hit by the bomblet blast!") : span_highdanger("you are hit by the bomblet blast!"))
				living_target.apply_damages(explosion_damage * 0.5, explosion_damage * 0.5, 0, 0, 0, blocked = BOMB, updating_health = TRUE)
				staggerstun(living_target, P, stagger = stagger_amount, slowdown = slow_amount)
			else if(isobj(target))
				var/obj/obj_victim = target
				obj_victim.take_damage(explosion_damage, BRUTE, BOMB)

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
	icon_state = "bullet"
	flags_ammo_behavior = AMMO_BALLISTIC
	sound_hit 	 = "ballistic_hit"
	sound_armor = "ballistic_armor"
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


/datum/ammo/ags_shrapnel
	name = "fragmentation grenade"
	icon_state = "grenade_projectile"
	hud_state = "grenade_frag"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "40mm_grenade"
	handful_amount = 1
	ping = null //no bounce off.
	sound_bounce = "rocket_bounce"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_IFF
	armor_type = "bomb"
	damage_falloff = 0.5
	shell_speed = 2
	accurate_range = 12
	max_range = 21
	damage = 15
	shrapnel_chance = 0
	bonus_projectiles_type = /datum/ammo/bullet/ags_spread
	bonus_projectiles_scatter = 20
	var/bonus_projectile_quantity = 15


/datum/ammo/ags_shrapnel/on_hit_mob(mob/M, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 2, 3, Get_Angle(proj.firer, M) )

/datum/ammo/ags_shrapnel/on_hit_obj(obj/O, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 2, 3, Get_Angle(proj.firer, O) )

/datum/ammo/ags_shrapnel/on_hit_turf(turf/T, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 2, 3, Get_Angle(proj.firer, T) )

/datum/ammo/ags_shrapnel/do_at_max_range(turf/T, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 2, 3, Get_Angle(proj.firer, get_turf(proj)) )

/datum/ammo/ags_shrapnel/incendiary
	name = "white phosphorous grenade"
	bonus_projectiles_type = /datum/ammo/bullet/ags_spread/incendiary

/datum/ammo/bullet/ags_spread
	name = "Shrapnel"
	icon_state = "flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 15
	accuracy_var_high = 5
	max_range = 6
	damage = 30
	penetration = 20
	sundering = 3
	damage_falloff = 0

/datum/ammo/bullet/ags_spread/incendiary
	name = "White phosphorous shrapnel"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_INCENDIARY
	damage = 20
	penetration = 10
	sundering = 1.5
	damage_falloff = 0

/datum/ammo/bullet/ags_spread/incendiary/on_hit_mob(mob/M, obj/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/bullet/ags_spread/incendiary/on_hit_obj(obj/O, obj/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/bullet/ags_spread/incendiary/on_hit_turf(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/bullet/ags_spread/incendiary/do_at_max_range(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/bullet/ags_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)


/datum/ammo/bullet/coilgun
	name = "high-velocity tungsten slug"
	hud_state = "railgun_ap"
	icon_state = "blue_bullet"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 5
	max_range = 31
	damage = 70
	penetration = 35
	sundering = 5
	bullet_color = COLOR_PULSE_BLUE
	on_pierce_multiplier = 0.85

/datum/ammo/bullet/coilgun/on_hit_mob(mob/M, obj/projectile/P)
	staggerstun(M, P, weaken = 0.2 SECONDS, slowdown = 1, knockback = 3)


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
	sound_bounce = "rocket_bounce"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	armor_type = "bomb"
	damage_falloff = 0
	shell_speed = 2
	accuracy = 40
	accurate_range = 20
	max_range = 14
	damage = 200
	penetration = 100
	sundering = 100
	bullet_color = LIGHT_COLOR_FIRE
	barricade_clear_distance = 2

/datum/ammo/rocket/drop_nade(turf/T)
	explosion(T, 0, 4, 6, 0, 2)

/datum/ammo/rocket/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/rocket/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : O.loc)

/datum/ammo/rocket/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/rocket/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/rocket/he
	name = "high explosive rocket"
	icon_state = "rocket_he"
	hud_state = "rocket_he"
	accurate_range = 20
	max_range = 14
	damage = 200
	penetration = 100
	sundering = 100

/datum/ammo/rocket/he/unguided
	damage = 100
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING // We want this one to specifically go over onscreen range.

/datum/ammo/rocket/he/unguided/drop_nade(turf/T)
	explosion(T, 0, 7, 0, 0, 2)

/datum/ammo/rocket/ap
	name = "kinetic penetrator"
	icon_state = "rocket_ap"
	hud_state = "rocket_ap"
	damage = 340
	accurate_range = 15
	penetration = 200
	sundering = 0

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
	explosion(T, 0, 4, 6, 0, 7)

/datum/ammo/rocket/mech
	name = "large high-explosive rocket"
	damage = 75
	penetration = 50
	max_range = 30

/datum/ammo/rocket/mech/drop_nade(turf/T)
	explosion(T, 0, 0, 5, 0, 5)

/datum/ammo/rocket/heavy_isg
	name = "15cm round"
	icon_state = "heavyrr"
	hud_state = "bigshell_he"
	hud_state_empty = "shell_empty"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_EXPLOSIVE
	damage = 50
	penetration = 200
	max_range = 30
	shell_speed = 0.75
	accuracy = 30
	accurate_range = 21
	handful_amount = 1

/datum/ammo/rocket/heavy_isg/drop_nade(turf/T)
	explosion(T, 0, 7, 8, 12)

/datum/ammo/rocket/heavy_isg/unguided
	hud_state = "bigshell_he_unguided"
	flags_ammo_behavior = AMMO_ROCKET

/datum/ammo/bullet/heavy_isg_apfds
	name = "15cm APFDS round"
	icon_state = "apfds"
	hud_state = "bigshell_apfds"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	damage = 200
	penetration = 75
	shell_speed = 7
	accurate_range = 24
	accurate_range_min = 6
	max_range = 35

/datum/ammo/bullet/isg_apfds/on_hit_turf(turf/T, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/bullet/isg_apfds/on_hit_mob(mob/M, obj/projectile/P)
	P.proj_max_range -= 2
	staggerstun(M, P, max_range = 20, slowdown = 0.5)

/datum/ammo/bullet/isg_apfds/on_hit_obj(obj/O, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/rocket/wp
	name = "white phosphorous rocket"
	icon_state = "rocket_wp"
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
	///The radius for the non explosion effects
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
	icon_state = "rpg_incendiary"
	flags_ammo_behavior = AMMO_ROCKET
	effect_radius = 5

/datum/ammo/rocket/wp/quad/ds
	name = "super thermobaric rocket"
	hud_state = "rocket_thermobaric"
	flags_ammo_behavior = AMMO_ROCKET
	damage = 200
	penetration = 75
	max_range = 30
	sundering = 100

/datum/ammo/rocket/wp/unguided
	damage = 100
	flags_ammo_behavior = AMMO_ROCKET|AMMO_INCENDIARY|AMMO_SUNDERING
	effect_radius = 5

/datum/ammo/rocket/recoilless
	name = "high explosive shell"
	icon_state = "recoilless_rifle_he"
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
	explosion(T, 0, 3, 4, 0, 2)

/datum/ammo/rocket/recoilless/heat
	name = "HEAT shell"
	icon_state = "recoilless_rifle_heat"
	hud_state = "shell_heat"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING
	damage = 200
	penetration = 100
	sundering = 0

/datum/ammo/rocket/recoilless/heat/drop_nade(turf/T)
	explosion(T, flash_range = 1)

/datum/ammo/rocket/recoilless/heat/mech //for anti mech use in HvH
	name = "HEAM shell"
	accuracy = -10 //Not designed for anti human use
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING|AMMO_UNWIELDY

/datum/ammo/rocket/recoilless/heat/mech/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))
	if(ismecha(O))
		P.damage *= 3 //this is specifically designed to hurt mechs

/datum/ammo/rocket/recoilless/heat/mech/drop_nade(turf/T)
	explosion(T, 0, 1, 0, 0, 1)

/datum/ammo/rocket/recoilless/light
	name = "light explosive shell"
	icon_state = "recoilless_rifle_le"
	hud_state = "shell_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING //We want this to specifically go farther than onscreen range.
	accurate_range = 15
	max_range = 20
	damage = 75
	penetration = 50
	sundering = 25

/datum/ammo/rocket/recoilless/light/drop_nade(turf/T)
	explosion(T, 0, 1, 8, 0, 1)

/datum/ammo/rocket/recoilless/chemical
	name = "low velocity chemical shell"
	icon_state = "recoilless_rifle_smoke"
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
	icon_state = "recoilless_rifle_cloak"
	hud_state = "shell_cloak"
	smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/rocket/recoilless/chemical/plasmaloss
	name = "low velocity chemical shell"
	icon_state = "recoilless_rifle_tanglefoot"
	hud_state = "shell_tanglefoot"
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/rocket/recoilless/low_impact
	name = "low impact explosive shell"
	icon_state = "recoilless_rifle_le"
	hud_state = "shell_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING //We want this to specifically go farther than onscreen range.
	accurate_range = 15
	max_range = 20
	damage = 75
	penetration = 15
	sundering = 25

/datum/ammo/rocket/recoilless/low_impact/drop_nade(turf/T)
	explosion(T, 0, 1, 8, 0, 2)

/datum/ammo/rocket/oneuse
	name = "explosive rocket"
	damage = 100
	penetration = 100
	sundering = 100
	max_range = 30

/datum/ammo/rocket/som
	name = "high explosive RPG"
	icon_state = "rpg_he"
	hud_state = "rpg_he"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING
	accurate_range = 15
	max_range = 20
	damage = 80
	penetration = 20
	sundering = 20

/datum/ammo/rocket/som/drop_nade(turf/T)
	explosion(T, 0, 3, 6, 0, 2)

/datum/ammo/rocket/som/light
	name = "low impact RPG"
	icon_state = "rpg_le"
	hud_state = "rpg_le"
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING
	accurate_range = 15
	damage = 60
	penetration = 10

/datum/ammo/rocket/som/light/drop_nade(turf/T)
	explosion(T, 0, 2, 7, 0, 2)

/datum/ammo/rocket/som/thermobaric
	name = "thermobaric RPG"
	icon_state = "rpg_thermobaric"
	hud_state = "rpg_thermobaric"
	damage = 30

/datum/ammo/rocket/som/thermobaric/drop_nade(turf/T)
	explosion(T, 0, 4, 5, 0, 4, 4)

/datum/ammo/rocket/som/heat //Anti tank, or mech
	name = "HEAT RPG"
	icon_state = "rpg_heat"
	hud_state = "rpg_heat"
	damage = 200
	penetration = 100
	sundering = 0
	accuracy = -10 //Not designed for anti human use
	flags_ammo_behavior = AMMO_ROCKET|AMMO_SUNDERING|AMMO_UNWIELDY

/datum/ammo/rocket/som/heat/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(get_turf(O))
	if(ismecha(O))
		P.damage *= 3 //this is specifically designed to hurt mechs

/datum/ammo/rocket/som/heat/drop_nade(turf/T)
	explosion(T, 0, 1, 0, 0, 1)

/datum/ammo/rocket/som/rad
	name = "irrad RPG"
	icon_state = "rpg_rad"
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
		var/sound_level
		if(get_dist(victim, T) <= inner_range)
			strength = rad_strength
			sound_level = 4
		else if(get_dist(victim, T) <= mid_range)
			strength = rad_strength * 0.7
			sound_level = 3
		else
			strength = rad_strength * 0.3
			sound_level = 2

		strength = victim.modify_by_armor(strength, BIO, 25)
		victim.apply_radiation(strength, sound_level)

	explosion(T, weak_impact_range = 4)

/datum/ammo/rocket/atgun_shell
	name = "high explosive ballistic cap shell"
	icon_state = "atgun"
	hud_state = "shell_heat"
	hud_state_empty = "shell_empty"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF
	shell_speed = 2
	damage = 90
	penetration = 30
	sundering = 25
	max_range = 30
	handful_amount = 1

/datum/ammo/rocket/atgun_shell/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 0, 2)

/datum/ammo/rocket/atgun_shell/on_hit_turf(turf/T, obj/projectile/P) //no explosion every time it hits a turf
	P.proj_max_range -= 10

/datum/ammo/rocket/atgun_shell/apcr
	name = "tungsten penetrator"
	hud_state = "shell_apcr"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 4
	damage = 200
	penetration = 70
	sundering = 25

/datum/ammo/rocket/atgun_shell/apcr/drop_nade(turf/T)
	explosion(T, flash_range = 1)

/datum/ammo/rocket/atgun_shell/apcr/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))
	P.proj_max_range -= 5
	staggerstun(M, P, max_range = 20, stagger = 1 SECONDS, slowdown = 0.5, knockback = 2, hard_size_threshold = 3)

/datum/ammo/rocket/atgun_shell/apcr/on_hit_obj(obj/O, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/rocket/atgun_shell/apcr/on_hit_turf(turf/T, obj/projectile/P)
	P.proj_max_range -= 5

/datum/ammo/rocket/atgun_shell/he
	name = "low velocity high explosive shell"
	hud_state = "shell_he"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	damage = 50
	penetration = 50
	sundering = 35

/datum/ammo/rocket/atgun_shell/he/drop_nade(turf/T)
	explosion(T, 0, 3, 5)

/datum/ammo/rocket/atgun_shell/he/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/rocket/atgun_shell/beehive
	name = "beehive shell"
	hud_state = "shell_le"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	shell_speed = 3
	damage = 30
	penetration = 30
	sundering = 5
	bonus_projectiles_type = /datum/ammo/bullet/atgun_spread
	bonus_projectiles_scatter = 8
	var/bonus_projectile_quantity = 10

/datum/ammo/rocket/atgun_shell/beehive/drop_nade(turf/T)
	explosion(T, flash_range = 1)

/datum/ammo/rocket/atgun_shell/beehive/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, slowdown = 0.2, knockback = 1)
	drop_nade(get_turf(M))
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 5, 3, Get_Angle(proj.firer, M) )

/datum/ammo/rocket/atgun_shell/beehive/on_hit_obj(obj/O, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 5, 3, Get_Angle(proj.firer, O) )

/datum/ammo/rocket/atgun_shell/beehive/on_hit_turf(turf/T, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 5, 3, Get_Angle(proj.firer, T) )

/datum/ammo/rocket/atgun_shell/beehive/do_at_max_range(turf/T, obj/projectile/proj)
	playsound(proj, sound(get_sfx("explosion_micro")), 30, falloff = 5)
	fire_directionalburst(proj, proj.firer, proj.shot_from, bonus_projectile_quantity, 5, 3, Get_Angle(proj.firer, get_turf(proj)) )

/datum/ammo/rocket/atgun_shell/beehive/incend
	name = "napalm shell"
	hud_state = "shell_heat"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_SUNDERING
	shell_speed = 3
	bonus_projectiles_type = /datum/ammo/bullet/atgun_spread/incendiary

/datum/ammo/bullet/atgun_spread
	name = "Shrapnel"
	icon_state = "flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	accuracy_var_low = 15
	accuracy_var_high = 5
	max_range = 6
	damage = 30
	penetration = 20
	sundering = 3
	damage_falloff = 0

/datum/ammo/bullet/atgun_spread/incendiary
	name = "incendiary flechette"
	flags_ammo_behavior = AMMO_BALLISTIC|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB|AMMO_INCENDIARY|AMMO_LEAVE_TURF
	damage = 20
	penetration = 10
	sundering = 1.5

/datum/ammo/bullet/atgun_spread/incendiary/on_hit_mob(mob/M, obj/projectile/proj)
	return

/datum/ammo/bullet/atgun_spread/incendiary/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(5, 10)

/datum/ammo/bullet/atgun_spread/incendiary/on_leave_turf(turf/T, atom/firer, obj/projectile/proj)
	drop_flame(T)

/datum/ammo/mortar
	name = "80mm shell"
	icon_state = "mortar"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_PASS_THROUGH_TURF|AMMO_PASS_THROUGH_MOVABLE
	shell_speed = 0.75
	damage = 0
	penetration = 0
	sundering = 0
	accuracy = 1000
	max_range = 1000
	ping = null
	bullet_color = COLOR_VERY_SOFT_YELLOW

/datum/ammo/mortar/drop_nade(turf/T)
	explosion(T, 1, 2, 5, 0, 3)

/datum/ammo/mortar/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T)

/datum/ammo/mortar/incend/drop_nade(turf/T)
	explosion(T, 0, 2, 3, 0, 7, throw_range = 0)
	flame_radius(4, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/smoke
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/mortar/smoke/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 1, 0, 3, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, T, 11)
	smoke.start()

/datum/ammo/mortar/smoke/plasmaloss
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/flare/drop_nade(turf/T)
	new /obj/effect/temp_visual/above_flare(T)
	playsound(T, 'sound/weapons/guns/fire/flare.ogg', 50, 1, 4)

/datum/ammo/mortar/howi
	name = "150mm shell"
	icon_state = "howi"

/datum/ammo/mortar/howi/drop_nade(turf/T)
	explosion(T, 1, 6, 7, 0, 12)

/datum/ammo/mortar/howi/incend/drop_nade(turf/T)
	explosion(T, 0, 3, 0, 0, 0, 3, throw_range = 0)
	flame_radius(5, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/smoke/howi
	name = "150mm shell"
	icon_state = "howi"

/datum/ammo/mortar/smoke/howi/wp
	smoketype = /datum/effect_system/smoke_spread/phosphorus

/datum/ammo/mortar/smoke/howi/wp/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 1, 0, 0, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(6, T, 7)
	smoke.start()
	flame_radius(4, T)
	flame_radius(1, T, burn_intensity = 45, burn_duration = 75, burn_damage = 15, fire_stacks = 75)

/datum/ammo/mortar/smoke/howi/plasmaloss
	smoketype = /datum/effect_system/smoke_spread/plasmaloss

/datum/ammo/mortar/smoke/howi/plasmaloss/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 5, 0, 0, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, T, 11)
	smoke.start()

/datum/ammo/mortar/rocket
	name = "rocket"
	icon_state = "rocket"
	shell_speed = 1.5

/datum/ammo/mortar/rocket/drop_nade(turf/T)
	explosion(T, 1, 2, 5, 0, 3)

/datum/ammo/mortar/rocket/incend/drop_nade(turf/T)
	explosion(T, 0, 3, 0, 0, 3, throw_range = 0)
	flame_radius(5, T)
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 35, 1, 4)

/datum/ammo/mortar/rocket/minelayer/drop_nade(turf/T)
	var/obj/item/explosive/mine/mine = new /obj/item/explosive/mine(T)
	mine.deploy_mine(null, TGMC_LOYALIST_IFF)

/datum/ammo/mortar/rocket/smoke
	///the smoke effect at the point of detonation
	var/datum/effect_system/smoke_spread/smoketype = /datum/effect_system/smoke_spread/tactical

/datum/ammo/mortar/rocket/smoke/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 1, 0, 3, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(10, T, 11)
	smoke.start()

/datum/ammo/mortar/rocket/mlrs
	shell_speed = 2.5

/datum/ammo/mortar/rocket/mlrs/drop_nade(turf/T)
	explosion(T, 0, 0, 4, 0, 2)

/datum/ammo/mortar/rocket/smoke/mlrs
	shell_speed = 2.5
	smoketype = /datum/effect_system/smoke_spread/mustard

/datum/ammo/mortar/rocket/smoke/mlrs/drop_nade(turf/T)
	var/datum/effect_system/smoke_spread/smoke = new smoketype()
	explosion(T, 0, 0, 2, 0, 0, throw_range = 0)
	playsound(T, 'sound/effects/smoke.ogg', 25, 1, 4)
	smoke.set_up(5, T, 6)
	smoke.start()

/*
//================================================
					Energy Ammo
//================================================
*/

/datum/ammo/energy
	ping = "ping_s"
	sound_hit 	 = "energy_hit"
	sound_armor = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"

	damage_type = BURN
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SOUND_PITCH
	armor_type = "energy"
	accuracy = 15 //lasers fly fairly straight
	bullet_color = COLOR_LASER_RED
	barricade_clear_distance = 2

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
	staggerstun(M, P, stun = 20 SECONDS)

/datum/ammo/energy/tesla
	name = "energy ball"
	icon_state = "tesla"
	hud_state = "taser"
	hud_state_empty = "battery_empty"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SPECIAL_PROCESS
	shell_speed = 0.1
	damage = 20
	penetration = 20
	bullet_color = COLOR_TESLA_BLUE

/datum/ammo/energy/tesla/ammo_process(obj/projectile/proj, damage)
	zap_beam(proj, 4, damage)

/datum/ammo/energy/tesla/focused
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SPECIAL_PROCESS|AMMO_IFF
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
	armor_type = LASER
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
	staggerstun(M, P, stagger = 1 SECONDS, slowdown = 0.75)

/datum/ammo/energy/lasgun/pulsebolt
	name = "pulse bolt"
	icon_state = "pulse2"
	hud_state = "pulse"
	damage = 45 // this is gotta hurt...
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

	staggerstun(C, P, stagger = 2 SECONDS, slowdown = 1) //Staggers and slows down briefly

	return ..()

// TE Lasers //

/datum/ammo/energy/lasgun/marine
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN
	damage = 20
	penetration = 10
	sundering = 1.5
	max_range = 30
	hitscan_effect_icon = "beam"

/datum/ammo/energy/lasgun/marine/carbine
	sundering = 1
	max_range = 18

/datum/ammo/energy/lasgun/marine/overcharge
	name = "overcharged laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 40
	penetration = 20
	sundering = 2
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun/marine/weakening
	name = "weakening laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 30
	penetration = 10
	sundering = 0
	damage_type = STAMINA
	hitscan_effect_icon = "blue_beam"
	bullet_color = COLOR_DISABLER_BLUE
	///plasma drained per hit
	var/plasma_drain = 25

/datum/ammo/energy/lasgun/marine/weakening/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 6, slowdown = 1)

	if(!isxeno(M))
		return
	var/mob/living/carbon/xenomorph/xeno_victim = M
	xeno_victim.use_plasma(plasma_drain * xeno_victim.xeno_caste.plasma_regen_limit)

/datum/ammo/energy/lasgun/marine/microwave
	name = "microwave laser bolt"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 20
	penetration = 20
	sundering = 2
	hitscan_effect_icon = "beam_grass"
	bullet_color = LIGHT_COLOR_GREEN
	///number of microwave stacks to apply when hitting mobvs
	var/microwave_stacks = 1

/datum/ammo/energy/lasgun/marine/microwave/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	var/datum/status_effect/stacking/microwave/debuff = living_victim.has_status_effect(STATUS_EFFECT_MICROWAVE)

	if(debuff)
		debuff.add_stacks(microwave_stacks)
	else
		living_victim.apply_status_effect(STATUS_EFFECT_MICROWAVE, microwave_stacks)

/datum/ammo/energy/lasgun/marine/blast
	name = "wide range laser blast"
	icon_state = "heavylaser2"
	hud_state = "laser_spread"
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/blast/spread
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
	bullet_color = LIGHT_COLOR_PURPLE

/datum/ammo/energy/lasgun/marine/blast/spread
	name = "additional laser blast"

/datum/ammo/energy/lasgun/marine/impact
	name = "impact laser blast"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 35
	penetration = 10
	sundering = 0
	hitscan_effect_icon = "pu_laser"
	bullet_color = LIGHT_COLOR_PURPLE

/datum/ammo/energy/lasgun/marine/impact/on_hit_mob(mob/M, obj/projectile/proj)
	var/knockback_dist = round(LERP(3, 1, proj.distance_travelled / 6), 1)
	staggerstun(M, proj, max_range = 6, knockback = knockback_dist)

/datum/ammo/energy/lasgun/marine/cripple
	name = "impact laser blast"
	icon_state = "overchargedlaser"
	hud_state = "laser_sniper"
	damage = 20
	penetration = 10
	sundering = 0
	hitscan_effect_icon = "blue_beam"
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/cripple/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, slowdown = 1.5)

/datum/ammo/energy/lasgun/marine/autolaser
	name = "machine laser bolt"
	damage = 18
	penetration = 15
	sundering = 1

/datum/ammo/energy/lasgun/marine/autolaser/burst
	name = "burst machine laser bolt"
	hud_state = "laser_efficiency"
	damage = 12

/datum/ammo/energy/lasgun/marine/autolaser/charge
	name = "charged machine laser bolt"
	hud_state = "laser_efficiency"
	damage = 50
	penetration = 30
	sundering = 3
	hitscan_effect_icon = "beam_heavy"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOB

/datum/ammo/energy/lasgun/marine/autolaser/charge/on_hit_turf(turf/T, obj/projectile/proj)
	if(istype(T, /turf/closed/wall))
		var/turf/closed/wall/wall_victim = T
		wall_victim.take_damage(proj.damage, proj.damtype, proj.armor_type)

/datum/ammo/energy/lasgun/marine/autolaser/melting
	name = "melting machine laser bolt"
	hud_state = "laser_efficiency"
	damage = 15
	penetration = 20
	sundering = 0
	hitscan_effect_icon = "beam_solar"
	bullet_color = LIGHT_COLOR_YELLOW
	///number of melting stacks to apply when hitting mobs
	var/melt_stacks = 2

/datum/ammo/energy/lasgun/marine/autolaser/melting/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	var/datum/status_effect/stacking/melting/debuff = living_victim.has_status_effect(STATUS_EFFECT_MELTING)

	if(debuff)
		debuff.add_stacks(melt_stacks)
	else
		living_victim.apply_status_effect(STATUS_EFFECT_MELTING, melt_stacks)

/datum/ammo/energy/lasgun/marine/sniper
	name = "sniper laser bolt"
	hud_state = "laser_sniper"
	damage = 60
	penetration = 30
	accurate_range_min = 5
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 5
	max_range = 40
	damage_falloff = 0
	hitscan_effect_icon = "beam_heavy"

/datum/ammo/energy/lasgun/marine/sniper_heat
	name = "sniper heat bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 40
	penetration = 10
	accurate_range_min = 5
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 1
	hitscan_effect_icon = "u_laser_beam"
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/shatter
	name = "sniper shattering bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 40
	penetration = 30
	accurate_range_min = 5
	sundering = 10
	hitscan_effect_icon = "pu_laser"
	bullet_color = LIGHT_COLOR_PURPLE
	///shatter effection duration when hitting mobs
	var/shatter_duration = 5 SECONDS

/datum/ammo/energy/lasgun/marine/shatter/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return

	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)

/datum/ammo/energy/lasgun/marine/shatter/heavy_laser
	sundering = 1
	accurate_range_min = 0

/datum/ammo/energy/lasgun/marine/ricochet
	name = "sniper laser bolt"
	icon_state = "microwavelaser"
	hud_state = "laser_heat"
	damage = 100
	penetration = 30
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_SNIPER
	sundering = 1
	hitscan_effect_icon = "u_laser_beam"
	bonus_projectiles_scatter = 0
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/ricochet/one
	damage = 80
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet

/datum/ammo/energy/lasgun/marine/ricochet/two
	damage = 65
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet/one

/datum/ammo/energy/lasgun/marine/ricochet/three
	damage = 50
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet/two

/datum/ammo/energy/lasgun/marine/ricochet/four
	damage = 40
	bonus_projectiles_type = /datum/ammo/energy/lasgun/marine/ricochet/three

/datum/ammo/energy/lasgun/marine/ricochet/on_hit_turf(turf/T, obj/projectile/proj)
	reflect(T, proj, 5)

/datum/ammo/energy/lasgun/marine/ricochet/on_hit_obj(obj/O, obj/projectile/proj)
	reflect(get_turf(O), proj, 5)

/datum/ammo/energy/lasgun/marine/pistol
	name = "pistol laser bolt"
	damage = 20
	penetration = 5
	sundering = 1
	hitscan_effect_icon = "beam_particle"
	bullet_color = COLOR_DISABLER_BLUE

/datum/ammo/energy/lasgun/marine/pistol/disabler
	name = "disabler bolt"
	icon_state = "disablershot"
	hud_state = "laser_disabler"
	damage = 70
	penetration = 0
	damage_type = STAMINA
	hitscan_effect_icon = "beam_stun"
	bullet_color = LIGHT_COLOR_YELLOW

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
	bullet_color = COLOR_LASER_RED

/datum/ammo/energy/lasgun/pistol/disabler/on_hit_mob(mob/M,obj/projectile/P)
	staggerstun(M, P, stagger = 1 SECONDS, slowdown = 0.75)

/datum/ammo/energy/lasgun/marine/xray
	name = "xray heat bolt"
	hud_state = "laser_xray"
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
	hud_state = "laser_overcharge"
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
	drop_nade(O.density ? get_step_towards(O, P) : O, P)

/datum/ammo/energy/lasgun/marine/heavy_laser/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T)

/datum/ammo/energy/lasgun/marine/heavy_laser/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T)

/datum/ammo/energy/plasma
	name = "superheated plasma"
	icon_state = "plasma_small"
	hud_state = "plasma"
	hud_state_empty = "battery_empty"
	armor_type = ENERGY
	bullet_color = COLOR_DISABLER_BLUE
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING
	shell_speed = 3

/datum/ammo/energy/plasma/minigun_rapid
	icon_state = "plasma_ball_small"
	damage = 15
	penetration = 15
	sundering = 0.5
	damage_falloff = 0.5
	scatter = 3

/datum/ammo/energy/plasma/minigun_incendiary
	icon_state = "plasma_big"
	hud_state = "plasma_blast"
	damage = 35
	penetration = 25
	sundering = 1
	damage_falloff = 0.5
	flags_ammo_behavior = AMMO_ENERGY|AMMO_INCENDIARY|AMMO_EXPLOSIVE

	///Fire burn time
	var/heat = 12
	///Fire damage
	var/burn_damage = 9
	///Fire color
	var/fire_color = "green"

/datum/ammo/energy/plasma/minigun_glob
	icon_state = "plasma_ball_big"
	hud_state = "plasma_sphere"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ENERGY|AMMO_SUNDERING|AMMO_INCENDIARY
	damage = 35
	penetration = 25
	sundering = 1
	damage_falloff = 0.5

/datum/ammo/energy/plasma/minigun_glob/drop_nade(turf/T, radius = 1)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/weapons/guns/fire/flamethrower2.ogg', 50, 1, 4)
	flame_radius(radius, T, 3, 3, 3, 3)

/datum/ammo/energy/plasma/minigun_glob/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M))

/datum/ammo/energy/plasma/minigun_glob/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? get_step_towards(O, P) : O, P)

/datum/ammo/energy/plasma/minigun_glob/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T)

/datum/ammo/energy/plasma/minigun_glob/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T)

/datum/ammo/energy/plasma/sniper
	icon_state = "plasma_big"
	hud_state = "plasma_blast"
	damage = 70
	penetration = 30
	sundering = 7
	damage_falloff = 0
	accuracy = 1.1
	accurate_range_min = 5
	shell_speed = 4
	accurate_range = 30

/datum/ammo/energy/plasma/rifle_standard
	damage = 15
	penetration = 10
	sundering = 0.5
	damage_falloff = 0.25

/datum/ammo/energy/plasma/rifle_marksman
	icon_state = "plasma_big"
	hud_state = "plasma_blast"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	damage = 45
	penetration = 20
	sundering = 2
	damage_falloff = 0.15
	accurate_range = 25

/datum/ammo/energy/plasma/rifle_overcharge
	icon_state = "plasma_ball_big"
	hud_state = "plasma_sphere"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_ENERGY|AMMO_SUNDERING|AMMO_INCENDIARY
	damage = 50
	penetration = 20
	sundering = 4
	max_range = 50
	damage_falloff = 0.25
	shell_speed = 3.5
	var/shatter_duration = 5 SECONDS

/datum/ammo/energy/plasma/rifle_overcharge/on_hit_turf(turf/T, obj/projectile/proj)
	reflect(T, proj, 5)

/datum/ammo/energy/plasma/rifle_overcharge/on_hit_obj(obj/O, obj/projectile/proj)
	reflect(get_turf(O), proj, 5)

/datum/ammo/energy/plasma/rifle_overcharge/do_at_max_range(turf/T, obj/projectile/proj)
	explosion(T, 0, 2, 1, 0, throw_range = 0)

/datum/ammo/energy/plasma/rifle_overcharge/on_hit_mob(mob/M, obj/projectile/proj)
	explosion(get_turf(M), 0, 2, 1, 0, throw_range = 0)
	if(!isliving(M))
		return
	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)

/datum/ammo/energy/plasma/carbine_standard
	icon_state = "plasma_ball_small"
	damage = 20
	penetration = 10
	sundering = 0.5
	damage_falloff = 0.25

/datum/ammo/energy/plasma/carbine_standard/one
	bonus_projectiles_type = /datum/ammo/energy/plasma/carbine_standard

/datum/ammo/energy/plasma/carbine_standard/two
	bonus_projectiles_type = /datum/ammo/energy/plasma/carbine_standard/one

/datum/ammo/energy/plasma/carbine_standard/three
	bonus_projectiles_type = /datum/ammo/energy/plasma/carbine_standard/two

/datum/ammo/energy/plasma/carbine_standard/four
	bonus_projectiles_type = /datum/ammo/energy/plasma/carbine_standard/three

/datum/ammo/energy/plasma/carbine_standard/on_hit_turf(turf/T, obj/projectile/proj)
	reflect(T, proj, 10)

/datum/ammo/energy/plasma/carbine_trifire
	icon_state = "plasma_ball_small"
	hud_state = "plasma_blast"
	damage = 10
	penetration = 35
	sundering = 0.5
	damage_falloff = 0.5
	shell_speed = 4

/datum/ammo/energy/plasma/carbine_trifire/on_hit_mob(mob/M, obj/projectile/proj)
	staggerstun(M, proj, max_range = 10, slowdown = 0.2)

/datum/ammo/energy/plasma/pistol_standard
	damage = 35
	penetration = 10
	sundering = 1
	damage_falloff = 0.5

/datum/ammo/energy/plasma/pistol_automatic
	damage = 10
	penetration = 10
	sundering = 0.5
	damage_falloff = 0.5

/datum/ammo/energy/plasma/pistol_trifire
	icon_state = "plasma_ball_small"
	hud_state = "plasma_sphere"
	damage = 10
	penetration = 10
	sundering = 0.5
	damage_falloff = 0.5

/datum/ammo/energy/plasma/pistol_trifire/one
	bonus_projectiles_type = /datum/ammo/energy/plasma/pistol_trifire

/datum/ammo/energy/plasma/pistol_trifire/two
	bonus_projectiles_type = /datum/ammo/energy/plasma/pistol_trifire/one

/datum/ammo/energy/plasma/pistol_trifire/three
	bonus_projectiles_type = /datum/ammo/energy/plasma/pistol_trifire/two

/datum/ammo/energy/plasma/pistol_trifire/four
	bonus_projectiles_type = /datum/ammo/energy/plasma/pistol_trifire/three
	bonus_projectiles_amount = 3
	bonus_projectiles_scatter = 7

/datum/ammo/energy/plasma/pistol_trifire/on_hit_turf(turf/T, obj/projectile/proj)
	reflect(T, proj, 10)

/datum/ammo/energy/plasma/cannon_standard
	icon_state = "plasma_ball_small"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_PASS_THROUGH_MOB
	damage = 90
	penetration = 25
	sundering = 5
	damage_falloff = 0.25

/datum/ammo/energy/plasma/cannon_heavy
	icon_state = "plasma_ball_big"
	hud_state = "plasma_sphere"
	damage = 130
	penetration = 35
	sundering = 10
	damage_falloff = 0.25
	shell_speed = 4
	var/shatter_duration = 5 SECONDS

/datum/ammo/energy/plasma/cannon_heavy/on_hit_mob(mob/M, obj/projectile/proj)
	if(!isliving(M))
		return
	var/mob/living/living_victim = M
	living_victim.apply_status_effect(STATUS_EFFECT_SHATTER, shatter_duration)


/datum/ammo/energy/plasma/cannon_flamer
	//copy paste of flamer standard code kuro fix this
	icon_state = "plasma_big"
	hud_state = "flame"
	damage_type = BURN
	flags_ammo_behavior = AMMO_INCENDIARY|AMMO_FLAME|AMMO_EXPLOSIVE
	armor_type = "fire"
	max_range = 7
	damage = 31
	damage_falloff = 0
	incendiary_strength = 30 //Firestacks cap at 20, but that's after armor.
	bullet_color = LIGHT_COLOR_FIRE
	var/fire_color = "green"
	var/burntime = 13
	var/burnlevel = 25

/datum/ammo/energy/plasma/cannon_flamer/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(burntime, burnlevel, fire_color)

/datum/ammo/energy/plasma/cannon_flamer/on_hit_mob(mob/M, obj/projectile/P)
	drop_flame(get_turf(M))

/datum/ammo/energy/plasma/cannon_flamer/on_hit_obj(obj/O, obj/projectile/P)
	drop_flame(get_turf(O))

/datum/ammo/energy/plasma/cannon_flamer/on_hit_turf(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/energy/plasma/cannon_flamer/do_at_max_range(turf/T, obj/projectile/P)
	drop_flame(get_turf(T))

/datum/ammo/energy/xeno
	barricade_clear_distance = 0
	///Plasma cost to fire this projectile
	var/ability_cost
	///Particle type used when this ammo is used
	var/particles/channel_particle
	///The colour the xeno glows when using this ammo type
	var/glow_color

/datum/ammo/energy/xeno/psy_blast
	name = "psychic blast"
	flags_ammo_behavior = AMMO_XENO|AMMO_EXPLOSIVE|AMMO_ROCKET|AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN
	damage = 35
	penetration = 10
	sundering = 1
	max_range = 7
	accurate_range = 7
	hitscan_effect_icon = "beam_cult"
	icon_state = "psy_blast"
	ability_cost = 230
	channel_particle = /particles/warlock_charge/psy_blast
	glow_color = "#9e1f1f"
	///The AOE for drop_nade
	var/aoe_range = 2

/datum/ammo/energy/xeno/psy_blast/drop_nade(turf/T, obj/projectile/P)
	if(!T || !isturf(T))
		return
	playsound(T, 'sound/effects/EMPulse.ogg', 50)
	var/aoe_damage = 25
	if(isxeno(P.firer))
		var/mob/living/carbon/xenomorph/xeno_firer = P.firer
		aoe_damage = xeno_firer.xeno_caste.blast_strength

	var/list/throw_atoms = list()
	var/list/turf/target_turfs = generate_true_cone(T, aoe_range, -1, 359, 0, air_pass = TRUE)
	for(var/turf/target_turf AS in target_turfs)
		for(var/atom/movable/target AS in target_turf)
			if(isliving(target))
				var/mob/living/living_victim = target
				if(living_victim.stat == DEAD)
					continue
				if(!isxeno(living_victim))
					living_victim.apply_damage(aoe_damage, BURN, null, ENERGY, FALSE, FALSE, TRUE, penetration)
					staggerstun(living_victim, P, 10, slowdown = 1)
			else if(isobj(target))
				var/obj/obj_victim = target
				if(!(obj_victim.resistance_flags & XENO_DAMAGEABLE))
					continue
				obj_victim.take_damage(aoe_damage, BURN, ENERGY, TRUE, armour_penetration = penetration)
			if(target.anchored)
				continue
			throw_atoms += target

	for(var/atom/movable/target AS in throw_atoms)
		var/throw_dir = get_dir(T, target)
		if(T == get_turf(target))
			throw_dir = get_dir(P.starting_turf, T)
		target.safe_throw_at(get_ranged_target_turf(T, throw_dir, 5), 3, 1, spin = TRUE)

	new /obj/effect/temp_visual/shockwave(T, aoe_range + 2)

/datum/ammo/energy/xeno/psy_blast/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(M), P)

/datum/ammo/energy/xeno/psy_blast/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? get_step_towards(O, P) : O, P)

/datum/ammo/energy/xeno/psy_blast/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T, P)

/datum/ammo/energy/xeno/psy_blast/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? get_step_towards(T, P) : T, P)

/datum/ammo/energy/xeno/psy_blast/psy_lance
	name = "psychic lance"
	flags_ammo_behavior = AMMO_XENO|AMMO_ENERGY|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOVABLE
	damage = 60
	penetration = 50
	accuracy = 100
	sundering = 5
	max_range = 12
	hitscan_effect_icon = "beam_hcult"
	icon_state = "psy_lance"
	ability_cost = 300
	channel_particle = /particles/warlock_charge/psy_blast/psy_lance
	glow_color = "#CB0166"

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_obj(obj/O, obj/projectile/P)
	if(ismecha(O))
		var/obj/vehicle/sealed/mecha/mech_victim = O
		mech_victim.take_damage(200, BURN, ENERGY, TRUE, armour_penetration = penetration)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_mob(mob/M, obj/projectile/P)
	if(isxeno(M))
		return
	staggerstun(M, P, 9, stagger = 4 SECONDS, slowdown = 2, knockback = 1)

/datum/ammo/energy/xeno/psy_blast/psy_lance/on_hit_turf(turf/T, obj/projectile/P)
	return

/datum/ammo/energy/xeno/psy_blast/psy_lance/do_at_max_range(turf/T, obj/projectile/P)
	return

/datum/ammo/energy/lasgun/marine/mech
	name = "superheated laser bolt"
	damage = 45
	penetration = 20
	sundering = 1
	damage_falloff = 0.5

/datum/ammo/energy/lasgun/marine/mech/burst
	damage = 30
	penetration = 10
	sundering = 0.75
	damage_falloff = 0.6

/datum/ammo/energy/lasgun/marine/mech/smg
	name = "superheated pulsed laser bolt"
	damage = 15
	penetration = 10
	hitscan_effect_icon = "beam_particle"

/datum/ammo/energy/lasgun/marine/mech/lance_strike
	name = "particle lance"
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SNIPER|AMMO_SUNDERING|AMMO_HITSCAN|AMMO_PASS_THROUGH_MOVABLE|AMMO_PASS_THROUGH_MOB
	damage_type = BRUTE
	damage = 100
	armor_type = MELEE
	penetration = 25
	sundering = 8
	damage_falloff = -12.5 //damage increases per turf crossed
	max_range = 4
	on_pierce_multiplier = 0.5
	hitscan_effect_icon = "lance"

/datum/ammo/energy/lasgun/marine/mech/lance_strike/super
	damage = 120
	damage_falloff = -8
	max_range = 5

// Plasma //
/datum/ammo/energy/sectoid_plasma
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
	bullet_color = LIGHT_COLOR_ELECTRIC_GREEN

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
	flags_ammo_behavior = AMMO_ENERGY|AMMO_SUNDERING|AMMO_SOUND_PITCH
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
	sound_hit 	 = "energy_hit"
	sound_armor = "ballistic_armor"
	sound_miss	 = "ballistic_miss"
	sound_bounce = "ballistic_bounce"

/datum/ammo/energy/volkite/on_hit_mob(mob/M,obj/projectile/P)
	deflagrate(M, P)

/datum/ammo/energy/volkite/medium
	max_range = 25
	accurate_range = 12
	damage = 30
	accuracy_var_low = 3
	accuracy_var_high = 3
	fire_burst_damage = 20

/datum/ammo/energy/volkite/medium/custom
	deflagrate_multiplier = 2

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
	///The hivenumber of this ammo
	var/hivenumber = XENO_HIVE_NORMAL

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
	stagger_stacks = 1.1 SECONDS
	slowdown_stacks = 1.5
	smoke_strength = 0.5
	smoke_range = 0
	reagent_transfer_amount = 4

///Set up the list of reagents the spit transfers upon impact
/datum/ammo/xeno/toxin/proc/set_reagents()
	spit_reagents = list(/datum/reagent/toxin/xeno_neurotoxin = reagent_transfer_amount)

/datum/ammo/xeno/toxin/on_hit_mob(mob/living/carbon/carbon_victim, obj/projectile/proj)
	drop_neuro_smoke(get_turf(carbon_victim))

	if(!istype(carbon_victim) || carbon_victim.stat == DEAD || carbon_victim.issamexenohive(proj.firer) )
		return

	if(isnestedhost(carbon_victim))
		return

	carbon_victim.adjust_stagger(stagger_stacks)
	carbon_victim.add_slowdown(slowdown_stacks)

	set_reagents()
	for(var/reagent_id in spit_reagents)
		spit_reagents[reagent_id] = carbon_victim.modify_by_armor(spit_reagents[reagent_id], armor_type, penetration, proj.def_zone)

	carbon_victim.reagents.add_reagent_list(spit_reagents)

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
	if(T.density || istype(T, /turf/open/space)) // No structures in space
		return

	for(var/obj/O in T.contents)
		if(is_type_in_typecache(O, GLOB.no_sticky_resin))
			return

	new /obj/alien/resin/sticky/thin(T)

/datum/ammo/xeno/sticky/turret
	max_range = 9

/datum/ammo/xeno/sticky/globe
	name = "sticky resin globe"
	icon_state = "sticky_globe"
	damage = 40
	max_range = 7
	spit_cost = 200
	added_spit_delay = 8 SECONDS
	bonus_projectiles_type = /datum/ammo/xeno/sticky/mini
	bonus_projectiles_scatter = 22
	var/bonus_projectile_quantity = 16
	var/bonus_projectile_range = 3
	var/bonus_projectile_speed = 1

/datum/ammo/xeno/sticky/mini
	damage = 5
	max_range = 3

/datum/ammo/xeno/sticky/globe/on_hit_obj(obj/O, obj/projectile/P)
	var/turf/initial_turf = O.density ? P.loc : get_turf(O)
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/sticky/globe/on_hit_turf(turf/T, obj/projectile/P)
	var/turf/initial_turf = T.density ? P.loc : T
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/sticky/globe/on_hit_mob(mob/M, obj/projectile/P)
	var/turf/initial_turf = get_turf(M)
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/sticky/globe/do_at_max_range(turf/T, obj/projectile/P)
	var/turf/initial_turf = T.density ? P.loc : T
	drop_resin(initial_turf)
	fire_directionalburst(P, P.firer, P.shot_from, bonus_projectile_quantity, bonus_projectile_range, bonus_projectile_speed, Get_Angle(P.firer, initial_turf))

/datum/ammo/xeno/acid
	name = "acid spit"
	icon_state = "xeno_acid"
	sound_hit 	 = "acid_hit"
	sound_bounce = "acid_bounce"
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

/datum/ammo/xeno/acid/drop_nade(turf/T) //Leaves behind an acid pool; defaults to 1-3 seconds.
	if(T.density)
		return
	new /obj/effect/xenomorph/spray(T, puddle_duration, puddle_acid_damage)

/datum/ammo/xeno/acid/medium
	name = "acid spatter"
	damage = 30
	flags_ammo_behavior = AMMO_XENO

/datum/ammo/xeno/acid/auto
	name = "light acid spatter"
	damage = 10
	damage_falloff = 0.3
	spit_cost = 25
	added_spit_delay = 0

/datum/ammo/xeno/acid/auto/on_hit_mob(mob/M, obj/projectile/P)
	var/turf/T = get_turf(M)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/auto/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : get_turf(O))

/datum/ammo/xeno/acid/auto/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/auto/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

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

/datum/ammo/xeno/acid/heavy/on_hit_mob(mob/M, obj/projectile/P)
	var/turf/T = get_turf(M)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : get_turf(O))

/datum/ammo/xeno/acid/heavy/on_hit_turf(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

/datum/ammo/xeno/acid/heavy/do_at_max_range(turf/T, obj/projectile/P)
	drop_nade(T.density ? P.loc : T)

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
	///Base spread range
	var/fixed_spread_range = 3
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
	if(!do_after(user_xeno, 2 SECONDS, NONE, trap))
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
	var/turf/target_turf = get_turf(victim)
	drop_nade(target_turf.density ? proj.loc : target_turf, proj.firer)

	if(!istype(victim) || victim.stat == DEAD || victim.issamexenohive(proj.firer))
		return

	victim.Paralyze(hit_paralyze_time)
	victim.blur_eyes(hit_eye_blur)
	victim.adjustDrowsyness(hit_drowsyness)

	if(!reagent_transfer_amount || !iscarbon(victim))
		return

	var/mob/living/carbon/carbon_victim = victim
	set_reagents()
	for(var/reagent_id in spit_reagents)
		spit_reagents[reagent_id] = carbon_victim.modify_by_armor(spit_reagents[reagent_id], armor_type, penetration, proj.def_zone)

	carbon_victim.reagents.add_reagent_list(spit_reagents)

/datum/ammo/xeno/boiler_gas/on_hit_obj(obj/O, obj/projectile/P)
	if(ismecha(O))
		P.damage *= 7 //Globs deal much higher damage to mechs.
	var/turf/target_turf = get_turf(O)
	drop_nade(O.density ? P.loc : target_turf, P.firer)

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
		range = fixed_spread_range
	smoke_system.set_up(range, T)
	smoke_system.start()
	smoke_system = null
	T.visible_message(danger_message)

/datum/ammo/xeno/boiler_gas/corrosive
	name = "glob of acid"
	icon_state = "boiler_gas"
	sound_hit 	 = "acid_hit"
	sound_bounce = "acid_bounce"
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
	if(!do_after(user_xeno, 3 SECONDS, NONE, trap))
		return FALSE
	trap.set_trap_type(TRAP_SMOKE_ACID)
	trap.smoke = new /datum/effect_system/smoke_spread/xeno/acid
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
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(M), hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/on_hit_obj(obj/O, obj/projectile/proj)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(get_turf(O), hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/on_hit_turf(turf/T, obj/projectile/P)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(T.density ? P.loc : T, hivenumber)
	hugger.go_idle()

/datum/ammo/xeno/hugger/do_at_max_range(turf/T, obj/projectile/P)
	var/obj/item/clothing/mask/facehugger/hugger = new hugger_type(T.density ? P.loc : T, hivenumber)
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
	var/hit_weaken = 2 SECONDS
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
	if(T.density || (O.density && !(O.allow_pass_flags & PASS_PROJECTILE)))
		T = get_turf(proj)
	drop_leashball(T.density ? proj.loc : T, proj.firer)

/datum/ammo/xeno/leash_ball/do_at_max_range(turf/T, obj/projectile/proj)
	drop_leashball(T.density ? proj.loc : T)


/// This spawns a leash ball and checks if the turf is dense before doing so
/datum/ammo/xeno/leash_ball/proc/drop_leashball(turf/T)
	new /obj/structure/xeno/aoe_leash(get_turf(T), hivenumber)

/datum/ammo/xeno/spine //puppeteer
	name = "spine"
	damage = 35
	icon_state = "spine"
	damage_type = BRUTE
	bullet_color = COLOR_WHITE
	sound_hit = 'sound/bullets/spear_armor1.ogg'
	flags_ammo_behavior = AMMO_XENO|AMMO_SKIPS_ALIENS

/*
//================================================
					Misc Ammo
//================================================
*/

/datum/ammo/bullet/pepperball
	name = "pepperball"
	hud_state = "pepperball"
	hud_state_empty = "pepperball_empty"
	flags_ammo_behavior = AMMO_BALLISTIC
	accurate_range = 15
	damage_type = STAMINA
	armor_type = "bio"
	damage = 70
	penetration = 0
	shrapnel_chance = 0
	///percentage of xenos total plasma to drain when hit by a pepperball
	var/drain_multiplier = 0.05
	///Flat plasma to drain, unaffected by caste plasma amount.
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
	sound_hit 	 = "alloy_hit"
	sound_armor	 = "alloy_armor"
	sound_bounce = "alloy_bounce"
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
	icon_state = "pulse1"
	hud_state = "water"
	hud_state_empty = "water_empty"
	damage = 0
	shell_speed = 1
	damage_type = BURN
	flags_ammo_behavior = AMMO_EXPLOSIVE
	bullet_color = null

/datum/ammo/water/proc/splash(turf/extinguished_turf, splash_direction)
	var/obj/flamer_fire/current_fire = locate(/obj/flamer_fire) in extinguished_turf
	if(current_fire)
		qdel(current_fire)
	for(var/mob/living/mob_caught in extinguished_turf)
		mob_caught.ExtinguishMob()
	new /obj/effect/temp_visual/dir_setting/water_splash(extinguished_turf, splash_direction)

/datum/ammo/water/on_hit_mob(mob/M, obj/projectile/P)
	splash(get_turf(M), P.dir)

/datum/ammo/water/on_hit_obj(obj/O, obj/projectile/P)
	splash(get_turf(O), P.dir)

/datum/ammo/water/on_hit_turf(turf/T, obj/projectile/P)
	splash(get_turf(T), P.dir)

/datum/ammo/water/do_at_max_range(turf/T, obj/projectile/P)
	splash(get_turf(T), P.dir)

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

/datum/ammo/grenade_container/on_hit_mob(mob/M, obj/projectile/P)
	drop_nade(get_turf(P))

/datum/ammo/grenade_container/on_hit_obj(obj/O, obj/projectile/P)
	drop_nade(O.density ? P.loc : O.loc)

/datum/ammo/grenade_container/on_hit_turf(turf/T, obj/projectile/P)
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

/datum/ammo/grenade_container/ags_grenade
	name = "grenade shell"
	flags_ammo_behavior = AMMO_EXPLOSIVE|AMMO_IFF
	icon_state = "grenade_projectile"
	hud_state = "grenade_he"
	hud_state_empty = "grenade_empty"
	handful_icon_state = "40mm_grenade"
	handful_amount = 1
	max_range = 21
	nade_type = /obj/item/explosive/grenade/ags

/datum/ammo/grenade_container/ags_grenade/flare
	hud_state = "grenade_dummy"
	nade_type = /obj/item/explosive/grenade/flare

/datum/ammo/grenade_container/ags_grenade/cloak
	hud_state = "grenade_hide"
	nade_type = /obj/item/explosive/grenade/smokebomb/cloak/ags

/datum/ammo/grenade_container/ags_grenade/tanglefoot
	hud_state = "grenade_drain"
	nade_type = /obj/item/explosive/grenade/smokebomb/drain/agls
