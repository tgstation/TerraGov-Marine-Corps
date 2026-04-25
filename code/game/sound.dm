
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

/**
 * Proc used to play a sound.
 *
 * Arguments:
 * * source: what played the sound.
 * * soundin: the .ogg to use.
 * * vol: the initial volume of the sound, 0 is no sound at all, 75 is loud queen screech.
 * * vary: to make the frequency var of the sound vary (mostly unused).
 * * sound_range: the maximum theoretical range (in tiles) of the sound, by default is equal to the volume.
 * * falloff: how the sound's volume decreases with distance, low is fast decrease and high is slow decrease. \
A good representation is: 'byond applies a volume reduction to the sound every X tiles', where X is falloff.
 */
/proc/playsound(atom/source, soundin, vol, vary, sound_range, falloff, is_global, frequency, channel = 0, ambient_sound = FALSE, ignore_walls = TRUE)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	if(islist(soundin))
		CRASH("playsound(): soundin attempted to pass a list! Consider using pick()")

	if(!soundin)
		CRASH("playsound(): no soundin passed")

	if(vol < SOUND_AUDIBLE_VOLUME_MIN) // never let sound go below SOUND_AUDIBLE_VOLUME_MIN or bad things will happen
		CRASH("playsound(): volume below SOUND_AUDIBLE_VOLUME_MIN. [vol] < [SOUND_AUDIBLE_VOLUME_MIN]")

	var/turf/turf_source = get_turf(source)

	if (!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

	if(!sound_range)
		sound_range = round(0.5*vol) //if no specific range, the max range is equal to half the volume.

	if(!frequency)
		frequency = GET_RANDOM_FREQ
	var/sound/S = isdatum(soundin) ? soundin : sound(get_sfx(soundin))
	var/source_z = turf_source.z

	var/list/listeners

	var/turf/above_turf = GET_TURF_ABOVE(turf_source)
	var/turf/below_turf = GET_TURF_BELOW(turf_source)

	// todo replace me with CALCULATE_MAX_SOUND_AUDIBLE_DISTANCE from tg so we dont have massive ass ranges fnr
	var/audible_distance = sound_range

	if(ignore_walls)
		listeners = get_hearers_in_range(audible_distance, turf_source, RECURSIVE_CONTENTS_CLIENT_MOBS)
		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_range(audible_distance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_range(audible_distance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

	else //these sounds don't carry through walls
		listeners = get_hearers_in_view(audible_distance, turf_source, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(above_turf && istransparentturf(above_turf))
			listeners += get_hearers_in_view(audible_distance, above_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)

		if(below_turf && istransparentturf(turf_source))
			listeners += get_hearers_in_view(audible_distance, below_turf, RECURSIVE_CONTENTS_CLIENT_MOBS)
		for(var/mob/listening_ghost as anything in SSmobs.dead_players_by_zlevel[source_z])
			if(get_dist(listening_ghost, turf_source) <= audible_distance)
				listeners += listening_ghost

	// snowflake, ai eyes dont have a client
	// this also ignores walls cus I cant be assed rn
	for(var/mob/ai_eye AS in GLOB.aiEyes)
		var/turf/eye_turf = get_turf(ai_eye)
		if(!eye_turf || eye_turf.z != turf_source.z)
			continue
		if(get_dist(eye_turf, turf_source) <= audible_distance)
			listeners += ai_eye


	for(var/mob/listener AS in listeners)
		if(ambient_sound && !(listener.client?.prefs?.toggles_sound & SOUND_AMBIENCE))
			continue
		listener.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global, channel, S)

	//We do tanks separately, since they are not actually on the source z, and we need some other stuff to get accurate directional sound
	//todo stop ignoring walls
	for(var/obj/vehicle/sealed/armored/armor AS in GLOB.tank_list)
		var/is_same_z = (armor.z == source_z) || (armor.z == above_turf?.z) || (armor.z == below_turf?.z)
		if(!armor.interior || !is_same_z || get_dist(armor.loc, turf_source) > sound_range)
			continue
		// sounds vehicles with interiors make must be played inside the tank, see /obj/vehicle/sealed/armored/proc/play_interior_sound(...)
		if(armor == source)
			continue
		if(!length(armor.interior.occupants))
			continue
		listeners += armor.interior.play_outside_sound(
			turf_source,
			soundin,
			vol*0.5,
			vary,
			frequency,
			falloff,
			is_global,
			channel,
			ambient_sound,
			S
		)

	return listeners

/**
 * Plays a sound locally
 *
 * Arguments:
 * * turf_source - The turf our sound originates from
 * * soundin - the .ogg or SFX of our sound
 * * vol - Changes the volume of our sound, relevant when measuring falloff
 * * vary - to make the frequency var of the sound vary (mostly unused).
 * * frequency - Optional: if vary is set, this is how much we vary by (or a random amount if not given any value)
 * * falloff - Optional: Calculates falloff if not passed a value
 * * is_global - if false, sets our environment to SOUND_ENVIRONMENT_ROOM
 * * channel - Optional: Picks a random available channel if not set
 * * sound_to_use - Optional: Will default to soundin
 * * distance_multiplier - Affects x and z hearing
 */
/mob/proc/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, is_global, channel = 0, sound/sound_to_use, distance_multiplier = 1)
	if(!client)
		return FALSE

	if(!sound_to_use)
		sound_to_use = sound(get_sfx(soundin))
	sound_to_use.wait = 0 //No queue
	sound_to_use.channel = channel || SSsounds.random_available_channel()
	sound_to_use.volume = vol

	if(vary)
		sound_to_use.frequency = frequency ? frequency : GET_RANDOM_FREQ

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/turf_loc = get_turf(src)

		if(sound_to_use.volume < SOUND_AUDIBLE_VOLUME_MIN)
			return //Too quiet to be audible

		var/dx = turf_source.x - turf_loc.x // Hearing from the right/left
		sound_to_use.x = dx * distance_multiplier
		var/dz = turf_source.y - turf_loc.y // Hearing from infront/behind
		sound_to_use.z = dz * distance_multiplier
		//The y value is for above your head, but there is no ceiling in 2d spessmens.
		sound_to_use.y = 1
		sound_to_use.falloff = falloff ? falloff : FALLOFF_SOUNDS * max(round(sound_to_use.volume * 0.05), 1)

	if(!is_global)
		sound_to_use.environment = SOUND_ENVIRONMENT_ROOM

	SEND_SOUND(src, sound_to_use)

/mob/living/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff, is_global, channel = 0, sound/sound_to_use, distance_multiplier = 1)
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

///Used to convert a SFX define into a .ogg so we can add some variance to sounds. If soundin is already a .ogg, we simply return it
/proc/get_sfx(soundin)
	if(!istext(soundin))
		return soundin
	switch(soundin)
		// General effects
		if(SFX_SHATTER)
			soundin = pick('sound/effects/glassbr1.ogg','sound/effects/glassbr2.ogg','sound/effects/glassbr3.ogg')
		if(SFX_EXPLOSION_LARGE)
			soundin = pick('sound/effects/explosion/large1.ogg','sound/effects/explosion/large2.ogg','sound/effects/explosion/large3.ogg','sound/effects/explosion/large4.ogg','sound/effects/explosion/large5.ogg','sound/effects/explosion/large6.ogg')
		if(SFX_EXPLOSION_MICRO)
			soundin = pick('sound/effects/explosion/micro1.ogg','sound/effects/explosion/micro2.ogg','sound/effects/explosion/micro3.ogg')
		if(SFX_EXPLOSION_SMALL)
			soundin = pick('sound/effects/explosion/small1.ogg','sound/effects/explosion/small2.ogg','sound/effects/explosion/small3.ogg','sound/effects/explosion/small4.ogg')
		if(SFX_EXPLOSION_MED)
			soundin = pick('sound/effects/explosion/medium1.ogg','sound/effects/explosion/medium2.ogg','sound/effects/explosion/medium3.ogg','sound/effects/explosion/medium4.ogg','sound/effects/explosion/medium5.ogg','sound/effects/explosion/medium6.ogg')
		if(SFX_EXPLOSION_SMALL_DISTANT)
			soundin = pick('sound/effects/explosion/small_far1.ogg','sound/effects/explosion/small_far2.ogg','sound/effects/explosion/small_far3.ogg','sound/effects/explosion/small_far4.ogg')
		if(SFX_EXPLOSION_LARGE_DISTANT)
			soundin = pick('sound/effects/explosion/far1.ogg','sound/effects/explosion/far2.ogg','sound/effects/explosion/far3.ogg','sound/effects/explosion/far4.ogg','sound/effects/explosion/far5.ogg')
		if(SFX_EXPLOSION_CREAK)
			soundin = pick('sound/effects/creak1.ogg','sound/effects/creak2.ogg')
		if(SFX_SPARKS)
			soundin = pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
		if(SFX_RUSTLE)
			soundin = pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
		if(SFX_PUNCH)
			soundin = pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
		if(SFX_CLOWNSTEP)
			soundin = pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
		if(SFX_SWING_HIT)
			soundin = pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
		if(SFX_PAGE_TURN)
			soundin = pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
		if(SFX_GASBREATH)
			soundin = pick('sound/effects/gasmaskbreath.ogg', 'sound/effects/gasmaskbreath2.ogg')
		if(SFX_TERMINAL_TYPE)
			soundin = pick('sound/machines/terminal_button01.ogg', 'sound/machines/terminal_button02.ogg', 'sound/machines/terminal_button03.ogg', \
				'sound/machines/terminal_button04.ogg', 'sound/machines/terminal_button05.ogg', 'sound/machines/terminal_button06.ogg', \
				'sound/machines/terminal_button07.ogg', 'sound/machines/terminal_button08.ogg')
		if(SFX_VENDING)
			soundin = pick('sound/machines/vending_cans.ogg', 'sound/machines/vending_drop.ogg')
		if(SFX_INCENDIARY_EXPLOSION)
			soundin = pick('sound/effects/incendiary_explosion_1.ogg', 'sound/effects/incendiary_explosion_2.ogg', 'sound/effects/incendiary_explosion_3.ogg')
		if(SFX_MOLOTOV)
			soundin = pick('sound/effects/molotov_detonate_1.ogg', 'sound/effects/molotov_detonate_2.ogg', 'sound/effects/molotov_detonate_3.ogg')
		if(SFX_FLASHBANG)
			soundin = pick('sound/effects/flashbang_explode_1.ogg', 'sound/effects/flashbang_explode_2.ogg')
		// Weapons/bullets
		if(SFX_BALLISTIC_HIT)
			soundin = pick('sound/bullets/bullet_impact1.ogg','sound/bullets/bullet_impact2.ogg','sound/bullets/bullet_impact3.ogg')
		if(SFX_BALLISTIC_HITMARKER)
			soundin = pick('sound/bullets/bullet_impact4.ogg','sound/bullets/bullet_impact5.ogg','sound/bullets/bullet_impact6.ogg','sound/bullets/bullet_impact7.ogg')
		if(SFX_BALLISTIC_ARMOR)
			soundin = pick('sound/bullets/bullet_armor1.ogg','sound/bullets/bullet_armor2.ogg','sound/bullets/bullet_armor3.ogg','sound/bullets/bullet_armor4.ogg')
		if(SFX_BALLISTIC_MISS)
			soundin = pick('sound/bullets/bullet_miss1.ogg','sound/bullets/bullet_miss2.ogg','sound/bullets/bullet_miss3.ogg','sound/bullets/bullet_miss4.ogg')
		if(SFX_BALLISTIC_BOUNCE)
			soundin = pick('sound/bullets/bullet_ricochet1.ogg','sound/bullets/bullet_ricochet2.ogg','sound/bullets/bullet_ricochet3.ogg','sound/bullets/bullet_ricochet4.ogg','sound/bullets/bullet_ricochet5.ogg','sound/bullets/bullet_ricochet6.ogg','sound/bullets/bullet_ricochet7.ogg','sound/bullets/bullet_ricochet8.ogg')
		if(SFX_ROCKET_BOUNCE)
			soundin = pick('sound/bullets/rocket_ricochet1.ogg','sound/bullets/rocket_ricochet2.ogg','sound/bullets/rocket_ricochet3.ogg')
		if(SFX_ENERGY_HIT)
			soundin = pick('sound/bullets/energy_impact1.ogg')
		if(SFX_ALLOY_HIT)
			soundin = pick('sound/bullets/spear_impact1.ogg')
		if(SFX_ALLOY_ARMOR)
			soundin = pick('sound/bullets/spear_armor1.ogg')
		if(SFX_ALLOY_BOUNCE)
			soundin = pick('sound/bullets/spear_ricochet1.ogg','sound/bullets/spear_ricochet2.ogg')
		if(SFX_GUN_SILENCED)
			soundin = pick('sound/weapons/guns/fire/silenced_shot1.ogg','sound/weapons/guns/fire/silenced_shot2.ogg')
		if(SFX_GUN_SMARTGUN)
			soundin = pick('sound/weapons/guns/fire/smartgun1.ogg', 'sound/weapons/guns/fire/smartgun2.ogg', 'sound/weapons/guns/fire/smartgun3.ogg')
		if(SFX_GUN_SMARTGPMG)
			soundin = pick ('sound/weapons/guns/fire/sg60_1.ogg', 'sound/weapons/guns/fire/sg60_2.ogg')
		if(SFX_GUN_FLAMETHROWER)
			soundin = pick('sound/weapons/guns/fire/flamethrower1.ogg', 'sound/weapons/guns/fire/flamethrower2.ogg', 'sound/weapons/guns/fire/flamethrower3.ogg')
		if(SFX_GUN_AR12)
			soundin = pick('sound/weapons/guns/fire/tgmc/kinetic/gun_ar12_1.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_ar12_2.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_ar12_3.ogg')
		if(SFX_GUN_FB12) // idk why i called it "fb-12", ah too late now
			soundin = pick('sound/weapons/guns/fire/tgmc/kinetic/gun_fb12_1.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_fb12_2.ogg','sound/weapons/guns/fire/tgmc/kinetic/gun_fb12_3.ogg')
		if(SFX_SHOTGUN_SOM)
			soundin = pick('sound/weapons/guns/fire/v51_1.ogg','sound/weapons/guns/fire/v51_2.ogg','sound/weapons/guns/fire/v51_3.ogg','sound/weapons/guns/fire/v51_4.ogg')
		if(SFX_GUN_PULSE)
			soundin = pick('sound/weapons/guns/fire/m41a_1.ogg','sound/weapons/guns/fire/m41a_2.ogg','sound/weapons/guns/fire/m41a_3.ogg','sound/weapons/guns/fire/m41a_4.ogg','sound/weapons/guns/fire/m41a_5.ogg','sound/weapons/guns/fire/m41a_6.ogg')
		if(SFX_RPG_FIRE)
			soundin = pick('sound/weapons/guns/fire/rpg_1.ogg', 'sound/weapons/guns/fire/rpg_2.ogg', 'sound/weapons/guns/fire/rpg_3.ogg')
		if(SFX_AC_FIRE)
			soundin = pick('sound/weapons/guns/fire/autocannon_1.ogg', 'sound/weapons/guns/fire/autocannon_2.ogg', 'sound/weapons/guns/fire/autocannon_3.ogg')
		if(SFX_SVD_FIRE)
			soundin = pick('sound/weapons/guns/fire/svd1.ogg', 'sound/weapons/guns/fire/svd2.ogg', 'sound/weapons/guns/fire/svd3.ogg')
		if(SFX_FAL_FIRE)
			soundin = pick('sound/weapons/guns/fire/fal1.ogg', 'sound/weapons/guns/fire/fal2.ogg')
		if(SFX_MP38_FIRE)
			soundin = pick('sound/weapons/guns/fire/mp38_1.ogg', 'sound/weapons/guns/fire/mp38_2.ogg')
		if(SFX_SLAM)
			soundin = pick('sound/effects/slam1.ogg', 'sound/effects/slam2.ogg', 'sound/effects/slam3.ogg')

		// Xeno
		if(SFX_ACID_HIT)
			soundin = pick('sound/bullets/acid_impact1.ogg')
		if(SFX_ACID_BOUNCE)
			soundin = pick('sound/bullets/acid_impact1.ogg')
		if(SFX_ALIEN_CLAW_FLESH)
			soundin = pick('sound/weapons/alien_claw_flesh1.ogg','sound/weapons/alien_claw_flesh2.ogg','sound/weapons/alien_claw_flesh3.ogg')
		if(SFX_ALIEN_CLAW_METAL)
			soundin = pick('sound/weapons/alien_claw_metal1.ogg','sound/weapons/alien_claw_metal2.ogg','sound/weapons/alien_claw_metal3.ogg')
		if(SFX_ALIEN_BITE)
			soundin = pick('sound/weapons/alien_bite1.ogg','sound/weapons/alien_bite2.ogg')
		if(SFX_ALIEN_TAIL_ATTACK)
			soundin = 'sound/weapons/alien_tail_attack.ogg'
		if(SFX_ALIEN_FOOTSTEP_LARGE)
			soundin = pick('sound/effects/alien/footstep_large1.ogg','sound/effects/alien/footstep_large2.ogg','sound/effects/alien/footstep_large3.ogg')
		if(SFX_ALIEN_CHARGE)
			soundin = pick('sound/effects/alien/footstep_charge1.ogg','sound/effects/alien/footstep_charge2.ogg','sound/effects/alien/footstep_charge3.ogg')
		if(SFX_ALIEN_RESIN_BUILD)
			soundin = pick('sound/effects/alien/resin_build1.ogg','sound/effects/alien/resin_build2.ogg','sound/effects/alien/resin_build3.ogg')
		if(SFX_ALIEN_RESIN_BREAK)
			soundin = pick('sound/effects/alien/resin_break1.ogg','sound/effects/alien/resin_break2.ogg')
		if(SFX_ALIEN_RESIN_MOVE)
			soundin = pick('sound/effects/alien/resin_move1.ogg','sound/effects/alien/resin_move2.ogg')
		if(SFX_ALIEN_TALK)
			soundin = pick('sound/voice/alien/talk.ogg','sound/voice/alien/talk2.ogg','sound/voice/alien/talk3.ogg')
		if(SFX_ALIEN_GROWL)
			soundin = pick('sound/voice/alien/growl1.ogg','sound/voice/alien/growl2.ogg','sound/voice/alien/growl3.ogg','sound/voice/alien/growl4.ogg')
		if(SFX_ALIEN_HISS)
			soundin = pick('sound/voice/alien/hiss1.ogg','sound/voice/alien/hiss2.ogg','sound/voice/alien/hiss3.ogg')
		if(SFX_ALIEN_TAIL_SWIPE)
			soundin = pick('sound/effects/alien/tail_swipe1.ogg','sound/effects/alien/tail_swipe2.ogg','sound/effects/alien/tail_swipe3.ogg')
		if(SFX_ALIEN_HELP)
			soundin = pick('sound/voice/alien/help1.ogg','sound/voice/alien/help2.ogg')
		if(SFX_ALIEN_DROOL)
			soundin = pick('sound/voice/alien/drool1.ogg','sound/voice/alien/drool2.ogg')
		if(SFX_ALIEN_ROAR)
			soundin = pick('sound/voice/alien/roar1.ogg','sound/voice/alien/roar2.ogg','sound/voice/alien/roar3.ogg','sound/voice/alien/roar4.ogg','sound/voice/alien/roar5.ogg','sound/voice/alien/roar6.ogg','sound/voice/alien/roar7.ogg','sound/voice/alien/roar8.ogg','sound/voice/alien/roar9.ogg','sound/voice/alien/roar10.ogg','sound/voice/alien/roar11.ogg','sound/voice/alien/roar12.ogg')
		if(SFX_ALIEN_ROAR_LARVA)
			soundin = pick('sound/voice/alien/roar_larva1.ogg','sound/voice/alien/roar_larva2.ogg','sound/voice/alien/roar_larva3.ogg','sound/voice/alien/roar_larva4.ogg')
		if(SFX_QUEEN)
			soundin = pick('sound/voice/alien/queen_command.ogg','sound/voice/alien/queen_command2.ogg','sound/voice/alien/queen_command3.ogg')
		if(SFX_ALIEN_VENTPASS)
			soundin = pick('sound/effects/alien/ventpass1.ogg', 'sound/effects/alien/ventpass2.ogg')
		if(SFX_BEHEMOTH_STEP_SOUNDS)
			soundin = pick('sound/effects/alien/footstep_large1.ogg', 'sound/effects/alien/footstep_large2.ogg', 'sound/effects/alien/footstep_large3.ogg')
		if(SFX_BEHEMOTH_ROLLING)
			soundin = 'sound/effects/alien/behemoth/roll.ogg'
		if(SFX_BEHEMOTH_EARTH_PILLAR_HIT)
			soundin = pick('sound/effects/alien/behemoth/earth_pillar_hit_1.ogg', 'sound/effects/alien/behemoth/earth_pillar_hit_2.ogg', 'sound/effects/alien/behemoth/earth_pillar_hit_3.ogg', 'sound/effects/alien/behemoth/earth_pillar_hit_4.ogg', 'sound/effects/alien/behemoth/earth_pillar_hit_5.ogg', 'sound/effects/alien/behemoth/earth_pillar_hit_6.ogg')
		if(SFX_CONQUEROR_WILL_HOOK)
			soundin = pick('sound/effects/alien/conqueror/will_hook_1.ogg', 'sound/effects/alien/conqueror/will_hook_2.ogg', 'sound/effects/alien/conqueror/will_hook_3.ogg')
		if(SFX_CONQUEROR_WILL_EXTRA)
			soundin = pick('sound/effects/alien/conqueror/will_extra_1.ogg', 'sound/effects/alien/conqueror/will_extra_2.ogg')

		// Human
		if(SFX_MALE_SCREAM)
			soundin = pick('sound/voice/human/male/scream_1.ogg','sound/voice/human/male/scream_2.ogg','sound/voice/human/male/scream_3.ogg','sound/voice/human/male/scream_4.ogg','sound/voice/human/male/scream_5.ogg','sound/voice/human/male/scream_6.ogg', 'sound/voice/human/male/scream_7.ogg')
		if(SFX_MALE_PAIN)
			soundin = pick('sound/voice/human/male/pain_1.ogg','sound/voice/human/male/pain_2.ogg','sound/voice/human/male/pain_3.ogg','sound/voice/human/male/pain_4.ogg','sound/voice/human/male/pain_5.ogg','sound/voice/human/male/pain_6.ogg','sound/voice/human/male/pain_7.ogg','sound/voice/human/male/pain_8.ogg', 'sound/voice/human/male/pain_9.ogg', 'sound/voice/human/male/pain_10.ogg', 'sound/voice/human/male/pain_11.ogg')
		if(SFX_MALE_GORED)
			soundin = pick('sound/voice/human/male/gored_1.ogg','sound/voice/human/male/gored_2.ogg', 'sound/voice/human/male/gored3.ogg')
		if(SFX_MALE_FRAGOUT)
			soundin = pick('sound/voice/human/male/grenadethrow_1.ogg', 'sound/voice/human/male/grenadethrow_2.ogg', 'sound/voice/human/male/grenadethrow_3.ogg')
		if(SFX_MALE_WARCRY)
			soundin = pick('sound/voice/human/male/warcry_1.ogg','sound/voice/human/male/warcry_2.ogg','sound/voice/human/male/warcry_3.ogg','sound/voice/human/male/warcry_4.ogg','sound/voice/human/male/warcry_5.ogg','sound/voice/human/male/warcry_6.ogg','sound/voice/human/male/warcry_7.ogg','sound/voice/human/male/warcry_8.ogg','sound/voice/human/male/warcry_9.ogg','sound/voice/human/male/warcry_10.ogg','sound/voice/human/male/warcry_11.ogg','sound/voice/human/male/warcry_12.ogg','sound/voice/human/male/warcry_13.ogg','sound/voice/human/male/warcry_14.ogg','sound/voice/human/male/warcry_15.ogg','sound/voice/human/male/warcry_16.ogg','sound/voice/human/male/warcry_17.ogg','sound/voice/human/male/warcry_18.ogg','sound/voice/human/male/warcry_19.ogg','sound/voice/human/male/warcry_20.ogg','sound/voice/human/male/warcry_21.ogg','sound/voice/human/male/warcry_22.ogg','sound/voice/human/male/warcry_23.ogg','sound/voice/human/male/warcry_24.ogg','sound/voice/human/male/warcry_25.ogg','sound/voice/human/male/warcry_26.ogg','sound/voice/human/male/warcry_27.ogg','sound/voice/human/male/warcry_28.ogg','sound/voice/human/male/warcry_29.ogg')
		if(SFX_FEMALE_SCREAM)
			soundin = pick('sound/voice/human/female/scream_1.ogg','sound/voice/human/female/scream_2.ogg','sound/voice/human/female/scream_3.ogg','sound/voice/human/female/scream_4.ogg','sound/voice/human/female/scream_5.ogg')
		if(SFX_FEMALE_PAIN)
			soundin = pick('sound/voice/human/female/pain_1.ogg','sound/voice/human/female/pain_2.ogg','sound/voice/human/female/pain_3.ogg')
		if(SFX_FEMALE_GORED)
			soundin = pick('sound/voice/human/female/gored_1.ogg','sound/voice/human/female/gored_2.ogg')
		if(SFX_FEMALE_FRAGOUT)
			soundin = pick("sound/voice/human_female_grenadethrow_1.ogg", 'sound/voice/human/female/grenadethrow_2.ogg', 'sound/voice/human/female/grenadethrow_3.ogg')
		if(SFX_FEMALE_WARCRY)
			soundin = pick('sound/voice/human/female/warcry_1.ogg','sound/voice/human/female/warcry_2.ogg','sound/voice/human/female/warcry_3.ogg','sound/voice/human/female/warcry_4.ogg','sound/voice/human/female/warcry_5.ogg','sound/voice/human/female/warcry_6.ogg','sound/voice/human/female/warcry_7.ogg','sound/voice/human/female/warcry_8.ogg','sound/voice/human/female/warcry_9.ogg','sound/voice/human/female/warcry_10.ogg','sound/voice/human/female/warcry_11.ogg','sound/voice/human/female/warcry_12.ogg','sound/voice/human/female/warcry_13.ogg','sound/voice/human/female/warcry_14.ogg','sound/voice/human/female/warcry_15.ogg','sound/voice/human/female/warcry_16.ogg','sound/voice/human/female/warcry_17.ogg','sound/voice/human/female/warcry_18.ogg','sound/voice/human/female/warcry_19.ogg')
		if(SFX_MALE_HUGGED)
			soundin = pick("sound/voice/human_male_facehugged1.ogg", 'sound/voice/human/male/facehugged2.ogg', 'sound/voice/human/male/facehugged3.ogg')
		if(SFX_FEMALE_HUGGED)
			soundin = pick("sound/voice/human_female_facehugged1.ogg", 'sound/voice/human/female/facehugged2.ogg')
		if(SFX_MALE_GASP)
			soundin = pick("sound/voice/human_male_gasp1.ogg", 'sound/voice/human/male/gasp2.ogg', 'sound/voice/human/male/gasp3.ogg')
		if(SFX_FEMALE_GASP)
			soundin = pick("sound/voice/human_female_gasp1.ogg", 'sound/voice/human/female/gasp2.ogg')
		if(SFX_MALE_COUGH)
			soundin = pick("sound/voice/human_male_cough1.ogg", 'sound/voice/human/male/cough2.ogg')
		if(SFX_FEMALE_COUGH)
			soundin = pick("sound/voice/human_female_cough1.ogg", 'sound/voice/human/female/cough2.ogg')
		if(SFX_MALE_PREBURST)
			soundin = pick("sound/voice/human_male_preburst1.ogg", 'sound/voice/human/male/preburst2.ogg', 'sound/voice/human/male/preburst3.ogg', 'sound/voice/human/male/preburst4.ogg', 'sound/voice/human/male/preburst5.ogg', 'sound/voice/human/male/preburst6.ogg', 'sound/voice/human/male/preburst7.ogg', 'sound/voice/human/male/preburst8.ogg', 'sound/voice/human/male/preburst9.ogg', 'sound/voice/human/male/preburst10.ogg')
		if(SFX_FEMALE_PREBURST)
			soundin = pick("sound/voice/human_female_preburst1.ogg", 'sound/voice/human/female/preburst2.ogg', 'sound/voice/human/female/preburst3.ogg')
		if(SFX_JUMP)
			soundin = pick('sound/effects/bounce_1.ogg','sound/effects/bounce_2.ogg','sound/effects/bounce_3.ogg','sound/effects/bounce_4.ogg')

		//robot race
		if(SFX_ROBOT_SCREAM)
			soundin = pick('sound/voice/robot/robot_scream1.ogg', 'sound/voice/robot/robot_scream2.ogg', 'sound/voice/robot/robot_scream2.ogg')
		if(SFX_ROBOT_PAIN)
			soundin = pick('sound/voice/robot/robot_pain1.ogg', 'sound/voice/robot/robot_pain2.ogg', 'sound/voice/robot/robot_pain3.ogg')
		if(SFX_ROBOT_WARCRY)
			soundin = pick('sound/voice/robot/robot_warcry1.ogg', 'sound/voice/robot/robot_warcry2.ogg', 'sound/voice/robot/robot_warcry3.ogg')

	return soundin
