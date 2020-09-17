
/mob/living/carbon/xenomorph/proc/death_cry()
	playsound(loc, prob(50) == TRUE ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)


/mob/living/carbon/xenomorph/death(gibbing, deathmessage = "lets out a waning guttural screech, green blood bubbling from its maw.", silent)
	if(stat == DEAD)
		return ..()
	return ..() //Just a different standard deathmessage


/mob/living/carbon/xenomorph/on_death()
	GLOB.alive_xeno_list -= src
	GLOB.dead_xeno_list += src
	hive?.on_xeno_death(src)

	if(LAZYLEN(stomach_contents))
		empty_gut()
		visible_message("<span class='danger'>Something bursts out of [src]!</span>")

	if(is_zoomed)
		zoom_out()

	set_light(0)

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

	var/isAI = GetComponent(/datum/component/ai_controller)
	if (isAI)
		gib()

	return ..()


/mob/living/carbon/xenomorph/proc/xeno_death_alert()
	if(is_centcom_level(z))
		return
	var/area/A = get_area(src)
	xeno_message("Hive: \The [src] has <b>died</b>[A? " at [sanitize(A.name)]":""]!", 3, hivenumber)

/mob/living/carbon/xenomorph/gib()

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	SEND_SIGNAL(src, COMSIG_XENOMORPH_GIBBING)

	remains.icon_state = xeno_caste.gib_anim

	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.

	return ..()

/mob/living/carbon/xenomorph/gib_animation()
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, xeno_caste.gib_flick, icon)

/mob/living/carbon/xenomorph/spawn_gibs()
	xgibs(get_turf(src))

/mob/living/carbon/xenomorph/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-a")
