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

		if("help")
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)

		if("grab")
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

		if("hurt")
			var/datum/hive_status/hive
			if(M.hivenumber && M.hivenumber <= hive_datum.len)
				hive = hive_datum[M.hivenumber]
			else return

			if(!hive.slashing_allowed && !M.is_intelligent)
				to_chat(M, "<span class='warning'>Slashing is currently <b>forbidden</b> by the Queen. You refuse to slash [src].</span>")
				return FALSE

			if(stat == DEAD)
				if(luminosity > 0)
					playsound(loc, "alien_claw_metal", 25, 1)
					M.flick_attack_overlay(src, "slash")
					var/datum/effect_system/spark_spread/spark_system2
					spark_system2 = new /datum/effect_system/spark_spread()
					spark_system2.set_up(5, 0, src)
					spark_system2.attach(src)
					spark_system2.start(src)
					disable_lights()
					to_chat(M, "<span class='warning'>You disable whatever annoying lights the dead creature possesses.</span>")
				else
					to_chat(M, "<span class='warning'>[src] is dead, why would you want to touch it?</span>")
				return FALSE

			if(!M.is_intelligent)
				if(hive.slashing_allowed == 2)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.hivenumber == M.hivenumber)
								to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is a host inside!</span>")
								return FALSE

					if(M.health > round(M.maxHealth * 0.66)) //Note : Under 66 % health
						to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>")
						return FALSE

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.hivenumber == M.hivenumber)
							to_chat(M, "<span class='warning'>You should not harm this host! It has a sister inside.</span>")
							return FALSE

			if(check_shields(0, M.name) && prob(66)) //Bit of a bonus
				M.visible_message("<span class='danger'>\The [M]'s slash is blocked by [src]'s shield!</span>", \
				"<span class='danger'>Your slash is blocked by [src]'s shield!</span>", null, 5)
				return FALSE

			//From this point, we are certain a full attack will go out. Calculate damage and modifiers
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper) + dam_bonus

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
			if(prob(M.bite_chance) && !M.critical_proc && !no_crit && !M.stealth_router(HANDLE_STEALTH_CHECK)) //Can't crit if we already crit in the past 3 seconds; stealthed ironically can't crit because weeoo das a lotta damage
				damage *= 1.5
				attack_sound = "alien_bite"
				attack_message1 = "<span class='danger'>\The [src] is viciously shredded by \the [M]'s sharp teeth!</span>"
				attack_message2 = "<span class='danger'>You viciously rend \the [src] with your teeth!</span>"
				log = "bit"
				M.critical_proc = TRUE
				spawn(CRITICAL_HIT_DELAY)
					M.critical_proc = FALSE

			//Check for a special bite attack
			if(prob(M.bite_chance) && !M.critical_proc && !no_crit && !M.stealth_router(HANDLE_STEALTH_CHECK)) //Can't crit if we already crit in the past 3 seconds; stealthed ironically can't crit because weeoo das a lotta damage
				damage *= 1.25
				attack_flick = "tail"
				attack_sound = 'sound/weapons/alien_tail_attack.ogg'
				attack_message1 = "<span class='danger'>\The [src] is suddenly impaled by \the [M]'s sharp tail!</span>"
				attack_message2 = "<span class='danger'>You violently impale \the [src] with your tail!</span>"
				log = "tail-stabbed"
				M.critical_proc = TRUE
				spawn(CRITICAL_HIT_DELAY)
					M.critical_proc = FALSE

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

			if(isYautja(src) && check_zone(M.zone_selected) == "head")
				if(istype(wear_mask, /obj/item/clothing/mask/gas/yautja))
					var/knock_chance = 1
					if(M.frenzy_aura > 0)
						knock_chance += 2 * M.frenzy_aura
					if(M.is_intelligent)
						knock_chance += 2
					knock_chance += min(round(damage * 0.25), 10) //Maximum of 15% chance.
					if(prob(knock_chance))
						playsound(loc, "alien_claw_metal", 25, 1)
						M.visible_message("<span class='danger'>The [M] smashes off [src]'s [wear_mask.name]!</span>", \
						"<span class='danger'>You smash off [src]'s [wear_mask.name]!</span>", null, 5)
						drop_inv_item_on_ground(wear_mask)
						emote("roar")
						return TRUE

			//The normal attack proceeds
			playsound(loc, attack_sound, 25, 1)
			M.visible_message("[attack_message1]", \
			"[attack_message2]")

			//Logging, including anti-rulebreak logging
			if(src.status_flags & XENO_HOST && src.stat != DEAD)
				if(istype(src.buckled, /obj/structure/bed/nest)) //Host was buckled to nest while infected, this is a rule break
					log_combat(M, src, log, addition="while they were infected and nested")
					msg_admin_ff("[key_name(M)] slashed [key_name(src)] while they were infected and nested.") //This is a blatant rulebreak, so warn the admins
				else //Host might be rogue, needs further investigation
					log_combat(M, src, log, addition="while they were infected")
			else //Normal xenomorph friendship with benefits
				log_combat(M, src, log)

			if(M.stealth_router(HANDLE_STEALTH_CHECK)) //Cancel stealth if we have it due to aggro.
				if(M.stealth_router(HANDLE_SNEAK_ATTACK_CHECK)) //Pouncing prevents us from making a sneak attack for 4 seconds
					damage *= 3 //Massive damage on the sneak attack... hope you have armour.
					KnockOut(2) //...And we knock them out
					M.visible_message("<span class='danger'>\The [M] strikes [src] with vicious precision!</span>", \
					"<span class='danger'>You strike [src] with vicious precision!</span>")
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)

			apply_damage(damage, BRUTE, affecting, armor_block, sharp = 1, edge = 1) //This should slicey dicey
			updatehealth()

			M.process_rage_attack() //Process Ravager rage gains on attack

		if("disarm")
			if(M.legcuffed && isYautja(src))
				to_chat(M, "<span class='xenodanger'>You don't have the dexterity to tackle the headhunter with that thing on your leg!</span>")
				return FALSE
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

			playsound(loc, 'sound/weapons/alien_knockdown.ogg', 25, 1)

			var/tackle_pain = (rand(M.tackle_damage * 0.20, M.tackle_damage * 0.80) + rand(M.tackle_damage * 0.20, M.tackle_damage * 0.80))
			if(M.frenzy_aura)
				tackle_pain = tackle_pain * (1 + (0.05 * M.frenzy_aura))  //Halloss damage increased by 5% per rank of frenzy aura
			if(protection_aura)
				tackle_pain = tackle_pain * (1 - (0.10 + 0.05 * protection_aura))  //Halloss damage decreased by 10% + 5% per rank of protection aura
			if(M.stealth_router(HANDLE_STEALTH_CHECK))
				if(M.stealth_router(HANDLE_SNEAK_ATTACK_CHECK))
					KnockOut(2)
					tackle_pain *= 2 //Halloss multiplied by 2.
					M.visible_message("<span class='danger'>\The [M] strikes [src] with vicious precision!</span>", \
					"<span class='danger'>You strike [src] with vicious precision!</span>")
				M.stealth_router(HANDLE_STEALTH_CODE_CANCEL)
			if(dam_bonus)
				tackle_pain += dam_bonus
			apply_damage(tackle_pain, HALLOSS)
			updatehealth()
			updateshock()
			var/throttle_message = "<span class='danger'>The [M] throttles [src]!</span>"
			var/throttle_message2 = "<span class='danger'>You throttle [src]!</span>"
			if(tackle_pain > 40)
				throttle_message = "<span class='danger'>\The [M] badly throttles [src]!</span>"
				throttle_message2 = "<span class='danger'>You badly throttle [src]!</span>"
			M.visible_message("[throttle_message]", \
			"[throttle_message2]", null, 5)
			return TRUE

	return TRUE

/mob/living/carbon/Xenomorph/proc/process_rage_attack()
	return FALSE

/mob/living/carbon/Xenomorph/Ravager/process_rage_attack()
	rage += 5 //Gain 5 rage stacks for the attack.
	last_rage = world.time //We incremented rage, so bookmark this.


//Every other type of nonhuman mob
/mob/living/attack_alien(mob/living/carbon/Xenomorph/M)
	if (M.fortify)
		return FALSE

	switch(M.a_intent)
		if("help")
			M.visible_message("<span class='notice'>\The [M] caresses [src] with its scythe-like arm.</span>", \
			"<span class='notice'>You caress [src] with your scythe-like arm.</span>", null, 5)
			return FALSE

		if("grab")
			if(M == src || anchored || buckled)
				return FALSE

			if(Adjacent(M)) //Logic!
				M.start_pulling(src)

		if("hurt")
			if(isXeno(src) && xeno_hivenumber(src) == M.hivenumber)
				M.visible_message("<span class='warning'>\The [M] nibbles [src].</span>", \
				"<span class='warning'>You nibble [src].</span>", null, 5)
				return TRUE

			var/datum/hive_status/hive
			if(M.hivenumber && M.hivenumber <= hive_datum.len)
				hive = hive_datum[M.hivenumber]
			else return

			if(!M.is_intelligent)
				if(hive.slashing_allowed == 2)
					if(status_flags & XENO_HOST)
						for(var/obj/item/alien_embryo/embryo in src)
							if(embryo.hivenumber == M.hivenumber)
								to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. There is a host inside!</span>")
								return FALSE

					if(M.health > round(2 * M.maxHealth / 3)) //Note : Under 66 % health
						to_chat(M, "<span class='warning'>You try to slash [src], but find you <B>cannot</B>. You are not yet injured enough to overcome the Queen's orders.</span>")
						return FALSE

				else if(istype(buckled, /obj/structure/bed/nest) && (status_flags & XENO_HOST))
					for(var/obj/item/alien_embryo/embryo in src)
						if(embryo.hivenumber == M.hivenumber)
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
			var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)

			//Frenzy auras stack in a way, then the raw value is multipled by two to get the additive modifier
			if(M.frenzy_aura > 0)
				damage += (M.frenzy_aura * 2)

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

		if("disarm")
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
