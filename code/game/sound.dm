
///Default override for echo
/sound
	echo = list(
		0, // Direct
		0, // DirectHF
		-10000, // Room, -10000 means no low frequency sound reverb
		-10000, // RoomHF, -10000 means no high frequency sound reverb
		0, // Obstruction
		0, // ObstructionLFRatio
		0, // Occlusion
		0.25, // OcclusionLFRatio
		1.5, // OcclusionRoomRatio
		1.0, // OcclusionDirectRatio
		0, // Exclusion
		1.0, // ExclusionLFRatio
		0, // OutsideVolumeHF
		0, // DopplerFactor
		0, // RolloffFactor
		0, // RoomRolloffFactor
		1.0, // AirAbsorptionFactor
		0, // Flags (1 = Auto Direct, 2 = Auto Room, 4 = Auto RoomHF)
	)
	// todo pls port tg style enviromental sound
	//environment = SOUND_ENVIRONMENT_NONE //Default to none so sounds without overrides dont get reverb
	environment = list(
		100.0, 0.5, \
		-250, -1000, 0, \
		1.5, 0.75, 1.0, \
		-2000, 0.01, \
		500, 0.015, \
		0.25, 0.1, \
		0.25, 0.1, \
		-10.0, \
		5000.0, 250.0, \
		1.0, 10.0, 10.0, 255, \
	)

/**Proc used to play a sound.
 * Arguments:
 * * source: what played the sound.
 * * soundin: the .ogg to use.
 * * vol: the initial volume of the sound, 0 is no sound at all, 75 is loud queen screech.
 * * vary: to make the frequency var of the sound vary (mostly unused).
 * * sound_range: the maximum theoretical range (in tiles) of the sound, by default is equal to the volume.
 * * falloff: how the sound's volume decreases with distance, low is fast decrease and high is slow decrease. \
A good representation is: 'byond applies a volume reduction to the sound every X tiles', where X is falloff.
 */
/proc/playsound(atom/source, soundin, vol, vary, sound_range, falloff, is_global, frequency, channel = 0)
	var/turf/turf_source = get_turf(source)

	if(!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

	if(!sound_range)
		sound_range = round(0.5*vol) //if no specific range, the max range is equal to half the volume.

	if(!frequency)
		frequency = GET_RANDOM_FREQ // Same frequency for everybody
	// Looping through the player list has the added bonus of working for mobs inside containers
	var/sound/S = sound(get_sfx(soundin))
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(!M.client)
			continue
		var/turf/T = get_turf(M)
		if(!T || T.z != turf_source.z || get_dist(M, turf_source) > sound_range)
			continue
		M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global, channel, S)

//todo rename S to sound_to_use
/mob/proc/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, is_global, channel = 0, sound/S, distance_multiplier = 1)
	if(!client)
		return FALSE

	if(!S)
		S = sound(get_sfx(soundin))
	S.wait = 0 //No queue
	S.channel = channel || SSsounds.random_available_channel()
	S.volume = vol

	if(vary)
		S.frequency = frequency ? frequency : GET_RANDOM_FREQ

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		distance *= distance_multiplier

		if(S.volume <= 2*distance)
			return FALSE //no volume or too far away to hear such a volume level.

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx * distance_multiplier
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz * distance_multiplier
		//The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = falloff ? falloff : FALLOFF_SOUNDS * max(round(S.volume * 0.05), 1)

	if(!is_global)
		S.environment = SOUND_ENVIRONMENT_ROOM

	SEND_SOUND(src, S)


/mob/living/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, is_global, channel = 0, sound/S, distance_multiplier = 1)
	if(ear_deaf > 0)
		return FALSE
	return ..()

/mob/proc/stop_sound_channel(chan)
	SEND_SOUND(src, sound(null, repeat = 0, wait = 0, channel = chan))

/mob/proc/set_sound_channel_volume(channel, volume)
	var/sound/S = sound(null, FALSE, FALSE, channel, volume)
	S.status = SOUND_UPDATE
	SEND_SOUND(src, S)

/client/proc/play_title_music(vol = 85)
	if(!SSticker?.login_music)
		return FALSE
	if(prefs && (prefs.toggles_sound & SOUND_LOBBY))
		SEND_SOUND(src, sound(SSticker.login_music, repeat = 0, wait = 0, volume = vol, channel = CHANNEL_LOBBYMUSIC)) // MAD JAMS


///Play sound for all online mobs on a given Z-level. Good for ambient sounds.
/proc/playsound_z(z, soundin, _volume)
	soundin = sound(get_sfx(soundin), channel = SSsounds.random_available_channel(), volume = _volume)
	for(var/mob/M AS in GLOB.player_list)
		if(isnewplayer(M))
			continue
		if (M.z == z)
			SEND_SOUND(M, soundin)

///Play a sound for all cliented humans and ghosts by zlevel
/proc/playsound_z_humans(z, soundin, _volume)
	soundin = sound(get_sfx(soundin), channel = SSsounds.random_available_channel(), volume = _volume)
	for(var/mob/living/carbon/human/H AS in GLOB.humans_by_zlevel["[z]"])
		if(H.client)
			SEND_SOUND(H, soundin)
	for(var/mob/dead/observer/O AS in SSmobs.dead_players_by_zlevel[z])
		if(O.client)
			SEND_SOUND(O, soundin)

///Play a sound for all cliented xenos and ghosts by hive on a zlevel
/proc/playsound_z_xenos(z, soundin, _volume, hive_type = XENO_HIVE_NORMAL)
	soundin = sound(get_sfx(soundin), channel = SSsounds.random_available_channel(), volume = _volume)
	for(var/mob/living/carbon/xenomorph/X AS in GLOB.hive_datums[hive_type].xenos_by_zlevel["[z]"])
		if(X.client)
			SEND_SOUND(X, soundin)
	for(var/mob/dead/observer/O AS in SSmobs.dead_players_by_zlevel[z])
		if(O.client)
			SEND_SOUND(O, soundin)

// The pick() proc has a built-in chance that can be added to any option by adding ,X; to the end of an option, where X is the % chance it will play.
/proc/get_sfx(S)
	if(!istext(S))
		return S
	switch(S)
		// General effects
		if("shatter")
			S = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
		if("explosion_large")
			S = pick('sound/effects/explosion_large1.ogg','sound/effects/explosion_large2.ogg','sound/effects/explosion_large3.ogg','sound/effects/explosion_large4.ogg','sound/effects/explosion_large5.ogg','sound/effects/explosion_large6.ogg')
		if("explosion_micro")
			S = pick('sound/effects/explosion_micro1.ogg','sound/effects/explosion_micro2.ogg','sound/effects/explosion_micro3.ogg')
		if("explosion_small")
			S = pick('sound/effects/explosion_small1.ogg','sound/effects/explosion_small2.ogg','sound/effects/explosion_small3.ogg','sound/effects/explosion_small4.ogg')
		if("explosion_med")
			S = pick('sound/effects/explosion_med1.ogg','sound/effects/explosion_med2.ogg','sound/effects/explosion_med3.ogg','sound/effects/explosion_med4.ogg','sound/effects/explosion_med5.ogg','sound/effects/explosion_med6.ogg')
		if("explosion_small_distant")
			S = pick('sound/effects/explosion_smallfar1.ogg','sound/effects/explosion_smallfar2.ogg','sound/effects/explosion_smallfar3.ogg','sound/effects/explosion_smallfar4.ogg')
		if("explosion_large_distant")
			S = pick('sound/effects/explosion_far1.ogg','sound/effects/explosion_far2.ogg','sound/effects/explosion_far3.ogg','sound/effects/explosion_far4.ogg','sound/effects/explosion_far5.ogg')
		if("explosion_creak")
			S = pick('sound/effects/creak1.ogg','sound/effects/creak2.ogg')
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
		if("gasbreath")
			S = pick('sound/effects/gasmaskbreath.ogg', 'sound/effects/gasmaskbreath2.ogg')
		if("terminal_type")
			S = pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg', \
				'sound/machines/terminal_button04.ogg', 'sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', \
				'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg')
		if("vending")
			S = pick('sound/machines/vending_cans.ogg', 'sound/machines/vending_drop.ogg')
		if("incendiary_explosion")
			S = pick('sound/effects/incendiary_explosion_1.ogg', 'sound/effects/incendiary_explosion_2.ogg', 'sound/effects/incendiary_explosion_3.ogg')
		if("molotov")
			S = pick('sound/effects/molotov_detonate_1.ogg', 'sound/effects/molotov_detonate_2.ogg', 'sound/effects/molotov_detonate_3.ogg')
		if("flashbang")
			S = pick('sound/effects/flashbang_explode_1.ogg', 'sound/effects/flashbang_explode_2.ogg')
		// Weapons/bullets
		if("ballistic_hit")
			S = pick('sound/bullets/bullet_impact1.ogg','sound/bullets/bullet_impact2.ogg','sound/bullets/bullet_impact3.ogg')
		if("ballistic hitmarker")
			S = pick('sound/bullets/bullet_impact4.ogg','sound/bullets/bullet_impact5.ogg','sound/bullets/bullet_impact6.ogg','sound/bullets/bullet_impact7.ogg')
		if("ballistic_armor")
			S = pick('sound/bullets/bullet_armor1.ogg','sound/bullets/bullet_armor2.ogg','sound/bullets/bullet_armor3.ogg','sound/bullets/bullet_armor4.ogg')
		if("ballistic_miss")
			S = pick('sound/bullets/bullet_miss1.ogg','sound/bullets/bullet_miss2.ogg','sound/bullets/bullet_miss3.ogg','sound/bullets/bullet_miss4.ogg')
		if("ballistic_bounce")
			S = pick('sound/bullets/bullet_ricochet1.ogg','sound/bullets/bullet_ricochet2.ogg','sound/bullets/bullet_ricochet3.ogg','sound/bullets/bullet_ricochet4.ogg','sound/bullets/bullet_ricochet5.ogg','sound/bullets/bullet_ricochet6.ogg','sound/bullets/bullet_ricochet7.ogg','sound/bullets/bullet_ricochet8.ogg')
		if("rocket_bounce")
			S = pick('sound/bullets/rocket_ricochet1.ogg','sound/bullets/rocket_ricochet2.ogg','sound/bullets/rocket_ricochet3.ogg')
		if("energy_hit")
			S = pick('sound/bullets/energy_impact1.ogg')
		if("alloy_hit")
			S = pick('sound/bullets/spear_impact1.ogg')
		if("alloy_armor")
			S = pick('sound/bullets/spear_armor1.ogg')
		if("alloy_bounce")
			S = pick('sound/bullets/spear_ricochet1.ogg','sound/bullets/spear_ricochet2.ogg')
		if("gun_silenced")
			S = pick('sound/weapons/guns/fire/silenced_shot1.ogg','sound/weapons/guns/fire/silenced_shot2.ogg')
		if("gun_smartgun")
			S = pick('sound/weapons/guns/fire/smartgun1.ogg', 'sound/weapons/guns/fire/smartgun2.ogg', 'sound/weapons/guns/fire/smartgun3.ogg')
		if("gun_flamethrower")
			S = pick('sound/weapons/guns/fire/flamethrower1.ogg', 'sound/weapons/guns/fire/flamethrower2.ogg', 'sound/weapons/guns/fire/flamethrower3.ogg')
		if("gun_ar12")
			S = pick('sound/weapons/guns/fire/tgmc/kinetic/gun_ar12_1.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_ar12_2.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_ar12_3.ogg')
		if("gun_fb12") // idk why i called it "fb-12", ah too late now
			S = pick('sound/weapons/guns/fire/tgmc/kinetic/gun_fb12_1.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_fb12_2.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_fb12_3.ogg')
		if("shotgun_som")
			S = pick('sound/weapons/guns/fire/v51_1.ogg','sound/weapons/guns/fire/v51_2.ogg','sound/weapons/guns/fire/v51_3.ogg','sound/weapons/guns/fire/v51_4.ogg')
		if("gun_pulse")
			S = pick('sound/weapons/guns/fire/m41a_1.ogg','sound/weapons/guns/fire/m41a_2.ogg','sound/weapons/guns/fire/m41a_3.ogg','sound/weapons/guns/fire/m41a_4.ogg','sound/weapons/guns/fire/m41a_5.ogg','sound/weapons/guns/fire/m41a_6.ogg')
		if("rpg_fire")
			S = pick('sound/weapons/guns/fire/rpg_1.ogg', 'sound/weapons/guns/fire/rpg_2.ogg', 'sound/weapons/guns/fire/rpg_3.ogg')
		if("ac_fire")
			S = pick('sound/weapons/guns/fire/autocannon_1.ogg', 'sound/weapons/guns/fire/autocannon_2.ogg', 'sound/weapons/guns/fire/autocannon_3.ogg')
		if("svd_fire")
			S = pick('sound/weapons/guns/fire/svd1.ogg', 'sound/weapons/guns/fire/svd2.ogg', 'sound/weapons/guns/fire/svd3.ogg')
		if("fal_fire")
			S = pick('sound/weapons/guns/fire/fal1.ogg', 'sound/weapons/guns/fire/fal2.ogg')
		if("mp38_fire")
			S = pick('sound/weapons/guns/fire/mp38_1.ogg', 'sound/weapons/guns/fire/mp38_2.ogg')

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
		if("alien_tail_attack")
			S = 'sound/weapons/alien_tail_attack.ogg'
		if("alien_footstep_large")
			S = pick('sound/effects/alien_footstep_large1.ogg','sound/effects/alien_footstep_large2.ogg','sound/effects/alien_footstep_large3.ogg')
		if("alien_charge")
			S = pick('sound/effects/alien_footstep_charge1.ogg','sound/effects/alien_footstep_charge2.ogg','sound/effects/alien_footstep_charge3.ogg')
		if("alien_resin_build")
			S = pick('sound/effects/alien_resin_build1.ogg','sound/effects/alien_resin_build2.ogg','sound/effects/alien_resin_build3.ogg')
		if("alien_resin_break")
			S = pick('sound/effects/alien_resin_break1.ogg','sound/effects/alien_resin_break2.ogg')
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
		if("alien_ventpass")
			S = pick('sound/effects/alien_ventpass1.ogg', 'sound/effects/alien_ventpass2.ogg')
		if("behemoth_step_sounds")
			S = pick('sound/effects/alien_footstep_large1.ogg', 'sound/effects/alien_footstep_large2.ogg', 'sound/effects/alien_footstep_large3.ogg')
		if("behemoth_rolling")
			S = 'sound/effects/behemoth/behemoth_roll.ogg'
		if("behemoth_earth_pillar_hit")
			S = pick('sound/effects/behemoth/earth_pillar_hit_1.ogg', 'sound/effects/behemoth/earth_pillar_hit_2.ogg', 'sound/effects/behemoth/earth_pillar_hit_3.ogg', 'sound/effects/behemoth/earth_pillar_hit_4.ogg', 'sound/effects/behemoth/earth_pillar_hit_5.ogg', 'sound/effects/behemoth/earth_pillar_hit_6.ogg')

		// Human
		if("male_scream")
			S = pick('sound/voice/human_male_scream_1.ogg','sound/voice/human_male_scream_2.ogg','sound/voice/human_male_scream_3.ogg','sound/voice/human_male_scream_4.ogg','sound/voice/human_male_scream_5.ogg','sound/voice/human_male_scream_6.ogg', 'sound/voice/human_male_scream_7.ogg')
		if("male_pain")
			S = pick('sound/voice/human_male_pain_1.ogg','sound/voice/human_male_pain_2.ogg','sound/voice/human_male_pain_3.ogg','sound/voice/human_male_pain_4.ogg','sound/voice/human_male_pain_5.ogg','sound/voice/human_male_pain_6.ogg','sound/voice/human_male_pain_7.ogg','sound/voice/human_male_pain_8.ogg', 'sound/voice/human_male_pain_9.ogg', 'sound/voice/human_male_pain_10.ogg', 'sound/voice/human_male_pain_11.ogg')
		if("male_gored")
			S = pick('sound/voice/human_male_gored_1.ogg','sound/voice/human_male_gored_2.ogg', 'sound/voice/human_male_gored3.ogg')
		if("male_fragout")
			S = pick('sound/voice/human_male_grenadethrow_1.ogg', 'sound/voice/human_male_grenadethrow_2.ogg', 'sound/voice/human_male_grenadethrow_3.ogg')
		if("male_warcry")
			S = pick('sound/voice/human_male_warcry_1.ogg','sound/voice/human_male_warcry_2.ogg','sound/voice/human_male_warcry_3.ogg','sound/voice/human_male_warcry_4.ogg','sound/voice/human_male_warcry_5.ogg','sound/voice/human_male_warcry_6.ogg','sound/voice/human_male_warcry_7.ogg','sound/voice/human_male_warcry_8.ogg','sound/voice/human_male_warcry_9.ogg','sound/voice/human_male_warcry_10.ogg','sound/voice/human_male_warcry_11.ogg','sound/voice/human_male_warcry_12.ogg','sound/voice/human_male_warcry_13.ogg','sound/voice/human_male_warcry_14.ogg','sound/voice/human_male_warcry_15.ogg','sound/voice/human_male_warcry_16.ogg','sound/voice/human_male_warcry_17.ogg','sound/voice/human_male_warcry_18.ogg','sound/voice/human_male_warcry_19.ogg','sound/voice/human_male_warcry_20.ogg','sound/voice/human_male_warcry_21.ogg','sound/voice/human_male_warcry_22.ogg','sound/voice/human_male_warcry_23.ogg','sound/voice/human_male_warcry_24.ogg','sound/voice/human_male_warcry_25.ogg','sound/voice/human_male_warcry_26.ogg','sound/voice/human_male_warcry_27.ogg','sound/voice/human_male_warcry_28.ogg','sound/voice/human_male_warcry_29.ogg')
		if("female_scream")
			S = pick('sound/voice/human_female_scream_1.ogg','sound/voice/human_female_scream_2.ogg','sound/voice/human_female_scream_3.ogg','sound/voice/human_female_scream_4.ogg','sound/voice/human_female_scream_5.ogg')
		if("female_pain")
			S = pick('sound/voice/human_female_pain_1.ogg','sound/voice/human_female_pain_2.ogg','sound/voice/human_female_pain_3.ogg')
		if("female_gored")
			S = pick('sound/voice/human_female_gored_1.ogg','sound/voice/human_female_gored_2.ogg')
		if("female_fragout")
			S = pick("sound/voice/human_female_grenadethrow_1.ogg", 'sound/voice/human_female_grenadethrow_2.ogg', 'sound/voice/human_female_grenadethrow_3.ogg')
		if("female_warcry")
			S = pick('sound/voice/human_female_warcry_1.ogg','sound/voice/human_female_warcry_2.ogg','sound/voice/human_female_warcry_3.ogg','sound/voice/human_female_warcry_4.ogg','sound/voice/human_female_warcry_5.ogg','sound/voice/human_female_warcry_6.ogg','sound/voice/human_female_warcry_7.ogg','sound/voice/human_female_warcry_8.ogg','sound/voice/human_female_warcry_9.ogg','sound/voice/human_female_warcry_10.ogg','sound/voice/human_female_warcry_11.ogg','sound/voice/human_female_warcry_12.ogg','sound/voice/human_female_warcry_13.ogg','sound/voice/human_female_warcry_14.ogg','sound/voice/human_female_warcry_15.ogg','sound/voice/human_female_warcry_16.ogg','sound/voice/human_female_warcry_17.ogg','sound/voice/human_female_warcry_18.ogg','sound/voice/human_female_warcry_19.ogg')
		if("male_hugged")
			S = pick("sound/voice/human_male_facehugged1.ogg", 'sound/voice/human_male_facehugged2.ogg', 'sound/voice/human_male_facehugged3.ogg')
		if("female_hugged")
			S = pick("sound/voice/human_female_facehugged1.ogg", 'sound/voice/human_female_facehugged2.ogg')
		if("male_gasp")
			S = pick("sound/voice/human_male_gasp1.ogg", 'sound/voice/human_male_gasp2.ogg', 'sound/voice/human_male_gasp3.ogg')
		if("female_gasp")
			S = pick("sound/voice/human_female_gasp1.ogg", 'sound/voice/human_female_gasp2.ogg')
		if("male_cough")
			S = pick("sound/voice/human_male_cough1.ogg", 'sound/voice/human_male_cough2.ogg')
		if("female_cough")
			S = pick("sound/voice/human_female_cough1.ogg", 'sound/voice/human_female_cough2.ogg')
		if("male_preburst")
			S = pick("sound/voice/human_male_preburst1.ogg", 'sound/voice/human_male_preburst2.ogg', 'sound/voice/human_male_preburst3.ogg', 'sound/voice/human_male_preburst4.ogg', 'sound/voice/human_male_preburst5.ogg', 'sound/voice/human_male_preburst6.ogg', 'sound/voice/human_male_preburst7.ogg', 'sound/voice/human_male_preburst8.ogg', 'sound/voice/human_male_preburst9.ogg', 'sound/voice/human_male_preburst10.ogg')
		if("female_preburst")
			S = pick("sound/voice/human_female_preburst1.ogg", 'sound/voice/human_female_preburst2.ogg', 'sound/voice/human_female_preburst3.ogg')
		if("jump")
			S = pick('sound/effects/bounce_1.ogg','sound/effects/bounce_2.ogg','sound/effects/bounce_3.ogg','sound/effects/bounce_4.ogg')

		//robot race
		if("robot_scream")
			S = pick('sound/voice/robot/robot_scream1.ogg', 'sound/voice/robot/robot_scream2.ogg', 'sound/voice/robot/robot_scream2.ogg')
		if("robot_pain")
			S = pick('sound/voice/robot/robot_pain1.ogg', 'sound/voice/robot/robot_pain2.ogg', 'sound/voice/robot/robot_pain3.ogg')
		if("robot_warcry")
			S = pick('sound/voice/robot/robot_warcry1.ogg', 'sound/voice/robot/robot_warcry2.ogg', 'sound/voice/robot/robot_warcry3.ogg')
	return S
