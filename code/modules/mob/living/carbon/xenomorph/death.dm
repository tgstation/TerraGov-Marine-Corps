
/mob/living/carbon/xenomorph/proc/death_cry()
	playsound(loc, prob(50) ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)


/mob/living/carbon/xenomorph/death(gibbing, deathmessage = "lets out a waning guttural screech, green blood bubbling from its maw.", silent)
	if(stat == DEAD)
		return ..()
	return ..() //Just a different standard deathmessage


/mob/living/carbon/xenomorph/on_death()
	GLOB.alive_xeno_list -= src
	GLOB.dead_xeno_list += src

	hive?.on_xeno_death(src)
	hive.update_tier_limits() //Update our tier limits.

	if(is_zoomed)
		zoom_out()

	SSminimaps.remove_marker(src)
	set_light_on(FALSE)

	if(hud_used)
		if(hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used.staminas)
			hud_used.staminas.icon_state = "staminaloss200"
		if(hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_empty"
	update_icons()

	death_cry()

	xeno_death_alert()

	hud_set_queen_overwatch() //updates the overwatch hud to remove the upgrade chevrons, gold star, etc

	GLOB.round_statistics.total_xeno_deaths++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "total_xeno_deaths")

	switch (upgrade)
		if(XENO_UPGRADE_TWO)
			switch(tier)
				if(XENO_TIER_TWO)
					SSmonitor.stats.elder_T2--
				if(XENO_TIER_THREE)
					SSmonitor.stats.elder_T3--
				if(XENO_TIER_FOUR)
					SSmonitor.stats.elder_T4--
		if(XENO_UPGRADE_THREE, XENO_UPGRADE_FOUR)
			switch(tier)
				if(XENO_TIER_TWO)
					SSmonitor.stats.ancient_T2--
				if(XENO_TIER_THREE)
					SSmonitor.stats.ancient_T3--
				if(XENO_TIER_FOUR)
					SSmonitor.stats.ancient_T4--

	if(GetComponent(/datum/component/ai_controller))
		gib()

	eject_victim()

	to_chat(src,"<b>[span_deadsay("<p style='font-size:1.5em'><big>We have perished.</big><br><small>But it is not the end of us yet... wait until a newborn can rise in this world...</small></p>")]</b>")

	return ..()


/mob/living/carbon/xenomorph/proc/xeno_death_alert()
	if(is_centcom_level(z))
		return
	var/area/A = get_area(src)
	xeno_message("Hive: \The [src] has <b>died</b>[A? " at [A]":""]!", "xenoannounce", xeno_caste.caste_flags & CASTE_DO_NOT_ALERT_LOW_LIFE ? 2 : 5, hivenumber)

/mob/living/carbon/xenomorph/gib()

	var/atom/movable/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	SEND_SIGNAL(src, COMSIG_XENOMORPH_GIBBING)

	remains.icon_state = xeno_caste.gib_anim

	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.

	return ..()

/mob/living/carbon/xenomorph/gib_animation()
	new /atom/movable/effect/overlay/temp/gib_animation/xeno(loc, 0, src, xeno_caste.gib_flick, icon)

/mob/living/carbon/xenomorph/spawn_gibs()
	xgibs(get_turf(src))

/mob/living/carbon/xenomorph/dust_animation()
	new /atom/movable/effect/overlay/temp/dust_animation(loc, 0, src, "dust-a")
