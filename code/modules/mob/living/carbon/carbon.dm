/mob/living/carbon/Initialize(mapload)
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


/mob/living/carbon/relaymove(mob/user, direction)
	if(user.incapacitated(TRUE))
		return
	if(!chestburst && (status_flags & XENO_HOST) && isxenolarva(user))
		var/mob/living/carbon/xenomorph/larva/L = user
		L.initiate_burst(src)


/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null)
	if(status_flags & GODMODE)
		return
	shock_damage *= siemens_coeff
	if(shock_damage<1)
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
	addtimer(CALLBACK(src, PROC_REF(do_vomit)), 5 SECONDS)


/mob/living/carbon/proc/do_vomit()
	adjust_stagger(3 SECONDS)
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

		AdjustUnconscious(-6 SECONDS)
		AdjustStun(-6 SECONDS)
		if(IsParalyzed())
			if(staminaloss)
				adjustStaminaLoss(-20, FALSE)
		AdjustParalyzed(-6 SECONDS)

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
	if(hud_used?.throw_icon) //in case we don't have the HUD and we use the hotkey
		hud_used.throw_icon.icon_state = "act_throw_off"

/mob/living/carbon/proc/throw_mode_on()
	src.in_throw_mode = 1
	if(hud_used?.throw_icon)
		hud_used.throw_icon.icon_state = "act_throw_on"

///Throws active held item at target in params
/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	. = ..()
	throw_mode_off()
	if(is_ventcrawling) //NOPE
		return
	if(stat || !target)
		return
	if(target.type == /atom/movable/screen)
		return

	var/atom/movable/thrown_thing
	var/obj/item/I = get_active_held_item()

	if(!I || HAS_TRAIT(I, TRAIT_NODROP))
		return

	var/spin_throw = TRUE
	if(isgrabitem(I))
		spin_throw = FALSE

	//real item in hand, not a grab
	thrown_thing = I.on_thrown(src, target)

	//actually throw it!
	if(!thrown_thing)
		return

	var/list/throw_modifiers = list()
	throw_modifiers["targetted_throw"] = TRUE
	throw_modifiers["range_modifier"] = 0
	throw_modifiers["speed_modifier"] = 0
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target, thrown_thing, throw_modifiers)

	if(!lastarea)
		lastarea = get_area(src.loc)
	if(isspaceturf(loc))
		inertia_dir = get_dir(target, src)
		step(src, inertia_dir)

	visible_message(span_warning("[src] has thrown [thrown_thing]."), null, null, 5)

	playsound(src, 'sound/effects/throw.ogg', 30, 1)

	thrown_thing.throw_at(target, thrown_thing.throw_range + throw_modifiers["range_modifier"], max(1, thrown_thing.throw_speed + throw_modifiers["speed_modifier"]), src, spin_throw, !throw_modifiers["targetted_throw"], throw_modifiers["targetted_throw"])

///Called by the carbon throw_item() proc. Returns null if the item negates the throw, or a reference to the thing to suffer the throw else.
/obj/item/proc/on_thrown(mob/living/carbon/user, atom/target)
	if((flags_item & ITEM_ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return
	user.dropItemToGround(src, TRUE)
	return src

/mob/living/carbon/fire_act(exposed_temperature, exposed_volume)
	. = ..()
	adjust_bodytemperature(100, 0, BODYTEMP_HEAT_DAMAGE_LIMIT_ONE+10)

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

	if(species.species_flags & ROBOTIC_LIMBS)
		to_chat(src, span_warning("Your artificial body does not require sleep."))
		return
	if(IsSleeping())
		to_chat(src, span_warning("You are already sleeping"))
		return
	if(tgui_alert(src, "You sure you want to sleep for a while?", "Sleep", list("Yes","No")) == "Yes")
		SetSleeping(40 SECONDS) //Short nap

/mob/living/carbon/Bump(atom/movable/AM)
	if(now_pushing)
		return
	. = ..()

/mob/living/carbon/slip(slip_source_name, stun_time, paralyze_time, run_only, override_noslip, slide_steps)
	set waitfor = 0
	if(buckled || (run_only && (m_intent != MOVE_INTENT_RUN)) || lying_angle)
		return FALSE //can't slip while buckled, if the slip is run only and we're not running or while resting

	stop_pulling()
	visible_message(span_warning("[src] slipped on \the [slip_source_name]!"), span_warning("You slipped on \the [slip_source_name]!"))
	playsound(src, 'sound/misc/slip.ogg', 25, 1)
	Stun(stun_time)
	Paralyze(paralyze_time)
	. = TRUE
	if(slide_steps && lying_angle)//lying check to make sure we downed the mob
		var/slide_dir = dir
		for(var/i in 1 to slide_steps)
			step(src, slide_dir)
			if(!lying_angle)
				break


/mob/living/carbon/vv_get_dropdown()
	. = ..()
	. += "---"
	. -= "Update Icon"
	.["Regenerate Icons"] = "?_src_=vars;[HrefToken()];regenerateicons=[REF(src)]"

/mob/living/carbon/update_tracking(mob/living/carbon/C)
	var/atom/movable/screen/LL_dir = hud_used.SL_locator

	if(C.z != src.z || get_dist(src, C) < 1 || src == C)
		LL_dir.icon_state = ""
	else
		LL_dir.icon_state = "Blue_arrow"
		LL_dir.transform = 0 //Reset and 0 out
		LL_dir.transform = turn(LL_dir.transform, Get_Angle(src, C))

/mob/living/carbon/clear_leader_tracking()
	var/atom/movable/screen/LL_dir = hud_used.SL_locator
	LL_dir.icon_state = "SL_locator_off"


/mob/living/carbon/proc/equip_preference_gear(client/C)
	if(!C?.prefs)
		return

	var/datum/preferences/P = C.prefs
	var/list/gear = P.gear

	if(!length(gear))
		return

	for(var/i in GLOB.gear_datums)
		var/datum/gear/G = GLOB.gear_datums[i]
		if(!G || !gear.Find(i))
			continue
		if(!equip_to_slot_or_del(new G.path, G.slot)) //try to put in the slot it says its supposed to go, if you can't: put it in a bag
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
		RegisterSignal(src, COMSIG_MOVABLE_PULL_MOVED, TYPE_PROC_REF(/mob/living/carbon/human, oncritdrag))
		return
	if(. == UNCONSCIOUS)
		UnregisterSignal(src, COMSIG_MOVABLE_PULL_MOVED)
