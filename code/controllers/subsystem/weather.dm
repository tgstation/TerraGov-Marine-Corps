#define STARTUP_STAGE 1
#define MAIN_STAGE 2
#define WIND_DOWN_STAGE 3
#define END_STAGE 4

//Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(weather)
	name = "Weather"
	priority = 1
	wait = 1
	runlevels = RUNLEVEL_GAME
	var/list/processing = list()
	var/list/curweathers = list()
	var/list/eligible_zlevels = list()
	var/list/next_hit_by_zlevel = list() //Used by barometers to know when the next storm is coming
	var/list/turf2process = list()
	var/list/currentrun = list()
	processing_flag = PROCESSING_WEATHER


/datum/controller/subsystem/weather/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	//cache for sanic speed (lists are references anyways)
	var/list/current_run = currentrun

	for(var/datum/weather/W in curweathers)
		W.process()

	for(var/client/C in GLOB.clients)
		C.update_weather()

	while(current_run.len)
		var/atom/thing = current_run[current_run.len]
		current_run.len--
		if(!thing || QDELETED(thing))
			processing -= thing
			if (MC_TICK_CHECK)
				return
			continue
		var/acted = FALSE
		for(var/datum/weather/W in curweathers)
			if(W.can_weather_act(thing))
				if(W.weather_act(thing))
					STOP_PROCESSING(src,thing)
				acted = TRUE
		if(!curweathers.len || !acted)
			STOP_PROCESSING(src,thing)
		if(MC_TICK_CHECK)
			return

	// start random weather on relevant levels
/*	for(var/z in eligible_zlevels)
		var/possible_weather = eligible_zlevels[z]
		var/datum/weather/W = pickweight(possible_weather)
		run_weather(W, list(text2num(z)))
		eligible_zlevels -= z
		var/randTime = rand(3000, 6000)
		addtimer(CALLBACK(src, PROC_REF(make_eligible), z, possible_weather), randTime + initial(W.weather_duration_upper), TIMER_UNIQUE) //Around 5-10 minutes between weathers
		next_hit_by_zlevel["[z]"] = world.time + randTime + initial(W.telegraph_duration)*/

/datum/controller/subsystem/weather/Initialize(start_timeofday)
	for(var/V in subtypesof(/datum/weather))
		var/datum/weather/W = V
		var/probability = initial(W.probability)
		var/target_trait = initial(W.target_trait)

		// any weather with a probability set may occur at random
		if (probability)
			for(var/z in SSmapping.levels_by_trait(target_trait))
				LAZYINITLIST(eligible_zlevels["[z]"])
				eligible_zlevels["[z]"][W] = probability
	return ..()

/datum/controller/subsystem/weather/proc/run_weather(datum/weather/weather_datum_type, z_levels)
	if (istext(weather_datum_type))
		for (var/V in subtypesof(/datum/weather))
			var/datum/weather/W = V
			if (initial(W.name) == weather_datum_type)
				weather_datum_type = V
				break
	if (!ispath(weather_datum_type, /datum/weather))
		CRASH("run_weather called with invalid weather_datum_type: [weather_datum_type || "null"]")
		return

	if (isnull(z_levels))
		z_levels = SSmapping.levels_by_trait(initial(weather_datum_type.target_trait))
	else if (isnum(z_levels))
		z_levels = list(z_levels)
	else if (!islist(z_levels))
		CRASH("run_weather called with invalid z_levels: [z_levels || "null"]")
		return

	var/datum/weather/W = new weather_datum_type(z_levels)
	W.telegraph()

/datum/controller/subsystem/weather/proc/make_eligible(z, possible_weather)
	eligible_zlevels[z] = possible_weather
	next_hit_by_zlevel["[z]"] = null

/datum/controller/subsystem/weather/proc/get_weather(z, area/active_area)
	var/datum/weather/A
	for(var/V in curweathers)
		var/datum/weather/W = V
		if((z in W.impacted_z_levels) && W.area_type == active_area.type)
			A = W
			break
	return A

/atom/proc/weather_trigger(W)
	return

/mob/living/weather_trigger(W)
	if(W==/datum/weather/rain)
		START_PROCESSING(SSweather,src)

/turf/proc/trigger_weather(atom/A)
	if(A)
		var/area/AR = get_area(src)
		if(AR)
			for(var/datum/weather/X in SSweather.curweathers)
				if(AR in X.impacted_areas)
					A.weather_trigger(X.type)
