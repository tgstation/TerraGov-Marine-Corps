/mob/living/carbon/human/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user

	if(user != src && !check_shields(COMBAT_TOUCH_ATTACK, human_user.melee_damage, "melee"))
		visible_message(span_danger("[user] attempted to touch [src]!"), null, null, 5)
		return FALSE

	human_user.changeNext_move(7)
	switch(human_user.a_intent)
		if(INTENT_HELP)
			if(on_fire && human_user != src)
				fire_stacks = max(fire_stacks - 1, 0)
				playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				human_user.visible_message(span_danger("[human_user] tries to put out the fire on [src]!"), \
					span_warning("You try to put out the fire on [src]!"), null, 5)
				if(fire_stacks <= 0)
					human_user.visible_message(span_danger("[human_user] has successfully extinguished the fire on [src]!"), \
						span_notice("You extinguished the fire on [src]."), null, 5)
					ExtinguishMob()
				return TRUE

			var/datum/status_effect/stacking/melting_fire/burning = has_status_effect(STATUS_EFFECT_MELTING_FIRE)
			if(burning && human_user != src)
				playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				human_user.visible_message(span_danger("[human_user] tries to put out the fire on [src]!"), \
				span_warning("You try to put out the fire on [src]!"), null, 5)
				burning.add_stacks(-PYROGEN_ASSIST_REMOVAL_STRENGTH)
				if(QDELETED(burning))
					human_user.visible_message(span_danger("[human_user] has successfully extinguished the fire on [src]!"), \
					span_notice("You extinguished the fire on [src]."), null, 5)
				return TRUE

			if(istype(wear_mask, /obj/item/clothing/mask/facehugger) && human_user != src)
				human_user.stripPanelUnequip(wear_mask, src, SLOT_WEAR_MASK)
				return TRUE

			if(health >= get_crit_threshold())
				help_shake_act(human_user)
				return TRUE

			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
				to_chat(human_user, span_boldnotice("Can't help this one. Body has gone cold."))
				return FALSE

			if(species?.species_flags & ROBOTIC_LIMBS)
				to_chat(human_user, span_boldnotice("You can't help this one, [p_they()] [p_have()] no lungs!"))
				return FALSE

			if((head && (head.inventory_flags & COVERMOUTH)) || (wear_mask && (wear_mask.inventory_flags & COVERMOUTH)))
				to_chat(human_user, span_boldnotice("Remove [p_their()] mask!"))
				return FALSE

			if((human_user.head && (human_user.head.inventory_flags & COVERMOUTH)) || (human_user.wear_mask && (human_user.wear_mask.inventory_flags & COVERMOUTH)))
				to_chat(human_user, span_boldnotice("Remove your mask!"))
				return FALSE

			//CPR
			if(human_user.do_actions)
				return TRUE

			human_user.visible_message(span_danger("[human_user] is trying perform CPR on [src]!"), null, null, 4)

			if(!do_after(human_user, 4 SECONDS, NONE, src, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
				return TRUE

			if(health > get_death_threshold() && health < get_crit_threshold())
				var/suff = min(getOxyLoss(), 5) //Pre-merge level, less healing, more prevention of dieing.
				adjustOxyLoss(-suff)
				updatehealth()
				visible_message(span_warning("[human_user] performs CPR on [src]!"),
					span_boldnotice("You feel a breath of fresh air enter your lungs. It feels good."),
					vision_distance = 3)
				to_chat(human_user, span_warning("Repeat at least every 7 seconds."))
			else if(!HAS_TRAIT(src, TRAIT_UNDEFIBBABLE) && TIMER_COOLDOWN_FINISHED(src, COOLDOWN_CPR))
				TIMER_COOLDOWN_START(src, COOLDOWN_CPR, 7 SECONDS)
				dead_ticks -= 5
				visible_message(span_warning("[human_user] performs CPR on [src]!"), vision_distance = 3)
				to_chat(human_user, span_warning("The patient gains a little more time. Repeat every 7 seconds."))
			else
				to_chat(human_user, span_warning("You fail to aid [src]."))

			return TRUE

		if(INTENT_GRAB)
			if(human_user == src || anchored)
				return FALSE

			human_user.start_pulling(src)

			return TRUE

		if(INTENT_HARM)
			// See if they can attack, and which attacks to use.
			if(human_user == src && !human_user.do_self_harm)
				return FALSE
			var/datum/unarmed_attack/attack = human_user.species.unarmed
			if(!attack.is_usable(human_user))
				attack = human_user.species.secondary_unarmed
			if(!attack.is_usable(human_user))
				return FALSE

			var/attack_verb = pick(attack.attack_verb)
			//if you're lying/buckled, the miss chance is ignored anyway
			var/target_zone = get_zone_with_miss_chance(human_user.zone_selected, src, 10 - (human_user.skills.getRating(SKILL_UNARMED) - skills.getRating(SKILL_UNARMED)) * 5)

			if(!human_user.melee_damage || !target_zone)
				human_user.do_attack_animation(src)
				playsound(loc, attack.miss_sound, 25, TRUE)
				visible_message(span_danger("[human_user] [attack_verb] at [src], but misses!"), null, null, 5)
				log_combat(human_user, src, "[attack_verb]", "(missed)")
				if(!human_user.mind?.bypass_ff && !mind?.bypass_ff && human_user.faction == faction)
					var/turf/T = get_turf(src)
					log_ffattack("[key_name(human_user)] missed a punch against [key_name(src)] in [AREACOORD(T)].")
					msg_admin_ff("[ADMIN_TPMONTY(human_user)] missed a punch against [ADMIN_TPMONTY(src)] in [ADMIN_VERBOSEJMP(T)].")
				return FALSE

			human_user.do_attack_animation(src, ATTACK_EFFECT_YELLOWPUNCH)
			var/max_dmg = max(human_user.melee_damage + (human_user.skills.getRating(SKILL_UNARMED) * UNARMED_SKILL_DAMAGE_MOD), 3)
			var/damage = max_dmg
			if(!lying_angle)
				damage = rand(1, max_dmg)

			playsound(loc, attack.attack_sound, 25, TRUE)

			visible_message(span_danger("[human_user] [attack_verb] [src]!"), null, null, 5)
			var/list/hit_report = list()
			if(damage >= 4 && prob(25))
				visible_message(span_danger("[human_user] has weakened [src]!"), null, null, 5)
				apply_effect(3 SECONDS, EFFECT_PARALYZE)
				hit_report += "(KO)"

			damage += attack.damage
			apply_damage(damage, BRUTE, target_zone, MELEE, attack.sharp, attack.edge, updating_health = TRUE, attacker = user)

			hit_report += "(RAW DMG: [damage])"

			log_combat(human_user, src, "[attack_verb]", "[hit_report.Join(" ")]")
			if(!human_user.mind?.bypass_ff && !mind?.bypass_ff && human_user.faction == faction)
				var/turf/T = get_turf(src)
				human_user.ff_check(damage, src)
				log_ffattack("[key_name(human_user)] punched [key_name(src)] in [AREACOORD(T)] [hit_report.Join(" ")].")
				msg_admin_ff("[ADMIN_TPMONTY(human_user)] punched [ADMIN_TPMONTY(src)] in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")

		if(INTENT_DISARM)

			human_user.do_attack_animation(src, ATTACK_EFFECT_DISARM)

			//Accidental gun discharge
			if(human_user.skills.getRating(SKILL_UNARMED) < SKILL_UNARMED_MP)
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
						visible_message("<span class='danger'>[src]'s [W.name] goes off during struggle!", null, null, 5)
						log_combat(human_user, src, "disarmed", "making their [W.name] go off")
						var/list/turfs = list()
						for(var/turf/T in view())
							turfs += T
						var/turf/target = pick(turfs)
						return W.afterattack(target,src)

			var/randn = rand(1, 100) + skills.getRating(SKILL_UNARMED) * UNARMED_SKILL_DISARM_MOD - human_user.skills.getRating(SKILL_UNARMED) * UNARMED_SKILL_DISARM_MOD

			if (randn <= 25)
				apply_effect(3 SECONDS, EFFECT_PARALYZE)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				visible_message(span_danger("[human_user] pushes [src] over!"), null, null, 5)
				log_combat(human_user, src, "pushed")
				return

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message(span_danger("[human_user] breaks [src]'s grip on [pulling]!"), null, null, 5)
					stop_pulling()
				else
					drop_held_item()
					visible_message(span_danger("[human_user] disarms [src]!"), null, null, 5)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 7)
				log_combat(user, src, "disarmed")
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, 7)
			visible_message(span_danger("[human_user] attempts to disarm [src]!"), null, null, 5)
			log_combat(human_user, src, "missed a disarm")

/mob/living/carbon/human/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return


/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(src == M)
		if(holo_card_color) //if we have a triage holocard printed on us, we remove it.
			holo_card_color = null
			visible_message(span_notice("[src] removes the holo card on [p_them()]self."),
				span_notice("You remove the holo card on yourself."), null, 3)
			return


		check_self_for_injuries()
		return

	return ..()


/mob/living/carbon/human/proc/check_self_for_injuries()
	var/list/final_msg = list()
	visible_message(span_notice("[src] examines [p_them()]sel[gender == PLURAL ? "ves" : "f"]."))
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
		final_msg += status=="OK" ? span_notice(msg) : span_alert (msg)


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
			final_msg += span_info(pick("You've got some grime on you.", "You're a bit dirty."))
		if(80 to 150)
			final_msg += span_info(pick("You're not far off filthy.", "You're pretty dirty.", "There's still one or two clean spots left on you."))
		else
			final_msg += span_info(pick("There's a full layer of dirt covering you. Maybe it'll work as camo?", "You could go for a shower.", "You've reached a more complete understanding of grime."))

	to_chat(src, custom_boxed_message("blue_box", final_msg.Join("\n")))
