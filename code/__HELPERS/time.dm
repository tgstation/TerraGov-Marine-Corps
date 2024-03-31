//Returns the world time in english
/proc/worldtime2text()
	return gameTimestamp("hh:mm:ss", world.time)

/proc/time_stamp(format = "hh:mm:ss", show_ds)
	var/time_string = time2text(world.timeofday, format)
	return show_ds ? "[time_string]:[world.timeofday % 10]" : time_string

/proc/gameTimestamp(format = "hh:mm:ss", wtime=null)
	if(!wtime)
		wtime = world.time
	return time2text(wtime - GLOB.timezoneOffset, format)

/proc/station_time(display_only = FALSE, wtime=world.time)
	return ((((wtime - SSticker.round_start_time) * SSticker.station_time_rate_multiplier) + SSticker.gametime_offset) % 864000) - (display_only? GLOB.timezoneOffset : 0)

/proc/station_time_timestamp(format = "hh:mm:ss", wtime)
	return time2text(station_time(TRUE, wtime), format)

GLOBAL_VAR_INIT(tod, FALSE)
GLOBAL_VAR_INIT(forecast, FALSE)
GLOBAL_VAR_INIT(todoverride, FALSE)
GLOBAL_VAR_INIT(dayspassed, FALSE)

/proc/settod()
	var/time = station_time()
	var/oldtod = GLOB.tod
	if(time >= SSnightshift.nightshift_start_time || time <= SSnightshift.nightshift_dawn_start)
		GLOB.tod = "night"
//		testing("set [tod]")
	if(time > SSnightshift.nightshift_dawn_start && time <= SSnightshift.nightshift_day_start)
		GLOB.tod = "dawn"
//		testing("set [tod]")
	if(time > SSnightshift.nightshift_day_start && time <= SSnightshift.nightshift_dusk_start)
		GLOB.tod = "day"
//		testing("set [tod]")
	if(time > SSnightshift.nightshift_dusk_start && time <= SSnightshift.nightshift_start_time)
		GLOB.tod = "dusk"
//		testing("set [tod]")
	if(GLOB.todoverride)
		GLOB.tod = GLOB.todoverride
	if((GLOB.tod != oldtod) && !GLOB.todoverride && (GLOB.dayspassed>1)) //weather check on tod changes
		if(!GLOB.forecast)
			switch(GLOB.tod)
				if("dawn")
					if(prob(12))
						GLOB.forecast = "fog"
					if(prob(13))
						GLOB.forecast = "rain"
				if("day")
					if(prob(5))
						GLOB.forecast = "rain"
				if("dusk")
					if(prob(13))
						GLOB.forecast = "rain"
				if("night")
					if(prob(5))
						GLOB.forecast = "fog"
					if(prob(21))
						GLOB.forecast = "rain"
			if(GLOB.forecast == "rain")
				var/foundnd
				for(var/datum/weather/rain/R in SSweather.curweathers)
					foundnd = TRUE
				if(!foundnd)
					SSweather.run_weather(/datum/weather/rain, 1)
			if(GLOB.forecast == "fog")
				var/foundnd
				for(var/datum/weather/fog/R in SSweather.curweathers)
					foundnd = TRUE
				if(!foundnd)
					SSweather.run_weather(/datum/weather/fog, 1)
		else
			switch(GLOB.forecast) //end the weather now
				if("rain")
					if(GLOB.tod == "day")
						GLOB.forecast = "rainbow"
					else
						GLOB.forecast = null
				if("rainbow")
					GLOB.forecast = null
				if("fog")
					GLOB.forecast = null

	if(GLOB.tod != oldtod)
		if(GLOB.tod == "dawn")
			GLOB.dayspassed++
			if(GLOB.dayspassed == 8)
				GLOB.dayspassed = 1
		for(var/mob/living/player in GLOB.mob_list)
			if(player.stat != DEAD && player.client)
				player.do_time_change()

	if(GLOB.tod)
		return GLOB.tod
	else
		testing("COULDNT FIND TOD [GLOB.tod] .. [time]")
		return null

/mob/living/proc/do_time_change()
	if(!mind)
		return
	if(GLOB.tod == "dawn")
		var/text_to_show
		switch(GLOB.dayspassed)
			if(1)
				text_to_show = "DAWN OF THE FIRST DAE\nMOON'S DAE"
			if(2)
				text_to_show = "DAWN OF THE SECOND DAE\nTIW'S DAE"
			if(3)
				text_to_show = "DAWN OF THE THIRD DAE\nWEDDING'S DAE"
			if(4)
				text_to_show = "DAWN OF THE FOURTH DAE\nTHULE'S DAE"
			if(5)
				text_to_show = "DAWN OF THE FIFTH DAE\nFREYJA'S DAE"
			if(6)
				text_to_show = "DAWN OF THE SIXTH DAE\nSATURN'S DAE"
			if(7)
				text_to_show = "DAWN OF THE SEVENTH DAE\nSUN'S DAE"
		if(!text_to_show)
			return
		if(text_to_show in mind.areas_entered)
			return
		mind.areas_entered += text_to_show
		var/obj/screen/area_text/T = new()
		client.screen += T
		T.maptext = {"<span style='vertical-align:top; text-align:center;
					color: #7c5b10; font-size: 150%;
					text-shadow: 1px 1px 2px black, 0 0 1em black, 0 0 0.2em black;
					font-family: "Nosfer", "Pterra";'>[text_to_show]</span>"}
		T.maptext_width = 205
		T.maptext_height = 209
		T.maptext_x = 12
		T.maptext_y = -120
		playsound_local(src, 'sound/misc/newday.ogg', 100, FALSE)
		animate(T, alpha = 255, time = 10, easing = EASE_IN)
		addtimer(CALLBACK(src, .proc/clear_area_text, T), 35)
	var/obj/screen/daynight/D = new()
	D.alpha = 0
	client.screen += D
	animate(D, alpha = 255, time = 20, easing = EASE_IN)
	addtimer(CALLBACK(src, .proc/clear_time_icon, D), 30)

/proc/station_time_debug(force_set)
	if(isnum(force_set))
		SSticker.gametime_offset = force_set
		return
	SSticker.gametime_offset = rand(0, 864000)		//hours in day * minutes in hour * seconds in minute * deciseconds in second
	if(prob(50))
		SSticker.gametime_offset = FLOOR(SSticker.gametime_offset, 3600)
	else
		SSticker.gametime_offset = CEILING(SSticker.gametime_offset, 3600)

//returns timestamp in a sql and a not-quite-compliant ISO 8601 friendly format
/proc/SQLtime(timevar)
	return time2text(timevar || world.timeofday, "YYYY-MM-DD hh:mm:ss")


GLOBAL_VAR_INIT(midnight_rollovers, 0)
GLOBAL_VAR_INIT(rollovercheck_last_timeofday, 0)
/proc/update_midnight_rollover()
	if (world.timeofday < GLOB.rollovercheck_last_timeofday) //TIME IS GOING BACKWARDS!
		return GLOB.midnight_rollovers++
	return GLOB.midnight_rollovers

/proc/weekdayofthemonth()
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day
	switch(DD)
		if(8 to 13)
			return 2
		if(14 to 20)
			return 3
		if(21 to 27)
			return 4
		if(28 to INFINITY)
			return 5
		else
			return 1

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


/proc/daysSince(realtimev)
	return round((world.realtime - realtimev) / (24 HOURS))
