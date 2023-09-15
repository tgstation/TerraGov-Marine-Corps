//Hot hot Aliens on Aliens action.
//Actually just used for eating people.
/mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/X, damage_amount = X.xeno_caste.melee_damage, damage_type = BRUTE, damage_flag = "", effects = TRUE, armor_penetration = 0, isrightclick = FALSE)
	if(status_flags & INCORPOREAL || X.status_flags & INCORPOREAL) //Incorporeal xenos cannot attack or be attacked
		return

	if(src == X)
		return TRUE
	if(isxenolarva(X)) //Larvas can't eat people
		X.visible_message(span_danger("[X] nudges its head against \the [src]."), \
		span_danger("We nudge our head against \the [src]."))
		return FALSE

	switch(X.a_intent)
		if(INTENT_HELP)
			if(on_fire)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				X.visible_message(span_danger("[X] tries to put out the fire on [src]!"), \
					span_warning("We try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					X.visible_message(span_danger("[X] has successfully extinguished the fire on [src]!"), \
						span_notice("We extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE
			X.visible_message(span_notice("\The [X] caresses \the [src] with its scythe-like arm."), \
			span_notice("We caress \the [src] with our scythe-like arm."), null, 5)

		if(INTENT_GRAB)
			if(anchored)
				return FALSE
			if(!X.start_pulling(src))
				return FALSE
			X.visible_message(span_warning("[X] grabs \the [src]!"), \
			span_warning("We grab \the [src]!"), null, 5)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

		if(INTENT_HARM, INTENT_DISARM)//Can't slash other xenos for now. SORRY  // You can now! --spookydonut
			if(issamexenohive(X) && !HAS_TRAIT(src, TRAIT_BANISHED))
				X.do_attack_animation(src)
				X.visible_message(span_warning("\The [X] nibbles \the [src]."), \
				span_warning("We nibble \the [src]."), null, 5)
				return TRUE
			// copypasted from attack_alien.dm
			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = X.xeno_caste.melee_damage

			//Somehow we will deal no damage on this attack
			if(!damage)
				X.do_attack_animation(src)
				playsound(X.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				X.visible_message(span_danger("\The [X] lunges at [src]!"), \
				span_danger("We lunge at [src]!"), null, 5)
				return FALSE

			X.visible_message(span_danger("\The [X] slashes [src]!"), \
			span_danger("We slash [src]!"), null, 5)
			log_combat(X, src, "slashed")

			X.do_attack_animation(src, ATTACK_EFFECT_REDSLASH)
			playsound(loc, "alien_claw_flesh", 25, 1)
			apply_damage(damage, BRUTE, blocked = MELEE, updating_health = TRUE)
