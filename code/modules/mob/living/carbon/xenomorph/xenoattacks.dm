//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/xenomorph/attack_animal(mob/living/M as mob)
	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(!S.melee_damage)
			M.do_attack_animation(src)
			S.emote("me", EMOTE_VISIBLE, "[S.friendly] [src]")
		else
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message(span_danger("[S] [S.attacktext] [src]!"), null, null, 5)
			var/damage = S.melee_damage
			apply_damage(damage, BRUTE, blocked = MELEE)
			UPDATEHEALTH(src)
			log_combat(S, src, "attacked")


/mob/living/carbon/xenomorph/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	if(status_flags & INCORPOREAL) //Incorporeal xenos cannot attack
		return

	var/mob/living/carbon/human/H = user

	H.changeNext_move(7)
	switch(H.a_intent)

		if(INTENT_HELP)
			if(stat == DEAD)
				H.visible_message(span_warning("\The [H] pokes \the [src], but nothing happens."), \
				span_warning("You poke \the [src], but nothing happens."), null, 5)
			else
				H.visible_message(span_notice("\The [H] pets \the [src]."), \
					span_notice("You pet \the [src]."), null, 5)

		if(INTENT_GRAB)
			if(H == src || anchored)
				return 0

			H.start_pulling(src)

		if(INTENT_DISARM, INTENT_HARM)
			var/datum/unarmed_attack/attack = H.species.unarmed
			if(!attack.is_usable(H))
				attack = H.species.secondary_unarmed
			if(!attack.is_usable(H))
				return FALSE

			if(!H.melee_damage)
				H.do_attack_animation(src)
				playsound(loc, attack.miss_sound, 25, TRUE)
				visible_message(span_danger("[H] tried to [pick(attack.attack_verb)] [src]!"), null, null, 5)
				return FALSE

			H.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
			playsound(loc, attack.attack_sound, 25, TRUE)
			visible_message(span_danger("[H] [pick(attack.attack_verb)]ed [src]!"), null, null, 5)
			apply_damage(melee_damage + attack.damage, BRUTE, blocked = MELEE, updating_health = TRUE)


//Hot hot Aliens on Aliens action.
//Actually just used for eating people.
/mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(status_flags & INCORPOREAL || xeno_attacker.status_flags & INCORPOREAL) //Incorporeal xenos cannot attack or be attacked
		return

	if(src == xeno_attacker)
		return TRUE

	if(isxenolarva(xeno_attacker)) //Larvas can't eat people
		xeno_attacker.visible_message(span_danger("[xeno_attacker] nudges its head against \the [src]."), \
		span_danger("We nudge our head against \the [src]."))
		return FALSE

	switch(xeno_attacker.a_intent)
		if(INTENT_HELP)
			if(on_fire)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				xeno_attacker.visible_message(span_danger("[xeno_attacker] tries to put out the fire on [src]!"), \
					span_warning("We try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					xeno_attacker.visible_message(span_danger("[xeno_attacker] has successfully extinguished the fire on [src]!"), \
						span_notice("We extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE

			xeno_attacker.visible_message(span_notice("\The [xeno_attacker] caresses \the [src] with its scythe-like arm."), \
			span_notice("We caress \the [src] with our scythe-like arm."), null, 5)

		if(INTENT_GRAB)
			if(anchored)
				return FALSE
			if(!xeno_attacker.start_pulling(src))
				return FALSE
			xeno_attacker.visible_message(span_warning("[xeno_attacker] grabs \the [src]!"), \
			span_warning("We grab \the [src]!"), null, 5)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

		if(INTENT_HARM, INTENT_DISARM)//Can't slash other xenos for now. SORRY  // You can now! --spookydonut
			if(issamexenohive(xeno_attacker))
				xeno_attacker.do_attack_animation(src)
				xeno_attacker.visible_message(span_warning("\The [xeno_attacker] nibbles \the [src]."), \
				span_warning("We nibble \the [src]."), null, 5)
				return TRUE
			// Not at the base of the proc otherwise we can just nibble for free slashing effects
			SEND_SIGNAL(xeno_attacker, COMSIG_XENOMORPH_ATTACK_HOSTILE_XENOMORPH, src, damage_amount, xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier)
			// copypasted from attack_alien.dm
			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = xeno_attacker.xeno_caste.melee_damage

			//Somehow we will deal no damage on this attack
			if(!damage)
				xeno_attacker.do_attack_animation(src)
				playsound(xeno_attacker.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				xeno_attacker.visible_message(span_danger("\The [xeno_attacker] lunges at [src]!"), \
				span_danger("We lunge at [src]!"), null, 5)
				return FALSE

			xeno_attacker.visible_message(span_danger("\The [xeno_attacker] slashes [src]!"), \
			span_danger("We slash [src]!"), null, 5)
			log_combat(xeno_attacker, src, "slashed")

			xeno_attacker.do_attack_animation(src, ATTACK_EFFECT_REDSLASH)
			playsound(loc, "alien_claw_flesh", 25, 1)
			apply_damage(damage, BRUTE, blocked = MELEE, updating_health = TRUE)
