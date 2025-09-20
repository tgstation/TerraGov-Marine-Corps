//Ash storms happen frequently on lavaland. They heavily obscure vision, and cause high fire damage to anyone caught outside.
/datum/weather/ash_storm
	name = "ash storm"
	desc = "An intense atmospheric storm lifts ash off of the planet's surface and billows it down across the area, dealing intense fire damage to the unprotected."

	telegraph_message = span_userdanger("An eerie moan rises on the wind. Sheets of burning ash blacken the horizon. Seek shelter.")
	telegraph_duration = 600
	telegraph_overlay = "light_ash"

	weather_message = span_userdanger("<i>Smoldering clouds of scorching ash billow down around you! Get inside!</i>")
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "ash_storm"

	end_message = span_danger("The shrieking wind whips away the last of the ash and falls to its usual murmur. It should be safe to go outside now.")
	end_duration = 300
	end_overlay = "light_ash"

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_ASHSTORM

	probability = 40

	barometer_predictable = TRUE
	play_screen_indicator = TRUE

	var/datum/looping_sound/active_ashstorm/sound_active_ashstorm = new(list(), FALSE, TRUE)
	var/datum/looping_sound/weak_ashstorm/sound_weak_ashstorm = new(list(), FALSE, TRUE)

/datum/weather/ash_storm/telegraph()
	. = ..()
	var/list/impacted_mobs = list()
	for(var/mob/impacted_mob AS in GLOB.player_list)
		if(!(impacted_mob?.client?.prefs?.toggles_sound & SOUND_WEATHER))
			continue
		var/turf/impacted_mob_turf = get_turf(impacted_mob)
		if(!impacted_mob_turf || !(impacted_mob.z in impacted_z_levels))
			continue
		impacted_mobs |= impacted_mob
		CHECK_TICK

	sound_active_ashstorm.output_atoms = impacted_mobs
	sound_weak_ashstorm.output_atoms = impacted_mobs

	sound_weak_ashstorm.start()

/datum/weather/ash_storm/start()
	. = ..()
	sound_weak_ashstorm.stop()

	sound_active_ashstorm.start()

/datum/weather/ash_storm/wind_down()
	. = ..()
	sound_active_ashstorm.stop()

	sound_weak_ashstorm.start()

/datum/weather/ash_storm/end()
	. = ..()
	sound_weak_ashstorm.stop()

/datum/weather/ash_storm/proc/is_storm_immune(atom/L)
	while (L && !isturf(L))
		if(iscarbon(L))// if we're a non immune mob inside an immune mob we have to reconsider if that mob is immune to protect ourselves
			var/mob/living/carbon/the_mob = L
			if(the_mob.status_flags & INCORPOREAL)
				return TRUE
		L = L.loc //Check parent items immunities (recurses up to the turf)
	return FALSE //RIP you

/datum/weather/ash_storm/weather_act(mob/living/L)
	if(L.stat == DEAD)
		return
	if(is_storm_immune(L))
		return
	L.adjustFireLoss(6)


//Emberfalls are the result of an ash storm passing by close to the playable area of lavaland. They have a 10% chance to trigger in place of an ash storm.
/datum/weather/ash_storm/emberfall
	name = "emberfall"
	desc = "A passing ash storm blankets the area in harmless embers."

	telegraph_duration = 300
	telegraph_message = span_danger("An eerie moan rises on the wind. Sheets of burning ash blacken the horizon.")

	weather_message = span_notice("Gentle embers waft down around you like grotesque snow. The storm seems to have passed you by...")
	weather_overlay = "light_ash"

	end_message = span_notice("The emberfall slows, stops. Another layer of hardened soot to the basalt beneath your feet.")
	end_sound = null

	aesthetic = TRUE
	play_screen_indicator = FALSE

	probability = 60
