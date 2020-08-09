//Acid rain is part of the natural weather cycle in the humid forests of LV, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 400
	telegraph_message = "<span class='highdanger'>Thunder rumbles far above. You hear acidic droplets hissing against the canopy. Seek shelter!</span>"
	telegraph_sound = 'sound/weather/acidrain/acidrain_start.ogg'
	telegraph_overlay = "rain_med"

	weather_message = "<span class='highdanger'><i>Acidic rain pours down around you! Get inside!</i></span>"
	weather_overlay = "rain_high"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = "<span class='boldannounce'>The downpour gradually slows to a light shower. It should be safe outside now.</span>"
	end_sound = 'sound/weather/acidrain/acidrain_end.ogg'
	end_overlay = "rain_med"

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_ACIDRAIN

	barometer_predictable = TRUE

	probability = 60

	var/datum/looping_sound/acidrain/midsound = new(list(), FALSE, TRUE)

/datum/weather/acid_rain/telegraph()
	. = ..()
	var/list/eligible_areas = list()
	for (var/z in impacted_z_levels)
		eligible_areas += SSmapping.areas_in_z["[z]"]

	midsound.output_atoms = eligible_areas

/datum/weather/acid_rain/start()
	. = ..()
	midsound.start()

/datum/weather/acid_rain/end()
	. = ..()
	midsound.stop()

/datum/weather/acid_rain/weather_act(mob/living/L)
	var/resist = L.getarmor(null, "acid")
	if(prob(max(0,100-resist)))
		L.adjustFireLoss(7)
		to_chat(L, "<span class='boldannounce'>You feel the acid rain melting you away!</span>")

/datum/weather/acid_rain/harmless

	telegraph_message = "<span class='boldannounce'>Thunder rumbles far above. You hear droplets drumming against the canopy.</span>"
	telegraph_overlay = "rain_low"

	weather_message = "<span class='boldannounce'><i>Rain pours down around you!</i></span>"
	weather_overlay = "rain_med"

	end_message = "<span class='boldannounce'>The downpour gradually slows to a light shower.</span>"
	end_overlay = "rain_low"

	aesthetic = TRUE

	probability = 40
