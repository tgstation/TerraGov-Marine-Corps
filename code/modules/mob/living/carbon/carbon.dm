/mob/living/carbon/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_CARBON_DEVOURED_BY_XENO, .proc/on_devour_by_xeno)
	adjust_nutrition_speed(0)


/mob/living/carbon/Destroy()
	if(afk_status == MOB_RECENTLY_DISCONNECTED)
		set_afk_status(MOB_DISCONNECTED)
	if(isxeno(loc))
		var/mob/living/carbon/xenomorph/devourer = loc
		devourer.do_regurgitate(src)
	return ..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition && stat != DEAD)
			adjust_nutrition(-HUNGER_FACTOR * 0.1 * ((m_intent == MOVE_INTENT_RUN) ? 2 : 1))

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

/mob/living/carbon/relaymove(mob/user, direction)
	if(user.incapacitated(TRUE))
		return
	if(!chestburst && (status_flags & XENO_HOST) && isxenolarva(user))
		var/mob/living/carbon/xenomorph/larva/L = user
		L.initiate_burst(src)


/mob/living/carbon/gib()
	if(legcuffed)
		dropItemToGround(legcuffed)

	return ..()


/mob/living/carbon/attack_paw(mob/living/carbon/monkey/user)
	user.changeNext_move(CLICK_CD_MELEE) //Adds some lag to the 'attack'


/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null)
	if(status_flags & GODMODE)	return 0	//godmode
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0

	apply_damage(shock_damage, BURN, def_zone)
	UPDATEHEALTH(src)

	playsound(loc, "sparks", 25, TRUE)
	if (shock_damage > 10)
		src.visible_message(
			"<span class='warning'> [src] was shocked by the [source]!</span>", \
			"<span class='danger'>You feel a powerful shock course through your body!</span>", \
			"<span class='warning'> You hear a heavy electrical crack.</span>" \
		)
		if(isxeno(src) && mob_size == MOB_SIZE_BIG)
			Stun(20)//Sadly, something has to stop them from bumping them 10 times in a second
			Paralyze(20)
		else
			Stun(20 SECONDS)//This should work for now, more is really silly and makes you lay there forever
			Paralyze(20 SECONDS)
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
		else
			wielded_item.unwield(src) //Get rid of it.
	if(wielded_item && wielded_item.zoom) //Adding this here while we're at it
		wielded_item.zoom(src)
	hand = !hand
	SEND_SIGNAL(src, COMSIG_CARBON_SWAPPED_HANDS)
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		hud_used.l_hand_hud_object.update_icon(hand)
		hud_used.r_hand_hud_object.update_icon(!hand)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.add_overlay("hand_active")
		else
			hud_used.r_hand_hud_object.add_overlay("hand_active")
	return

/mob/living/carbon/proc/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

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

	if(COOLDOWN_CHECK(src, COOLDOWN_PUKE))
		return

	COOLDOWN_START(src, COOLDOWN_PUKE, 40 SECONDS) //5 seconds before the actual action plus 35 before the next one.
	to_chat(src, "<spawn class='warning'>You feel like you are about to throw up!")
	addtimer(CALLBACK(src, .proc/do_vomit), 5 SECONDS)


/mob/living/carbon/proc/do_vomit()
	Stun(10 SECONDS)
	visible_message("<spawn class='warning'>[src] throws up!","<spawn class='warning'>You throw up!", null, 5)
	playsound(loc, 'sound/effects/splat.ogg', 25, TRUE, 7)

	var/turf/location = loc
	if (istype(location, /turf))
		location.add_vomit_floor(src, 1)

	adjust_nutrition(-40)
	adjustToxLoss(-3)


/mob/living/carbon/proc/help_shake_act(mob/living/carbon/shaker)
	if(health < get_crit_threshold())
		return

	if(src == shaker)
		return

	if(IsAdminSleeping())
		to_chat(shaker, "<span class='highdanger'>This player has been admin slept, do not interfere with them.</span>")
		return

	if(lying_angle || IsSleeping())
		if(client)
			AdjustSleeping(-10 SECONDS)
		if(!IsSleeping())
			set_resting(FALSE)
		shaker.visible_message("<span class='notice'>[shaker] shakes [src] trying to get [p_them()] up!",
			"<span class='notice'>You shake [src] trying to get [p_them()] up!", null, 4)

		AdjustUnconscious(-60)
		AdjustStun(-60)
		if(IsParalyzed())
			if(staminaloss)
				adjustStaminaLoss(-20, FALSE)
		AdjustParalyzed(-60)

		playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 5)
		return

	if(ishuman(shaker))
		var/mob/living/carbon/human/shaker_human = shaker
		shaker_human.species.hug(shaker_human, src)
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 5)
		return

	shaker.visible_message("<span class='notice'>[shaker] hugs [src] to make [p_them()] feel better!</span>",
		"<span class='notice'>You hug [src] to make [p_them()] feel better!</span>", null, 4)
	playsound(loc, 'sound/weapons/thudswoosh.ogg', 25, TRUE, 5)


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
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)


/mob/living/carbon/throw_item(atom/target)
	. = ..()
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
			if(grab_state >= GRAB_NECK)
				var/mob/living/M = G.grabbed_thing
				spin_throw = FALSE //thrown mobs don't spin
				thrown_thing = M
				var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
				var/turf/end_T = get_turf(target)
				if(start_T && end_T)
					var/start_T_descriptor = "tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]"
					var/end_T_descriptor = "tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]"

					log_combat(usr, M, "thrown", addition="from [start_T_descriptor] with the target [end_T_descriptor]")
			else
				to_chat(src, "<span class='warning'>You need a better grip!</span>")
	else if(istype(I, /obj/item/riding_offhand))
		var/obj/item/riding_offhand/riding_item = I
		spin_throw = FALSE
		thrown_thing = riding_item.rider
		var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
		var/turf/end_T = get_turf(target)
		if(start_T && end_T)
			log_combat(usr, thrown_thing, "thrown", addition = "from tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)] with the target tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]")
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

		playsound(src, 'sound/effects/throw.ogg', 30, 1)
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, spin_throw)

/mob/living/carbon/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	adjust_bodytemperature(100, 0, BODYTEMP_HEAT_DAMAGE_LIMIT_ONE+10)


/mob/living/carbon/show_inv(mob/living/carbon/user)
	user.set_interaction(src)
	var/dat = {"
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=[SLOT_WEAR_MASK]'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[SLOT_L_HAND]'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[SLOT_R_HAND]'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=[SLOT_BACK]'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank) && !( internal )) ? " <A href='?src=\ref[src];internal=1'>Set Internal</A>" : "")]
	<BR>[(handcuffed ? "<A href='?src=\ref[src];item=[SLOT_HANDCUFFED]'>Handcuffed</A>" : "<A href='?src=\ref[src];item=handcuffs'>Not Handcuffed</A>")]
	<BR>[(internal ? "<A href='?src=\ref[src];internal=1'>Remove Internal</A>" : "")]
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR>"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "<div align='center'>[src]</div>", 325, 500)
	popup.set_content(dat)
	popup.open()

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/human/proc/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	switch(handle_pulse())
		if(PULSE_NONE)
			return PULSE_NONE
		if(PULSE_SLOW)
			var/temp = rand(40, 60)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_NORM)
			var/temp = rand(60, 90)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_FAST)
			var/temp = rand(90, 120)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_2FAST)
			var/temp = rand(120, 160)
			return num2text(method ? temp : temp + rand(-10, 10))
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(IsSleeping())
		to_chat(src, "<span class='warning'>You are already sleeping</span>")
		return
	if(alert(src,"You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		SetSleeping(40 SECONDS) //Short nap


/mob/living/carbon/Bump(atom/movable/AM)
	if(now_pushing)
		return
	. = ..()

/mob/living/carbon/slip(slip_source_name, stun_level, weaken_level, run_only, override_noslip, slide_steps)
	set waitfor = 0
	if(buckled) return FALSE //can't slip while buckled
	if(run_only && (m_intent != MOVE_INTENT_RUN)) return FALSE
	if(lying_angle)
		return FALSE //can't slip if already lying down.
	stop_pulling()
	to_chat(src, "<span class='warning'>You slipped on \the [slip_source_name? slip_source_name : "floor"]!</span>")
	playsound(src.loc, 'sound/misc/slip.ogg', 25, 1)
	Stun(stun_level)
	Paralyze(weaken_level)
	. = TRUE
	if(slide_steps && lying_angle)//lying check to make sure we downed the mob
		var/slide_dir = dir
		for(var/i=1, i<=slide_steps, i++)
			step(src, slide_dir)
			sleep(2)
			if(!lying_angle)
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



/mob/living/carbon/human/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	see_in_dark = species.darksight
	see_invisible = initial(see_invisible)

	if(species)
		if(species.lighting_alpha)
			lighting_alpha = initial(species.lighting_alpha)
		if(species.see_in_dark)
			see_in_dark = initial(species.see_in_dark)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		if((G.toggleable && G.active) || !G.toggleable)
			sight |= G.vision_flags
			see_in_dark = max(G.darkness_view, see_in_dark)
			if(G.invis_override)
				see_invisible = G.invis_override
			else
				see_invisible = min(G.invis_view, see_invisible)
			if(!isnull(G.lighting_alpha))
				lighting_alpha = min(lighting_alpha, G.lighting_alpha)

	if(see_override)
		see_invisible = see_override

	return ..()


//AFK STATUS
/mob/living/carbon/proc/set_afk_status(new_status, afk_timer)
	switch(new_status)
		if(MOB_CONNECTED, MOB_DISCONNECTED)
			if(afk_timer_id)
				deltimer(afk_timer_id)
				afk_timer_id = null
		if(MOB_RECENTLY_DISCONNECTED)
			if(afk_status == MOB_RECENTLY_DISCONNECTED)
				if(timeleft(afk_timer_id) > afk_timer)
					deltimer(afk_timer_id) //We'll go with the shorter timer.
				else
					return
			afk_timer_id = addtimer(CALLBACK(src, .proc/on_sdd_grace_period_end), afk_timer, TIMER_STOPPABLE)
	afk_status = new_status
	SEND_SIGNAL(src, COMSIG_CARBON_SETAFKSTATUS, new_status, afk_timer)


/mob/living/carbon/proc/on_sdd_grace_period_end()
	if(stat == DEAD)
		return FALSE
	if(isclientedaghost(src))
		return FALSE
	set_afk_status(MOB_DISCONNECTED)
	return TRUE

/mob/living/carbon/human/on_sdd_grace_period_end()
	. = ..()
	if(!.)
		return
	log_admin("[key_name(src)] (Job: [job.title]) has been away for 15 minutes.")
	message_admins("[ADMIN_TPMONTY(src)] (Job: [job.title]) has been away for 15 minutes.")

/mob/living/carbon/xenomorph/on_sdd_grace_period_end()
	. = ..()
	if(!.)
		return
	if(client)
		return

	var/mob/picked = get_alien_candidate()
	if(!picked)
		return

	SSticker.mode.transfer_xeno(picked, src)

	to_chat(src, "<span class='xenoannounce'>We are an old xenomorph re-awakened from slumber!</span>")
	playsound_local(get_turf(src), 'sound/effects/xeno_newlarva.ogg')


/mob/living/carbon/verb/middle_mousetoggle()
	set name = "Toggle Middle/Shift Clicking"
	set desc = "Toggles between using middle mouse click and shift click for selected ability use."
	set category = "IC"

	middle_mouse_toggle = !middle_mouse_toggle
	if(!middle_mouse_toggle)
		to_chat(src, "<span class='notice'>The selected special ability will now be activated with shift clicking.</span>")
	else
		to_chat(src, "<span class='notice'>The selected special ability will now be activated with middle mouse clicking.</span>")

/mob/living/carbon/set_stat(new_stat)
	. = ..()
	if(isnull(.))
		return
	if(stat == UNCONSCIOUS)
		blind_eyes(1)
		disabilities |= DEAF
	else if(. == UNCONSCIOUS)
		adjust_blindness(-1)
		disabilities &= ~DEAF
