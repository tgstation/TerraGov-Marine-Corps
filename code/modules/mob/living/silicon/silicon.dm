/mob/living/silicon
	gender = NEUTER
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"

	initial_language_holder = /datum/language_holder/synthetic

	var/obj/machinery/camera/builtInCamera = null
	var/obj/item/radio/headset/almayer/mcom/silicon/radio = null

	var/list/HUD_toggled = list(0, 0, 0)


/mob/living/silicon/Initialize()
	. = ..()
	radio = new(src)
	GLOB.silicon_mobs += src


/mob/living/silicon/Destroy()
	GLOB.silicon_mobs -= src
	QDEL_NULL(radio)
	return ..()


/mob/living/silicon/drop_held_item()
	return


/mob/living/silicon/drop_all_held_items()
	return


/mob/living/silicon/get_held_item()
	return


/mob/living/silicon/get_inactive_held_item()
	return


/mob/living/silicon/get_active_held_item()
	return


/mob/living/silicon/put_in_l_hand(obj/item/I)
	return


/mob/living/silicon/put_in_r_hand(obj/item/I)
	return


/mob/living/silicon/stripPanelEquip(obj/item/I, mob/M, slot)
	return


/mob/living/silicon/stripPanelUnequip(obj/item/I, mob/M, slot)
	return


/mob/living/silicon/med_hud_set_health()
	return


/mob/living/silicon/med_hud_set_status()
	return


/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			take_limb_damage(20)
			Stun(rand(5, 10))
		if(2)
			take_limb_damage(10)
			Stun(rand(1, ))
	flash_eyes(1, TRUE, type = /obj/screen/fullscreen/flash/noise)

	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	return ..()


/mob/living/silicon/stun_effect_act(stun_amount, agony_amount)
	return


/mob/living/silicon/IsAdvancedToolUser()
	return TRUE


/mob/living/silicon/apply_effect(effect = 0, effecttype = STUN, blocked = FALSE)
	return FALSE


/mob/living/silicon/adjustToxLoss(amount)
	return FALSE


/mob/living/silicon/setToxLoss(amount)
	return FALSE


/mob/living/silicon/adjustCloneLoss(amount)
	return FALSE


/mob/living/silicon/setCloneLoss(amount)
	return FALSE


/mob/living/silicon/adjustBrainLoss(amount)
	return FALSE


/mob/living/silicon/setBrainLoss(amount)
	return FALSE


//can't inject synths
/mob/living/silicon/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE)
	if(user && error_msg)
		to_chat(user, "<span class='alert'>The armoured plating is too tough.</span>")
	return FALSE


/mob/living/silicon/proc/toggle_sensor_mode()
	if(!client)
		return
	var/list/listed_huds = list("Medical HUD", "Security HUD", "Squad HUD")
	var/hud_choice = input("Choose a HUD to toggle", "Toggle HUD", null) as null|anything in listed_huds
	if(!client)
		return
	var/datum/atom_hud/H
	var/HUD_nbr = 1
	switch(hud_choice)
		if("Medical HUD")
			H = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
		if("Security HUD")
			H = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
			HUD_nbr = 2
		if("Squad HUD")
			H = GLOB.huds[DATA_HUD_SQUAD]
			HUD_nbr = 3
		else
			return

	if(HUD_toggled[HUD_nbr])
		HUD_toggled[HUD_nbr] = 0
		H.remove_hud_from(src)
		to_chat(src, "<span class='boldnotice'>[hud_choice] Disabled</span>")
	else
		HUD_toggled[HUD_nbr] = 1
		H.add_hud_to(src)
		to_chat(src, "<span class='boldnotice'>[hud_choice] Enabled</span>")


/mob/living/silicon/ex_act(severity)
	flash_eyes()

	switch(severity)
		if(1)
			if(stat == DEAD)
				return
			adjustBruteLoss(100)
			adjustFireLoss(100)
			if(!anchored)
				gib()
		if(2)
			if(stat == DEAD)
				return
			adjustBruteLoss(60)
			adjustFireLoss(60)
		if(3)
			if(stat == DEAD)
				return
			adjustBruteLoss(30)

	updatehealth()


/mob/living/silicon/emp_act(severity)
	. = ..()

	to_chat(src, "<span class='danger'>Electromagnetic pulse detected.</span>")

	switch(severity)
		if(1)
			adjustBruteLoss(20)
		if(2)
			adjustBruteLoss(10)

	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	flash_eyes()


/mob/living/silicon/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/changed = 0
	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)
	return ..()


/mob/living/silicon/attack_hand(mob/living/user)
	switch(user.a_intent)
		if(INTENT_HELP)
			user.visible_message("[user] pets [src].", "<span class='notice'>You pet [src].</span>")
		
		if(INTENT_GRAB)
			user.start_pulling(src)

		else
			user.animation_attack_on(src)
			playsound(loc, 'sound/effects/bang.ogg', 10, 1)
			visible_message("<span class='danger'>[user] punches [src], but doesn't leave a dent.</span>", \
				"<span class='warning'>[user] punches [src], but doesn't leave a dent.</span>")