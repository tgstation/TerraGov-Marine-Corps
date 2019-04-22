/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	immune_to_ssd = 1
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer

	//Used in say.dm.
	var/speak_statement = "states"
	var/speak_exclamation = "declares"
	var/speak_query = "queries"
	var/pose //Yes, now AIs can pose too.
	var/obj/item/camera/siliconcam/aiCamera = null //photography
	var/local_transmit //If set, can only speak to others of the same type within a short range.

	var/med_hud = MOB_HUD_MEDICAL_ADVANCED //Determines the med hud to use
	var/sec_hud = MOB_HUD_SECURITY_ADVANCED //Determines the sec hud to use
	var/list/HUD_toggled = list(0,0,0)

/mob/living/silicon/Initialize()
	. = ..()
	GLOB.silicon_mobs += src
	grant_language(/datum/language/common)

/mob/living/silicon/Destroy()
	GLOB.silicon_mobs -= src
	return ..()

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/drop_held_item()
	return

/mob/living/silicon/drop_all_held_items()
	return

/mob/living/simple_animal/update_transform()
	var/matrix/ntransform = matrix(transform) //aka transform.Copy()
	var/changed = 0

	if(resize != RESIZE_DEFAULT_SIZE)
		changed++
		ntransform.Scale(resize)
		resize = RESIZE_DEFAULT_SIZE

	if(changed)
		animate(src, transform = ntransform, time = 2, easing = EASE_IN|EASE_OUT)

/mob/living/silicon/emp_act(severity)
	switch(severity)
		if(1)
			src.take_limb_damage(20)
			Stun(rand(5,10))
		if(2)
			src.take_limb_damage(10)
			Stun(rand(1,5))
	flash_eyes(1, TRUE, type = /obj/screen/fullscreen/flash/noise)

	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()

/mob/living/silicon/stun_effect_act(var/stun_amount, var/agony_amount)
	return	//immune

/mob/living/silicon/electrocute_act(var/shock_damage, var/obj/source, var/siemens_coeff = 1.0)

	if (istype(source, /obj/machinery/containment_field))
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(5, 1, loc)
		s.start()

		shock_damage *= 0.75	//take reduced damage
		take_overall_damage(0, shock_damage)
		visible_message("<span class='warning'> [src] was shocked by \the [source]!</span>", \
			"<span class='danger'>Energy pulse detected, system damaged!</span>", \
			"<span class='warning'> You hear an electrical crack</span>")
		if(prob(20))
			Stun(2)
		return

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return TRUE

/mob/living/silicon/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now

/proc/islinked(var/mob/living/silicon/robot/bot, var/mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0


// this function shows health in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	if(!stat)
		stat(null, text("System integrity: [round((health/maxHealth)*100)]%"))
	else
		stat(null, text("Systems nonfunctional"))

// this function displays the station time in the status panel
/mob/living/silicon/proc/show_station_time()
	stat(null, "Station Time: [worldtime2text()]")


// this function displays the shuttles ETA in the status panel if the shuttle has been called
/mob/living/silicon/proc/show_emergency_shuttle_eta()
	var/eta_status = SSevacuation?.get_status_panel_eta()
	if(eta_status)
		stat("Evacuation in:", eta_status)


// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/Stat()
	. = ..()

	if(statpanel("Stats"))
		show_station_time()
		show_emergency_shuttle_eta()
		show_system_integrity()

// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	var/dat
	if(GLOB.datacore)
		dat += GLOB.datacore.get_manifest(1) // make it monochrome

	var/datum/browser/popup = new(src, "airoster", "<div align='center'>Crew Manifest</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(src, "airoster")

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

/mob/living/silicon/verb/pose()
	set name = "Set Pose"
	set desc = "Sets a description which will be shown when someone examines you."
	set category = "IC"

	pose =  copytext(sanitize(input(usr, "This is [src]. It is...", "Pose", null)  as text), 1, MAX_MESSAGE_LEN)

/mob/living/silicon/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Sets an extended description of your character's features."
	set category = "IC"

	flavor_text =  copytext(sanitize(input(usr, "Please enter your new flavour text.", "Flavour text", null)  as text), 1)

/mob/living/silicon/binarycheck()
	return 1

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
