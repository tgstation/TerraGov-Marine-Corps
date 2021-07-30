//Darude sandstorm starts playing
/datum/weather/ash_storm/sand
	name = "severe sandstorm"
	telegraph_message = span_highdanger("You see a dust cloud rising over the horizon. That can't be good...")
	telegraph_duration = 300
	telegraph_overlay = "dust_med"
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_highdanger("<i>Hot sand and wind batter you! Get inside!</i>")
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "dust_high"

	end_message = span_boldannounce("The shrieking wind whips away the last of the sand and falls to its usual murmur. It should be safe to go outside now.")
	end_duration = 300
	end_overlay = "dust_med"

	target_trait = ZTRAIT_SANDSTORM

	probability = 40
	repeatable = FALSE

/datum/weather/ash_storm/sand/weather_act(mob/living/L)
	if(L.stat == DEAD)
		return
	if(is_storm_immune(L))
		return
	L.adjustBruteLoss(6)
	to_chat(L, span_boldannounce("You are battered by the coarse sand!"))

/datum/weather/ash_storm/sand/harmless
	name = "Sandfall"
	desc = "A passing sandstorm blankets the area in sand."

	telegraph_message = span_boldannounce("The wind begins to intensify, blowing sand up from the ground...")
	telegraph_overlay = "dust_low"
	telegraph_sound = null

	weather_message = span_notice("Gentle sand wafts down around you like grotesque snow. The storm seems to have passed you by...")
	weather_overlay = "dust_med"

	end_message = span_notice("The sandfall slows, stops. Another layer of sand on the mesa beneath your feet.")
	end_overlay = "dust_low"

	aesthetic = TRUE

	probability = 60
	repeatable = TRUE
