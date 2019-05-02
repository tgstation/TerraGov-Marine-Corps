//Proc used to play a sound.
//source: self-explanatory.
//input: the .ogg to use.
//vol: the initial volume of the sound, 0 is no sound at all, 75 is loud queen screech.
//vary: to make the frequency var of the sound vary (mostly unused).
//extrarange: the maximum theoretical range (in tiles) of the sound, by default is equal to the world.view.
//falloff: how the sound's volume decreases with distance, low is fast decrease and high is slow decrease.
//channel: byond channel to play the sound on
//pressure_affected: if the sound is affected by pressure
//ignore_walls: is the sound blocked by opacue tiles.
//do_owner: a custom datum object for the sounds to pull from
//A good representation is: 'byond applies a volume reduction to the sound every X tiles', where X is falloff.


/proc/playsound(atom/source, input, vol as num, vary, extrarange as num, falloff, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE, do_owner)
	if(isarea(source))
		CRASH("playsound(): source is an area")
		return

	var/turf/turf_source = get_turf(source)

	if (!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || open_sound_channel()

 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/maxdistance = (world.view + extrarange)
	var/z = turf_source.z
	var/list/listeners = SSmobs.clients_by_zlevel[z]
	if(!ignore_walls) //these sounds don't carry through walls
		listeners = listeners & hearers(maxdistance, turf_source)

	for(var/P in listeners)
		var/mob/M = P
		
		if(get_dist(M, turf_source) <= maxdistance)
			sound_or_datum(M, turf_source, source, input, do_owner, vol, vary, frequency, falloff, channel, pressure_affected)
	
	for(var/P in SSmobs.dead_players_by_zlevel[z])
		var/mob/M = P
		if(get_dist(M, turf_source) <= maxdistance)
			sound_or_datum(M, turf_source, source, input, do_owner, vol, vary, frequency, falloff, channel, pressure_affected)
			
/proc/sound_or_datum(mob/receiver, turf/turf_source, atom/source, input, datum/do_owner, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE)
	if(istype(input, /datum/outputs))
		var/last_played_time
		if(do_owner)
			last_played_time = do_owner.datum_outputs[input]
		else
			last_played_time = source.datum_outputs[input]
		var/datum/outputs/O = input
		if(O.send_info(receiver, turf_source, vol, vary, frequency, falloff, channel, pressure_affected, last_played_time))
			if(do_owner)
				do_owner.datum_outputs[input] = world.time
			else
				source.datum_outputs[input] = world.time
	else
		var/sound/S = sound(get_sfx(input))
		receiver.playsound_local(turf_source, input, vol, vary, frequency, falloff, channel, pressure_affected, S)

//kept for legacy support and uploaded admin sounds
/mob/proc/playsound_local(turf/turf_source, soundin, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE, sound/S)
	if(!client || !can_hear())
		return

	if(!S)
		S = sound(get_sfx(soundin))

	S.wait = 0 //No queue
	S.channel = channel || open_sound_channel()
	S.volume = vol

	if(vary)
		if(frequency)
			S.frequency = frequency
		else
			S.frequency = GET_RANDOM_FREQ

	if(isturf(turf_source))
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		S.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

		if(pressure_affected)
			//Atmosphere affects sound
			var/pressure_factor = 1
			var/hearer_pressure = T.return_pressure()
			var/source_pressure = turf_source.return_pressure()

			if(hearer_pressure && source_pressure)
				var/pressure = min(hearer_pressure, source_pressure)
				if(pressure < ONE_ATMOSPHERE)
					pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
			else //space
				pressure_factor = 0

			if(distance <= 1)
				pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

			S.volume *= pressure_factor
			//End Atmosphere affecting sound

		if(S.volume <= 0)
			return //No sound

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		// The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	SEND_SOUND(src, S)

/proc/sound_to_playing_players(soundin, volume = 100, vary = FALSE, frequency = 0, falloff = FALSE, channel = 0, pressure_affected = FALSE, sound/S)
	if(!S)
		S = sound(get_sfx(soundin))
	for(var/m in GLOB.player_list)
		if(ismob(m) && !isnewplayer(m))
			var/mob/M = m
			M.playsound_local(M, null, volume, vary, frequency, falloff, channel, pressure_affected, S)

/proc/open_sound_channel()
	var/static/next_channel = 1	//loop through the available 1024 - (the ones we reserve) channels and pray that its not still being used
	. = ++next_channel
	if(next_channel > CHANNEL_HIGHEST_AVAILABLE)
		next_channel = 1

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/client/proc/playtitlemusic()
	if(!SSticker?.login_music)	return FALSE
	if(prefs.toggles_sound & SOUND_LOBBY)
		src << sound(SSticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS


/proc/playsound_z(atom/z, soundin, volume) // Play sound for all online mobs on a given Z-level. Good for ambient sounds.
	soundin = get_sfx(soundin)

	for(var/mob/M in GLOB.player_list)
		if (M.z)
			M << sound(soundin, volume)


// The pick() proc has a built-in chance that can be added to any option by adding ,X; to the end of an option, where X is the % chance it will play.
/proc/get_sfx(S)
	if(istext(S))
		switch(S)
			// General effects
			if("shatter")
				S = pick('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
			if("explosion")
				S = pick('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg')
			if("sparks")
				S = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
			if("rustle")
				S = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
			if("punch")
				S = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
			if("clownstep")
				S = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
			if("swing_hit")
				S = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
			if("pageturn")
				S = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
			// Weapons/bullets
			if("ballistic_hit")
				S = pick('sound/bullets/bullet_impact1.ogg','sound/bullets/bullet_impact2.ogg','sound/bullets/bullet_impact1.ogg')
			if("ballistic_armor")
				S = pick('sound/bullets/bullet_armor1.ogg','sound/bullets/bullet_armor2.ogg','sound/bullets/bullet_armor3.ogg','sound/bullets/bullet_armor4.ogg')
			if("ballistic_miss")
				S = pick('sound/bullets/bullet_miss1.ogg','sound/bullets/bullet_miss2.ogg','sound/bullets/bullet_miss3.ogg','sound/bullets/bullet_miss3.ogg')
			if("ballistic_bounce")
				S = pick('sound/bullets/bullet_ricochet1.ogg','sound/bullets/bullet_ricochet2.ogg','sound/bullets/bullet_ricochet3.ogg','sound/bullets/bullet_ricochet4.ogg','sound/bullets/bullet_ricochet5.ogg','sound/bullets/bullet_ricochet6.ogg','sound/bullets/bullet_ricochet7.ogg','sound/bullets/bullet_ricochet8.ogg')
			if("rocket_bounce")
				S = pick('sound/bullets/rocket_ricochet1.ogg','sound/bullets/rocket_ricochet2.ogg','sound/bullets/rocket_ricochet3.ogg')
			if("energy_hit")
				S = pick('sound/bullets/energy_impact1.ogg')
			if("energy_miss")
				S = pick('sound/bullets/energy_miss1.ogg')
			if("energy_bounce")
				S = pick('sound/bullets/energy_ricochet1.ogg')
			if("alloy_hit")
				S = pick('sound/bullets/spear_impact1.ogg')
			if("alloy_armor")
				S = pick('sound/bullets/spear_armor1.ogg')
			if("alloy_bounce")
				S = pick('sound/bullets/spear_ricochet1.ogg','sound/bullets/spear_ricochet2.ogg')
			if("gun_silenced")
				S = pick('sound/weapons/gun_silenced_shot1.ogg','sound/weapons/gun_silenced_shot2.ogg')
			if("gun_pulse")
				S = pick('sound/weapons/gun_m41a_1.ogg','sound/weapons/gun_m41a_2.ogg','sound/weapons/gun_m41a_3.ogg','sound/weapons/gun_m41a_4.ogg','sound/weapons/gun_m41a_5.ogg','sound/weapons/gun_m41a_6.ogg')
			if("gun_smartgun")
				S = pick('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')
			// Xeno
			if("acid_hit")
				S = pick('sound/bullets/acid_impact1.ogg')
			if("acid_bounce")
				S = pick('sound/bullets/acid_impact1.ogg')
			if("alien_claw_flesh")
				S = pick('sound/weapons/alien_claw_flesh1.ogg','sound/weapons/alien_claw_flesh2.ogg','sound/weapons/alien_claw_flesh3.ogg')
			if("alien_claw_metal")
				S = pick('sound/weapons/alien_claw_metal1.ogg','sound/weapons/alien_claw_metal2.ogg','sound/weapons/alien_claw_metal3.ogg')
			if("alien_bite")
				S = pick('sound/weapons/alien_bite1.ogg','sound/weapons/alien_bite2.ogg')
			if("alien_footstep_large")
				S = pick('sound/effects/alien_footstep_large1.ogg','sound/effects/alien_footstep_large2.ogg','sound/effects/alien_footstep_large3.ogg')
			if("alien_charge")
				S = pick('sound/effects/alien_footstep_charge1.ogg','sound/effects/alien_footstep_charge2.ogg','sound/effects/alien_footstep_charge3.ogg')
			if("alien_resin_build")
				S = pick('sound/effects/alien_resin_build1.ogg','sound/effects/alien_resin_build2.ogg','sound/effects/alien_resin_build3.ogg')
			if("alien_resin_break")
				S = pick('sound/effects/alien_resin_break1.ogg','sound/effects/alien_resin_break2.ogg','sound/effects/alien_resin_break3.ogg')
			if("alien_resin_move")
				S = pick('sound/effects/alien_resin_move1.ogg','sound/effects/alien_resin_move2.ogg')
			if("alien_talk")
				S = pick('sound/voice/alien_talk.ogg','sound/voice/alien_talk2.ogg','sound/voice/alien_talk3.ogg')
			if("alien_growl")
				S = pick('sound/voice/alien_growl1.ogg','sound/voice/alien_growl2.ogg','sound/voice/alien_growl3.ogg','sound/voice/alien_growl4.ogg')
			if("alien_hiss")
				S = pick('sound/voice/alien_hiss1.ogg','sound/voice/alien_hiss2.ogg','sound/voice/alien_hiss3.ogg')
			if("alien_tail_swipe")
				S = pick('sound/effects/alien_tail_swipe1.ogg','sound/effects/alien_tail_swipe2.ogg','sound/effects/alien_tail_swipe3.ogg')
			if("alien_help")
				S = pick('sound/voice/alien_help1.ogg','sound/voice/alien_help2.ogg')
			if("alien_drool")
				S = pick('sound/voice/alien_drool1.ogg','sound/voice/alien_drool2.ogg')
			if("alien_roar")
				S = pick('sound/voice/alien_roar1.ogg','sound/voice/alien_roar2.ogg','sound/voice/alien_roar3.ogg','sound/voice/alien_roar4.ogg','sound/voice/alien_roar5.ogg','sound/voice/alien_roar6.ogg','sound/voice/alien_roar7.ogg','sound/voice/alien_roar8.ogg','sound/voice/alien_roar9.ogg','sound/voice/alien_roar10.ogg','sound/voice/alien_roar11.ogg','sound/voice/alien_roar12.ogg')
			if("alien_roar_larva")
				S = pick('sound/voice/alien_roar_larva1.ogg','sound/voice/alien_roar_larva2.ogg','sound/voice/alien_roar_larva3.ogg','sound/voice/alien_roar_larva4.ogg')
			if("queen")
				S = pick('sound/voice/alien_queen_command.ogg','sound/voice/alien_queen_command2.ogg','sound/voice/alien_queen_command3.ogg')
			// Human
			if("male_scream")
				S = pick('sound/voice/human_male_scream_1.ogg','sound/voice/human_male_scream_2.ogg','sound/voice/human_male_scream_3.ogg','sound/voice/human_male_scream_4.ogg','sound/voice/human_male_scream_5.ogg','sound/voice/human_male_scream_6.ogg',5;'sound/voice/human_male_scream_joke1.ogg',5;'sound/voice/human_male_scream_joke2.ogg',5;'sound/voice/human_male_scream_joke3.ogg',5;'sound/voice/human_male_scream_joke4.ogg')
			if("male_pain")
				S = pick('sound/voice/human_male_pain_1.ogg','sound/voice/human_male_pain_2.ogg','sound/voice/human_male_pain_3.ogg','sound/voice/human_male_pain_4.ogg','sound/voice/human_male_pain_5.ogg','sound/voice/human_male_pain_6.ogg','sound/voice/human_male_pain_7.ogg','sound/voice/human_male_pain_8.ogg',5;'sound/voice/human_male_pain_joke1.ogg',5;'sound/voice/human_male_pain_joke2.ogg')
			if("male_fragout")
				S = pick('sound/voice/human_male_grenadethrow_1.ogg', 'sound/voice/human_male_grenadethrow_2.ogg', 'sound/voice/human_male_grenadethrow_3.ogg')
			if("female_scream")
				S = pick('sound/voice/human_female_scream_1.ogg','sound/voice/human_female_scream_2.ogg','sound/voice/human_female_scream_3.ogg','sound/voice/human_female_scream_4.ogg',5;'sound/voice/human_female_scream_5.ogg')
			if("female_pain")
				S = pick('sound/voice/human_female_pain_1.ogg','sound/voice/human_female_pain_2.ogg','sound/voice/human_female_pain_3.ogg')
			if("female_fragout")
				S = pick("sound/voice/human_female_grenadethrow_1.ogg", 'sound/voice/human_female_grenadethrow_2.ogg', 'sound/voice/human_female_grenadethrow_3.ogg')

	return S
