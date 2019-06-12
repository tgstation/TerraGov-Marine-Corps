/mob/living/carbon/Destroy()
	. = ..()
	stomach_contents.Cut() //movable atom's Destroy() deletes all content, we clear stomach_contents to be safe.

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition && stat != DEAD)
			nutrition -= HUNGER_FACTOR/10
			if(m_intent == MOVE_INTENT_RUN)
				nutrition -= HUNGER_FACTOR/10

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

/mob/living/carbon/relaymove(mob/user, direction)
	if(user.incapacitated(TRUE)) return
	if(user in src.stomach_contents)
		if(user.client)
			user.client.move_delay = world.time + 20
		if(prob(30))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message("<span class='warning'> You hear something rumbling inside [src]'s stomach...</span>", 2)
	else if(!chestburst && (status_flags & XENO_HOST) && isxenolarva(user))
		var/mob/living/carbon/xenomorph/larva/L = user
		L.initiate_burst(src)


/mob/living/carbon/gib()
	if(legcuffed)
		dropItemToGround(legcuffed)

	for(var/atom/movable/A in stomach_contents)
		stomach_contents.Remove(A)
		A.forceMove(loc)
		if(isliving(A))
			var/mob/living/L = A
			L.SetKnockeddown(1)
			visible_message("<span class='danger'>[A] bursts out of [src]!</span>")

	. = ..()


/mob/living/carbon/revive()
	if (handcuffed && !initial(handcuffed))
		dropItemToGround(handcuffed)
	handcuffed = initial(handcuffed)

	if (legcuffed && !initial(legcuffed))
		dropItemToGround(legcuffed)
	legcuffed = initial(legcuffed)

	return ..()


/mob/living/carbon/human/attack_hand(mob/living/carbon/M)
	if(!iscarbon(M))
		return

	next_move += 7 //Adds some lag to the 'attack'
	return


/mob/living/carbon/attack_paw(mob/living/carbon/M)
	if(!iscarbon(M))
		return

	next_move += 7 //Adds some lag to the 'attack'
	return

/mob/living/carbon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0, var/def_zone = null)
	if(status_flags & GODMODE)	return 0	//godmode
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0

	src.apply_damage(shock_damage, BURN, def_zone, used_weapon="Electrocution")

	playsound(loc, "sparks", 25, 1)
	if (shock_damage > 10)
		src.visible_message(
			"<span class='warning'> [src] was shocked by the [source]!</span>", \
			"<span class='danger'>You feel a powerful shock course through your body!</span>", \
			"<span class='warning'> You hear a heavy electrical crack.</span>" \
		)
		if(isxeno(src) && mob_size == MOB_SIZE_BIG)
			Stun(1)//Sadly, something has to stop them from bumping them 10 times in a second
			KnockDown(1)
		else
			Stun(10)//This should work for now, more is really silly and makes you lay there forever
			KnockDown(10)
	else
		src.visible_message(
			"<span class='warning'> [src] was mildly shocked by the [source].</span>", \
			"<span class='warning'> You feel a mild shock course through your body.</span>", \
			"<span class='warning'> You hear a light zapping.</span>" \
		)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, loc)
	s.start()

	return shock_damage


/mob/living/carbon/proc/swap_hand()
	var/obj/item/wielded_item = get_active_held_item()
	if(wielded_item && (wielded_item.flags_item & WIELDED)) //this segment checks if the item in your hand is twohanded.
		var/obj/item/weapon/twohanded/offhand/offhand = get_inactive_held_item()
		if(offhand && (offhand.flags_item & WIELDED))
			to_chat(src, "<span class='warning'>Your other hand is too busy holding \the [offhand.name]</span>")
			return
		else wielded_item.unwield(src) //Get rid of it.
	if(wielded_item && wielded_item.zoom) //Adding this here while we're at it
		wielded_item.zoom(src)
	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		hud_used.l_hand_hud_object.update_icon(hand)
		hud_used.r_hand_hud_object.update_icon(!hand)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.add_overlay("hand_active")
		else
			hud_used.r_hand_hud_object.add_overlay("hand_active")
	return

/mob/living/carbon/proc/activate_hand(var/selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()


/mob/living/carbon/vomit()
	if(stat == DEAD) //Corpses don't puke
		return

	if(!lastpuke)
		lastpuke = TRUE
		to_chat(src, "<spawn class='warning'>You feel like you are about to throw up!")
		addtimer(CALLBACK(src, .proc/do_vomit), 5 SECONDS)


/mob/living/carbon/proc/do_vomit()
	Stun(5)
	visible_message("<spawn class='warning'>[src] throws up!","<spawn class='warning'>You throw up!", null, 5)
	playsound(loc, 'sound/effects/splat.ogg', 25, 1, 7)

	var/turf/location = loc
	if (istype(location, /turf))
		location.add_vomit_floor(src, 1)

	nutrition = max(nutrition - 40, 0)
	adjustToxLoss(-3)
	addtimer(VARSET_CALLBACK(src, lastpuke, FALSE), 35 SECONDS) //wait 35 seconds before next volley


/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health >= get_crit_threshold())
		if(src != M)
			var/t_him = "it"
			if (gender == MALE)
				t_him = "him"
			else if (gender == FEMALE)
				t_him = "her"
			if(lying || sleeping)
				if(client)
					AdjustSleeping(-5)
				if(sleeping == 0)
					set_resting(FALSE)
				M.visible_message("<span class='notice'>[M] shakes [src] trying to wake [t_him] up!", \
									"<span class='notice'>You shake [src] trying to wake [t_him] up!", null, 4)
				AdjustKnockedout(-3)
				AdjustStunned(-3)
				AdjustKnockeddown(-3)

				if(halloss > 0)
					var/halloss_mod = 1
					if(ishuman(src))
						var/mob/living/carbon/human/H = src
						if(H.protection_aura)
							halloss_mod += 0.5 + 0.5 * H.protection_aura //SL Hold Aura bonus: +100% of the normal recovery bonus, SO: +150%, XO/CO: +200%
					adjustHalLoss(REST_HALLOSS_RECOVERY_RATE * halloss_mod) //UP AND AT THEM SOLDIER!!


			else
				var/mob/living/carbon/human/H = M
				if(istype(H))
					H.species.hug(H,src)
				else
					M.visible_message("<span class='notice'>[M] hugs [src] to make [t_him] feel better!</span>", \
								"<span class='notice'>You hug [src] to make [t_him] feel better!</span>", null, 4)

			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 25, 1, 5)

//Throwing stuff

/mob/living/carbon/proc/toggle_throw_mode()
	if (src.in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()

/mob/living/carbon/proc/throw_mode_off()
	src.in_throw_mode = 0
	if(hud_used && hud_used.throw_icon) //in case we don't have the HUD and we use the hotkey
		hud_used.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(hud_used && hud_used.throw_icon)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	src.throw_mode_off()
	if(is_ventcrawling) //NOPE
		return
	if(usr.stat || !target)
		return
	if(target.type == /obj/screen)
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = get_active_held_item()

	if(!I || (I.flags_item & NODROP)) return

	var/spin_throw = TRUE

	if (istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(ismob(G.grabbed_thing))
			if(grab_level >= GRAB_NECK)
				var/mob/living/M = G.grabbed_thing
				spin_throw = FALSE //thrown mobs don't spin
				thrown_thing = M
				var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
				var/turf/end_T = get_turf(target)
				if(start_T && end_T)
					var/start_T_descriptor = "tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]"
					var/end_T_descriptor = "tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]"

					log_combat(usr, M, "thrown", addition="from [start_T_descriptor] with the target [end_T_descriptor]")
					msg_admin_attack("[ADMIN_TPMONTY(usr)] has thrown [ADMIN_TPMONTY(M)].")
			else
				to_chat(src, "<span class='warning'>You need a better grip!</span>")

	else //real item in hand, not a grab
		thrown_thing = I
		dropItemToGround(I, TRUE)

	//actually throw it!
	if (thrown_thing)
		visible_message("<span class='warning'>[src] has thrown [thrown_thing].</span>", null, null, 5)

		if(!lastarea)
			lastarea = get_area(src.loc)
		if(isspaceturf(loc) || !lastarea.has_gravity)
			inertia_dir = get_dir(target, src)
			step(src, inertia_dir)

		playsound(src, 'sound/effects/throw.ogg', 50, 1)
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, spin_throw)

/mob/living/carbon/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	adjust_bodytemperature(100, 0, BODYTEMP_HEAT_DAMAGE_LIMIT_ONE+10)


/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_interaction(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=[SLOT_BACK]'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank) && !( internal )) ? " <A href='?src=\ref[src];internal=1'>Set Internal</A>" : "")]
	<BR>[(handcuffed ? "<A href='?src=\ref[src];item=[SLOT_HANDCUFFED]'>Handcuffed</A>" : "<A href='?src=\ref[src];item=handcuffs'>Not Handcuffed</A>")]
	<BR>[(internal ? "<A href='?src=\ref[src];internal=1'>Remove Internal</A>" : "")]
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, "window=mob[name];size=325x500")
	onclose(user, "mob[name]")
	return

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return PULSE_NONE
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(sleeping)
		to_chat(src, "<span class='warning'>You are already sleeping</span>")
		return
	if(alert(src,"You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		sleeping = 20 //Short nap


/mob/living/carbon/Bump(atom/movable/AM, yes)
	if(!yes || now_pushing)
		return
	. = ..()

/mob/living/carbon/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	set waitfor = 0
	if(buckled) return FALSE //can't slip while buckled
	if(run_only && (m_intent != MOVE_INTENT_RUN)) return FALSE
	if(lying) return FALSE //can't slip if already lying down.
	stop_pulling()
	to_chat(src, "<span class='warning'>You slipped on \the [slip_source_name? slip_source_name : "floor"]!</span>")
	playsound(src.loc, 'sound/misc/slip.ogg', 25, 1)
	Stun(stun_level)
	KnockDown(weaken_level)
	. = TRUE
	if(slide_steps && lying)//lying check to make sure we downed the mob
		var/slide_dir = dir
		for(var/i=1, i<=slide_steps, i++)
			step(src, slide_dir)
			sleep(2)
			if(!lying)
				break



/mob/living/carbon/on_stored_atom_del(atom/movable/AM)
	..()
	if(stomach_contents.len && ismob(AM))
		for(var/X in stomach_contents)
			if(AM == X)
				stomach_contents -= AM
				break


/mob/living/carbon/vv_get_dropdown()
	. = ..()
	. += "---"
	. -= "Update Icon"
	.["Regenerate Icons"] = "?_src_=vars;[HrefToken()];regenerateicons=[REF(src)]"

/mob/living/carbon/update_leader_tracking(mob/living/carbon/C)
	var/obj/screen/LL_dir = hud_used.SL_locator

	if(C.z != src.z || get_dist(src, C) < 1 || src == C)
		LL_dir.icon_state = ""
	else
		LL_dir.icon_state = "SL_locator"
		LL_dir.transform = 0 //Reset and 0 out
		LL_dir.transform = turn(LL_dir.transform, Get_Angle(src, C))

/mob/living/carbon/clear_leader_tracking()
	var/obj/screen/LL_dir = hud_used.SL_locator
	LL_dir.icon_state = "SL_locator_off"


/mob/living/carbon/proc/equip_preference_gear(client/C)
	if(!C?.prefs || !istype(back, /obj/item/storage/backpack))
		return

	var/datum/preferences/P = C.prefs
	var/list/gear = P.gear

	if(!length(gear))
		return

	for(var/i in GLOB.gear_datums)
		var/datum/gear/G = GLOB.gear_datums[i]
		if(!G || !gear.Find(i))
			continue
		equip_to_slot_or_del(new G.path, SLOT_IN_BACKPACK)