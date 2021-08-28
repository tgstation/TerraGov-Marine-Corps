

/**
 * # Looping sound Subsystem
 *
 * Maintains a clientside-timer-like system to handle looping sounds.
 * Looping sounds are binary inserted into [looping_sound_queue]
 * Which is then checked against REALTIMEOFDAY for when to fire [/datum/looping_sound/proc/sound_loop()]
 *
 */
SUBSYSTEM_DEF(loopingsounds)
	name = "Looping Sounds"
	flags = SS_TICKER | SS_NO_INIT
	wait = 1
	priority = FIRE_PRIORITY_LOOPINGSOUND

	/// Binary insert queue for [/datum/looping_sound]
	var/list/datum/looping_sound/looping_sound_queue = list()

/datum/controller/subsystem/loopingsounds/stat_entry(msg)
	..("Quelen:[length(looping_sound_queue)]")


/datum/controller/subsystem/loopingsounds/fire(resumed = FALSE)
	var/static/next_looping_sound_index = 0
	if(next_looping_sound_index)
		looping_sound_queue.Cut(1, next_looping_sound_index+1)
		next_looping_sound_index = 0
	for(next_looping_sound_index in 1 to length(looping_sound_queue))
		if(MC_TICK_CHECK)
			next_looping_sound_index--
			break
		var/datum/looping_sound/ctime_timer = looping_sound_queue[next_looping_sound_index]
		if(ctime_timer.nextlooptime > REALTIMEOFDAY)
			next_looping_sound_index--
			break

		if(ctime_timer.sound_loop())
			ctime_timer.nextlooptime = REALTIMEOFDAY + ctime_timer.mid_length
			BINARY_INSERT(ctime_timer, looping_sound_queue, /datum/looping_sound, ctime_timer, nextlooptime, COMPARE_KEY)
			continue
		ctime_timer.stop()

	if(next_looping_sound_index)
		looping_sound_queue.Cut(1, next_looping_sound_index+1)
		next_looping_sound_index = 0


/datum/controller/subsystem/loopingsounds/Recover()
	looping_sound_queue |= SSloopingsounds.looping_sound_queue
