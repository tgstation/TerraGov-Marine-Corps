//Used to manage sending droning sounds to various clients
SUBSYSTEM_DEF(droning)
	name = "Droning"
	flags = SS_NO_INIT|SS_NO_FIRE

/datum/controller/subsystem/droning/proc/area_entered(area/area_entered, client/entering)
	if(!area_entered || !entering)
		return
/*
	if(HAS_TRAIT(entering.mob, TRAIT_LEAN) && !area_entered.droning_sound)
		//just kill the previous droning sound
		kill_droning(entering)
		return
	if(HAS_TRAIT(entering.mob, TRAIT_BLOODARN) && !area_entered.droning_sound)
		//just kill the previous droning sound
		kill_droning(entering)
		return
*/
	var/list/last_droning = list()
	last_droning |= entering.last_droning_sound
	var/list/new_droning = list()
	new_droning |= area_entered.droning_sound_current

	if(HAS_TRAIT(entering.mob, TRAIT_DRUQK))
		new_droning = list('sound/music/spice.ogg', 100)

	//Same ambience, don't bother
	if(last_droning ~= new_droning)
		return
	play_area_sound(area_entered, entering)

/datum/controller/subsystem/droning/proc/play_area_sound(area/area_player, client/listener)
	if(!area_player || !listener)
		return

	if(area_player.droningniqqa)

		if(!area_player.droning_sound)
			return
		var/used_gay

		if(GLOB.tod == "dawn")
			if(area_player.droning_sound_dawn)
				used_gay = area_player.droning_sound_dawn
			else
				used_gay = area_player.droning_sound

		if(GLOB.tod == "day")
			if(area_player.droning_sound)
				used_gay = area_player.droning_sound
			else
				used_gay = null

		if(GLOB.tod == "dusk")
			if(area_player.droning_sound_dusk)
				used_gay = area_player.droning_sound_dusk
			else
				used_gay = area_player.droning_sound

		if(GLOB.tod == "night")
			if(area_player.droning_sound_night)
				used_gay = area_player.droning_sound_night
			else
				used_gay = area_player.droning_sound

		if(HAS_TRAIT(listener.mob, TRAIT_DRUQK))
			used_gay = list('sound/music/spice.ogg', 100)
		//our music for real
		area_player.droning_sound_current = used_gay
		//last phase!
		if(listener?.mob.cmode)
			last_phase(area_player, listener, shouldskip = TRUE)
		else
			last_phase(area_player, listener, shouldskip = FALSE)

/datum/controller/subsystem/droning/proc/play_combat_music(music = null, client/dreamer)
	if(!music || !dreamer)
		return
/*
	if(HAS_TRAIT(dreamer.mob, TRAIT_LEAN))
		return
	if(HAS_TRAIT(dreamer.mob, TRAIT_BLOODARN))
		return
*/

	if(HAS_TRAIT(dreamer.mob, TRAIT_DRUQK))
		return

	//kill the previous droning sound
	kill_droning(dreamer)
	var/sound/combat_music = sound(pick(music), repeat = TRUE, wait = 0, channel = CHANNEL_BUZZ, volume = dreamer?.prefs.musicvol)
	SEND_SOUND(dreamer, combat_music)
	dreamer.droning_sound = combat_music
	dreamer.last_droning_sound = combat_music.file

/datum/controller/subsystem/droning/proc/last_phase(area/area_player, client/listener, shouldskip = FALSE)
	if(!area_player || !listener)
		return
	if(!listener?.droning_sound)
		shouldskip = TRUE
	if(listener?.mob.cmode)
		shouldskip = TRUE
	if(shouldskip)
		var/sound/droning = sound(pick(area_player.droning_sound_current), area_player.droning_repeat, area_player.droning_wait, area_player.droning_channel, listener?.prefs.musicvol)

		if(HAS_TRAIT(listener.mob, TRAIT_DRUQK))
			droning.file = 'sound/music/spice.ogg'

		listener.droning_sound = droning
		listener.last_droning_sound = area_player.droning_sound
		SEND_SOUND(listener, droning)
	else
		var/sound/sound_killer = sound()
		sound_killer.channel = listener.droning_sound.channel
		sound_killer.volume = listener.prefs.musicvol
		while(sound_killer.volume > 0)
			if(sound_killer.volume <= 0)
				break
			sound_killer.volume = max(sound_killer.volume - 5, 0)
			sound_killer.status = SOUND_UPDATE
			SEND_SOUND(listener, sound_killer)
			sleep(1)
		listener.droning_sound = null
		listener.last_droning_sound = null
		var/sound/droning = sound(pick(area_player.droning_sound_current), area_player.droning_repeat, area_player.droning_wait, area_player.droning_channel, listener?.prefs.musicvol)

		if(HAS_TRAIT(listener.mob, TRAIT_DRUQK))
			droning.file = 'sound/music/spice.ogg'

		listener.droning_sound = droning
		listener.last_droning_sound = area_player.droning_sound_current
		SEND_SOUND(listener, droning)

/datum/controller/subsystem/droning/proc/kill_droning(client/victim)
	if(!victim?.droning_sound)
		return
	var/sound/sound_killer = sound()
	sound_killer.channel = victim.droning_sound.channel
	SEND_SOUND(victim, sound_killer)
	victim.droning_sound = null
	victim.last_droning_sound = null

/datum/controller/subsystem/droning/proc/play_loop(area/area_entered, client/dreamer)
	if(!area_entered || !dreamer)
		return
	//kill the previous looping
	kill_loop(dreamer)

	var/retard = null
	if(area_entered.loopniqqa)
		if(GLOB.tod == "night")
			if(area_entered.ambientnight)
				retard = area_entered.ambientnight
		else
			if(area_entered.ambientsounds)
				retard = area_entered.ambientsounds

	if(!retard)
		return
	var/sound/loop_sound = sound(pick(retard), repeat = TRUE, wait = 0, channel = CHANNEL_MUSIC, volume = dreamer?.prefs.musicvol)
	SEND_SOUND(dreamer, loop_sound)
	dreamer.loop_sound = TRUE

/datum/controller/subsystem/droning/proc/kill_loop(client/victim)
	if(!victim?.loop_sound)
		return
	victim?.mob.stop_sound_channel(CHANNEL_MUSIC)
	victim?.loop_sound = FALSE

/datum/controller/subsystem/droning/proc/kill_rain(client/victim)
	if(!victim?.rain_sound)
		return
	victim?.mob.stop_sound_channel(CHANNEL_RAIN)
	victim?.rain_sound = FALSE

/datum/controller/subsystem/droning/proc/play_rain(area/area_entered, client/dreamer)
	if(!area_entered || !dreamer)
		return
	kill_rain(dreamer)

	var/retard = null
	if(area_entered.ambientrain)
		retard = area_entered.ambientrain

	if(!retard)
		return
	var/sound/loop_sound = sound(pick(retard), repeat = TRUE, wait = 0, channel = CHANNEL_RAIN, volume = dreamer?.prefs.musicvol)
	SEND_SOUND(dreamer, loop_sound)
	dreamer.rain_sound = TRUE