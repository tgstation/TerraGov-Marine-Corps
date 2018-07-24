
/mob/living/carbon/Xenomorph/death(gibbed)
	var/msg = !is_robotic ? "lets out a waning guttural screech, green blood bubbling from its maw." : "begins to shudder, and the lights go out in its eyes as it lies still."
	. = ..(gibbed,msg)
	if(!.) return //If they're already dead, it will return.

	living_xeno_list -= src

	if(is_zoomed)
		zoom_out()

	SetLuminosity(0)

	if(!gibbed)
		if(hud_used && hud_used.healths)
			hud_used.healths.icon_state = "health_dead"
		if(hud_used && hud_used.alien_plasma_display)
			hud_used.alien_plasma_display.icon_state = "power_display_empty"
		update_icons()

	var/datum/hive_status/hive
	if(hivenumber && hivenumber <= hive_datum.len)
		hive = hive_datum[hivenumber]
	else return

	if(z != ADMIN_Z_LEVEL) //so xeno players don't get death messages from admin tests
		switch(caste)
			if("Queen")
				var/mob/living/carbon/Xenomorph/Queen/XQ = src
				playsound(loc, 'sound/voice/alien_queen_died.ogg', 75, 0)
				if(XQ.observed_xeno)
					XQ.set_queen_overwatch(XQ.observed_xeno, TRUE)
				if(XQ.ovipositor)
					XQ.dismount_ovipositor(TRUE)

				if(hivenumber == XENO_HIVE_NORMAL)
					if(ticker.mode.stored_larva)
						ticker.mode.stored_larva = round(ticker.mode.stored_larva * ((upgrade+1)/6.0)) // 83/66/50/33 for ancient/elite emp/elite queen/queen
						var/turf/larva_spawn
						while(ticker.mode.stored_larva > 0) // stil some left
							larva_spawn = pick(xeno_spawn)
							new /mob/living/carbon/Xenomorph/Larva(larva_spawn)
							ticker.mode.stored_larva--

				if(hive.living_xeno_queen == src)
					xeno_message("<span class='xenoannounce'>A sudden tremor ripples through the hive... the Queen has been slain! Vengeance!</span>",3, hivenumber)
					xeno_message("<span class='xenoannounce'>The slashing of hosts is now permitted.</span>",2)
					hive.slashing_allowed = 1
					hive.living_xeno_queen = null
					//on the off chance there was somehow two queen alive
					for(var/mob/living/carbon/Xenomorph/Queen/Q in living_mob_list)
						if(!isnull(Q) && Q != src && Q.stat != DEAD && Q.hivenumber == hivenumber)
							hive.living_xeno_queen = Q
							break
					for(var/mob/living/carbon/Xenomorph/L in hive.xeno_leader_list)
						L.handle_xeno_leader_pheromones(XQ)
					if(ticker && ticker.mode)
						ticker.mode.check_queen_status(hive.queen_time)
			else
				if(hive.living_xeno_queen && hive.living_xeno_queen.observed_xeno == src)
					hive.living_xeno_queen.set_queen_overwatch(src, TRUE)
				if(queen_chosen_lead)
					queen_chosen_lead = FALSE
				if(caste == "Predalien")
					playsound(loc, 'sound/voice/predalien_death.ogg', 75, 1)
				else
					playsound(loc, prob(50) == 1 ? 'sound/voice/alien_death.ogg' : 'sound/voice/alien_death2.ogg', 25, 1)
				var/area/A = get_area(src)
				if(hive.living_xeno_queen)
					xeno_message("Hive: \The [src] has <b>died</b>[A? " at [sanitize(A.name)]":""]!", 3, hivenumber)

	if(src in hive.xeno_leader_list)	//Strip them from the Xeno leader list, if they are indexed in here
		hive.xeno_leader_list -= src

	hud_set_queen_overwatch() //updates the overwatch hud to remove the upgrade chevrons, gold star, etc

	for(var/atom/movable/A in stomach_contents)
		stomach_contents.Remove(A)
		A.acid_damage = 0 //Reset the acid damage
		A.forceMove(loc)

	round_statistics.total_xeno_deaths++







/mob/living/carbon/Xenomorph/gib()

	var/obj/effect/decal/remains/xeno/remains = new(get_turf(src))
	remains.icon = icon
	remains.pixel_x = pixel_x //For 2x2.

	switch(caste) //This will need to be changed later, when we have proper xeno pathing. Might do it on caste or something.
		if("Boiler")
			var/mob/living/carbon/Xenomorph/Boiler/B = src
			visible_message("<span class='danger'>[src] begins to bulge grotesquely, and explodes in a cloud of corrosive gas!</span>")
			B.smoke.set_up(2, 0, get_turf(src))
			B.smoke.start()
			remains.icon_state = "gibbed-a-corpse"
		if("Runner")
			remains.icon_state = "gibbed-a-corpse-runner"
		if("Bloody Larva","Predalien Larva")
			remains.icon_state = "larva_gib_corpse"
		else
			remains.icon_state = "gibbed-a-corpse"

	check_blood_splash(35, BURN, 65, 2) //Some testing numbers. 35 burn, 65 chance.

	..(1)



/mob/living/carbon/Xenomorph/gib_animation()
	var/to_flick = "gibbed-a"
	switch(caste)
		if("Runner")
			to_flick = "gibbed-a-runner"
		if("Bloody Larva","Predalien Larva")
			to_flick = "larva_gib"
	new /obj/effect/overlay/temp/gib_animation/xeno(loc, src, to_flick, icon)

/mob/living/carbon/Xenomorph/spawn_gibs()
	xgibs(get_turf(src))



/mob/living/carbon/Xenomorph/dust_animation()
	new /obj/effect/overlay/temp/dust_animation(loc, src, "dust-a")
