//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/xenomorph/attack_animal(mob/living/M as mob)

	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(!S.melee_damage)
			S.emote("me", EMOTE_VISIBLE, "[S.friendly] [src]")
		else
			M.do_attack_animation(src)
			M.flick_attack_overlay(src, "punch")
			visible_message("<span class='danger'>[S] [S.attacktext] [src]!</span>", null, null, 5)
			var/damage = S.melee_damage
			apply_damage(damage, BRUTE)
			log_combat(S, src, "attacked")
			updatehealth()

/mob/living/carbon/xenomorph/attack_paw(mob/living/carbon/monkey/user)
	. = ..()

	switch(user.a_intent)

		if(INTENT_HELP)
			help_shake_act(user)
		else
			if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return 0
			if(health > 0)
				user.do_attack_animation(src)
				playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
				visible_message("<span class='danger'>\The [user] bites \the [src].</span>", \
				"<span class='danger'>We are bit by \the [user].</span>", null, 5)
				apply_damage(rand(1, 3), BRUTE)
				updatehealth()


/mob/living/carbon/xenomorph/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	H.changeNext_move(7)
	switch(H.a_intent)

		if(INTENT_HELP)
			if(stat == DEAD)
				H.visible_message("<span class='warning'>\The [H] pokes \the [src], but nothing happens.</span>", \
				"<span class='warning'>You poke \the [src], but nothing happens.</span>", null, 5)
			else
				H.visible_message("<span class='notice'>\The [H] pets \the [src].</span>", \
					"<span class='notice'>You pet \the [src].</span>", null, 5)

		if(INTENT_GRAB)
			if(H == src || anchored)
				return 0

			H.start_pulling(src)

		else
			var/datum/unarmed_attack/attack = H.species.unarmed
			if(!attack.is_usable(H)) attack = H.species.secondary_unarmed
			if(!attack.is_usable(H))
				return 0

			H.do_attack_animation(src)
			H.flick_attack_overlay(src, "punch")

			var/damage = rand(1, 3)
			if(prob(85))
				damage += attack.damage > 5 ? attack.damage : 0

				playsound(loc, attack.attack_sound, 25, 1)
				visible_message("<span class='danger'>[H] [pick(attack.attack_verb)]ed [src]!</span>", null, null, 5)
				apply_damage(damage, BRUTE)
				updatehealth()
			else
				playsound(loc, attack.miss_sound, 25, 1)
				visible_message("<span class='danger'>[H] tried to [pick(attack.attack_verb)] [src]!</span>", null, null, 5)

	return

//Hot hot Aliens on Aliens action.
//Actually just used for eating people.
/mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/M)
	if(src != M)
		if(isxenolarva(M)) //Larvas can't eat people
			M.visible_message("<span class='danger'>[M] nudges its head against \the [src].</span>", \
			"<span class='danger'>We nudge our head against \the [src].</span>")
			return 0

		switch(M.a_intent)
			if(INTENT_HELP)

				if(on_fire)
					fire_stacks = max(fire_stacks - 1, 0)
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
					M.visible_message("<span class='danger'>[M] tries to put out the fire on [src]!</span>", \
						"<span class='warning'>We try to put out the fire on [src]!</span>", null, 5)
					if(fire_stacks <= 0)
						M.visible_message("<span class='danger'>[M] has successfully extinguished the fire on [src]!</span>", \
							"<span class='notice'>We extinguished the fire on [src].</span>", null, 5)
						ExtinguishMob()
					return 1
				else
					M.visible_message("<span class='notice'>\The [M] caresses \the [src] with its scythe-like arm.</span>", \
					"<span class='notice'>We caress \the [src] with our scythe-like arm.</span>", null, 5)

			if(INTENT_GRAB)
				if(M == src || anchored)
					return 0

				if(Adjacent(M)) //Logic!
					M.start_pulling(src)

					M.visible_message("<span class='warning'>[M] grabs \the [src]!</span>", \
					"<span class='warning'>We grab \the [src]!</span>", null, 5)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

			if(INTENT_HARM)//Can't slash other xenos for now. SORRY  // You can now! --spookydonut
				M.do_attack_animation(src)
				if(issamexenohive(M))
					M.visible_message("<span class='warning'>\The [M] nibbles \the [src].</span>", \
					"<span class='warning'>We nibble \the [src].</span>", null, 5)
					return 1
				else
					// copypasted from attack_alien.dm
					//From this point, we are certain a full attack will go out. Calculate damage and modifiers
					var/damage = M.xeno_caste.melee_damage + FRENZY_DAMAGE_BONUS(M)

					//Somehow we will deal no damage on this attack
					if(!damage)
						playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
						M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
						"<span class='danger'>We lunge at [src]!</span>", null, 5)
						return 0

					M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
					"<span class='danger'>We slash [src]!</span>", null, 5)
					log_combat(M, src, "slashed")

					M.flick_attack_overlay(src, "slash")
					playsound(loc, "alien_claw_flesh", 25, 1)
					apply_damage(damage, BRUTE)

			if(INTENT_DISARM)
				M.do_attack_animation(src)
				M.flick_attack_overlay(src, "disarm")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1)
				M.visible_message("<span class='warning'>\The [M] shoves \the [src]!</span>", \
				"<span class='warning'>We shove \the [src]!</span>", null, 5)
				if(ismonkey(src))
					knock_down(8)
		return 1
