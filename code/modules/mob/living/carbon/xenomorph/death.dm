
/mob/living/carbon/Xenomorph/death(gibbed)
	var/msg = isxenosilicon(src) ? "begins to shudder, and the lights go out in its eyes as it lies still." : "lets out a waning guttural screech, green blood bubbling from its maw."
	. = ..(gibbed,msg)
	if(!.) return //If they're already dead, it will return.

	GLOB.alive_xeno_list -= src
	GLOB.dead_xeno_list += src
	round_statistics.total_xeno_deaths++

	if(is_zoomed)
		zoom_out()

	SetLuminosity(0)

	if(!gibbed)
		if(hud_used && hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used && hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_empty"
		update_icons()

	for(var/atom/movable/A in stomach_contents)
		stomach_contents.Remove(A)
		A.forceMove(loc)

	var/datum/hive_status/hive = hive_datum[hivenumber]
	if(!istype(hive))
		return

	if(src in hive.xeno_leader_list)	//Strip them from the Xeno leader list, if they are indexed in here
		hive.xeno_leader_list -= src

	hud_set_queen_overwatch() //updates the overwatch hud to remove the upgrade chevrons, gold star, etc

	if(is_centcom_level(z))
		return


	if(hive.living_xeno_queen && hive.living_xeno_queen.observed_xeno == src)
		hive.living_xeno_queen.set_queen_overwatch(src, TRUE)
	if(queen_chosen_lead)
		queen_chosen_lead = FALSE
	if(isxenopredalien(src))
		playsound(loc, 'sound/voice/predalien_death.ogg', 75, 1)
	else
		playsound(loc, prob(50) == 1 ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)
	var/area/A = get_area(src)
	if(hive.living_xeno_queen)
		xeno_message("Hive: \The [src] has <b>died</b>[A? " at [sanitize(A.name)]":""]!", 3, hivenumber)



/mob/living/carbon/Xenomorph/Queen/death()
	. = ..()

	playsound(loc, 'sound/voice/alien_queen_died.ogg', 75, 0)
	if(observed_xeno)
		set_queen_overwatch(observed_xeno, TRUE)

	if(ovipositor)
		dismount_ovipositor(TRUE)

	var/datum/hive_status/hive = hive_datum[hivenumber]
	if(!istype(hive))
		return

	if(hive.living_xeno_queen != src)
		return

	xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... the Queen has been slain! Vengeance!</span>",3, hivenumber)
	xeno_message("<span class='xenoannounce'>The slashing of hosts is now permitted.</span>",2)
	hive.slashing_allowed = TRUE
	hive.living_xeno_queen = null
	//on the off chance there was somehow two queen alive
	for(var/mob/living/carbon/Xenomorph/Queen/Q in GLOB.alive_xeno_list)
		if(!isnull(Q) && Q != src && Q.stat != DEAD && Q.hivenumber == hivenumber)
			hive.living_xeno_queen = Q
			break

	for(var/mob/living/carbon/Xenomorph/L in hive.xeno_leader_list)
		L.handle_xeno_leader_pheromones(src)

	if(!isdistress(SSticker?.mode))
		return

	var/datum/game_mode/distress/D = SSticker.mode
	var/i = 0
	for(var/X in GLOB.alive_xeno_list)
		if(isxenolarva(X) || isxenodrone(X))
			i++
	if(i > 0)
		D.queen_death_countdown = world.time + QUEEN_DEATH_COUNTDOWN
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/check_queen_status, hive.queen_time), QUEEN_DEATH_COUNTDOWN)
	else
		D.queen_death_countdown = world.time + QUEEN_DEATH_NOLARVA
		addtimer(CALLBACK(SSticker.mode, /datum/game_mode.proc/check_queen_status, hive.queen_time), QUEEN_DEATH_NOLARVA)

	if(hivenumber != XENO_HIVE_NORMAL)
		return

	if(!D.stored_larva)
		return

	D.stored_larva = round(D.stored_larva * QUEEN_DEATH_LARVA_MULTIPLIER
	while(D.stored_larva > 0) // stil some left
		new /mob/living/carbon/Xenomorph/Larva(pick(GLOB.xeno_spawn))
		D.stored_larva--


/mob/living/carbon/Xenomorph/gib()

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	if(isxenoboiler(src))
		var/mob/living/carbon/Xenomorph/Boiler/B = src
		visible_message("<span class='danger'>[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!</span>")
		B.smoke.set_up(2, 0, get_turf(src))
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

/mob/living/carbon/Xenomorph/Hunter/gib()

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	remains.icon_state = "Hunter Gibs"

	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.

	return ..()


/mob/living/carbon/Xenomorph/gib_animation()
	var/to_flick = "gibbed-a"
	if(isxenorunner(src))
		to_flick = "gibbed-a-runner"
	else if(isxenolarva(src))
		to_flick = "larva_gib"
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, to_flick, icon)


/mob/living/carbon/Xenomorph/Hunter/gib_animation()
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, "Hunter Gibbed", icon)


/mob/living/carbon/Xenomorph/spawn_gibs()
	xgibs(get_turf(src))



/mob/living/carbon/Xenomorph/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-a")
