//This file deals with xenos clicking on stuff in general. Including mobs, objects, general atoms, etc.
//Abby

/*
 * Important note about attack_alien : In our code, attack_ procs are received by src, not dealt by src
 * For example, attack_alien defined for humans means what will happen to THEM when attacked by an alien
 * In that case, the first argument is always the attacker. For attack_alien, it should always be Xenomorph sub-types
 */


/mob/living/carbon/human/attack_alien(mob/living/carbon/Xenomorph/M, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if (M.fortify)
		return FALSE

	var/intent = force_intent ? force_intent : M.a_intent

	switch(intent)

		if(INTENT_HELP)
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)

		if(INTENT_GRAB)
			if(M == src || anchored || buckled)
				return FALSE

			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s grab is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your grab was blocked by [src]'s shield!</span>", null, 5)
				playsound(loc, 'sound/weapons/alien_claw_block.ogg', 25, 1) //Feedback
				return FALSE

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

			if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

		if(INTENT_HARM)
			if(stat == DEAD)
				if(luminosity > 0)
					playsound(loc, "alien_claw_metal", 25, 1)
					M.flick_attack_overlay(src, "slash")
					disable_lights(sparks = TRUE)
					to_chat(M, "<span class='warning'>You disable whatever annoying lights the dead creature possesses.</span>")
				else
					to_chat(M, "<span class='warning'>[src] is dead, why would you want to touch it?</span>")
				return FALSE

			if(!M.hive.slashing_allowed && !(M.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
				to_chat(M, "<span class='warning'>Slashing is currently <b>forbidden</b> by the Queen. You refuse to slash [src].</span>")
				return FALSE

			if(!(M.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
				if(M.hive.slashing_allowed == XENO_SLASHING_RESTRICTED)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.issamexenohive(M))
								to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is an embryo inside!</span>")
								return FALSE

					if(M.health > round(M.maxHealth * 0.66)) //Note : Under 66 % health
						to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>")
						return FALSE

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.issamexenohive(M))
							to_chat(M, "<span class='warning'>You should not harm this host! It has a sister inside.</span>")
							return FALSE

			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s slash is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your slash is blocked by [src]'s shield!</span>", null, 5)
				return FALSE

			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper) + dam_bonus

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

			M.animation_attack_on(src)

			var/attack_flick =  "slash"
			var/attack_sound = "alien_claw_flesh"
			var/attack_message1 = "<span class='danger'>\The [M] slashes [src]!</span>"
			var/attack_message2 = "<span class='danger'>You slash [src]!</span>"
			var/log = "slashed"
			//Check for a special bite attack
			if(prob(M.xeno_caste.bite_chance) && !M.critical_proc && !no_crit && !M.stealth_router(HANDLE_STEALTH_CHECK)) //Can't crit if we already crit in the past 3 seconds; stealthed ironically can't crit because weeoo das a lotta damage
				damage *= 1.5
				attack_sound = "alien_bite"
				attack_message1 = "<span class='danger'>\The [src] is viciously shredded by \the [M]'s sharp teeth!</span>"
				attack_message2 = "<span class='danger'>You viciously rend \the [src] with your teeth!</span>"
				log = "bit"
				M.critical_proc = TRUE
				addtimer(CALLBACK(M, /mob/living/carbon/Xenomorph/proc/reset_critical_hit), M.xeno_caste.rng_min_interval)

			//Check for a special bite attack
			if(prob(M.xeno_caste.tail_chance) && !M.critical_proc && !no_crit && !M.stealth_router(HANDLE_STEALTH_CHECK)) //Can't crit if we already crit in the past 3 seconds; stealthed ironically can't crit because weeoo das a lotta damage
				damage *= 1.25
				attack_flick = "tail"
				attack_sound = 'sound/weapons/alien_tail_attack.ogg'
				attack_message1 = "<span class='danger'>\The [src] is suddenly impaled by \the [M]'s sharp tail!</span>"
				attack_message2 = "<span class='danger'>You violently impale \the [src] with your tail!</span>"
				log = "tail-stabbed"
				M.critical_proc = TRUE
				addtimer(CALLBACK(M, /mob/living/carbon/Xenomorph/proc/reset_critical_hit), M.xeno_caste.rng_min_interval)

			//Somehow we will deal no damage on this attack
			if(!damage)
				playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.animation_attack_on(src)
				M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
				"<span class='danger'>You lunge at [src]!</span>", null, 5)
				return FALSE

			M.flick_attack_overlay(src, attack_flick)
			var/datum/limb/affecting
			if(set_location)
				affecting = get_limb(set_location)
			else if(M.stealth_router(HANDLE_STEALTH_CHECK) && M.stealth_router(HANDLE_SNEAK_ATTACK_CHECK)) //We always get the limb we're aiming for if we're sneak attacking
				affecting = get_limb(M.zone_selected)
			else
				affecting = get_limb(ran_zone(M.zone_selected, 70))
			if(!affecting || (random_location && !set_location)) //No organ, just get a random one
				affecting = get_limb(ran_zone(null, 0))
			if(no_head && affecting == get_limb("chest"))
				affecting = get_limb("chest")
			if(!affecting) //Still nothing??
				affecting = get_limb("chest") //Gotta have a torso?!

			var/armor_block = run_armor_check(affecting, "melee")

			//The normal attack proceeds
			playsound(loc, attack_sound, 25, 1)
			M.visible_message("[attack_message1]", \
			"[attack_message2]")

			if(status_flags & XENO_HOST && stat != DEAD)
				if(istype(buckled, /obj/structure/bed/nest))
					var/turf/T = get_turf(M)
					log_ffattack("[key_name(M)] slashed [key_name(src)] while they were infected and nested in [AREACOORD(T)].")
					log_combat(M, src, log, addition = "while they were infected and nested")
					msg_admin_ff("[ADMIN_TPMONTY(M)] slashed [ADMIN_TPMONTY(src)] while they were infected and nested in [ADMIN_VERBOSEJMP(T)].")
				else
					log_combat(M, src, log, addition = "while they were infected")
			else //Normal xenomorph friendship with benefits
				log_combat(M, src, log)

			if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
				if(M.stealth_router(HANDLE_SNEAK_ATTACK_CHECK)) //Pouncing prevents us from making a sneak attack for 4 seconds
					if(m_intent == MOVE_INTENT_RUN)
						damage *= 1.75 //Half the multiplier if running.
						M.visible_message("<span class='danger'>\The [M] strikes [src] with vicious precision!</span>", \
						"<span class='danger'>You strike [src] with vicious precision!</span>")
					else
						damage *= 3.5 //Massive damage on the sneak attack... hope you have armour.
						M.visible_message("<span class='danger'>\The [M] strikes [src] with deadly precision!</span>", \
						"<span class='danger'>You strike [src] with deadly precision!</span>")
					KnockOut(2) //...And we knock them out
					adjust_stagger(3)
					add_slowdown(1.5)
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

			M.neuroclaw_router(src) //if we have neuroclaws...

			damage = M.hit_and_run_bonus(damage) //Apply Runner hit and run bonus damage if applicable
			apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
			updatehealth()

			M.process_rage_attack() //Process Ravager rage gains on attack

		if(INTENT_DISARM)
			if((status_flags & XENO_HOST) && istype(buckled, /obj/structure/bed/nest)) //No more memeing nested and infected hosts
				to_chat(M, "<span class='xenodanger'>You reconsider your mean-spirited bullying of the pregnant, secured host.</span>")
				return FALSE
			M.animation_attack_on(src)
			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s tackle is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your tackle is blocked by [src]'s shield!</span>", null, 5)
				return FALSE
			M.flick_attack_overlay(src, "disarm")

			if(!knocked_down && !no_stun && (traumatic_shock > 100))
				KnockDown(1)
				M.visible_message("<span class='danger'>\The [M] slams [src] to the ground!</span>", \
				"<span class='danger'>You slam [src] to the ground!</span>", null, 5)

			var/armor_block = run_armor_check("chest", "melee")

			playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)

			var/tackle_pain = M.xeno_caste.tackle_damage
			if(M.frenzy_aura)
				tackle_pain = tackle_pain * (1 + (0.05 * M.frenzy_aura))  //Halloss damage increased by 5% per rank of frenzy aura
			if(protection_aura)
				tackle_pain = tackle_pain * (1 - (0.10 + 0.05 * protection_aura))  //Halloss damage decreased by 10% + 5% per rank of protection aura
			if(M.stealth_router(HANDLE_STEALTH_CHECK))
				if(M.stealth_router(HANDLE_SNEAK_ATTACK_CHECK))
					KnockOut(2)
					if(m_intent == MOVE_INTENT_RUN && ( last_move_intent > (world.time - 20) ) ) //Allows us to slash while running... but only if we've been stationary for awhile
						tackle_pain *= 1.75 //Half the multiplier if running.
						M.visible_message("<span class='danger'>\The [M] strikes [src] with vicious precision!</span>", \
						"<span class='danger'>You strike [src] with vicious precision!</span>")
					else
						tackle_pain *= 3.5 //Massive damage on the sneak attack... hope you have armour.
						M.visible_message("<span class='danger'>\The [M] strikes [src] with deadly precision!</span>", \
						"<span class='danger'>You strike [src] with deadly precision!</span>")
					adjust_stagger(3)
					add_slowdown(1.5)
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)
			M.neuroclaw_router(src) //if we have neuroclaws...
			if(dam_bonus)
				tackle_pain += dam_bonus

			tackle_pain = M.hit_and_run_bonus(tackle_pain) //Apply Runner hit and run bonus damage if applicable

			apply_damage(tackle_pain, HALLOSS, "chest", armor_block * 0.4) //Only half armour applies vs tackle
			updatehealth()
			updateshock()
			var/throttle_message = "<span class='danger'>\The [M] throttles [src]!</span>"
			var/throttle_message2 = "<span class='danger'>You throttle [src]!</span>"
			if(tackle_pain > 40)
				throttle_message = "<span class='danger'>\The [M] badly throttles [src]!</span>"
				throttle_message2 = "<span class='danger'>You badly throttle [src]!</span>"
			M.visible_message("[throttle_message]", \
			"[throttle_message2]", null, 5)
			return TRUE

	return TRUE

/mob/living/carbon/Xenomorph/proc/reset_critical_hit()
	critical_proc = FALSE

/mob/living/carbon/Xenomorph/proc/process_rage_attack()
	return FALSE


//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/Xenomorph/M, dam_bonus, set_location = FALSE, random_location = FALSE, no_head = FALSE, no_crit = FALSE, force_intent = null)
	if (M.fortify)
		return FALSE

	var/intent = force_intent ? force_intent : M.a_intent

	switch(intent)
		if(INTENT_HELP)
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)
			return FALSE

		if(INTENT_GRAB)
			if(M == src || anchored || buckled)
				return FALSE

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)
			if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

		if(INTENT_HARM)
			if(isxeno(src) && issamexenohive(M))
				M.visible_message("<span class='warning'>\The [M] nibbles [src].</span>", \
				"<span class='warning'>You nibble [src].</span>", null, 5)
				return TRUE

			if(!(M.xeno_caste.caste_flags & CASTE_IS_INTELLIGENT))
				if(M.hive.slashing_allowed == XENO_SLASHING_RESTRICTED)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.issamexenohive(M))
								to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is a host inside!</span>")
								return FALSE

					if(M.health > round(2 * M.maxHealth / 3)) //Note : Under 66 % health
						to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>")
						return FALSE

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.issamexenohive(M))
							to_chat(M, "<span class='warning'>You should not harm this host! It has a sister inside.</span>")
							return FALSE

			if(issilicon(src) && stat != DEAD) //A bit of visual flavor for attacking Cyborgs. Sparks!
				var/datum/effect_system/spark_spread/spark_system
				spark_system = new /datum/effect_system/spark_spread()
				spark_system.set_up(5, 0, src)
				spark_system.attach(src)
				spark_system.start(src)
				playsound(loc, "alien_claw_metal", 25, 1)

			// copypasted from attack_alien.dm
			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.xeno_caste.melee_damage_lower, M.xeno_caste.melee_damage_upper)

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

			if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
				if(M.stealth_router(HANDLE_SNEAK_ATTACK_CHECK)) //Pouncing prevents us from making a sneak attack for 4 seconds
					damage *= 3.5 //Massive damage on the sneak attack... hope you have armour.
					KnockOut(2) //...And we knock them out
					M.visible_message("<span class='danger'>\The [M] strikes [src] with vicious precision!</span>", \
					"<span class='danger'>You strike [src] with vicious precision!</span>")
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

			//Somehow we will deal no damage on this attack
			if(!damage)
				playsound(M.loc, 'sound/weapons/alien_claw_swipe.ogg', 25, 1)
				M.animation_attack_on(src)
				M.visible_message("<span class='danger'>\The [M] lunges at [src]!</span>", \
				"<span class='danger'>You lunge at [src]!</span>", null, 5)
				return FALSE

			M.visible_message("<span class='danger'>\The [M] slashes [src]!</span>", \
			"<span class='danger'>You slash [src]!</span>", null, 5)
			log_combat(M, src, "slashed")

			playsound(loc, "alien_claw_flesh", 25, 1)
			apply_damage(damage, BRUTE)

		if(INTENT_DISARM)
			playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)
			M.visible_message("<span class='warning'>\The [M] shoves [src]!</span>", \
			"<span class='warning'>You shove [src]!</span>", null, 5)
			if(ismonkey(src))
				KnockDown(8)
	return FALSE

/mob/living/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	M.visible_message("<span class='danger'>[M] nudges its head against [src].</span>", \
	"<span class='danger'>You nudge your head against [src].</span>", null, 5)

/obj/attack_larva(mob/living/carbon/Xenomorph/Larva/M)
	return //larva can't do anything by default
