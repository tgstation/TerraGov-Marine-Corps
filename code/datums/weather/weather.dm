//The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.

/datum/weather
	var/name = "space wind"
	var/desc = ""

	var/telegraph_message = "<span class='warning'>The wind begins to pick up.</span>" //The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_duration = 300 //In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_sound //The sound file played to everyone on an affected z-level
	var/telegraph_overlay //The overlay applied to all tiles on the z-level

	var/weather_message = "<span class='danger'>The wind begins to blow ferociously!</span>" //Displayed in chat once the weather begins in earnest
	var/weather_duration = 1200 //In deciseconds, how long the weather lasts once it begins
	var/weather_duration_lower = 1200 //See above - this is the lowest possible duration
	var/weather_duration_upper = 1500 //See above - this is the highest possible duration
	var/weather_sound
	var/weather_overlay
	var/weather_color = null

	var/end_message = "<span class='danger'>The wind relents its assault.</span>" //Displayed once the weather is over
	var/end_duration = 50 //In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_sound
	var/end_overlay

	var/area_type = /area/space //Types of area to affect
	var/list/impacted_areas = list() //Areas to be affected by the weather, calculated when the weather begins
	var/list/protected_areas = list()//Areas that are protected and excluded from the affected areas.
	var/impacted_z_levels = list() // The list of z-levels that this weather is actively affecting

	var/overlay_layer = AREA_LAYER //Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_plane = BLACKNESS_PLANE
	var/aesthetic = FALSE //If the weather has no purpose other than looks
	var/immunity_type = "storm" //Used by mobs to prevent them from being affected by the weather

	var/stage = END_STAGE //The stage of the weather, from 1-4

	// These are read by the weather subsystem and used to determine when and where to run the weather.
	var/probability = 0 // Weight amongst other eligible weather. If zero, will never happen randomly.
	var/target_trait = ZTRAIT_STATION // The z-level trait to affect when run randomly or when not overridden.

	var/barometer_predictable = FALSE
	var/next_hit_time = 0 //For barometers to know when the next storm will hit
	var/weather_alpha = 255

	var/list/particles = list()

/datum/weather/New(z_levels)
	..()
//	impacted_z_levels = z_levels

/datum/weather/proc/update_specific_area(area)
	if(stage == STARTUP_STAGE)
		if(telegraph_overlay)
			update_areas(telegraph_overlay, area)
	if(stage == MAIN_STAGE)
		if(weather_overlay)
			update_areas(weather_overlay, area)
	if(stage == WIND_DOWN_STAGE)
		if(end_overlay)
			update_areas(end_overlay, area)

/datum/weather/proc/update_specific_turf(turf)
	if(stage == STARTUP_STAGE)
		if(telegraph_overlay)
			update_areas(telegraph_overlay, null, turf)
	if(stage == MAIN_STAGE)
		if(weather_overlay)
			update_areas(weather_overlay, null, turf)
	if(stage == WIND_DOWN_STAGE)
		if(end_overlay)
			update_areas(end_overlay, null, turf)


/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	stage = STARTUP_STAGE
	var/list/affectareas = list()
	for(var/V in get_areas(area_type))
		affectareas += V
	for(var/V in protected_areas)
		affectareas -= get_areas(V)
	for(var/V in affectareas)
		var/area/A = V
		if(A.z in impacted_z_levels)
			impacted_areas |= A
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.curweathers += src
	if(telegraph_overlay)
		update_areas(telegraph_overlay)
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(telegraph_message)
				to_chat(M, telegraph_message)
			if(telegraph_sound)
				SEND_SOUND(M, sound(telegraph_sound))
	addtimer(CALLBACK(src, .proc/start), telegraph_duration)

/datum/weather/proc/starteffected()
	return
//	for(var/i in GLOB.mob_living_list)
//		var/mob/living/L = i
//		if(can_weather_act(L))
//			SSweather.uniqueadd(L)

/datum/weather/proc/initialprocess()
	return

/datum/weather/proc/start()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.roguefight)
			return
	if(stage >= MAIN_STAGE)
		return
	stage = MAIN_STAGE
	for(var/client/CL in GLOB.clients)
		CL.update_weather(TRUE)
	if(weather_overlay)
		update_areas(weather_overlay)
	starteffected()
	initialprocess()
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(weather_message)
				to_chat(M, weather_message)
			if(weather_sound)
				SEND_SOUND(M, sound(weather_sound))
	addtimer(CALLBACK(src, .proc/wind_down), weather_duration)

/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	stage = WIND_DOWN_STAGE
	for(var/client/CL in GLOB.clients)
		CL.update_weather(TRUE)
	if(end_overlay)
		update_areas(end_overlay)
	for(var/M in GLOB.player_list)
		var/turf/mob_turf = get_turf(M)
		if(mob_turf && (mob_turf.z in impacted_z_levels))
			if(end_message)
				to_chat(M, end_message)
			if(end_sound)
				SEND_SOUND(M, sound(end_sound))
	addtimer(CALLBACK(src, .proc/end), end_duration)

/datum/weather/proc/end()
	if(stage == END_STAGE)
		return 1
	stage = END_STAGE
	update_areas()
	SSweather.curweathers -= src

/datum/weather/proc/can_weather_act(atom/A) //Can this weather impact a mob?
//	var/turf/target_turf = get_turf(A)
//	if(target_turf && !(target_turf.z in impacted_z_levels))
//		return
	if(isliving(A))
		var/mob/living/L = A
		if(immunity_type in L.weather_immunities)
			return
	if(!(get_area(A) in impacted_areas))
		return
	return 1

/datum/weather/proc/weather_act(atom/A) //What effect does this weather have on the hapless mob?
	return TRUE

/datum/weather/proc/update_areas(input, specific_area, specific_turf)
/*
	for(var/area/N in impacted_areas)
		N.blend_mode = 0
		N.layer = overlay_layer
		N.plane = overlay_plane
		N.icon = 'icons/effects/weather_effects.dmi'
		N.color = weather_color
		switch(stage)
			if(STARTUP_STAGE)
				N.icon_state = telegraph_overlay
			if(MAIN_STAGE)
				N.icon_state = weather_overlay
			if(WIND_DOWN_STAGE)
				N.icon_state = end_overlay
			if(END_STAGE)
				N.color = null
				N.icon_state = ""
				N.icon = 'icons/turf/areas.dmi'
				N.layer = initial(N.layer)
				N.plane = initial(N.plane)
				N.set_opacity(FALSE)*/
	if(specific_area)
		for(var/i in specific_area)
			var/area/N = i
			for(var/turf/T in N.contents)
				START_PROCESSING(SSweather,T)
	else if(specific_turf)
		var/turf/T = specific_turf
		START_PROCESSING(SSweather,T)
	else
		for(var/i in impacted_areas)
			var/area/N = i
			for(var/turf/T in N.contents)
				START_PROCESSING(SSweather,T)

/datum/weather/proc/get_used_state()
/*	switch(stage)
		if(STARTUP_STAGE)
			return telegraph_overlay
		if(MAIN_STAGE)
			return weather_overlay
		if(WIND_DOWN_STAGE)
			return end_overlay
	return ""*/ //thsi bugs out when rain falls then u set off a bomb
	return weather_overlay