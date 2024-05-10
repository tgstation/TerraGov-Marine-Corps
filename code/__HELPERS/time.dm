/proc/worldtime2text(time = world.time) // Shows current time starting at noon 12:00 (station time)
	return "[round(time / 36000) + 12]:[(time / 600 % 60) < 10 ? add_leading(num2text(time / 600 % 60), 1, "0") : time / 600 % 60]"


/proc/time_stamp(format = "hh:mm:ss") // Shows current GMT time
	return time2text(world.timeofday, format)


/proc/duration2text(time = world.time) // Shows current time starting at 0:00
	return "[round(time / 36000)]:[(time / 600 % 60) < 10 ? add_leading(num2text(time / 600 % 60), 1, "0") : time / 600 % 60]"


GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if(world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		return GLOB.midnight_rollovers++
	return GLOB.midnight_rollovers


//Takes a value of time in deciseconds.
//Returns a text value of that number in hours, minutes, or seconds.
/proc/DisplayTimeText(time_value, round_seconds_to = 0.1)
	var/second = FLOOR(time_value * 0.1, round_seconds_to)
	if(!second)
		return "right now"
	if(second < 60)
		return "[second] second[(second != 1)? "s":""]"
	var/minute = FLOOR(second / 60, 1)
	second = FLOOR(MODULUS(second, 60), round_seconds_to)
	var/secondT
	if(second)
		secondT = " and [second] second[(second != 1)? "s":""]"
	if(minute < 60)
		return "[minute] minute[(minute != 1)? "s":""][secondT]"
	var/hour = FLOOR(minute / 60, 1)
	minute = MODULUS(minute, 60)
	var/minuteT
	if(minute)
		minuteT = " and [minute] minute[(minute != 1)? "s":""]"
	if(hour < 24)
		return "[hour] hour[(hour != 1)? "s":""][minuteT][secondT]"
	var/day = FLOOR(hour / 24, 1)
	hour = MODULUS(hour, 24)
	var/hourT
	if(hour)
		hourT = " and [hour] hour[(hour != 1)? "s":""]"
	return "[day] day[(day != 1)? "s":""][hourT][minuteT][secondT]"


/proc/gameTimestamp(format = "hh:mm:ss", wtime = world.time)
	return time2text(wtime - GLOB.timezoneOffset, format)


/proc/stationTimestamp(format = "hh:mm:ss", wtime = world.time)
	return time2text(wtime - GLOB.timezoneOffset + (12 * 36000), format)


//returns timestamp in a sql and a not-quite-compliant ISO 8601 friendly format
/proc/SQLtime(timevar)
	return time2text(timevar || world.timeofday, "YYYY-MM-DD hh:mm:ss")
