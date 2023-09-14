#define NEST_UNBUCKLED_COOLDOWN 15 SECONDS

///Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.
/obj/structure/bed/nest
	name = ALIEN_NEST
	icon = 'modular_RUtgmc/icons/Xeno/Effects.dmi'


/obj/structure/bed/nest/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(X.status_flags & INCORPOREAL)
		return

	X.visible_message(span_xenonotice("\The [X] starts tearing down \the [src]!"), \
	span_xenonotice("We start to tear down \the [src]."))
	if(!do_after(X, 4 SECONDS, TRUE, X, BUSY_ICON_GENERIC))
		return
	if(!istype(src)) // Prevent jumping to other turfs if do_after completes with the wall already gone
		return
	X.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	X.visible_message(span_xenonotice("\The [X] tears down \the [src]!"), \
	span_xenonotice("We tear down \the [src]."))
	playsound(src, "alien_resin_break", 25)
	take_damage(max_integrity) // Ensure its destroyed

/obj/structure/bed/nest/user_buckle_mob(mob/living/buckling_mob, mob/user, check_loc = TRUE, silent)
	if(isxenohivemind(user))
		to_chat(user, span_warning("We lack limbs to do that."))
		return FALSE
	return ..()

/obj/structure/bed/nest/post_buckle_mob(mob/living/buckling_mob)
	. = ..()
	buckling_mob.reagents.add_reagent(/datum/reagent/medicine/xenojelly, 15)

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/buckled_mob)
	. = ..()
	TIMER_COOLDOWN_START(buckled_mob, COOLDOWN_NEST, NEST_UNBUCKLED_COOLDOWN)

#undef NEST_UNBUCKLED_COOLDOWN
