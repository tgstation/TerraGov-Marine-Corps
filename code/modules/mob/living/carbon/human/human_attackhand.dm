/mob/living/carbon/human/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/H = user

	if(user != src && !check_shields(COMBAT_TOUCH_ATTACK, H.melee_damage, "melee"))
		visible_message(span_danger("[user] attempted to touch [src]!"), null, null, 5)
		return FALSE

	H.changeNext_move(7)
	switch(H.a_intent)
		if(INTENT_HELP)
			if(on_fire && H != src)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				H.visible_message(span_danger("[H] tries to put out the fire on [src]!"), \
					span_warning("You try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					H.visible_message(span_danger("[H] has successfully extinguished the fire on [src]!"), \
						span_notice("You extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE

			if(istype(wear_mask, /obj/item/clothing/mask/facehugger) && H != src)
				H.stripPanelUnequip(wear_mask, src, SLOT_WEAR_MASK)
				return TRUE

			if(health >= get_crit_threshold())
				help_shake_act(H)
				return TRUE

			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
				to_chat(H, span_boldnotice("Can't help this one. Body has gone cold."))
				return FALSE

			if(species?.species_flags & ROBOTIC_LIMBS)
				to_chat(H, span_boldnotice("You can't help this one, [p_they()] [p_have()] no lungs!"))
				return FALSE

			if((head && (head.flags_inventory & COVERMOUTH)) || (wear_mask && (wear_mask.flags_inventory & COVERMOUTH)))
				to_chat(H, span_boldnotice("Remove [p_their()] mask!"))
				return FALSE

			if((H.head && (H.head.flags_inventory & COVERMOUTH)) || (H.wear_mask && (H.wear_mask.flags_inventory & COVERMOUTH)))
				to_chat(H, span_boldnotice("Remove your mask!"))
				return FALSE

			//CPR
			if(H.do_actions)
				return TRUE

			H.visible_message(span_danger("[H] is trying perform CPR on [src]!"), null, null, 4)

			if(!do_after(H, HUMAN_STRIP_DELAY, NONE, src, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
				return TRUE

			if(health > get_death_threshold() && health < get_crit_threshold())
				var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
				adjustOxyLoss(-suff)
				updatehealth()
				visible_message(span_warning(" [H] performs CPR on [src]!"),
					span_boldnotice("You feel a breath of fresh air enter your lungs. It feels good."),
					vision_distance = 3)
				to_chat(H, span_warning("Repeat at least every 7 seconds."))
			else if(!HAS_TRAIT(src, TRAIT_UNDEFIBBABLE) && !TIMER_COOLDOWN_CHECK(src, COOLDOWN_CPR))
				TIMER_COOLDOWN_START(src, COOLDOWN_CPR, 7 SECONDS)
				dead_ticks -= 5
				visible_message(span_warning(" [H] performs CPR on [src]!"), vision_distance = 3)
				to_chat(H, span_warning("The patient gains a little more time. Repeat every 7 seconds."))
			else
				to_chat(H, span_warning("You fail to aid [src]."))

			return TRUE

		if(INTENT_GRAB)
			if(H == src || anchored)
				return FALSE

			H.start_pulling(src)

			return TRUE

		if(INTENT_HARM)
			// See if they can attack, and which attacks to use.
			if(H == src && !H.do_self_harm)
				return FALSE
			var/datum/unarmed_attack/attack = H.species.unarmed
			if(!attack.is_usable(H))
				attack = H.species.secondary_unarmed
			if(!attack.is_usable(H))
				return FALSE

			if(!H.melee_damage)
				H.do_attack_animation(src)
				playsound(loc, attack.miss_sound, 25, TRUE)
				visible_message(span_danger("[H] tried to [pick(attack.attack_verb)] [src]!"), null, null, 5)
				log_combat(H, src, "[pick(attack.attack_verb)]ed", "(missed)")
				if(!H.mind?.bypass_ff && !mind?.bypass_ff && H.faction == faction)
					var/turf/T = get_turf(src)
					log_ffattack("[key_name(H)] missed a punch against [key_name(src)] in [AREACOORD(T)].")
					msg_admin_ff("[ADMIN_TPMONTY(H)] missed a punch against [ADMIN_TPMONTY(src)] in [ADMIN_VERBOSEJMP(T)].")
				return FALSE

			H.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
			var/max_dmg = H.melee_damage + H.skills.getRating(SKILL_CQC)
			var/damage = rand(1, max_dmg)

			var/target_zone = ran_zone(H.zone_selected)

			playsound(loc, attack.attack_sound, 25, TRUE)

			visible_message(span_danger("[H] [pick(attack.attack_verb)]ed [src]!"), null, null, 5)
			var/list/hit_report = list()
			if(damage >= 5 && prob(50))
				visible_message(span_danger("[H] has weakened [src]!"), null, null, 5)
				apply_effect(modify_by_armor(6 SECONDS, MELEE, def_zone = target_zone), WEAKEN)
				hit_report += "(KO)"

			damage += attack.damage
			apply_damage(damage, BRUTE, target_zone, MELEE, attack.sharp, attack.edge, updating_health = TRUE)

			hit_report += "(RAW DMG: [damage])"

			log_combat(H, src, "[pick(attack.attack_verb)]ed", "[hit_report.Join(" ")]")
			if(!H.mind?.bypass_ff && !mind?.bypass_ff && H.faction == faction)
				var/turf/T = get_turf(src)
				H.ff_check(damage, src)
				log_ffattack("[key_name(H)] punched [key_name(src)] in [AREACOORD(T)] [hit_report.Join(" ")].")
				msg_admin_ff("[ADMIN_TPMONTY(H)] punched [ADMIN_TPMONTY(src)] in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")

		if(INTENT_DISARM)

			H.do_attack_animation(src, ATTACK_EFFECT_DISARM)

			var/target_zone = ran_zone(H.zone_selected)

			//Accidental gun discharge
			if(user.skills.getRating(SKILL_CQC) < SKILL_CQC_MP)
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
						visible_message("<span class='danger'>[src]'s [W] goes off during struggle!", null, null, 5)
						log_combat(H, src, "disarmed", "making their [W] go off")
						var/list/turfs = list()
						for(var/turf/T in view())
							turfs += T
						var/turf/target = pick(turfs)
						return W.afterattack(target,src)

			var/randn = rand(1, 100) + skills.getRating(SKILL_CQC) * CQC_SKILL_DISARM_MOD - H.skills.getRating(SKILL_CQC) * CQC_SKILL_DISARM_MOD

			if (randn <= 25)
				apply_effect(modify_by_armor(6 SECONDS, MELEE, def_zone = target_zone), WEAKEN)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				visible_message(span_danger("[H] has pushed [src]!"), null, null, 5)
				log_combat(user, src, "pushed")
				return

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message(span_danger("[H] has broken [src]'s grip on [pulling]!"), null, null, 5)
					stop_pulling()
				else
					drop_held_item()
					visible_message(span_danger("[H] has disarmed [src]!"), null, null, 5)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				log_combat(user, src, "disarmed")
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, 7)
			visible_message(span_danger("[H] attempted to disarm [src]!"), null, null, 5)
			log_combat(user, src, "missed a disarm")
	return

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return


/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(src == M)
		if(holo_card_color) //if we have a triage holocard printed on us, we remove it.
			holo_card_color = null
			update_targeted()
			visible_message(span_notice("[src] removes the holo card on [p_them()]self."),
				span_notice("You remove the holo card on yourself."), null, 3)
			return


		check_self_for_injuries()
		return

	return ..()


/mob/living/carbon/human/proc/check_self_for_injuries()
	var/list/final_msg = list()
	balloon_alert_to_viewers("Examines [p_them()]self.", "You examine yourself")
	final_msg += span_notice("<b>You check yourself for injuries.</b>")

	for(var/datum/limb/org in limbs)
		var/status = ""
		var/treat = ""
		var/brutedamage = org.brute_dam
		var/burndamage = org.burn_dam
		var/brute_treated = org.is_bandaged()
		var/burn_treated = org.is_salved()

		switch(brutedamage)
			if(1 to 20)
				status += "bruised"
			if(20 to 40)
				status += "battered"
			if(40 to 60)
				status += "mangled"
			if(60 to 100)
				status += "brutalized"
			if(100 to INFINITY)
				status += "mutilated"

		if((org.limb_status & LIMB_BLEEDING) && (brutedamage > 0 && burndamage > 0))
			status += ", bleeding"
		else if((org.limb_status & LIMB_BLEEDING) && (brutedamage > 0 || burndamage > 0))
			status += " and bleeding"
		else if(org.limb_status & LIMB_BLEEDING)
			status += "bleeding"



		if(brutedamage > 0 && burndamage > 0)
			status += " and "

		switch(burndamage)
			if(1 to 20)
				status += "numb"
			if(20 to 40)
				status += "blistered"
			if(40 to 60)
				status += "peeling away"
			if(60 to 100)
				status += "searing away"
			if(100 to INFINITY)
				status += "burnt to a crisp"

		if(!status)
			status = "OK"

		if(org.limb_status & LIMB_SPLINTED)
			status += " <b>(SPLINTED)</b>"
		if(org.limb_status & LIMB_STABILIZED)
			status += " <b>(STABILIZED)</b>"
		if(org.limb_status & LIMB_NECROTIZED)
			status = "rotting"
		if(org.limb_status & LIMB_DESTROYED)
			status = "MISSING!"

		if(brute_treated && brutedamage > 0)
			treat = "(Bandaged"
			if(burn_treated && burndamage > 0)
				treat += " and Salved)"
			else
				treat += ")"
		else if(burn_treated && burndamage > 0)
			treat += "(Salved)"
		var/msg = "My [org.display_name] is [status]. [treat]"
		final_msg += status=="OK" ? span_notice(msg) : span_warning (msg)


	switch(staminaloss)
		if(1 to 30)
			final_msg += span_info("You feel fatigued.")
		if(30 to 60)
			final_msg += span_info("You feel pretty tired.")
		if(60 to 90)
			final_msg += span_info("You're quite worn out.")
		if(90 to INFINITY)
			final_msg += span_info("You're completely exhausted.")

	switch(oxyloss)
		if(1 to 15)
			final_msg += span_info("You feel slightly out of breath.")
		if(15 to 30)
			final_msg += span_info("You are having trouble breathing.")
		if(30 to 49)
			final_msg += span_info("You are getting faint from lack of breath.")

	switch(toxloss)
		if(1 to 5)
			final_msg += span_info("Your body stings slightly.")
		if(6 to 10)
			final_msg += span_info("Your whole body hurts a little.")
		if(11 to 15)
			final_msg += span_info("Your whole body hurts.")
		if(15 to 25.99)
			final_msg += span_info("Your whole body hurts badly.")
		if(26 to INFINITY)
			final_msg += span_info("Your body aches all over, it's driving you mad!")

	switch(germ_level)
		if(0 to 19)
			final_msg += span_info("You're [pick("free of grime", "pristine", "freshly laundered")].")
		if(20 to 79)
			final_msg += span_info(pick("You've got some grime on you", "You're a bit dirty"))
		if(80 to 150)
			final_msg += span_info(pick("You're not far off filthy.", "You're pretty dirty.", "There's still one or two clean spots left on you."))
		else
			final_msg += span_info(pick("There's a full layer of dirt covering you. Maybe it'll work as camo?", "You could go for a shower.", "You've reached a more complete understanding of grime."))

	to_chat(src, examine_block(final_msg.Join("\n")))
