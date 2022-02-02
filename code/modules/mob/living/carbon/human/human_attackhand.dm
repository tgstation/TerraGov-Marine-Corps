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

			if(health >= get_crit_threshold())
				help_shake_act(H)
				return TRUE

			if(HAS_TRAIT(src, TRAIT_UNDEFIBBABLE))
				to_chat(H, span_boldnotice("Can't help this one. Body has gone cold."))
				return FALSE

			if(isrobot(src) && (src.stat == DEAD))
				if(H.do_actions)
					return TRUE

				if(src.wear_suit)
					to_chat(H, span_warning("You can't reach [src]'s maintenance panel through their armor."))
					return FALSE

				var/mob/dead/observer/G = src.get_ghost()
				if(istype(G))
					notify_ghost(G, "<font size=3>Someone is trying to revive your body. Return to it if you want to be resurrected!</font>", ghost_sound = 'sound/effects/adminhelp.ogg', enter_text = "Enter", enter_link = "reentercorpse=1", source = src, action = NOTIFY_JUMP)
				else if(!src.client)
					//We couldn't find a suitable ghost, this means the person is not returning
					to_chat(H, span_warning("Maintenance panel of [src] is locked tight, this unit refuses to be restarted."))
					return FALSE

				var/restart_damage_threshold = 50 * (H.skills.getRating("engineer"))

				H.visible_message(span_notice("[H] starts fiddling with a panel on [src]'s chest."),
				span_notice("You try to force restart [src]."))
				playsound(get_turf(src),'sound/machines/computer_typing1.ogg', 25, 0)

				if(!do_mob(H, src, 7 SECONDS, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
					H.visible_message(span_warning("[H] stops attempting to restart [src]."),
					span_warning("You stop the restart sequence of [src]."))
					return FALSE

				playsound(get_turf(src), 'sound/items/defib_release.ogg', 25, 1)
				H.visible_message(span_notice("[H] successfully restarts [src]!"),
				span_notice("You complete the restart sequence of [src] and it sparks back to life!"))
				src.visible_message(span_danger("[src]'s joints suddenly start moving."))

				if(src.wear_suit)
					to_chat(H, span_warning("You can't reach [src]'s maintenance panel through their armor."))
					return FALSE

				if((HAS_TRAIT(src, TRAIT_UNDEFIBBABLE ) || src.suiciding))
					H.visible_message(span_warning("[src]'s backup battery blinks weakly, too late to save this one."),
					span_warning("[src]'s backup battery ran dry, it cannot be restarted"))
					return FALSE

				if(!src.client) //Freak case, no client at all. This is a braindead mob (like a colonist)
					H.visible_message(span_warning("[src] buzzes: No personality program detected, Attempting to revive..."),
					span_warning("[src]'s battery is on but no program can be found, you try restarting anyway..."))


				if(src.mind && !src.client) //Let's call up the correct ghost! Also, bodies with clients only, thank you.
					G = src.get_ghost()
					if(istype(G))
						src.visible_message(span_warning("[icon2html(src, viewers(H))] [src] buzzes: Restart sequence failed. Robot's personality program has almost shutdown, please try again."))
						return FALSE
					//We couldn't find a suitable ghost, this means the person is not returning
					H.visible_message(span_warning("[icon2html(src, viewers(H))] [src] buzzes: Robot has a DNR."))
					return FALSE

				if(!src.client) //Freak case, no client at all. This is a braindead mob (like a colonist)
					H.visible_message(span_warning("[icon2html(src, viewers(H))] [src] buzzes: Restart sequence failed. No personality program detected."))
					return FALSE

				if(src.health <= restart_damage_threshold)
					H.visible_message(span_warning("[icon2html(src, viewers(H))] [src] buzzes: Restart sequence failed. Sustained damage critical, repair damage and try again."))
					return FALSE

				src.visible_message(span_notice("[icon2html(src, viewers(H))] [src] beeps: Restart sequence successful."))
				src.set_stat(UNCONSCIOUS)
				src.emote("gasp")
				src.regenerate_icons()
				src.reload_fullscreens()
				src.flash_act()
				src.apply_effect(10, EYE_BLUR)
				src.apply_effect(10, PARALYZE)
				src.handle_regular_hud_updates()
				src.updatehealth() //One more time, so it doesn't show the target as dead on HUDs
				src.dead_ticks = 0 //We reset the DNR time
				REMOVE_TRAIT(src, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
				GLOB.round_statistics.total_human_revives++
				SSblackbox.record_feedback("tally", "round_statistics", 1, "total_human_revives")
				to_chat(src, span_notice("You suddenly feel a spark and your consciousness returns, dragging you back to the mortal plane."))

				notify_ghosts("<b>[H]</b> has brought <b>[src.name]</b> back to life!", source = src, action = NOTIFY_ORBIT)
				return TRUE

			if(species?.species_flags & ROBOTIC_LIMBS)
				to_chat(H, span_boldnotice("You cant help this one, [p_they()] have no lungs!"))
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

			if(!do_mob(H, src, HUMAN_STRIP_DELAY, BUSY_ICON_FRIENDLY, BUSY_ICON_MEDICAL))
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
			var/max_dmg = H.melee_damage + H.skills.getRating("cqc")
			var/damage = rand(1, max_dmg)

			var/datum/limb/affecting = get_limb(ran_zone(H.zone_selected))
			var/armor_block = run_armor_check(affecting, "melee")

			playsound(loc, attack.attack_sound, 25, TRUE)

			visible_message(span_danger("[H] [pick(attack.attack_verb)]ed [src]!"), null, null, 5)
			var/list/hit_report = list()
			if(damage >= 5 && prob(50))
				visible_message(span_danger("[H] has weakened [src]!"), null, null, 5)
				apply_effect(3, WEAKEN, armor_block)
				hit_report += "(KO)"

			damage += attack.damage
			apply_damage(damage, BRUTE, affecting, armor_block, attack.sharp, attack.edge, updating_health = TRUE)

			hit_report += "(RAW DMG: [damage])"

			log_combat(H, src, "[pick(attack.attack_verb)]ed", "[hit_report.Join(" ")]")
			if(!H.mind?.bypass_ff && !mind?.bypass_ff && H.faction == faction)
				var/turf/T = get_turf(src)
				H.ff_check(damage, src)
				log_ffattack("[key_name(H)] punched [key_name(src)] in [AREACOORD(T)] [hit_report.Join(" ")].")
				msg_admin_ff("[ADMIN_TPMONTY(H)] punched [ADMIN_TPMONTY(src)] in [ADMIN_VERBOSEJMP(T)] [hit_report.Join(" ")].")

		if(INTENT_DISARM)

			H.do_attack_animation(src, ATTACK_EFFECT_DISARM)

			var/datum/limb/affecting = get_limb(ran_zone(H.zone_selected))

			//Accidental gun discharge
			if(user.skills.getRating("cqc") < SKILL_CQC_MP)
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

			var/randn = rand(1, 100) + skills.getRating("cqc") * 5 - H.skills.getRating("cqc") * 5

			if (randn <= 25)
				apply_effect(3, WEAKEN, run_armor_check(affecting, "melee"))
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

		visible_message(span_notice("[src] examines [p_them()]self."),
			span_notice("You check yourself for injuries."), null, 3)
		check_self_for_injuries()
		return

	return ..()


/mob/living/carbon/human/proc/check_self_for_injuries()
	var/list/final_msg = list()

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
		if(org.limb_status & LIMB_MUTATED)
			status = "weirdly shapen."
		if(org.limb_status & LIMB_NECROTIZED)
			status = "rotting"
		if(org.limb_status & LIMB_DESTROYED)
			status = "MISSING!"

		if(brute_treated == FALSE && brutedamage > 0)
			treat = "(Bandaged"
			if(burn_treated == FALSE && burndamage > 0)
				treat += " and Salved)"
			else
				treat += ")"
		else if(burn_treated == FALSE && burndamage > 0)
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

	to_chat(src, final_msg.Join("\n"))
