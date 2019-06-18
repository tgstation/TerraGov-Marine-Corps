//There has to be a better way to define this shit. ~ Z
//can't equip anything
/mob/living/carbon/xenomorph/attack_ui(slot_id)
	return

/mob/living/carbon/xenomorph/attack_animal(mob/living/M as mob)

	if(isanimal(M))
		var/mob/living/simple_animal/S = M
		if(!S.melee_damage_upper)
			S.emote("[S.friendly] [src]")
		else
			M.animation_attack_on(src)
			M.flick_attack_overlay(src, "punch")
			visible_message("<span class='danger'>[S] [S.attacktext] [src]!</span>", null, null, 5)
			var/damage = rand(S.melee_damage_lower, S.melee_damage_upper)
			apply_damage(damage, BRUTE)
			log_combat(S, src, "attacked")
			updatehealth()

/mob/living/carbon/xenomorph/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!ismonkey(M)) //Fix for aliens receiving double messages when attacking other aliens
		return 0

	..()

	switch(M.a_intent)

		if(INTENT_HELP)
			help_shake_act(M)
		else
			if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return 0
			if(health > 0)
				M.animation_attack_on(src)
				M.flick_attack_overlay(src, "punch")
				playsound(loc, 'sound/weapons/bite.ogg', 25, 1)
				visible_message("<span class='danger'>\The [M] bites \the [src].</span>", \
				"<span class='danger'>You are bit by \the [M].</span>", null, 5)
				apply_damage(rand(1, 3), BRUTE)
				updatehealth()


/mob/living/carbon/xenomorph/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(.)
		return
	M.next_move += 7 //Adds some lag to the 'attack'. This will add up to 10
	switch(M.a_intent)

		if(INTENT_HELP)
			if(stat == DEAD)
				M.visible_message("<span class='warning'>\The [M] pokes \the [src], but nothing happens.</span>", \
				"<span class='warning'>You poke \the [src], but nothing happens.</span>", null, 5)
			else
				M.visible_message("<span class='notice'>\The [M] pets \the [src].</span>", \
					"<span class='notice'>You pet \the [src].</span>", null, 5)

		if(INTENT_GRAB)
			if(M == src || anchored)
				return 0

			M.start_pulling(src)

		else
			var/datum/unarmed_attack/attack = M.species.unarmed
			if(!attack.is_usable(M)) attack = M.species.secondary_unarmed
			if(!attack.is_usable(M))
				return 0

			M.animation_attack_on(src)
			M.flick_attack_overlay(src, "punch")

			var/damage = rand(1, 3)
			if(prob(85))
				damage += attack.damage > 5 ? attack.damage : 0

				playsound(loc, attack.attack_sound, 25, 1)
				visible_message("<span class='danger'>[M] [pick(attack.attack_verb)]ed [src]!</span>", null, null, 5)
				apply_damage(damage, BRUTE)
				updatehealth()
			else
				playsound(loc, attack.miss_sound, 25, 1)
				visible_message("<span class='danger'>[M] tried to [pick(attack.attack_verb)] [src]!</span>", null, null, 5)

	return

//Hot hot Aliens on Aliens action.
//Actually just used for eating people.
/mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/M)
	if(src != M)
		if(isxenolarva(M)) //Larvas can't eat people
			M.visible_message("<span class='danger'>[M] nudges its head against \the [src].</span>", \
			"<span class='danger'>You nudge your head against \the [src].</span>")
			return 0

		switch(M.a_intent)
			if(INTENT_HELP)

				if(on_fire)
					fire_stacks = max(fire_stacks - 1, 0)
					playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
					M.visible_message("<span class='danger'>[M] tries to put out the fire on [src]!</span>", \
						"<span class='warning'>You try to put out the fire on [src]!</span>", null, 5)
					if(fire_stacks <= 0)
						M.visible_message("<span class='danger'>[M] has successfully extinguished the fire on [src]!</span>", \
							"<span class='notice'>You extinguished the fire on [src].</span>", null, 5)
						ExtinguishMob()
					return 1
				else
					M.visible_message("<span class='notice'>\The [M] caresses \the [src] with its scythe-like arm.</span>", \
					"<span class='notice'>You caress \the [src] with your scythe-like arm.</span>", null, 5)

			if(INTENT_GRAB)
				if(M == src || anchored)
					return 0

				if(Adjacent(M)) //Logic!
					M.start_pulling(src)

					M.visible_message("<span class='warning'>[M] grabs \the [src]!</span>", \
					"<span class='warning'>You grab \the [src]!</span>", null, 5)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)

			if(INTENT_HARM)//Can't slash other xenos for now. SORRY  // You can now! --spookydonut
				M.animation_attack_on(src)
				if(issamexenohive(M))
					M.visible_message("<span class='warning'>\The [M] nibbles \the [src].</span>", \
					"<span class='warning'>You nibble \the [src].</span>", null, 5)
					return 1
				else
					// copypasted from attack_alien.dm
					//From this point, we are certain a full attack will go out. Calculate damage and modifiers
					var/damage = rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper) + FRENZY_DAMAGE_BONUS(M)

					//Somehow we will deal no damage on this attack
					if(!damage)
						playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
						M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
						"<span class='danger'>You lunge at [src]!</span>", null, 5)
						return 0

					M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
					"<span class='danger'>You slash [src]!</span>", null, 5)
					log_combat(M, src, "slashed")

					M.flick_attack_overlay(src, "slash")
					playsound(loc, "alien_claw_flesh", 25, 1)
					apply_damage(damage, BRUTE)

			if(INTENT_DISARM)
				M.animation_attack_on(src)
				M.flick_attack_overlay(src, "disarm")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1)
				M.visible_message("<span class='warning'>\The [M] shoves \the [src]!</span>", \
				"<span class='warning'>You shove \the [src]!</span>", null, 5)
				if(ismonkey(src))
					KnockDown(8)
		return 1
