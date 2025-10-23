#define NEST_RESIST_TIME 120 SECONDS
#define NEST_UNBUCKLED_COOLDOWN 5 SECONDS

///Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	hit_sound = SFX_ALIEN_RESIN_BREAK
	buckling_y = 6
	buckling_x = 0
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	max_integrity = 100
	layer = BELOW_OPEN_DOOR_LAYER
	var/buckleoverlaydir = SOUTH
	var/unbuckletime = 6 SECONDS
	var/resist_time = NEST_RESIST_TIME

/obj/structure/bed/nest/ai_should_stay_buckled(mob/living/carbon/npc)
	return TRUE

/obj/structure/bed/nest/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!ismob(G.grabbed_thing))
			return
		var/mob/M = G.grabbed_thing
		to_chat(user, span_notice("You place [M] on [src]."))
		M.forceMove(loc)
		user_buckle_mob(M, user)


/obj/structure/bed/nest/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.a_intent != INTENT_HARM)
		return attack_hand(xeno_attacker)
	return ..()

/obj/structure/bed/nest/user_buckle_mob(mob/living/buckling_mob, mob/living/user, check_loc = TRUE, silent, skip)
	if(skip)
		return ..()
	if(user.incapacitated() || !in_range(user, src) || buckling_mob.buckled)
		return FALSE
/*
	if(!isxeno(user))
		to_chat(user, span_warning("Gross! You're not touching that stuff."))
		return FALSE
*/
	if(LAZYLEN(buckled_mobs))
		to_chat(user, span_warning("There's already someone in [src]."))
		return FALSE
	if(ishuman(buckling_mob))
		var/mob/living/carbon/human/H = buckling_mob
		if(!TIMER_COOLDOWN_FINISHED(H, COOLDOWN_NEST))
			to_chat(user, span_warning("[H] was recently unbuckled. Wait a bit."))
			return FALSE

	user.visible_message(span_warning("[user] pins [buckling_mob] into [src], preparing the securing resin."),
	span_warning("[user] pins [buckling_mob] into [src], preparing the securing resin."))

	if(!do_mob(user, buckling_mob, 2 SECONDS, BUSY_ICON_HOSTILE))
		return FALSE
	if(QDELETED(src))
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, span_warning("There's already someone in [src]."))
		return FALSE
	if(!ishuman(buckling_mob))
		to_chat(user, span_warning("[buckling_mob] is not something we can capture."))
		return FALSE

	log_combat(user, buckling_mob, "nested", src)
	buckling_mob.visible_message(span_xenonotice("[user] applies a thick, vile resin, securing [buckling_mob] into [src]!"),
		span_xenonotice("[user] drenches you in a foul-smelling resin, trapping you in [src]!"),
		span_notice("You hear squelching."))
	playsound(loc, SFX_ALIEN_RESIN_MOVE, 50)

	silent = TRUE
	return ..()


/obj/structure/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	if(buckled_mob != user)
		if(user.incapacitated())
			return FALSE
		buckled_mob.visible_message(span_notice("\The [user] begins to pull \the [buckled_mob] free from \the [src]!"),
			span_notice("\The [user] begins to pull you free from \the [src]."),
			span_notice("You hear squelching."))
		if(isxeno(user))
			unbuckletime = 1 SECONDS//xeno go brr
		if(!do_after(user, unbuckletime, FALSE, buckled_mob, BUSY_ICON_FRIENDLY))
			return FALSE
		buckled_mob.visible_message(span_notice("\The [user] pulls \the [buckled_mob] free from \the [src]!"),
			span_notice("\The [user] pulls you free from \the [src]."),
			span_notice("You hear squelching."))
		playsound(loc, SFX_ALIEN_RESIN_MOVE, 50)
		TIMER_COOLDOWN_START(user, COOLDOWN_NEST, NEST_UNBUCKLED_COOLDOWN)
		silent = TRUE
		return ..()

	if(buckled_mob.incapacitated(TRUE))
		to_chat(buckled_mob, span_warning("You're currently unable to try that."))
		return FALSE
	buckled_mob.visible_message(span_warning("\The [buckled_mob] struggles to break free of \the [src]."), span_warning("You struggle to break free from \the [src]."), span_notice("You hear squelching."))
	if(!do_after(buckled_mob, resist_time, FALSE, buckled_mob, BUSY_ICON_DANGER))
		return FALSE
	buckled_mob.visible_message(span_danger("\The [buckled_mob] breaks free from \the [src]!"),
		span_danger("You pull yourself free from \the [src]!"),
		span_notice("You hear squelching."))
	silent = TRUE
	buckled_mob.AdjustStun(2 SECONDS)
	buckled_mob.set_lying_angle(90)
	buckled_mob.apply_damage(50, STAMINA, BODY_ZONE_L_ARM)
	buckled_mob.apply_damage(50, STAMINA, BODY_ZONE_R_ARM)
	buckled_mob.apply_damage(25, STAMINA, BODY_ZONE_L_LEG)
	buckled_mob.apply_damage(25, STAMINA, BODY_ZONE_R_LEG)
	return ..()


/obj/structure/bed/nest/post_buckle_mob(mob/living/buckling_mob)
	. = ..()
	ENABLE_BITFIELD(buckling_mob.restrained_flags, RESTRAINED_XENO_NEST)
	buckling_mob.pulledby?.stop_pulling()

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	if(QDELETED(buckled_mob))
		return
	DISABLE_BITFIELD(buckled_mob.restrained_flags, RESTRAINED_XENO_NEST)


/obj/structure/bed/nest/update_overlays()
	. = ..()
	if(LAZYLEN(buckled_mobs))
		. += image("icon_state" = "nest_overlay", "layer" = LYING_MOB_LAYER + 0.1)

/obj/structure/bed/nest/fire_act(burn_level)
	take_damage(burn_level * 2, BURN, FIRE)

/obj/structure/bed/nest/wall
	name = "wall alien nest"
	desc = "It's a wall of thick, sticky resin as a nest."
	icon = 'ntf_modular/icons/Xeno/Effects.dmi'
	icon_state = "nestwall"
	allow_pass_flags = null
	buckle_lying = 0
	buckling_x = 0
	buckling_y = 0
	density = TRUE
	smoothing_groups = list(SMOOTH_GROUP_XENO_STRUCTURES)

/obj/structure/bed/nest/wall/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	buckleoverlaydir = get_dir(src.loc, user.loc)
	src.dir = buckleoverlaydir
	face_atom(user)
	buckling_mob.face_atom(user)
	. = ..()
	if(!.)
		return
	walldir_update(buckling_mob)
	buckling_mob.set_lying_angle(0)
	update_overlays()

/obj/structure/bed/nest/wall/update_overlays()
	. = ..()
	if(LAZYLEN(buckled_mobs))
		. += image("icon_state" = "nestwall_overlay", "layer" = 6, "dir" = buckleoverlaydir, pixel_x = buckling_x, pixel_y = buckling_y)

/obj/structure/bed/nest/wall/proc/walldir_update(mob/buckling_mob)
	switch(buckleoverlaydir)
		if(4,3,5)
			buckleoverlaydir = 4
			dir = 4
			buckling_mob.dir = 4
			buckling_y = 0
			buckling_x = 12
			layer = 3
		if(8,9,7)
			buckleoverlaydir = 8
			dir = 8
			buckling_mob.dir = 8
			buckling_y = 0
			buckling_x = -12
			layer = 3
		if(1)
			dir = 1
			buckling_mob.dir = 1
			buckling_y = 12
			buckling_x = 0
			layer = 5
		if(2)
			dir = 2
			buckling_mob.dir = 2
			buckling_y = -6
			buckling_x = 0
			layer = 3
	buckling_mob.pixel_y = buckling_y
	buckling_mob.pixel_x = buckling_x

/obj/structure/bed/nest/wall/user_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	src.buckling_x = 0
	src.buckling_y = 0
	src.layer = 3
	buckled_mob.pixel_x = 0
	buckled_mob.pixel_y = 0


#undef NEST_RESIST_TIME
#undef NEST_UNBUCKLED_COOLDOWN
