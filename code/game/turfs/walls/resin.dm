/**
 * Resin walls
 *
 * Used mostly be xenomorphs
 */
/turf/closed/wall/resin
	name = RESIN_WALL
	desc = "Weird slime solidified into a wall."
	icon = 'icons/obj/smooth_objects/resin-wall.dmi'
	icon_state = "resin-wall-0"
	walltype = "resin-wall"
	base_icon_state = "resin-wall"
	max_integrity = 200
	layer = RESIN_STRUCTURE_LAYER
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_XENO_STRUCTURES)
	canSmoothWith = list(SMOOTH_GROUP_XENO_STRUCTURES)
	soft_armor = list(MELEE = 0, BULLET = 80, LASER = 75, ENERGY = 75, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	hard_armor = list(MELEE = 0, BULLET = 15, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = UNACIDABLE

	//Used for quickbuild refunding.
	var/is_normal_resin_wall = TRUE

/turf/closed/wall/resin/add_debris_element()
	AddElement(/datum/element/debris, null, -15, 8, 0.7)

/turf/closed/wall/resin/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD


/turf/closed/wall/resin/fire_act(burn_level)
	take_damage(burn_level * 1.25, BURN, FIRE)


/turf/closed/wall/resin/proc/thicken()
	ChangeTurf(/turf/closed/wall/resin/thick)
	return TRUE


/turf/closed/wall/resin/thick
	name = "thick resin wall"
	desc = "Weird slime solidified into a thick wall."
	max_integrity = 300
	icon_state = "thickresin0"
	walltype = "thickresin"


/turf/closed/wall/resin/thick/thicken()
	return FALSE


/turf/closed/wall/resin/membrane
	name = "resin membrane"
	desc = "Weird slime translucent enough to let light pass through."
	icon_state = "membrane0"
	walltype = "membrane"
	max_integrity = 120
	opacity = FALSE
	alpha = 180
	allow_pass_flags = PASS_GLASS
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_XENO_STRUCTURES)
	canSmoothWith = list(SMOOTH_GROUP_XENO_STRUCTURES)


/turf/closed/wall/resin/membrane/thicken()
	ChangeTurf(/turf/closed/wall/resin/membrane/thick)


/turf/closed/wall/resin/membrane/thick
	name = "thick resin membrane"
	desc = "Weird thick slime just translucent enough to let light pass through."
	max_integrity = 240
	icon_state = "thickmembrane0"
	walltype = "thickmembrane"
	alpha = 210


/turf/closed/wall/resin/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			take_damage(600, BRUTE, BOMB) // Heavy and devastate instakill walls.
		if(EXPLODE_HEAVY)
			take_damage(rand(400), BRUTE, BOMB)
		if(EXPLODE_LIGHT)
			take_damage(rand(75, 100), BRUTE, BOMB)
		if(EXPLODE_WEAK)
			take_damage(rand(30, 50), BRUTE, BOMB)


/turf/closed/wall/resin/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return
	if(CHECK_BITFIELD(SSticker.mode?.round_type_flags, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		if(is_normal_resin_wall)
			SSresinshaping.quickbuild_points_by_hive[xeno_attacker.hivenumber]++
			take_damage(max_integrity) // Ensure its destroyed
			return
	xeno_attacker.visible_message(span_xenonotice("\The [xeno_attacker] starts tearing down \the [src]!"), \
	span_xenonotice("We start to tear down \the [src]."))
	if(!do_after(xeno_attacker, 1 SECONDS, NONE, xeno_attacker, BUSY_ICON_GENERIC))
		return
	if(!istype(src)) // Prevent jumping to other turfs if do_after completes with the wall already gone
		return
	xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	xeno_attacker.visible_message(span_xenonotice("\The [xeno_attacker] tears down \the [src]!"), \
	span_xenonotice("We tear down \the [src]."))
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)
	take_damage(max_integrity) // Ensure its destroyed


/turf/closed/wall/resin/attack_hand(mob/living/user)
	to_chat(user, span_warning("You scrape ineffectively at \the [src]."))
	return TRUE


/turf/closed/wall/resin/attackby(obj/item/I, mob/living/user, params)
	if(I.item_flags & NOBLUDGEON || !isliving(user))
		return

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == BURN) //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1
	else if(I.damtype == BRUTE)
		multiplier += 0.75

	if(isplasmacutter(I) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage, BRUTE, MELEE)
	playsound(src, SFX_ALIEN_RESIN_BREAK, 25)

/turf/closed/wall/resin/dismantle_wall(devastated = 0, explode = 0)
	ScrapeAway()


/turf/closed/wall/resin/ChangeTurf(newtype)
	. = ..()
	if(.)
		var/turf/T
		for(var/i in GLOB.cardinals)
			T = get_step(src, i)
			if(!istype(T))
				continue
			for(var/obj/structure/mineral_door/resin/R in T)
				R.check_resin_support()

/**
 * Regenerating walls that start with lower health, but grow to a much higher hp over time
 */
/turf/closed/wall/resin/regenerating
	max_integrity = 75

	/// Total health possible for a wall after regenerating at max health
	var/max_upgradable_health = 300
	/// How much the walls integrity heals per tick (5 seconds)
	var/heal_per_tick = 25
	/// How much the walls max_integrity increases per tick (5 seconds)
	var/max_upgrade_per_tick = 6
	/// How long should the wall stop healing for when taking dmg
	var/cooldown_on_taking_dmg = 30 SECONDS
	///Whether we have a timer already to stop from clogging up the timer ss
	var/existingtimer = FALSE

/turf/closed/wall/resin/regenerating/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSslowprocess, src)

/**
 * Try to start processing on the wall.
 * Will return early if the wall is already at max upgradable health.
 */
/turf/closed/wall/resin/regenerating/proc/start_healing()
	if(wall_integrity == max_upgradable_health)
		return
	if(wall_integrity <= 0)
		return
	existingtimer = FALSE
	START_PROCESSING(SSslowprocess, src)

/turf/closed/wall/resin/regenerating/process()
	if(wall_integrity == max_upgradable_health)
		return PROCESS_KILL
	repair_damage(heal_per_tick)
	if(wall_integrity == max_integrity)
		max_integrity = min(max_integrity + max_upgrade_per_tick, max_upgradable_health)

/turf/closed/wall/resin/regenerating/take_damage(damage)
	var/destroyed = (wall_integrity - damage <= 0)
	. = ..()
	STOP_PROCESSING(SSslowprocess, src)
	if(destroyed) // I can't check qdel because the turf is replaced instead
		return
	if(existingtimer)// Dont spam timers >:(
		return
	addtimer(CALLBACK(src, PROC_REF(start_healing)), cooldown_on_taking_dmg)
	existingtimer = TRUE


/* Hivelord walls, they start off stronger */
/turf/closed/wall/resin/regenerating/thick
	max_integrity = 125

/turf/closed/wall/resin/regenerating/special
	name = "you shouldn't see this"
	is_normal_resin_wall = FALSE

/turf/closed/wall/resin/regenerating/special/bulletproof
	name = "bulletproof resin wall"
	desc = "Weird slime solidified into a wall. Looks shiny."
	soft_armor = list(MELEE = 0, BULLET = 100, LASER = 100, ENERGY = 100, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0) //You aren't damaging this with bullets without alot of AP.
	color = COLLOR_WALL_BULLETPROOF

/turf/closed/wall/resin/regenerating/special/fireproof
	name = "fireproof resin wall"
	desc = "Weird slime solidified into a wall. Very red."
	soft_armor = list(MELEE = 0, BULLET = 80, LASER = 75, ENERGY = 75, BOMB = 0, BIO = 0, FIRE = 200, ACID = 0)
	color = COLOR_WALL_FIREPROOF

/turf/closed/wall/resin/regenerating/special/hardy
	name = "hardy resin wall"
	desc = "Weird slime soldified into a wall. Looks very strong."
	max_upgradable_health = 450
	max_upgrade_per_tick = 12 //Upgrades faster, but if damaged at all it will be put on cooldown still to help against walling in combat.
	color = COLOR_WALL_HARDY
