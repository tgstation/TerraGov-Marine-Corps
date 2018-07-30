/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M)
	..()

	if((M != src) && check_shields(0, M.name))
		visible_message("\red <B>[M] attempted to touch [src]!</B>", null, null, 5)
		return 0

	if(M.gloves && istype(M.gloves, /obj/item/clothing/gloves/boxing/hologlove))

		var/damage = rand(0, 9)
		if(!damage)
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1)
			visible_message("\red <B>[M] has attempted to punch [src]!</B>")
			return 0
		var/datum/limb/affecting = get_limb(ran_zone(M.zone_selected))
		var/armor_block = run_armor_check(affecting, "melee")

		if(HULK in M.mutations)			damage += 5

		playsound(loc, "punch", 25, 1)

		visible_message("\red <B>[M] has punched [src]!</B>")

		apply_damage(damage, HALLOSS, affecting, armor_block)
		if(damage >= 9)
			visible_message("\red <B>[M] has weakened [src]!</B>")
			apply_effect(4, WEAKEN, armor_block)

		return

	M.next_move += 7 //Adds some lag to the 'attack'. This will add up to 10
	switch(M.a_intent)
		if("help")

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

			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				return 1
//			if(M.health < -75)	return 0

			if((M.head && (M.head.flags_inventory & COVERMOUTH)) || (M.wear_mask && (M.wear_mask.flags_inventory & COVERMOUTH)))
				M << "\blue <B>Remove your mask!</B>"
				return 0
			if((head && (head.flags_inventory & COVERMOUTH)) || (wear_mask && (wear_mask.flags_inventory & COVERMOUTH)))
				M << "\blue <B>Remove his mask!</B>"
				return 0

			//CPR
			if(M.action_busy)
				return 1
			M.visible_message("\red <B>[M] is trying perform CPR on [src]!</B>", null, null, 4)

			if(do_mob(M, src, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_MEDICAL))
				if(health > config.health_threshold_dead && health < config.health_threshold_crit)
					var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
					adjustOxyLoss(-suff)
					updatehealth()
					visible_message("\red [M] performs CPR on [src]!", null, null, 3)
					src << "\blue <b>You feel a breath of fresh air enter your lungs. It feels good.</b>"
					M << "\red Repeat at least every 7 seconds."


			return 1

		if("grab")
			if(M == src || anchored)
				return 0
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			M.start_pulling(src)

			return 1

		if("hurt")
			// See if they can attack, and which attacks to use.
			var/datum/unarmed_attack/attack = M.species.unarmed
			if(!attack.is_usable(M)) attack = M.species.secondary_unarmed
			if(!attack.is_usable(M)) return

			M.attack_log += text("\[[time_stamp()]\] <font color='red'>[pick(attack.attack_verb)]ed [src.name] ([src.ckey])</font>")
			attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [pick(attack.attack_verb)]ed by [M.name] ([M.ckey])</font>")
			msg_admin_attack("[key_name(M)] [pick(attack.attack_verb)]ed [key_name(src)]")

			M.animation_attack_on(src)
			M.flick_attack_overlay(src, "punch")

			var/max_dmg = 5
			if(M.mind. && M.mind.cm_skills)
				max_dmg += M.mind.cm_skills.cqc
			var/damage = rand(0, max_dmg)
			if(!damage)
				playsound(loc, attack.miss_sound, 25, 1)
				visible_message("<span class='danger'>[M] tried to [pick(attack.attack_verb)] [src]!</span>", null, null, 5)
				return

			var/datum/limb/affecting = get_limb(ran_zone(M.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee")

			if(HULK in M.mutations) damage += 5
			playsound(loc, attack.attack_sound, 25, 1)

			visible_message("<span class='danger'>[M] [pick(attack.attack_verb)]ed [src]!</span>", null, null, 5)
			if(damage >= 5 && prob(50))
				visible_message("<span class='danger'>[M] has weakened [src]!</span>", null, null, 5)
				apply_effect(3, WEAKEN, armor_block)

			damage += attack.damage
			apply_damage(damage, BRUTE, affecting, armor_block, sharp=attack.sharp, edge=attack.edge)


		if("disarm")
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

			M.animation_attack_on(src)
			M.flick_attack_overlay(src, "disarm")

			msg_admin_attack("[key_name(M)] disarmed [src.name] ([src.ckey])")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/datum/limb/affecting = get_limb(ran_zone(M.zone_selected))

			//Accidental gun discharge
			if(!M.mind || !M.mind.cm_skills || M.mind.cm_skills.cqc < SKILL_CQC_MP)
				if (istype(r_hand,/obj/item/weapon/gun) || istype(l_hand,/obj/item/weapon/gun))
					var/obj/item/weapon/gun/W = null
					var/chance = 0

					if (istype(l_hand,/obj/item/weapon/gun))
						W = l_hand
						chance = hand ? 40 : 20

					if (istype(r_hand,/obj/item/weapon/gun))
						W = r_hand
						chance = !hand ? 40 : 20

					if (prob(chance))
						visible_message("<span class='danger'>[src]'s [W.name] goes off during struggle!", null, null, 5)
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
				visible_message("\red <B>[M] has pushed [src]!</B>", null, null, 5)
				return

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("\red <b>[M] has broken [src]'s grip on [pulling]!</B>", null, null, 5)
					stop_pulling()
				else
					drop_held_item()
					visible_message("\red <B>[M] has disarmed [src]!</B>", null, null, 5)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, 7)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>", null, null, 5)
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return




/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if (health >= config.health_threshold_crit)
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
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
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

				if(org.status & LIMB_SPLINTED) status += " <b>(SPLINTED)</b>"
				if(org.status & LIMB_MUTATED)
					status = "weirdly shapen."
				if(org.status & LIMB_DESTROYED)
					status = "MISSING!"

				src << "\t [status=="OK"?"\blue ":"\red "]My [org.display_name] is [status]."
			if((SKELETON in mutations) && !w_uniform && !wear_suit)
				play_xylophone()
		else
			var/t_him = "it"
			if (gender == MALE)
				t_him = "him"
			else if (gender == FEMALE)
				t_him = "her"
			if (w_uniform)
				w_uniform.add_fingerprint(M)


			if(lying || sleeping)
				if(client)
					sleeping = max(0,src.sleeping-5)
				if(!sleeping)
					resting = 0
					update_canmove()
				M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!", \
									"<span class='notice'>You shake [src] trying to wake [t_him] up!", null, 4)
			else
				var/mob/living/carbon/human/H = M
				if(istype(H))
					H.species.hug(H,src)
				else
					M.visible_message("<span class='notice'>[M] hugs [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You hug [src] to make [t_him] feel better!</span>", null, 4)

			AdjustKnockedout(-3)
			AdjustStunned(-3)
			AdjustKnockeddown(-3)

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
