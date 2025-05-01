/**
 * Causes weather to occur on a z level in certain area types
 *
 * The effects of weather occur across an entire z-level. For instance, lavaland has periodic ash storms that scorch most unprotected creatures.
 * Weather always occurs on different z levels at different times, regardless of weather type.
 * Can have custom durations, targets, and can automatically protect indoor areas.
 *
 */

/datum/weather
	/// name of weather
	var/name = "space wind"
	/// description of weather
	var/desc = "Heavy gusts of wind blanket the area, periodically knocking down anyone caught in the open."
	/// The message displayed in chat to foreshadow the weather's beginning
	var/telegraph_message = span_warning("The wind begins to pick up.")
	/// In deciseconds, how long from the beginning of the telegraph until the weather begins
	var/telegraph_duration = 300
	/// The sound file played to everyone on an affected z-level
	var/telegraph_sound
	/// The overlay applied to all tiles on the z-level
	var/telegraph_overlay

	/// Displayed in chat once the weather begins in earnest
	var/weather_message = span_userdanger("The wind begins to blow ferociously!")
	/// In deciseconds, how long the weather lasts once it begins
	var/weather_duration = 1200
	/// See above - this is the lowest possible duration
	var/weather_duration_lower = 1200
	/// See above - this is the highest possible duration
	var/weather_duration_upper = 1500
	/// Looping sound while weather is occuring
	var/weather_sound
	/// Area overlay while the weather is occuring
	var/weather_overlay
	/// Color to apply to the area while weather is occuring
	var/weather_color = null

	/// Displayed once the weather is over
	var/end_message = span_danger("The wind relents its assault.")
	/// In deciseconds, how long the "wind-down" graphic will appear before vanishing entirely
	var/end_duration = 300
	/// Sound that plays while weather is ending
	var/end_sound
	/// Area overlay while weather is ending
	var/end_overlay

	/// Types of area to affect
	var/area_type = /area/space
	/// TRUE value protects areas with outdoors marked as false, regardless of area type
	var/protect_indoors = FALSE
	/// Areas to be affected by the weather, calculated when the weather begins
	var/list/impacted_areas = list()
	/// Areas that are protected and excluded from the affected areas.
	var/list/protected_areas = list()
	/// The list of z-levels that this weather is actively affecting
	var/list/impacted_z_levels
	/// Areas affected by weather have their blend modes changed
	var/list/impacted_areas_blend_modes = list()

	/// Since it's above everything else, this is the layer used by default. TURF_LAYER is below mobs and walls if you need to use that.
	var/overlay_layer = AREA_LAYER
	/// Plane for the overlay
	var/overlay_plane = ABOVE_LIGHTING_PLANE
	/// If the weather has no purpose other than looks
	var/aesthetic = FALSE
	/// If this bit of weather should also draw an overlay that's uneffected by lighting onto the area
	/// Taken from weather_glow.dmi
	var/use_glow = TRUE
	/// List of all overlays to apply to our turfs
	var/list/overlay_cache
	/// whether to play a warning to players that the weather is inbound
	var/play_screen_indicator = FALSE

	/// The stage of the weather, from 1-4
	var/stage = END_STAGE

	/// Weight amongst other eligible weather. If zero, will never happen randomly.
	var/probability = 0
	/// If this weather can happen multiple times in a row.
	var/repeatable = TRUE
	/// The z-level trait to affect when run randomly or when not overridden.
	var/target_trait = ZTRAIT_STATION

	/// Whether a barometer can predict when the weather will happen
	var/barometer_predictable = FALSE
	/// For barometers to know when the next storm will hit
	var/next_hit_time = 0

/datum/weather/New(z_levels)
	..()
	impacted_z_levels = z_levels

/**
 * Telegraphs the beginning of the weather on the impacted z levels
 *
 * Sends sounds and details to mobs in the area
 * Calculates duration and hit areas, and makes a callback for the actual weather to start
 *
 */
/datum/weather/proc/telegraph()
	if(stage == STARTUP_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_TELEGRAPH(type), src)
	stage = STARTUP_STAGE
	var/list/affectareas = get_areas(area_type)
	for(var/V in protected_areas)
		affectareas -= get_areas(V)
	for(var/V in affectareas)
		var/area/A = V
		if(protect_indoors && !A.outside)
			continue
		if(A.z in impacted_z_levels)
			impacted_areas |= A
	weather_duration = rand(weather_duration_lower, weather_duration_upper)
	SSweather.processing |= src
	update_areas()
	for(var/mob/impacted_mob AS in GLOB.player_list)
		var/turf/impacted_mob_turf = get_turf(impacted_mob)
		if(!impacted_mob_turf || !(impacted_mob.z in impacted_z_levels))
			continue
		if(play_screen_indicator)
			impacted_mob.play_screen_text(HUD_ANNOUNCEMENT_FORMATTING("WEATHER WARNING", "[capitalize(name)] inbound. Seek shelter", RIGHT_ALIGN_TEXT), /atom/movable/screen/text/screen_text/rightaligned)
		if(telegraph_message)
			to_chat(impacted_mob, telegraph_message)
		if(!(impacted_mob?.client?.prefs?.toggles_sound & SOUND_WEATHER))
			continue
		if(telegraph_sound)
			SEND_SOUND(impacted_mob, sound(telegraph_sound, volume = 60))
	addtimer(CALLBACK(src, PROC_REF(start)), telegraph_duration)

/**
 * Starts the actual weather and effects from it
 *
 * Updates area overlays and sends sounds and messages to mobs to notify them
 * Begins dealing effects from weather to mobs in the area
 *
 */
/datum/weather/proc/start()
	if(stage >= MAIN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_START(type), src)
	stage = MAIN_STAGE
	update_areas()
	for(var/mob/impacted_mob AS in GLOB.player_list)
		var/turf/impacted_mob_turf = get_turf(impacted_mob)
		if(!impacted_mob_turf || !(impacted_mob.z in impacted_z_levels))
			continue
		if(weather_message)
			to_chat(impacted_mob, weather_message)
		if(!(impacted_mob?.client?.prefs?.toggles_sound & SOUND_WEATHER))
			continue
		if(weather_sound)
			SEND_SOUND(impacted_mob, sound(weather_sound))
	addtimer(CALLBACK(src, PROC_REF(wind_down)), weather_duration)

/**
 * Weather enters the winding down phase, stops effects
 *
 * Updates areas to be in the winding down phase
 * Sends sounds and messages to mobs to notify them
 *
 */
/datum/weather/proc/wind_down()
	if(stage >= WIND_DOWN_STAGE)
		return
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_WINDDOWN(type), src)
	stage = WIND_DOWN_STAGE
	update_areas()
	for(var/mob/impacted_mob AS in GLOB.player_list)
		var/turf/impacted_mob_turf = get_turf(impacted_mob)
		if(!impacted_mob_turf || !(impacted_mob.z in impacted_z_levels))
			continue
		if(end_message)
			to_chat(impacted_mob, end_message)
		if(!(impacted_mob?.client?.prefs?.toggles_sound & SOUND_WEATHER))
			continue
		if(end_sound)
			SEND_SOUND(impacted_mob, sound(end_sound))
	addtimer(CALLBACK(src, PROC_REF(end)), end_duration)

/**
 * Fully ends the weather
 *
 * Effects no longer occur and area overlays are removed
 * Removes weather from processing completely
 *
 */
/datum/weather/proc/end()
	if(stage == END_STAGE)
		return TRUE
	SEND_GLOBAL_SIGNAL(COMSIG_WEATHER_END(type), src)
	stage = END_STAGE
	SSweather.processing -= src
	update_areas()

/**
 * Returns TRUE if the living mob can be affected by the weather
 *
 */
/datum/weather/proc/can_weather_act(mob/living/L)
	if(!isturf(L.loc))
		return FALSE
	var/turf/mob_turf = L.loc
	if(L && !(mob_turf.z in impacted_z_levels))
		return FALSE
	if(!(get_area(L) in impacted_areas))
		return FALSE
	return TRUE

/**
 * Affects the mob with whatever the weather does
 *
 */
/datum/weather/proc/weather_act(mob/living/L)
	return


/**
 * Updates the overlays on impacted areas
 */
/datum/weather/proc/update_areas()
	var/list/new_overlay_cache = generate_overlay_cache()
	for(var/area/impacted as anything in impacted_areas)
		if(length(overlay_cache))
			impacted.overlays -= overlay_cache
			if(impacted_areas_blend_modes[impacted])
				// revert the blend mode to the old state
				impacted.blend_mode = impacted_areas_blend_modes[impacted]
				impacted_areas_blend_modes[impacted] = null
		if(length(new_overlay_cache))
			impacted.overlays += new_overlay_cache
			// only change the blend mode if it's not default or overlay
			if(impacted.blend_mode > BLEND_OVERLAY)
				// save the old blend mode state
				impacted_areas_blend_modes[impacted] = impacted.blend_mode
				impacted.blend_mode = BLEND_OVERLAY

	overlay_cache = new_overlay_cache

/// Returns a list of visual offset -> overlays to use
/datum/weather/proc/generate_overlay_cache()
	// We're ending, so no overlays at all
	if(stage == END_STAGE)
		return list()

	var/weather_state = ""
	switch(stage)
		if(STARTUP_STAGE)
			weather_state = telegraph_overlay
		if(MAIN_STAGE)
			weather_state = weather_overlay
		if(WIND_DOWN_STAGE)
			weather_state = end_overlay

	// Use all possible offsets
	// Yes this is a bit annoying, but it's too slow to calculate and store these from turfs, and it shouldn't (I hope) look weird
	var/list/gen_overlay_cache = list()
	for(var/offset in 0 to SSmapping.max_plane_offset)
		// Note: what we do here is effectively apply two overlays to each area, for every unique multiz layer they inhabit
		// One is the base, which will be masked by lighting. the other is "glowing", and provides a nice contrast
		// This method of applying one overlay per z layer has some minor downsides, in that it could lead to improperly doubled effects if some have alpha
		// I prefer it to creating 2 extra plane masters however, so it's a cost I'm willing to pay
		// LU
		if(use_glow)
			var/mutable_appearance/glow_overlay = mutable_appearance('icons/effects/glow_weather.dmi', weather_state, overlay_layer, null, WEATHER_GLOW_PLANE, 100, offset_const = offset)
			glow_overlay.color = weather_color
			gen_overlay_cache += glow_overlay

		var/mutable_appearance/new_weather_overlay = mutable_appearance('icons/effects/weather_effects.dmi', weather_state, overlay_layer, plane = overlay_plane, offset_const = offset)
		new_weather_overlay.color = weather_color
		gen_overlay_cache += new_weather_overlay

	return gen_overlay_cache

