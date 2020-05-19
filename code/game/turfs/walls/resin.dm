/**
 * Resin walls
 * 
 * Used mostly be xenomorphs
 */ 
/turf/closed/wall/resin
	name = "resin wall"
	desc = "Weird slime solidified into a wall."
	icon = 'icons/Xeno/structures.dmi'
	icon_state = "resin0"
	walltype = "resin"
	max_integrity = 200
	layer = RESIN_STRUCTURE_LAYER
	tiles_with = list(/turf/closed/wall/resin, /turf/closed/wall/resin/membrane, /obj/structure/mineral_door/resin)
	soft_armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)


/turf/closed/wall/resin/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD


/turf/closed/wall/resin/LateInitialize(mapload)
	if(!locate(/obj/effect/alien/weeds) in loc)
		new /obj/effect/alien/weeds(loc)


/turf/closed/wall/resin/ChangeTurf(path, new_baseturf, flags)
	. = ..()
	new /obj/effect/alien/weeds(.)


/turf/closed/wall/resin/flamer_fire_act()
	take_damage(50, BURN, "fire")


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
			take_damage(500)
		if(EXPLODE_HEAVY)
			take_damage(rand(140, 300))
		if(EXPLODE_LIGHT)
			take_damage(rand(50, 100))


/turf/closed/wall/resin/attack_alien(mob/living/carbon/xenomorph/M)
	M.visible_message("<span class='xenonotice'>\The [M] starts tearing down \the [src]!</span>", \
	"<span class='xenonotice'>We start to tear down \the [src].</span>")
	if(!do_after(M, 4 SECONDS, TRUE, M, BUSY_ICON_GENERIC))
		return
	M.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	M.visible_message("<span class='xenonotice'>\The [M] tears down \the [src]!</span>", \
	"<span class='xenonotice'>We tear down \the [src].</span>")
	playsound(src, "alien_resin_break", 25)
	take_damage(max_integrity) // Ensure its destroyed


/turf/closed/wall/resin/attack_hand(mob/living/user)
	to_chat(user, "<span class='warning'>You scrape ineffectively at \the [src].</span>")
	return TRUE


/turf/closed/wall/resin/attackby(obj/item/I, mob/living/user, params)
	if(I.flags_item & NOBLUDGEON || !isliving(user))
		return attack_hand(user)

	user.changeNext_move(I.attack_speed)
	user.do_attack_animation(src, used_item = I)

	var/damage = I.force
	var/multiplier = 1
	if(I.damtype == "fire") //Burn damage deals extra vs resin structures (mostly welders).
		multiplier += 1

	if(istype(I, /obj/item/tool/pickaxe/plasmacutter) && !user.action_busy)
		var/obj/item/tool/pickaxe/plasmacutter/P = I
		if(P.start_cut(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD))
			multiplier += PLASMACUTTER_RESIN_MULTIPLIER
			P.cut_apart(user, name, src, PLASMACUTTER_BASE_COST * PLASMACUTTER_VLOW_MOD)

	damage *= max(0, multiplier)
	take_damage(damage)
	playsound(src, "alien_resin_break", 25)


/turf/closed/wall/resin/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSGLASS))
		return !opacity
	return !density


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


/turf/closed/wall/resin/can_be_dissolved()
	return FALSE

/**
 * Regenerating walls that start with lower health, but grow to a much higher hp over time
 */
/turf/closed/wall/resin/regenerating
	max_integrity = 100

	/// Total health possible for a wall after regenerating at max health
	var/max_upgradable_health = 600 
	/// How much the walls integrity heals per tick (2 seconds)
	var/heal_per_tick = 10
	/// How much the walls max_integrity increases per tick (2 seconds)
	var/max_upgrade_per_tick = 1
	/// How long should the wall stop healing for when taking dmg
	var/cooldown_on_taking_dmg = 30 SECONDS

/turf/closed/wall/resin/regenerating/Initialize(mapload, ...)
	. = ..()
	START_PROCESSING(SSobj, src)

/**
 * Try to start processing on the wall.
 * Will return early if the wall is already at max upgradable health.
 */
/turf/closed/wall/resin/regenerating/proc/start_healing()
	if(wall_integrity == max_upgradable_health)
		return
	START_PROCESSING(SSobj, src)

/turf/closed/wall/resin/regenerating/process()
	if(wall_integrity == max_upgradable_health)
		STOP_PROCESSING(SSobj, src)
		return
	repair_damage(heal_per_tick)
	if(wall_integrity == max_integrity)
		max_integrity = min(max_integrity + max_upgrade_per_tick, max_upgradable_health)

/turf/closed/wall/resin/regenerating/take_damage(damage)
	var/destroyed = (wall_integrity - damage <= 0)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(destroyed) // I can't check qdel because the turf is replaced instead
		return
	addtimer(CALLBACK(src, .proc/start_healing), cooldown_on_taking_dmg)


/* Hivelord walls, they start off stronger */
/turf/closed/wall/resin/regenerating/thick
	max_integrity = 200
