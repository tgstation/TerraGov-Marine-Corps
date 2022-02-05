/mob/living/carbon/Initialize()
	. = ..()
	adjust_nutrition_speed(0)

/mob/living/carbon/Destroy()
	if(afk_status == MOB_RECENTLY_DISCONNECTED)
		set_afk_status(MOB_DISCONNECTED)
	QDEL_NULL(back)
	QDEL_NULL(internal)
	QDEL_NULL(handcuffed)
	. = ..()
	species = null

/mob/living/carbon/on_death()
	if(species)
		to_chat(src,"<b>[span_deadsay("<p style='font-size:1.5em'>[species.special_death_message]</p>")]</b>")
	return ..()

/mob/living/carbon/Moved(oldLoc, dir)
	. = ..()
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


/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null)
	if(status_flags & GODMODE)	return 0	//godmode
	shock_damage *= siemens_coeff
	if (shock_damage<1)
		return 0

	apply_damage(shock_damage, BURN, def_zone, updating_health = TRUE)

	playsound(loc, "sparks", 25, TRUE)
	if (shock_damage > 10)
		src.visible_message(
			span_warning(" [src] was shocked by the [source]!"), \
			span_danger("You feel a powerful shock course through your body!"), \
			span_warning(" You hear a heavy electrical crack.") \
		)
		if(isxeno(src))
			if(mob_size != MOB_SIZE_BIG)
				Paralyze(4 SECONDS)
		else
			Paralyze(8 SECONDS)
	else
		src.visible_message(
			span_warning(" [src] was mildly shocked by the [source]."), \
			span_warning(" You feel a mild shock course through your body."), \
			span_warning(" You hear a light zapping.") \
		)

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, loc)
	s.start()

	return shock_damage

/mob/living/carbon/vomit()
	if(stat == DEAD) //Corpses don't puke
		return

	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_PUKE))
		return

	TIMER_COOLDOWN_START(src, COOLDOWN_PUKE, 40 SECONDS) //5 seconds before the actual action plus 35 before the next one.
	to_chat(src, "<spawn class='warning'>You feel like you are about to throw up!")
	addtimer(CALLBACK(src, .proc/do_vomit), 5 SECONDS)


/mob/living/carbon/proc/do_vomit()
	adjust_stagger(3)
	add_slowdown(3)

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
		to_chat(shaker, span_highdanger("This player has been admin slept, do not interfere with them."))
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

	shaker.visible_message(span_notice("[shaker] hugs [src] to make [p_them()] feel better!"),
		span_notice("You hug [src] to make [p_them()] feel better!"), null, 4)
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
	throw_mode_off()
	if(is_ventcrawling) //NOPE
		return
	if(stat || !target)
		return
	if(target.type == /obj/screen)
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = get_active_held_item()

	if(!I || (I.flags_item & NODROP))
		return

	var/spin_throw = TRUE
	if(isgrabitem(I))
		spin_throw = FALSE

	//real item in hand, not a grab
	thrown_thing = I.on_thrown(src, target)

	//actually throw it!
	if (thrown_thing)
		visible_message(span_warning("[src] has thrown [thrown_thing]."), null, null, 5)

		if(!lastarea)
			lastarea = get_area(src.loc)
		if(isspaceturf(loc))
			inertia_dir = get_dir(target, src)
			step(src, inertia_dir)

		playsound(src, 'sound/effects/throw.ogg', 30, 1)
		thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, spin_throw)

///Called by the carbon throw_item() proc. Returns null if the item negates the throw, or a reference to the thing to suffer the throw else.
/obj/item/proc/on_thrown(mob/living/carbon/user, atom/target)
	if((flags_item & ITEM_ABSTRACT) || (flags_item & NODROP))
		return
	user.dropItemToGround(src, TRUE)
	return src

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
		to_chat(src, span_warning("You are already sleeping"))
		return
	if(tgui_alert(src, "You sure you want to sleep for a while?", "Sleep", list("Yes","No")) == "Yes")
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
	to_chat(src, span_warning("You slipped on \the [slip_source_name? slip_source_name : "floor"]!"))
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

/mob/living/carbon/update_tracking(mob/living/carbon/C)
	var/obj/screen/LL_dir = hud_used.SL_locator

	if(C.z != src.z || get_dist(src, C) < 1 || src == C)
		LL_dir.icon_state = ""
	else
		LL_dir.icon_state = "Blue_arrow"
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

	if(HAS_TRAIT(src, TRAIT_SEE_IN_DARK))
		see_in_dark = max(see_in_dark, 8)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	return ..()

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

/mob/living/carbon/human/set_stat(new_stat) //registers/unregisters critdragging signals
	. = ..()
	if(new_stat == UNCONSCIOUS)
		RegisterSignal(src, COMSIG_MOVABLE_PULL_MOVED, /mob/living/carbon/human.proc/oncritdrag)
		return
	if(. == UNCONSCIOUS)
		UnregisterSignal(src, COMSIG_MOVABLE_PULL_MOVED)
