
/mob/living/carbon/xenomorph/proc/death_cry()
	playsound(loc, prob(50) == 1 ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)

/mob/living/carbon/xenomorph/death(gibbed)
	if(length(stomach_contents))
		empty_gut()
		visible_message("<span class='danger'>Something bursts out of [src]!</span>")

	var/msg = "lets out a waning guttural screech, green blood bubbling from its maw."
	. = ..(gibbed,msg)
	if(!.) return //If they're already dead, it will return.

	GLOB.alive_xeno_list -= src
	GLOB.dead_xeno_list += src
	hive?.on_xeno_death(src)

	if(is_zoomed)
		zoom_out()

	set_light(0)

	if(!gibbed)
		if(hud_used && hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used && hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_empty"
		update_icons()

	death_cry()

	xeno_death_alert()

	hud_set_queen_overwatch() //updates the overwatch hud to remove the upgrade chevrons, gold star, etc

	GLOB.round_statistics.total_xeno_deaths++

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

	..(1)

/mob/living/carbon/xenomorph/gib_animation()
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, xeno_caste.gib_flick, icon)

/mob/living/carbon/xenomorph/spawn_gibs()
	xgibs(get_turf(src))

/mob/living/carbon/xenomorph/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-a")
