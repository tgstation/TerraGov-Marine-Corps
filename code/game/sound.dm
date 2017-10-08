#define FALLOFF_SOUNDS 1

//Sound environment defines. Reverb preset for sounds played in an area, see sound datum reference for more.
#define GENERIC 0
#define PADDED_CELL 1
#define ROOM 2
#define BATHROOM 3
#define LIVINGROOM 4
#define STONEROOM 5
#define AUDITORIUM 6
#define CONCERT_HALL 7
#define CAVE 8
#define ARENA 9
#define HANGAR 10
#define CARPETED_HALLWAY 11
#define HALLWAY 12
#define STONE_CORRIDOR 13
#define ALLEY 14
#define FOREST 15
#define CITY 16
#define MOUNTAINS 17
#define QUARRY 18
#define PLAIN 19
#define PARKING_LOT 20
#define SEWER_PIPE 21
#define UNDERWATER 22
#define DRUGGED 23
#define DIZZY 24
#define PSYCHOTIC 25

#define ENCLOSED_SMALL ROOM
#define ENCLOSED_MEDIUM AUDITORIUM
#define ENCLOSED_LARGE CONCERT_HALL
#define ENCLOSED_HALLWAY_SMALL SEWER_PIPE
#define ENCLOSED_HALLWAY_MEDIUM HALLWAY
#define ENCLOSED_HALLWAY_LARGE HALLWAY

#define SOFTFLOOR_SMALL PADDED_CELL
#define SOFTFLOOR_MEDIUM LIVINGROOM
#define SOFTFLOOR_LARGE LIVINGROOM
#define SOFTFLOOR_HALLWAY_SMALL CARPETED_HALLWAY
#define SOFTFLOOR_HALLWAY_MEDIUM CARPETED_HALLWAY
#define SOFTFLOOR_HALLWAY_LARGE CARPETED_HALLWAY

#define SPACE UNDERWATER

//Proc used to play a sound.
//source: self-explanatory.
//soundin: the .ogg to use.
//vol: the initial volume of the sound, 0 is no sound at all, 75 is loud queen screech.
//vary: to make the frequency var of the sound vary (mostly unused).
//sound_range: the maximum theoretical range (in tiles) of the sound, by default is equal to the volume.
//falloff: how the sound's volume decreases with distance, low is fast decrease and high is slow decrease.
//A good representation is: 'byond applies a volume reduction to the sound every X tiles', where X is falloff.

/proc/playsound(atom/source, soundin, vol, vary, sound_range, falloff, is_global)

	if(!sound_range) sound_range = vol //if no specific range, the max range is equal to the volume.

	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = GET_RANDOM_FREQ // Same frequency for everybody
	var/turf/turf_source = get_turf(source)
	if(!turf_source) return
 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/mob/M
	var/turf/T
	for(var/i in player_list)
		M = i
		if(!istype(M) || !M.client) continue
		if(get_dist(M, turf_source) <= sound_range)
			T = get_turf(M)
			if(T && T.z == turf_source.z) M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global)

/mob/proc/playsound_local(turf/turf_source, soundin, vol, vary, frequency, var/falloff, is_global)
	if(!client || ear_deaf > 0)	r_FAL
	soundin = get_sfx(soundin)

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol
	S.environment = list(
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

	if(vary) S.frequency = frequency ? frequency : GET_RANDOM_FREQ

	//sound volume falloff with pressure
	var/pressure_factor = 1.0
	var/datum/gas_mixture/hearer_env = null

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if(pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else pressure_factor = 0 //in space
		if(distance <= 1) pressure_factor = max(pressure_factor, 0.15)	//hearing through contact
		S.volume *= round(pressure_factor, 0.1)

		if(S.volume <= 2*distance) r_FAL //no volume or too far away to hear such a volume level.

		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		//The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		if(falloff) S.falloff = falloff
		else S.falloff = FALLOFF_SOUNDS * max(round(S.volume * 0.05), 1) //louder sounds take a longer distance to fade.

		if(S.volume <= distance) r_FAL //no volume or too far away to hear such a volume level.

	if(!is_global)
		if(istype(src,/mob/living/))
			var/mob/living/M = src
			if (M.hallucination)
				S.environment = PSYCHOTIC
			else if (M.druggy)
				S.environment = DRUGGED
			else if (M.drowsyness)
				S.environment = DIZZY
			else if (M.confused)
				S.environment = DIZZY
			else if (M.sleeping)
				S.environment = UNDERWATER
			else if (pressure_factor < 0.5)
				S.environment = SPACE
			else
				var/area/A = get_area(src)
				if(A.dynamic_sound_env && hearer_env)
					var/env_size = hearer_env.group_multiplier //number of tiles in airgroup
					S.environment = return_sound_env(A.dynamic_sound_env,env_size)
				else
					S.environment = A.sound_env

		else if (pressure_factor < 0.5)
			S.environment = SPACE
		else

			var/area/A = get_area(src)
			if(A.dynamic_sound_env && hearer_env)
				var/env_size = hearer_env.group_multiplier //number of tiles in airgroup
				S.environment = return_sound_env(A.dynamic_sound_env,env_size)
			else
				S.environment = A.sound_env
	src << S

/mob/proc/return_sound_env(var/dynamic_sound_env, var/size)
	switch(dynamic_sound_env)
		if ("ENCLOSED")
			switch(size)
				if(0 to 64)
					return ENCLOSED_SMALL
				if(64 to 144)
					return ENCLOSED_MEDIUM
				else
					return ENCLOSED_LARGE
		if("ENCLOSED_HALLWAY")
			switch(size)
				if(0 to 64)
					return ENCLOSED_HALLWAY_SMALL
				if(64 to 144)
					return ENCLOSED_HALLWAY_MEDIUM
				else
					return ENCLOSED_HALLWAY_LARGE
		if ("SOFTFLOOR")
			switch(size)
				if(0 to 64)
					return SOFTFLOOR_SMALL
				if(64 to 144)
					return SOFTFLOOR_MEDIUM
				else
					return SOFTFLOOR_LARGE
		if ("SOFTFLOOR_HALLWAY")
			switch(size)
				if(0 to 64)
					return SOFTFLOOR_HALLWAY_SMALL
				if(64 to 144)
					return SOFTFLOOR_HALLWAY_MEDIUM
				else
					return SOFTFLOOR_HALLWAY_LARGE
	return SOFTFLOOR_SMALL

/proc/sound_to(target, soundin, env) //for command announcements, adminhelps, etc
	var/sound/S = sound(get_sfx(soundin))
	if(env)
		S.environment = env
	else
		S.environment = list(
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
	target << S

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	r_FAL
	if(prefs.toggles_sound & SOUND_LOBBY)
		src << sound(ticker.login_music, repeat = 0, wait = 0, volume = 85, channel = 1) // MAD JAMS

#define SOUND_PLAY_SHATTER pick('sound/effects/Glassbr1.ogg','sound/effects/Glassbr2.ogg','sound/effects/Glassbr3.ogg')
#define SOUND_PLAY_EXPLODE pick('sound/effects/Explosion1.ogg','sound/effects/Explosion2.ogg')
#define SOUND_PLAY_SPARK pick('sound/effects/sparks1.ogg','sound/effects/sparks2.ogg','sound/effects/sparks3.ogg','sound/effects/sparks4.ogg')
#define SOUND_PLAY_RUSTLE pick('sound/effects/rustle1.ogg','sound/effects/rustle2.ogg','sound/effects/rustle3.ogg','sound/effects/rustle4.ogg','sound/effects/rustle5.ogg')
#define SOUND_PLAY_PUNCH pick('sound/weapons/punch1.ogg','sound/weapons/punch2.ogg','sound/weapons/punch3.ogg','sound/weapons/punch4.ogg')
#define SOUND_PLAY_CLOWN pick('sound/effects/clownstep1.ogg','sound/effects/clownstep2.ogg')
#define SOUND_PLAY_SWING pick('sound/weapons/genhit1.ogg', 'sound/weapons/genhit2.ogg', 'sound/weapons/genhit3.ogg')
#define SOUND_PLAY_HISS pick('sound/voice/alien_talk.ogg','sound/voice/alien_talk2.ogg','sound/voice/alien_talk3.ogg')
#define SOUND_PLAY_PAGE pick('sound/effects/pageturn1.ogg', 'sound/effects/pageturn2.ogg','sound/effects/pageturn3.ogg')
#define SOUND_PLAY_QUEEN pick('sound/voice/alien_queen_command.ogg','sound/voice/alien_queen_command2.ogg','sound/voice/alien_queen_command3.ogg')
#define SOUND_PLAY_SCREAM_MALE pick('sound/voice/scream_male_1.ogg','sound/voice/scream_male_2.ogg','sound/voice/scream_male_3.ogg','sound/voice/scream_male_4.ogg','sound/voice/scream_male_5.ogg')
#define SOUND_PLAY_SCREAM_FEMALE pick('sound/voice/scream_female_1.ogg','sound/voice/scream_female_2.ogg','sound/voice/scream_female_3.ogg','sound/voice/scream_female_4.ogg','sound/voice/scream_female_5.ogg')
#define SOUND_PLAY_BALLISTIC_HIT pick('sound/bullets/bullet_impact1.ogg','sound/bullets/bullet_impact2.ogg','sound/bullets/bullet_impact1.ogg')
#define SOUND_PLAY_BALLISTIC_ARMOR pick('sound/bullets/bullet_armor1.ogg','sound/bullets/bullet_armor2.ogg','sound/bullets/bullet_armor3.ogg','sound/bullets/bullet_armor4.ogg')
#define SOUND_PLAY_BALLISTIC_MISS pick('sound/bullets/bullet_miss1.ogg','sound/bullets/bullet_miss2.ogg','sound/bullets/bullet_miss3.ogg','sound/bullets/bullet_miss3.ogg')
#define SOUND_PLAY_BALLISTIC_BOUNCE pick('sound/bullets/bullet_ricochet1.ogg','sound/bullets/bullet_ricochet2.ogg','sound/bullets/bullet_ricochet3.ogg','sound/bullets/bullet_ricochet4.ogg','sound/bullets/bullet_ricochet5.ogg','sound/bullets/bullet_ricochet6.ogg','sound/bullets/bullet_ricochet7.ogg','sound/bullets/bullet_ricochet8.ogg')
#define SOUND_PLAY_ROCKET_BOUNCE pick('sound/bullets/rocket_ricochet1.ogg','sound/bullets/rocket_ricochet2.ogg','sound/bullets/rocket_ricochet3.ogg')
#define SOUND_PLAY_ENERGY_HIT pick('sound/bullets/energy_impact1.ogg')
#define SOUND_PLAY_ENERGY_MISS pick('sound/bullets/energy_miss1.ogg')
#define SOUND_PLAY_ENERGY_BOUNCE pick('sound/bullets/energy_ricochet1.ogg')
#define SOUND_PLAY_ACID_HIT pick('sound/bullets/acid_impact1.ogg')
#define SOUND_PLAY_ACID_BOUNCE pick('sound/bullets/acid_impact1.ogg')
#define SOUND_PLAY_ALLOY_HIT pick('sound/bullets/spear_impact1.ogg')
#define SOUND_PLAY_ALLOY_ARMOR pick('sound/bullets/spear_armor1.ogg')
#define SOUND_PLAY_ALLOY_BOUNCE pick('sound/bullets/spear_ricochet1.ogg','sound/bullets/spear_ricochet2.ogg')
#define SOUND_PLAY_GUN_SILENCED pick('sound/weapons/gun_silenced_shot1.ogg','sound/weapons/gun_silenced_shot2.ogg')
#define SOUND_PLAY_GUN_PULSE pick('sound/weapons/gun_m41a_1.ogg','sound/weapons/gun_m41a_2.ogg','sound/weapons/gun_m41a_3.ogg','sound/weapons/gun_m41a_4.ogg','sound/weapons/gun_m41a_5.ogg','sound/weapons/gun_m41a_6.ogg')
#define SOUND_PLAY_GUN_SMARTGUN pick('sound/weapons/gun_smartgun1.ogg', 'sound/weapons/gun_smartgun2.ogg', 'sound/weapons/gun_smartgun3.ogg')

/proc/get_sfx(S)
	. = S
	if(istext(S))
		switch(S)
			if("shatter") . = SOUND_PLAY_SHATTER
			if("explosion") . = SOUND_PLAY_EXPLODE
			if("sparks") . = SOUND_PLAY_SPARK
			if("rustle") . = SOUND_PLAY_RUSTLE
			if("punch") . = SOUND_PLAY_PUNCH
			if("clownstep") . = SOUND_PLAY_CLOWN
			if("swing_hit") . = SOUND_PLAY_SWING
			if("hiss") . = SOUND_PLAY_HISS
			if("pageturn") . = SOUND_PLAY_PAGE
			if("queen") . = SOUND_PLAY_QUEEN
			if("scream_male") . = SOUND_PLAY_SCREAM_MALE
			if("scream_female") . = SOUND_PLAY_SCREAM_FEMALE
			if("ballistic_hit") . = SOUND_PLAY_BALLISTIC_HIT
			if("ballistic_armor") . = SOUND_PLAY_BALLISTIC_ARMOR
			if("ballistic_miss") . = SOUND_PLAY_BALLISTIC_MISS
			if("ballistic_bounce") . = SOUND_PLAY_BALLISTIC_BOUNCE
			if("rocket_bounce") . = SOUND_PLAY_ROCKET_BOUNCE
			if("energy_hit") . = SOUND_PLAY_ENERGY_HIT
			if("energy_miss") . = SOUND_PLAY_ENERGY_MISS
			if("energy_bounce") . = SOUND_PLAY_ENERGY_BOUNCE
			if("acid_hit") . = SOUND_PLAY_ACID_HIT
			if("acid_bounce") . = SOUND_PLAY_ACID_BOUNCE
			if("alloy_hit") . = SOUND_PLAY_ALLOY_HIT
			if("alloy_armor") . = SOUND_PLAY_ALLOY_ARMOR
			if("alloy_bounce") . = SOUND_PLAY_ALLOY_BOUNCE
			if("gun_silenced") . = SOUND_PLAY_GUN_SILENCED
			if("gun_pulse") . = SOUND_PLAY_GUN_PULSE
			if("gun_smartgun") . = SOUND_PLAY_GUN_SMARTGUN
