/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M)
	. = ..()
	if(.)
		return

	if((M != src) && check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>", null, null, 5)
		return 0

	M.next_move += 7 //Adds some lag to the 'attack'. This will add up to 10
	switch(M.a_intent)
		if(INTENT_HELP)

			if(on_fire && M != src)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				M.visible_message("<span class='danger'>[M] tries to put out the fire on [src]!</span>", \
					"<span class='warning'>You try to put out the fire on [src]!</span>", null, 5)
				if(fire_stacks <= 0)
					M.visible_message("<span class='danger'>[M] has successfully extinguished the fire on [src]!</span>", \
						"<span class='notice'>You extinguished the fire on [src].</span>", null, 5)
					ExtinguishMob()
				return 1

			if(health >= get_crit_threshold())
				help_shake_act(M)
				return 1
//			if(M.health < -75)	return 0

			if((M.head && (M.head.flags_inventory & COVERMOUTH)) || (M.wear_mask && (M.wear_mask.flags_inventory & COVERMOUTH)))
				to_chat(M, "<span class='boldnotice'>Remove your mask!</span>")
				return 0
			if((head && (head.flags_inventory & COVERMOUTH)) || (wear_mask && (wear_mask.flags_inventory & COVERMOUTH)))
				to_chat(M, "<span class='boldnotice'>Remove his mask!</span>")
				return 0

			//CPR
			if(M.action_busy)
				return 1
			M.visible_message("<span class='danger'>[M] is trying perform CPR on [src]!</span>", null, null, 4)

			if(do_mob(M, src, HUMAN_STRIP_DELAY, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
				if(health > get_death_threshold() && health < get_crit_threshold())
					var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
					adjustOxyLoss(-suff)
					updatehealth()
					visible_message("<span class='warning'> [M] performs CPR on [src]!</span>", null, null, 3)
					to_chat(src, "<span class='boldnotice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
					to_chat(M, "<span class='warning'>Repeat at least every 7 seconds.</span>")


			return 1

		if(INTENT_GRAB)
			if(M == src || anchored)
				return 0

			M.start_pulling(src)

			return 1

		if(INTENT_HARM)
			// See if they can attack, and which attacks to use.
			var/datum/unarmed_attack/attack = M.species.unarmed
			if(!attack.is_usable(M)) attack = M.species.secondary_unarmed
			if(!attack.is_usable(M)) return

			log_combat(M, src, "[pick(attack.attack_verb)]ed")
			msg_admin_attack("[key_name(M)] [pick(attack.attack_verb)]ed [key_name(src)]")

			M.animation_attack_on(src)
			M.flick_attack_overlay(src, "punch")

			var/max_dmg = 5
			if(M.mind && M.mind.cm_skills)
				max_dmg += M.mind.cm_skills.cqc
			var/damage = rand(0, max_dmg)
			if(!damage)
				playsound(loc, attack.miss_sound, 25, 1)
				visible_message("<span class='danger'>[M] tried to [pick(attack.attack_verb)] [src]!</span>", null, null, 5)
				return

			var/datum/limb/affecting = get_limb(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, attack.attack_sound, 25, 1)

			visible_message("<span class='danger'>[M] [pick(attack.attack_verb)]ed [src]!</span>", null, null, 5)
			if(damage >= 5 && prob(50))
				visible_message("<span class='danger'>[M] has weakened [src]!</span>", null, null, 5)
				apply_effect(3, WEAKEN, armor_block)

			damage += attack.damage
			apply_damage(damage, BRUTE, affecting, armor_block, sharp=attack.sharp, edge=attack.edge)


		if(INTENT_DISARM)
			log_combat(M, src, "disarmed")

			M.animation_attack_on(src)
			M.flick_attack_overlay(src, "disarm")

			msg_admin_attack("[key_name(M)] disarmed [src.name] ([src.ckey])")

			var/datum/limb/affecting = get_limb(ran_zone(M.zone_selected))

			//Accidental gun discharge
			if(!M.mind?.cm_skills || M.mind.cm_skills.cqc < SKILL_CQC_MP)
				if (istype(r_hand,/obj/item/weapon/gun) || istype(l_hand,/obj/item/weapon/gun))
					var/obj/item/weapon/gun/W = null
					var/chance = 0

					if (istype(l_hand,/obj/item/weapon/gun))
						W = l_hand
						chance = hand ? 40 : 20

					if (istype(r_hand,/obj/item/weapon/gun))
						W = r_hand
						chance = !hand ? 40 : 20

					if(prob(chance))
						log_combat(M, src, "disarmed, making their [W] go off")
						visible_message("<span class='danger'>[src]'s [W] goes off during struggle!", null, null, 5)
						var/list/turfs = list()
						for(var/turf/T in view())
							turfs += T
						var/turf/target = pick(turfs)
						return W.afterattack(target,src)

			var/randn = rand(1, 100)
			if(M.mind && M.mind.cm_skills)
				randn -= 5 * M.mind.cm_skills.cqc //attacker's martial arts training

			if(mind && mind.cm_skills)
				randn += 5 * mind.cm_skills.cqc //defender's martial arts training


			if (randn <= 25)
				apply_effect(3, WEAKEN, run_armor_check(affecting, "melee"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				visible_message("<span class='danger'>[M] has pushed [src]!</span>", null, null, 5)
				return

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("<span class='danger'>[M] has broken [src]'s grip on [pulling]!</span>", null, null, 5)
					stop_pulling()
				else
					drop_held_item()
					visible_message("<span class='danger'>[M] has disarmed [src]!</span>", null, null, 5)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, 7)
			visible_message("<span class='danger'>[M] attempted to disarm [src]!</span>", null, null, 5)
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return




/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if (health >= get_crit_threshold())
		if(src == M)
			if(holo_card_color) //if we have a triage holocard printed on us, we remove it.
				holo_card_color = null
				update_targeted()
				visible_message("<span class='notice'>[src] removes the holo card on [gender==MALE?"himself":"herself"].</span>", \
					"<span class='notice'>You remove the holo card on yourself.</span>", null, 3)
				return
			visible_message("<span class='notice'>[src] examines [gender==MALE?"himself":"herself"].</span>", \
				"<span class='notice'>You check yourself for injuries.</span>", null, 3)

			for(var/datum/limb/org in limbs)
				var/status = ""
				var/treat = ""
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				var/brute_treated = org.is_bandaged()
				var/burn_treated = org.is_salved()

				if(halloss > 0)
					status = "tingling"

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "battered"
				if(brutedamage > 40)
					status = "mangled"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "peeling away"

				else if(burndamage > 10)
					status += "blistered"
				else if(burndamage > 0)
					status += "numb"

				if(!status) status = "OK"

				if(org.limb_status & LIMB_SPLINTED)
					status += " <b>(SPLINTED)</b>"
				if(org.limb_status & LIMB_STABILIZED)
					status += " <b>(STABILIZED)</b>"
				if(org.limb_status & LIMB_MUTATED)
					status = "weirdly shapen."
				if(org.limb_status & LIMB_DESTROYED)
					status = "MISSING!"

				if(brute_treated == FALSE && brutedamage > 0)
					treat = "(Bandaged)"
				if(brute_treated == FALSE && burn_treated == FALSE && brutedamage > 0 && burndamage > 0)
					treat += " and "
				if(burn_treated == FALSE && burndamage > 0)
					treat += "(Salved)"

				to_chat(src, "\t [status=="OK"?"<span class='notice'> ":"<span class='warning'> "]My [org.display_name] is [status]. [treat]</span>")
	return ..()
