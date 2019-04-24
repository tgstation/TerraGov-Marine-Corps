
/mob/living/carbon/Xenomorph/proc/death_cry()
	playsound(loc, prob(50) == 1 ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)

/mob/living/carbon/Xenomorph/death(gibbed)
	var/msg = "lets out a waning guttural screech, green blood bubbling from its maw."
	. = ..(gibbed,msg)
	if(!.) return //If they're already dead, it will return.

	GLOB.alive_xeno_list -= src
	GLOB.dead_xeno_list += src
	hive?.on_xeno_death(src)

	if(is_zoomed)
		zoom_out()

	SetLuminosity(0)

	if(!gibbed)
		if(hud_used && hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used && hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_empty"
		update_icons()

	death_cry()

	xeno_death_alert()

	hud_set_queen_overwatch() //updates the overwatch hud to remove the upgrade chevrons, gold star, etc

	for(var/atom/movable/A in stomach_contents)
		stomach_contents.Remove(A)
		A.forceMove(loc)

	round_statistics.total_xeno_deaths++

/mob/living/carbon/Xenomorph/proc/xeno_death_alert()
	if(is_centcom_level(z))
		return
	var/area/A = get_area(src)
	xeno_message("Hive: \The [src] has <b>died</b>[A? " at [sanitize(A.name)]":""]!", 3, hivenumber)

/mob/living/carbon/Xenomorph/gib()

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	if(isxenoboiler(src))
		var/mob/living/carbon/Xenomorph/Boiler/B = src
		visible_message("<span class='danger'>[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!</span>")
		B.smoke.set_up(2, get_turf(src))
		B.smoke.start()
		remains.icon_state = "gibbed-a-corpse"
	else if(isxenorunner(src))
		remains.icon_state = "gibbed-a-corpse-runner"
	else if(isxenolarva(src))
		remains.icon_state = "larva_gib_corpse"
	else
		remains.icon_state = "gibbed-a-corpse"

	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.

	..(1)

/mob/living/carbon/Xenomorph/gib_animation()
	var/to_flick = "gibbed-a"
	if(isxenorunner(src))
		to_flick = "gibbed-a-runner"
	else if(isxenolarva(src))
		to_flick = "larva_gib"
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, to_flick, icon)

/mob/living/carbon/Xenomorph/spawn_gibs()
	xgibs(get_turf(src))

/mob/living/carbon/Xenomorph/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-a")
