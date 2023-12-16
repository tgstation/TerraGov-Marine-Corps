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
	soft_armor = list(MELEE = 0, BULLET = 70, LASER = 60, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)
	resistance_flags = UNACIDABLE

/turf/closed/wall/resin/add_debris_element()
	AddElement(/datum/element/debris, null, -15, 8, 0.7)

/turf/closed/wall/resin/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD


/turf/closed/wall/resin/flamer_fire_act(burnlevel)
	take_damage(burnlevel * 1.25, BURN, FIRE)


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


/turf/closed/wall/resin/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return
	if(CHECK_BITFIELD(SSticker.mode?.flags_round_type, MODE_ALLOW_XENO_QUICKBUILD) && SSresinshaping.active)
		SSresinshaping.quickbuild_points_by_hive[X.hivenumber]++
		take_damage(max_integrity) // Ensure its destroyed
		return
	X.visible_message(span_xenonotice("\The [X] starts tearing down \the [src]!"), \
	span_xenonotice("We start to tear down \the [src]."))
	if(!do_after(X, 1 SECONDS, NONE, X, BUSY_ICON_GENERIC))
		return
	if(!istype(src)) // Prevent jumping to other turfs if do_after completes with the wall already gone
		return
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	X.visible_message(span_xenonotice("\The [X] tears down \the [src]!"), \
	span_xenonotice("We tear down \the [src]."))
	playsound(src, "alien_resin_break", 25)
	take_damage(max_integrity) // Ensure its destroyed


/turf/closed/wall/resin/attack_hand(mob/living/user)
	to_chat(user, span_warning("You scrape ineffectively at \the [src]."))
	return TRUE


/turf/closed/wall/resin/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == BURN) //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.do_actions)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage, BRUTE, MELEE)
	playsound(src, "alien_resin_break", 25)

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
	max_integrity = 150

	/// Total health possible for a wall after regenerating at max health
	var/max_upgradable_health = 300
	/// How much the walls integrity heals per tick (5 seconds)
	var/heal_per_tick = 25
	/// How much the walls max_integrity increases per tick (5 seconds)
	var/max_upgrade_per_tick = 3
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
	max_integrity = 250
