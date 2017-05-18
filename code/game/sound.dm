#define FALLOFF_SOUNDS 1 //Loses 100 % volume at 100 tiles

/proc/playsound(atom/source, soundin, vol, vary, extrarange = 100, falloff, is_global)

	soundin = get_sfx(soundin) // same sound for everyone

	if(isarea(source))
		error("[source] is an area and is trying to make the sound: [soundin]")
		return

	var/frequency = GET_RANDOM_FREQ // Same frequency for everybody
	var/turf/turf_source = get_turf(source)
 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/mob/M
	var/turf/T
	for(var/i in player_list)
		M = i
		if(!istype(M) || !M.client) continue
		if(get_dist(M, turf_source) <= (world.view + extrarange) * 3)
			T = get_turf(M)
			if(T && T.z == turf_source.z) M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, is_global)

/mob/proc/playsound_local(turf/turf_source, soundin, vol, vary, frequency, var/falloff, is_global)
	if(!client || ear_deaf > 0)	r_FAL
	soundin = get_sfx(soundin)

	var/sound/S = sound(soundin)
	S.wait = 0 //No queue
	S.channel = 0 //Any channel
	S.volume = vol
	S.environment = -1
	if(vary) S.frequency = frequency ? frequency : GET_RANDOM_FREQ

	if(isturf(turf_source))
		// 3D sounds, the technology is here!
		var/turf/T = get_turf(src)

		//sound volume falloff with distance
		var/distance = get_dist(T, turf_source)

		//sound volume falloff with pressure
		var/pressure_factor = 1.0

		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())

			if(pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else pressure_factor = 0 //in space
		if(distance <= 1) pressure_factor = max(pressure_factor, 0.15)	//hearing through contact
		S.volume *= pressure_factor
		var/dx = turf_source.x - T.x // Hearing from the right/left
		S.x = dx
		var/dz = turf_source.y - T.y // Hearing from infront/behind
		S.z = dz
		//The y value is for above your head, but there is no ceiling in 2d spessmens.
		S.y = 1
		S.falloff = falloff ? falloff : FALLOFF_SOUNDS

		S.volume -= round(max(distance - world.view, 0) * S.falloff) //multiplicative falloff to add on top of natural audio falloff. Power of 1.1 is a magic coefficient
		if(S.volume <= 0) r_FAL	//No volume means no sound

		//Obviously, since BYOND is great, they already fuck with volume in-house depending on position
		//So, our only option at this point is to clamp the values so it doesn't affect the volume too much
		S.x = Clamp(-5, S.x, 5)
		S.y = Clamp(-5, S.y, 5)
		S.z = Clamp(-5, S.z, 5)

	if(!is_global) S.environment = 2
	src << S

/client/proc/playtitlemusic()
	if(!ticker || !ticker.login_music)	r_FAL
	if(prefs.toggles & SOUND_LOBBY)
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
