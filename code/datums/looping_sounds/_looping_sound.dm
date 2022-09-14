/**
 * # Looping sound datums
 *
 * Used to play sound(s) on repeat until they are stopped
 * Processed by the SSloopingsounds [/datum/controller/subsystem/loopingsounds]
 */
/datum/looping_sound
	///(list of atoms) The destination(s) for the sounds
	var/list/atom/output_atoms
	/// (list or soundfile) Since this can be either a list or a single soundfile you can have random sounds. May contain further lists but must contain a soundfile at the end.
	var/mid_sounds
	/// (num) The length to wait between playing mid_sounds
	var/mid_length
	///(num) Override for volume of start sound
	var/start_volume
	/// (soundfile) Sound played before starting the mid_sounds loop
	var/start_sound
	///(num) How long to wait in ticks before starting the main loop after playing start_sound
	var/start_length
	///(num) Override for volume of end sound
	var/end_volume
	/// (soundfile) The sound played after the main loop has concluded
	var/end_sound
	///(num) % Chance per loop to play a mid_sound
	var/chance
	/// (num) Sound output volume
	var/volume = 100
	///(bool) Whether sounds played by this datum should be slightly varied by [/proc/playsound()]
	var/vary = FALSE
	/// (num) The max amount of loops to run for.
	var/max_loops
	///(bool) If true plays directly to provided atoms instead of from them
	var/direct = FALSE
	///Range the sound will travel
	var/range = 0
	///The rate the volume falls off. Higher = volume drops slower
	var/falloff
	/// The ID of the timer that's used to loop the sounds.
	var/timer_id
	///(num) world.time when the datum started looping
	var/start_time = 0

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

///Performs checks for looping and optinally adds a new atom to output_atoms, then calls [/datum/looping_sound/proc/on_start()]
/datum/looping_sound/proc/start(atom/add_thing)
	if(add_thing)
		output_atoms |= add_thing
	if(timer_id)
		return
	on_start()

///Performs checks for ending looping and optinally removes an atom from output_atoms, then calls [/datum/looping_sound/proc/on_stop()]
/datum/looping_sound/proc/stop(atom/remove_thing)
	if(remove_thing)
		output_atoms -= remove_thing
	if(!timer_id)
		return
	on_stop()
	deltimer(timer_id, SSsound_loops)
	timer_id = null

/**
 * A simple proc handling the looping of the sound itself.
 *
 * Arguments:
 * * start_time - The time at which the `mid_sounds` started being played (so we know when to stop looping).
 */
/datum/looping_sound/proc/sound_loop(start_time)
	if(max_loops && world.time >= start_time + mid_length * max_loops)
		stop()
		return
	if(!chance || prob(chance))
		play(get_sound(start_time))
	if(!timer_id)
		timer_id = addtimer(CALLBACK(src, .proc/sound_loop, world.time), mid_length, TIMER_CLIENT_TIME | TIMER_STOPPABLE | TIMER_LOOP, SSsound_loops)

/**
 * Plays a sound file to our output_atoms
 * Arguments:
 * * soundfile: sound file to be played
 * * volume_override: Optional argument to override the usual volume var for this sound
 */
/datum/looping_sound/proc/play(soundfile, volume_override)
	var/list/atoms_cache = output_atoms
	var/sound/S = sound(soundfile)
	if(direct)
		S.channel = SSsounds.random_available_channel()
		S.volume = volume_override || volume //Use volume as fallback if theres no override
	for(var/i in 1 to atoms_cache.len)
		var/atom/thing = atoms_cache[i]
		if(direct)
			SEND_SOUND(thing, S)
		else
			playsound(thing, S, volume, vary, range, falloff)

/**
 * Picks and returns soundfile
 * Arguments:
 * * starttime: world.time when this loop started
 * * _mid_sounds: sound selection override as compared to the usual mid_sounds
 */
/datum/looping_sound/proc/get_sound(starttime, _mid_sounds)
	. = _mid_sounds || mid_sounds
	while(!isfile(.) && !isnull(.))
		. = pickweight(.)

/**
 * Called on loop start
 * plays start sound, sets start_time
 * then inserts into subsystem
 */
/datum/looping_sound/proc/on_start()
	var/start_wait = 1
	if(start_sound)
		play(start_sound, start_volume)
		start_wait = start_length
	addtimer(CALLBACK(src, .proc/sound_loop), start_wait, TIMER_CLIENT_TIME, SSsound_loops)

/**
 * Called on loop end
 * if there is a end_sound, plays it
 */
/datum/looping_sound/proc/on_stop()
	if(end_sound)
		play(end_sound, end_volume)
