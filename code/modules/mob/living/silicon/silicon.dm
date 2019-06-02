/mob/living/silicon
	gender = NEUTER
	verb_say = "states"
	verb_ask = "queries"
	verb_exclaim = "declares"
	verb_yell = "alarms"

	initial_language_holder = /datum/language_holder/synthetic

	var/obj/machinery/camera/builtInCamera = null
	var/obj/item/radio/headset/almayer/mcom/ai/radio = null

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


/mob/living/silicon/apply_effect(effect = 0, effecttype = STUN, blocked = 0)
	return 0 //The only effect that can hit them atm is flashes and they still directly edit so this works for now


// This adds the basic clock, and malf_ai info to all silicon lifeforms
/mob/living/silicon/Stat()
	. = ..()

	if(statpanel("Stats"))
		if(!stat)
			stat(null, text("System integrity: [round((health/maxHealth)*100)]%"))
		else
			stat(null, text("Systems nonfunctional"))


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
	var/datum/mob_hud/H
	var/HUD_nbr = 1
	switch(hud_choice)
		if("Medical HUD")
			H = huds[MOB_HUD_MEDICAL_OBSERVER]
		if("Security HUD")
			H = huds[MOB_HUD_SECURITY_ADVANCED]
			HUD_nbr = 2
		if("Squad HUD")
			H = huds[MOB_HUD_SQUAD]
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
		if(1.0)
			if (stat != 2)
				adjustBruteLoss(100)
				adjustFireLoss(100)
				if(!anchored)
					gib()
		if(2.0)
			if (stat != 2)
				adjustBruteLoss(60)
				adjustFireLoss(60)
		if(3.0)
			if (stat != 2)
				adjustBruteLoss(30)

	updatehealth()