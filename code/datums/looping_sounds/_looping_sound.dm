/*
	output_atoms	(list of atoms)			The destination(s) for the sounds

	mid_sounds		(list or soundfile)		Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	mid_length		(num)					The length to wait between playing mid_sounds

	start_sound		(soundfile)				Played before starting the mid_sounds loop
	start_length	(num)					How long to wait before starting the main loop after playing start_sound

	end_sound		(soundfile)				The sound played after the main loop has concluded

	chance			(num)					Chance per loop to play a mid_sound
	volume			(num)					Sound output volume
	max_loops		(num)					The max amount of loops to run for.
	direct			(bool)					If true plays directly to provided atoms instead of from them
*/
/datum/looping_sound
	var/list/atom/output_atoms
	var/mid_sounds
	var/mid_length
	var/start_sound
	var/start_length
	var/end_sound = 'sound/blank.ogg'
	var/chance
	var/volume = 100
	var/vary = FALSE
	var/max_loops
	var/direct
	var/extra_range = 0
	var/falloff
	var/frequency
	var/stopped = TRUE
	var/persistent_loop = FALSE //we stay in the client's played_loops so we keep updating volume even when out of range
	var/cursound
	var/list/thingshearing = list()
	var/ignore_wallz = TRUE
	var/timerid

/datum/looping_sound/New(list/_output_atoms=list(), start_immediately=FALSE, _direct=FALSE)
	if(!mid_sounds)
		WARNING("A looping sound datum was created without sounds to play.")
		return

	output_atoms = _output_atoms
	direct = _direct

	if(start_immediately)
		start()

/datum/looping_sound/Destroy()
	stop()
	output_atoms = null
	return ..()

/datum/looping_sound/proc/start(atom/add_thing)
	stopped = FALSE
	if(add_thing)
		output_atoms |= add_thing
//	if(timerid)
//		return
	on_start()

/datum/looping_sound/proc/stop(atom/remove_thing)
	if(!stopped)
		stopped = TRUE
		if(remove_thing)
			output_atoms -= remove_thing
		on_stop()
//		if(!timerid)
//			return
//		deltimer(timerid)
//		timerid = null

/datum/looping_sound/proc/sound_loop(starttime)
//	START_PROCESSING(SSsoundloopers, src)
	if(!cursound)
		cursound = get_sound(starttime)
	if(max_loops && world.time >= starttime + mid_length * max_loops)
		stop()
		return
	if(stopped)
		stop()
		return
	if(!chance || prob(chance))
		play(cursound)
//	if(!timerid)
//		timerid = addtimer(CALLBACK(src, PROC_REF(sound_loop), world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP)

/datum/looping_sound/proc/play(soundfile)
	var/list/atoms_cache = output_atoms
	var/sound/S = soundfile
	if(!istype(S))
		S = sound(soundfile)
	if(direct)
		S.channel = open_sound_channel()
		S.volume = volume
	for(var/i in 1 to atoms_cache.len)
		var/atom/thing = atoms_cache[i]
		if(direct)
			SEND_SOUND(thing, S)
		else
			var/list/R = playsound(thing, soundfile, volume, vary, extra_range, falloff, frequency, ignore_walls = ignore_wallz, repeat = src)
			if(!R || !R.len)
				R = list()
			for(var/mob/M in thingshearing)
				if(!M.client)
					thingshearing -= M
					continue
				if(!(M in R) || M.IsSleeping())// they are out of range
					var/list/L = M.client.played_loops[src]
					if(L)
						var/sound/SD = L["SOUND"]
						if(SD)
							if(persistent_loop)
								L["MUTESTATUS"] = TRUE
								L["VOL"] = 0
								M.mute_sound(SD)
								//M.play_ambience()
							else
								M.client.played_loops -= src
								thingshearing -= M
								M.stop_sound_channel(SD.channel)
				else
					on_hear_sound(M)

/datum/looping_sound/proc/on_hear_sound(mob/M)
	return

/datum/looping_sound/proc/get_sound(starttime, _mid_sounds)
	. = _mid_sounds || mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/datum/looping_sound/proc/on_start()
	var/start_wait = 0
	if(start_sound)
		play(start_sound)
		start_wait = start_length
	addtimer(CALLBACK(src, PROC_REF(begin_loop)), start_wait, TIMER_CLIENT_TIME)

/datum/looping_sound/proc/begin_loop()
	sound_loop()
	START_PROCESSING(SSsoundloopers, src)

/datum/looping_sound/proc/on_stop()
//	play(end_sound)
	STOP_PROCESSING(SSsoundloopers, src)
	for(var/mob/M in thingshearing)
		if(M.client)
			var/list/L = M.client.played_loops[src]
			if(L)
				testing("foundus")
				var/sound/SD = L["SOUND"]
				if(SD)
					testing("foundus2")
					M.stop_sound_channel(SD.channel)
				M.client.played_loops -= src
				thingshearing -= M
/*
/mob/proc/stop_all_loops()
	if(client)
		for(var/datum/looping_sound/X in client.played_loops)
			var/list/L = client.played_loops[X]
			var/sound/SD = L["SOUND"]
			if(SD)
				stop_sound_channel(SD.channel)
			client.played_loops -= X
			X.thingshearing -= src
*/