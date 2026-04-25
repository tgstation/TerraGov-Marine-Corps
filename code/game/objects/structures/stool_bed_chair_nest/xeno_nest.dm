#define NEST_RESIST_TIME 2.5 SECONDS
#define NEST_UNBUCKLED_COOLDOWN 5 SECONDS

///Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/bed/nest
	name = "alien nest"
	desc = "It's a gruesome pile of thick, sticky resin shaped like a nest."
	icon = 'icons/Xeno/Effects.dmi'
	icon_state = "nest"
	hit_sound = SFX_ALIEN_RESIN_BREAK
	buckling_y = 6
	buildstacktype = null //can't be disassembled and doesn't drop anything when destroyed
	resistance_flags = UNACIDABLE|XENO_DAMAGEABLE
	max_integrity = 100
	var/resisting_time = 0
	layer = BELOW_OBJ_LAYER

/obj/structure/bed/nest/grab_interact(obj/item/grab/grab, mob/user, base_damage = BASE_OBJ_SLAM_DAMAGE, is_sharp = FALSE)
	if(!ismob(grab.grabbed_thing))
		return
	var/mob/grabbed_mob = grab.grabbed_thing
	to_chat(user, span_notice("You place [grabbed_mob] on [src]."))
	grabbed_mob.forceMove(loc)
	return TRUE

/obj/structure/bed/nest/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.a_intent != INTENT_HARM)
		return attack_hand(xeno_attacker)
	return ..()


/obj/structure/bed/nest/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	if(user.incapacitated() || !in_range(user, src) || buckling_mob.buckled)
		return FALSE
	if(!isxeno(user))
		to_chat(user, span_warning("Gross! You're not touching that stuff."))
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, span_warning("There's already someone in [src]."))
		return FALSE
	if(ishuman(buckling_mob))
		var/mob/living/carbon/human/H = buckling_mob
		if(TIMER_COOLDOWN_RUNNING(H, COOLDOWN_NEST))
			to_chat(user, span_warning("[H] was recently unbuckled. Wait a bit."))
			return FALSE
		if(!H.lying_angle)
			to_chat(user, span_warning("[H] is resisting, ground [H.p_them()]."))
			return FALSE

	user.visible_message(span_warning("[user] pins [buckling_mob] into [src], preparing the securing resin."),
	span_warning("[user] pins [buckling_mob] into [src], preparing the securing resin."))

	if(!do_after(user, 1 SECONDS, NONE, buckling_mob, BUSY_ICON_HOSTILE))
		return FALSE
	if(QDELETED(src))
		return FALSE
	if(LAZYLEN(buckled_mobs))
		to_chat(user, span_warning("There's already someone in [src]."))
		return FALSE
	if(ishuman(buckling_mob) && !buckling_mob.lying_angle) //Improperly stunned Marines won't be nested
		to_chat(user, span_warning("[buckling_mob] is resisting, ground [buckling_mob.p_them()]."))
		return FALSE

	buckling_mob.visible_message(span_xenonotice("[user] secretes a thick, vile resin, securing [buckling_mob] into [src]!"),
		span_xenonotice("[user] drenches you in a foul-smelling resin, trapping you in [src]!"),
		span_notice("You hear squelching."))
	playsound(loc, SFX_ALIEN_RESIN_MOVE, 50)

	silent = TRUE
	return ..()


/obj/structure/bed/nest/user_unbuckle_mob(mob/living/buckled_mob, mob/user, silent)
	if(buckled_mob != user)
		if(user.incapacitated())
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
	if(!resisting_time)
		resisting_time = world.time
		buckled_mob.visible_message(span_warning("\The [buckled_mob] struggles to break free of \the [src]."),
			span_warning("You struggle to break free from \the [src]."),
			span_notice("You hear squelching."))
		addtimer(CALLBACK(src, PROC_REF(unbuckle_time_message), user), NEST_RESIST_TIME)
		return FALSE
	if(resisting_time + NEST_RESIST_TIME > world.time)
		to_chat(buckled_mob, span_warning("You're already trying to free yourself. Give it some time."))
		return FALSE
	buckled_mob.visible_message(span_danger("\The [buckled_mob] breaks free from \the [src]!"),
		span_danger("You pull yourself free from \the [src]!"),
		span_notice("You hear squelching."))
	silent = TRUE
	return ..()


/obj/structure/bed/nest/proc/unbuckle_time_message(mob/living/user)
	if(QDELETED(user) || !(user in buckled_mobs))
		return //Time has passed, conditions may have changed.
	if(resisting_time + NEST_RESIST_TIME > world.time)
		return //We've been freed and re-nested.
	to_chat(user, span_danger("You are ready to break free! Resist once more to free yourself!"))


/obj/structure/bed/nest/post_buckle_mob(mob/living/buckling_mob)
	. = ..()
	ENABLE_BITFIELD(buckling_mob.restrained_flags, RESTRAINED_XENO_NEST)
	buckling_mob.pulledby?.stop_pulling()

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	resisting_time = 0 //Reset it to keep track on if someone is actively resisting.
	if(QDELETED(buckled_mob))
		return
	DISABLE_BITFIELD(buckled_mob.restrained_flags, RESTRAINED_XENO_NEST)


/obj/structure/bed/nest/update_overlays()
	. = ..()
	if(LAZYLEN(buckled_mobs))
		. += image("icon_state" = "nest_overlay", "layer" = LYING_MOB_LAYER + 0.1)

/obj/structure/bed/nest/fire_act(burn_level)
	take_damage(burn_level * 2, BURN, FIRE)

#undef NEST_RESIST_TIME
#undef NEST_UNBUCKLED_COOLDOWN
