/**
 * _stubs.dm
 *
 * This file contains constructs that the process scheduler expects to exist
 * in a standard ss13 fork.
 */

/**
 * message_admins
 *
 * sends a message to admins
 */
///proc/message_admins(msg)
//	to_chat(world, msg)

/**
 * logTheThing
 *
 * In goonstation, this proc writes a message to either the world log or diary.
 *
 * Blame Keelin.
 */
/proc/logTheThing(type, source, target, text, diaryType)
	if(diaryType)
		to_chat(world, "Diary: \[[diaryType]:[type]] [text]")
	else
		to_chat(world, "Log: \[[type]] [text]")

/**
 * var/disposed
 *
 * In goonstation, disposed is set to 1 after an object enters the delete queue
 * or the object is placed in an object pool (effectively out-of-play so to speak)
 */
/datum/var/disposed

#define DELTA_CALC max(max(world.tick_usage, world.cpu) / 100, 1)
#define DS2TICKS(DS) ((DS)/world.tick_lag)
//returns the number of ticks slept
/proc/stoplag(initial_delay)
	//replace with something to determine if initializations have happened
	if (!processScheduler)
		sleep(world.tick_lag)
		return 1
	if (!initial_delay)
		initial_delay = world.tick_lag
	. = 0
	var/i = DS2TICKS(initial_delay) //get from _defines/math.dm
	do
		. += CEILING(i*DELTA_CALC, 1)
		sleep(i*world.tick_lag*DELTA_CALC)
		i *= 2
	while (world.tick_usage > TICK_LIMIT_TO_RUN)

#undef DELTA_CALC
