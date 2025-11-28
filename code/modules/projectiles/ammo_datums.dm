#define DEBUG_STAGGER_SLOWDOWN 0

GLOBAL_LIST_INIT(no_sticky_resin, typecacheof(list(/obj/item/clothing/mask/facehugger, /obj/alien/egg, /obj/structure/mineral_door, /obj/alien/resin, /obj/structure/bed/nest))) //For sticky/acid spit

/**
 * # The base ammo datum
 *
 * This datum is the base for absolutely every ammo type in the game.
*/
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
	var/accuracy_variation = 1
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
	var/armor_type = BULLET
	///How many stacks of sundering to apply to a mob on hit
	var/sundering = 0
	///how much damage airbursts do to mobs around the target, multiplier of the bullet's damage
	var/airburst_multiplier = 0.1
	///What kind of behavior the ammo has
	var/ammo_behavior_flags = NONE
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
	var/deflagrate_multiplier = 0.9
	///Flat damage caused if fire_burst is triggered by deflagrate
	var/fire_burst_damage = 10
	///Base fire stacks added on hit if the projectile has AMMO_INCENDIARY
	var/incendiary_strength = 10

/datum/ammo/proc/do_at_max_range(turf/target_turf, atom/movable/projectile/proj)
	return

///Does it do something special when shield blocked? Ie. a flare or grenade that still blows up.
/datum/ammo/proc/on_shield_block(mob/target_mob, atom/movable/projectile/proj)
	return

///Special effects when hitting dense turfs.
/datum/ammo/proc/on_hit_turf(turf/target_turf, atom/movable/projectile/proj)
	return

///Special effects when hitting mobs.
/datum/ammo/proc/on_hit_mob(mob/target_mob, atom/movable/projectile/proj)
	return

///Special effects when hitting objects.
/datum/ammo/proc/on_hit_obj(obj/target_obj, atom/movable/projectile/proj)
	return

///Special effects for leaving a turf. Only called if the projectile has AMMO_LEAVE_TURF enabled
/datum/ammo/proc/on_leave_turf(turf/target_turf, atom/movable/projectile/proj)
	return

///Handles CC application on the victim
/datum/ammo/proc/staggerstun(mob/victim, atom/movable/projectile/proj, max_range = 5, stun = 0, paralyze = 0, stagger = 0, slowdown = 0, knockback = 0, soft_size_threshold = 3, hard_size_threshold = 2)
	if(!victim)
		CRASH("staggerstun called without a mob target")
	if(!isliving(victim))
		return
	if(get_dist_euclidean(proj.starting_turf, victim) > max_range)
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
	if(hard_size_threshold >= victim.mob_size && (stun || paralyze || knockback))
		var/mob/living/living_victim = victim
		if(living_victim.IsStun() || living_victim.IsParalyzed()) //Prevent chain stunning.
			stun = 0
			paralyze = 0

		if(stun || paralyze)
			var/list/stunlist = list(stun, paralyze, stagger, slowdown)
			if(SEND_SIGNAL(living_victim, COMSIG_LIVING_PROJECTILE_STUN, stunlist, armor_type, penetration))
				stun = stunlist[1]
				paralyze = stunlist[2]
				stagger = stunlist[3]
				slowdown = stunlist[4]
			living_victim.apply_effects(stun,paralyze)

		if(knockback)
			if(isxeno(victim))
				impact_message += span_xenodanger("The blast knocks you off your feet!")
			else
				impact_message += span_userdanger("The blast knocks you off your feet!")
			victim.knockback(proj, knockback, 5)

	//Check for and apply soft CC
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Initial stagger is: <b>[carbon_victim.AmountStaggered()]</b>"))
		#endif
		if(!HAS_TRAIT(carbon_victim, TRAIT_STAGGER_RESISTANT)) //Some mobs like the Queen are immune to projectile stagger
			carbon_victim.Stagger(stagger)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Final stagger is: <b>[carbon_victim.AmountStaggered()]</b>"))
		#endif
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Initial slowdown is: <b>[carbon_victim.slowdown]</b>"))
		#endif
		carbon_victim.add_slowdown(slowdown)
		#if DEBUG_STAGGER_SLOWDOWN
		to_chat(world, span_debuginfo("Damage: Final slowdown is: <b>[carbon_victim.slowdown]</b>"))
		#endif
	to_chat(victim, "[impact_message]") //Summarize all the bad shit that happened


/datum/ammo/proc/airburst(atom/target, atom/movable/projectile/proj)
	if(!target || !proj)
		CRASH("airburst() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	for(var/mob/living/carbon/victim in orange(1, target))
		if(proj.firer == victim)
			continue
		victim.visible_message(span_danger("[victim] is hit by backlash from \a [proj.name]!"),
			isxeno(victim) ? span_xenodanger("We are hit by backlash from \a </b>[proj.name]</b>!") : span_userdanger("You are hit by backlash from \a </b>[proj.name]</b>!"))
		victim.apply_damage(proj.damage * airburst_multiplier, proj.ammo.damage_type, blocked = armor_type, updating_health = TRUE, attacker = proj.firer)

///handles the probability of a projectile hit to trigger fire_burst, based off actual damage done
/datum/ammo/proc/deflagrate(atom/target, atom/movable/projectile/proj)
	if(!target || !proj)
		CRASH("deflagrate() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	if(!istype(target, /mob/living))
		return

	var/mob/living/victim = target
	var/deflagrate_chance = victim.modify_by_armor(proj.damage - (proj.distance_travelled * proj.damage_falloff), FIRE, proj.penetration) * deflagrate_multiplier
	if(prob(deflagrate_chance))
		new /obj/effect/temp_visual/shockwave(get_turf(victim), 2)
		playsound(target, SFX_INCENDIARY_EXPLOSION, 40)
		fire_burst(target, proj)

///the actual fireblast triggered by deflagrate
/datum/ammo/proc/fire_burst(atom/target, atom/movable/projectile/proj)
	if(!target || !proj)
		CRASH("fire_burst() error: target [isnull(target) ? "null" : target] | proj [isnull(proj) ? "null" : proj]")
	for(var/mob/living/carbon/victim in range(1, target))
		if(victim == target)
			victim.visible_message(span_danger("[victim] bursts into flames as they are deflagrated by \a [proj.name]!"))
		else
			victim.visible_message(span_danger("[victim] is scorched by [target] as they burst into flames!"),
				isxeno(victim) ? span_xenodanger("We are scorched by [target] as they burst into flames!") : span_userdanger("you are scorched by [target] as they burst into flames!"))
		//Damages the victims, inflicts brief stagger+slow, and ignites
		victim.apply_damage(fire_burst_damage, BURN, blocked = FIRE, updating_health = TRUE, attacker = proj.firer)

		staggerstun(victim, proj, 30, stagger = 0.5 SECONDS, slowdown = 0.5)
		victim.adjust_fire_stacks(5)
		victim.IgniteMob()

/**
 * Fires additional projectiles, generally considered to still be originating from a gun
 * Such a buckshot
 * origin_override used to have the new projectile(s) originate from a different source than the main projectile
*/
/datum/ammo/proc/fire_bonus_projectiles(atom/movable/projectile/main_proj, mob/living/shooter, atom/source, range, speed, angle, target, origin_override) //todo: Combine these procs with extra args or something, as they are quite similar
	var/effect_icon = ""
	var/proj_type = /atom/movable/projectile
	if(istype(main_proj, /atom/movable/projectile/hitscan))
		proj_type = /atom/movable/projectile/hitscan
		var/atom/movable/projectile/hitscan/main_proj_hitscan = main_proj
		effect_icon = main_proj_hitscan.effect_icon
	for(var/i = 1 to bonus_projectiles_amount) //Want to run this for the number of bonus projectiles.
		var/atom/movable/projectile/new_proj = new proj_type(main_proj.loc, effect_icon)
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
/datum/ammo/proc/fire_directionalburst(atom/movable/projectile/main_proj, mob/living/shooter, atom/source, projectile_amount, angle, target, loc_override)
	var/effect_icon = ""
	var/proj_type = /atom/movable/projectile
	if(istype(main_proj, /atom/movable/projectile/hitscan))
		proj_type = /atom/movable/projectile/hitscan
		var/atom/movable/projectile/hitscan/main_proj_hitscan = main_proj
		effect_icon = main_proj_hitscan.effect_icon
	for(var/i = 1 to projectile_amount) //Want to run this for the number of bonus projectiles.
		var/atom/used_loc = loc_override ? loc_override : main_proj.loc
		var/atom/movable/projectile/new_proj = new proj_type(used_loc, effect_icon)
		// we do this so if we place inside something, we fly out of it instead of hitting it
		new_proj.hit_atoms += used_loc.contents
		if(bonus_projectiles_type)
			new_proj.generate_bullet(bonus_projectiles_type)
		else //If no bonus type is defined then the extra projectiles are the same as the main one.
			new_proj.generate_bullet(src)

		if(isgun(source))
			var/obj/item/weapon/gun/gun = source
			gun.apply_gun_modifiers(new_proj, target)

		//Scatter here is how many degrees extra stuff deviate from the main projectile's firing angle. Fully randomised with no 45 degree cap like normal bullets
		var/f = (i-1)
		var/new_angle = angle + (main_proj.ammo.bonus_projectiles_scatter * ((f % 2) ? (-(f + 1) * 0.5) : (f * 0.5)))
		if(new_angle < 0)
			new_angle += 360
		if(new_angle > 360)
			new_angle -= 360
		new_proj.fire_at(target, shooter, loc_override ? loc_override : main_proj.loc, null, null, new_angle, TRUE, scan_loc = TRUE)

/datum/ammo/proc/drop_flame(turf/T)
	if(!istype(T))
		return
	T.ignite(20, 20)


/datum/ammo/proc/set_smoke()
	return


/datum/ammo/proc/drop_nade(turf/T)
	return

///called on projectile process() when AMMO_SPECIAL_PROCESS flag is active
/datum/ammo/proc/ammo_process(atom/movable/projectile/proj, damage)
	CRASH("ammo_process called with unimplemented process!")

///bounces the projectile by creating a new projectile and calculating an angle of reflection
/datum/ammo/proc/reflect(turf/T, atom/movable/projectile/proj, scatter_variance)
	if(!bonus_projectiles_type) //while fire_bonus_projectiles does not require this var, it can cause infinite recursion in some cases, leading to death tiles
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
	fire_bonus_projectiles(proj, null, proj.shot_from, new_range, proj.projectile_speed, new_angle, null, get_step(T, dir_to_proj))
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
	ammo_behavior_flags = AMMO_BALLISTIC
	sound_hit = SFX_BALLISTIC_HIT
	sound_armor = SFX_BALLISTIC_ARMOR
	sound_miss = SFX_BALLISTIC_MISS
	sound_bounce = SFX_BALLISTIC_BOUNCE
	point_blank_range = 2
	accurate_range_min = 0
	shell_speed = 3
	damage = 10
	shrapnel_chance = 10
	bullet_color = COLOR_VERY_SOFT_YELLOW
	barricade_clear_distance = 2

