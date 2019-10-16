/mob/living/carbon/human/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if((user != src) && check_shields(0, user.name))
		visible_message("<span class='danger'>[user] attempted to touch [src]!</span>", null, null, 5)
		return 0

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	H.changeNext_move(7)
	switch(H.a_intent)
		if(INTENT_HELP)

			if(on_fire && H != src)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				H.visible_message("<span class='danger'>[H] tries to put out the fire on [src]!</span>", \
					"<span class='warning'>You try to put out the fire on [src]!</span>", null, 5)
				if(fire_stacks <= 0)
					H.visible_message("<span class='danger'>[H] has successfully extinguished the fire on [src]!</span>", \
						"<span class='notice'>You extinguished the fire on [src].</span>", null, 5)
					ExtinguishMob()
				return 1

			if(health >= get_crit_threshold())
				help_shake_act(H)
				return 1
//			if(H.health < -75)	return 0

			if((H.head && (H.head.flags_inventory & COVERMOUTH)) || (H.wear_mask && (H.wear_mask.flags_inventory & COVERMOUTH)))
				to_chat(H, "<span class='boldnotice'>Remove your mask!</span>")
				return 0
			if((head && (head.flags_inventory & COVERMOUTH)) || (wear_mask && (wear_mask.flags_inventory & COVERMOUTH)))
				to_chat(H, "<span class='boldnotice'>Remove his mask!</span>")
				return 0

			//CPR
			if(H.action_busy)
				return 1
			H.visible_message("<span class='danger'>[H] is trying perform CPR on [src]!</span>", null, null, 4)

			if(do_mob(H, src, HUMAN_STRIP_DELAY, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
				if(health > get_death_threshold() && health < get_crit_threshold())
					var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
					adjustOxyLoss(-suff)
					updatehealth()
					visible_message("<span class='warning'> [H] performs CPR on [src]!</span>", null, null, 3)
					to_chat(src, "<span class='boldnotice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
					to_chat(H, "<span class='warning'>Repeat at least every 7 seconds.</span>")


			return 1

		if(INTENT_GRAB)
			if(H == src || anchored)
				return 0

			H.start_pulling(src)

			return 1

		if(INTENT_HARM)
			// See if they can attack, and which attacks to use.
			var/datum/unarmed_attack/attack = H.species.unarmed
			if(!attack.is_usable(H)) attack = H.species.secondary_unarmed
			if(!attack.is_usable(H)) return

			log_combat(H, src, "[pick(attack.attack_verb)]ed")
			msg_admin_attack("[key_name(H)] [pick(attack.attack_verb)]ed [key_name(src)]")

			H.do_attack_animation(src)
			H.flick_attack_overlay(src, "punch")

			var/max_dmg = 5
			if(H.mind && H.mind.cm_skills)
				max_dmg += user.mind.cm_skills.cqc
			var/damage = rand(0, max_dmg)
			if(!damage)
				playsound(loc, attack.miss_sound, 25, 1)
				visible_message("<span class='danger'>[H] tried to [pick(attack.attack_verb)] [src]!</span>", null, null, 5)
				return

			var/datum/limb/affecting = get_limb(ran_zone(H.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, attack.attack_sound, 25, 1)

			visible_message("<span class='danger'>[H] [pick(attack.attack_verb)]ed [src]!</span>", null, null, 5)
			if(damage >= 5 && prob(50))
				visible_message("<span class='danger'>[H] has weakened [src]!</span>", null, null, 5)
				apply_effect(3, WEAKEN, armor_block)

			damage += attack.damage
			apply_damage(damage, BRUTE, affecting, armor_block, attack.sharp, attack.edge)


		if(INTENT_DISARM)
			log_combat(user, src, "disarmed")

			H.do_attack_animation(src)
			H.flick_attack_overlay(src, "disarm")

			msg_admin_attack("[key_name(H)] disarmed [src.name] ([src.ckey])")

			var/datum/limb/affecting = get_limb(ran_zone(H.zone_selected))

			//Accidental gun discharge
			if(!H.mind?.cm_skills || H.mind.cm_skills.cqc < SKILL_CQC_MP)
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
						log_combat(H, src, "disarmed, making their [W] go off")
						visible_message("<span class='danger'>[src]'s [W] goes off during struggle!", null, null, 5)
						var/list/turfs = list()
						for(var/turf/T in view())
							turfs += T
						var/turf/target = pick(turfs)
						return W.afterattack(target,src)

			var/randn = rand(1, 100)
			if(H.mind && H.mind.cm_skills)
				randn -= 5 * H.mind.cm_skills.cqc //attacker's martial arts training

			if(mind && mind.cm_skills)
				randn += 5 * mind.cm_skills.cqc //defender's martial arts training


			if (randn <= 25)
				apply_effect(3, WEAKEN, run_armor_check(affecting, "melee"))
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				visible_message("<span class='danger'>[H] has pushed [src]!</span>", null, null, 5)
				return

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("<span class='danger'>[H] has broken [src]'s grip on [pulling]!</span>", null, null, 5)
					stop_pulling()
				else
					drop_held_item()
					visible_message("<span class='danger'>[H] has disarmed [src]!</span>", null, null, 5)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, 7)
			visible_message("<span class='danger'>[H] attempted to disarm [src]!</span>", null, null, 5)
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
					if(brutedamage > 0 || burndamage > 0)
						status += " and "

				if(brutedamage > 0)
					status += "bruised"
				else if(brutedamage > 20)
					status += "battered"
				else if(brutedamage > 40)
					status += "mangled"
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
