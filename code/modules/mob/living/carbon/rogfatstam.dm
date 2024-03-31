/mob/living/proc/update_rogfat() //update hud and regen after last_fatigued delay on taking
//	maxrogfat = round(100 * (rogstam/maxrogstam))
//	if(maxrogfat < 5)
//		maxrogfat = 5

	if(world.time > last_fatigued + 50) //regen fatigue
		var/added = rogstam / maxrogstam
		added = round(-10+ (added*-40))
		if(rogfat >= 1)
			rogfat_add(added)
		else
			rogfat = 0

	update_health_hud()

/mob/living/proc/update_rogstam()
	maxrogstam = STAEND*100
	if(cmode)
		if(!HAS_TRAIT(src, RTRAIT_BREADY))
			rogstam_add(-2)

/mob/proc/rogstam_add(added as num)
	return

/mob/living/rogstam_add(added as num)
	if(HAS_TRAIT(src, TRAIT_NOFATSTAM))
		return TRUE
	rogstam += added
	if(rogstam > maxrogstam)
		rogstam = maxrogstam
		update_health_hud()
		return FALSE
	else
		if(rogstam <= 0)
			rogstam = 0
			if(m_intent == MOVE_INTENT_RUN) //can't sprint at zero stamina
				toggle_rogmove_intent(MOVE_INTENT_WALK)
		update_health_hud()
		return TRUE

/mob/proc/rogfat_add(added as num)
	return TRUE

/mob/living/rogfat_add(added as num, emote_override, force_emote = TRUE) //call update_rogfat here and set last_fatigued, return false when not enough fatigue left
	if(HAS_TRAIT(src, TRAIT_NOFATSTAM))
		return TRUE
	rogfat = CLAMP(rogfat+added, 0, maxrogfat)
	if(added > 0)
		rogstam_add(added * -1)
	if(added >= 5)
		if(rogstam <= 0)
			if(iscarbon(src))
				var/mob/living/carbon/C = src
				if(!HAS_TRAIT(C, TRAIT_NOHUNGER))
					if(C.nutrition <= 0)
						if(C.hydration <= 0)
							C.heart_attack()
							return FALSE
	if(rogfat >= maxrogfat)
		rogfat = maxrogfat
		update_health_hud()
		if(m_intent == MOVE_INTENT_RUN) //can't sprint at full fatigue
			toggle_rogmove_intent(MOVE_INTENT_WALK, TRUE)
		if(!emote_override)
			emote("fatigue", forced = force_emote)
		else
			emote(emote_override, forced = force_emote)
		blur_eyes(2)
		last_fatigued = world.time + 30 //extra time before fatigue regen sets in
		stop_attack()
		changeNext_move(CLICK_CD_EXHAUSTED)
		flash_fullscreen("blackflash")
		if(rogstam <= 0)
			addtimer(CALLBACK(src, .proc/Knockdown, 30), 10)
		addtimer(CALLBACK(src, .proc/Immobilize, 30), 10)
		if(iscarbon(src))
			var/mob/living/carbon/C = src
			if(C.stress >= 30)
				C.heart_attack()
			if(!HAS_TRAIT(C, TRAIT_NOHUNGER))
				if(C.nutrition <= 0)
					if(C.hydration <= 0)
						C.heart_attack()
		return FALSE
	else
		last_fatigued = world.time
		update_health_hud()
		return TRUE

/mob/living/carbon
	var/heart_attacking = FALSE

/mob/living/carbon/proc/heart_attack()
	if(HAS_TRAIT(src, TRAIT_NOFATSTAM))
		return
	if(!heart_attacking)
		heart_attacking = TRUE
		shake_camera(src, 1, 3)
		blur_eyes(10)
		var/stuffy = list("ZIZO GRABS MY WEARY HEART!","ARGH! MY HEART BEATS NO MORE!","NO... MY HEART HAS BEAT IT'S LAST!","MY HEART HAS GIVEN UP!","MY HEART BETRAYS ME!","THE METRONOME OF MY LIFE STILLS!")
		to_chat(src, "<span class='userdanger'>[pick(stuffy)]</span>")
		emote("breathgasp", forced = TRUE)
		addtimer(CALLBACK(src, .proc/adjustOxyLoss, 110), 30)

/mob/living/proc/freak_out()
	return

/mob/proc/do_freakout_scream()
	emote("scream", forced=TRUE)

/mob/living/carbon/freak_out()
	if(mob_timers["freakout"])
		if(world.time < mob_timers["freakout"] + 10 SECONDS)
			flash_fullscreen("stressflash")
			return
	mob_timers["freakout"] = world.time
	shake_camera(src, 1, 3)
	flash_fullscreen("stressflash")
	changeNext_move(CLICK_CD_EXHAUSTED)
	add_stress(/datum/stressevent/freakout)
	if(stress >= 30)
		heart_attack()
	else
		emote("fatigue", forced = TRUE)
		if(stress > 15)
			addtimer(CALLBACK(src, /mob/.proc/do_freakout_scream), rand(30,50))
	if(hud_used)
//		var/list/screens = list(hud_used.plane_masters["[OPENSPACE_BACKDROP_PLANE]"],hud_used.plane_masters["[BLACKNESS_PLANE]"],hud_used.plane_masters["[GAME_PLANE_UPPER]"],hud_used.plane_masters["[GAME_PLANE_FOV_HIDDEN]"], hud_used.plane_masters["[FLOOR_PLANE]"], hud_used.plane_masters["[GAME_PLANE]"], hud_used.plane_masters["[LIGHTING_PLANE]"])
		var/matrix/skew = matrix()
		skew.Scale(4)
		skew.Translate(-224,0)
		var/matrix/newmatrix = skew
		for(var/C in hud_used.plane_masters)
			var/obj/screen/plane_master/whole_screen = hud_used.plane_masters[C]
			if(whole_screen.plane == HUD_PLANE)
				continue
			animate(whole_screen, transform = newmatrix, time = 1, easing = QUAD_EASING)
			animate(transform = -newmatrix, time = 30, easing = QUAD_EASING)

/mob/living/proc/rogfat_reset()
	rogfat = 0
	last_fatigued = 0
	return
