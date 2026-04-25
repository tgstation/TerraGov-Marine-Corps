//Darude sandstorm starts playing
/datum/weather/ash_storm/sand
	name = "severe sandstorm"
	telegraph_message = span_userdanger("You see a dust cloud rising over the horizon. That can't be good...")
	telegraph_duration = 600
	telegraph_overlay = "dust_med"
	telegraph_sound = 'sound/effects/siren.ogg'

	weather_message = span_userdanger("<i>Hot sand and wind batter you! Get inside!</i>")
	weather_duration_lower = 600
	weather_duration_upper = 1200
	weather_overlay = "dust_high"

	end_message = span_danger("The shrieking wind whips away the last of the sand and falls to its usual murmur. It should be safe to go outside now.")
	end_duration = 300
	end_overlay = "dust_med"

	target_trait = ZTRAIT_SANDSTORM
	play_screen_indicator = TRUE

	probability = 40
	repeatable = FALSE
	use_glow = FALSE

/datum/weather/ash_storm/sand/weather_act(mob/living/L)
	if(L.stat == DEAD)
		return
	if(is_storm_immune(L))
		return
	to_chat(L, span_danger("You are battered by the coarse sand!"))
	if(!ishuman(L))
		L.adjustBruteLoss(6)
		return

	L.adjustBruteLoss(2)
	L.Stagger(2 SECONDS)


/datum/weather/ash_storm/sand/harmless
	name = "Sandfall"
	desc = "A passing sandstorm blankets the area in sand."

	telegraph_duration = 300
	telegraph_message = span_danger("The wind begins to intensify, blowing sand up from the ground...")
	telegraph_overlay = "dust_low"
	telegraph_sound = null

	weather_message = span_notice("Gentle sand wafts down around you like grotesque snow. The storm seems to have passed you by...")
	weather_overlay = "dust_med"

	end_message = span_notice("The sandfall slows, stops. Another layer of sand on the mesa beneath your feet.")
	end_overlay = "dust_low"

	aesthetic = TRUE
	play_screen_indicator = FALSE

	probability = 60
	repeatable = TRUE
