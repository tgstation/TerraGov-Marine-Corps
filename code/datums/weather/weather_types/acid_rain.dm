//Acid rain is part of the natural weather cycle in the humid forests of LV, and cause acid damage to anyone unprotected.
/datum/weather/acid_rain
	name = "acid rain"
	desc = "The planet's thunderstorms are by nature acidic, and will incinerate anyone standing beneath them without protection."

	telegraph_duration = 400
	telegraph_message = span_highdanger("Thunder rumbles far above. You hear acidic droplets hissing against the canopy. Seek shelter!")
	telegraph_sound = 'sound/weather/acidrain/acidrain_start.ogg'
	telegraph_overlay = "rain_med"

	weather_message = span_highdanger("<i>Acidic rain pours down around you! Get inside!</i>")
	weather_overlay = "acid_rain"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = span_boldannounce("The downpour gradually slows to a light shower. It should be safe outside now.")
	end_sound = 'sound/weather/acidrain/acidrain_end.ogg'
	end_overlay = "rain_low"

	area_type = /area
	protect_indoors = TRUE
	target_trait = ZTRAIT_ACIDRAIN

	barometer_predictable = TRUE

	probability = 40
	repeatable = FALSE

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
	if(L.stat == DEAD)
		return
	var/resist = L.get_soft_armor("acid")
	if(prob(max(0,100-resist)))
		L.adjustFireLoss(7)
		to_chat(L, span_boldannounce("You feel the acid rain melting you away!"))
	L.clean_mob()
	if(L.fire_stacks > -20)
		L.fire_stacks = max(-20, L.fire_stacks - 1)

/datum/weather/acid_rain/harmless

	telegraph_message = span_boldannounce("Thunder rumbles far above. You hear droplets drumming against the canopy.")
	telegraph_overlay = "rain_med"

	weather_message = span_boldannounce("<i>Rain pours down around you!</i>")
	weather_overlay = "rain_high"

	end_message = span_boldannounce("The downpour gradually slows to a light shower.")
	end_overlay = "rain_low"

	probability = 60
	repeatable = TRUE

/datum/weather/acid_rain/harmless/weather_act(mob/living/L)
	L.clean_mob()
	if(L.fire_stacks > -20)
		L.fire_stacks = max(-20, L.fire_stacks - 1)
		var/wetmessage = pick( "You're drenched in water!",
		"You're completely soaked by rainfall!",
		"You become soaked by the heavy rainfall!",
		"Water drips off your uniform as the rain soaks your outfit!",
		"Rushing water rolls off your face as the rain soaks you completely!",
		"Heavy raindrops hit your face as the rain thoroughly soaks your body!",
		"As you move through the heavy rain, your clothes become completely waterlogged!",
		)
		if(prob(20))
			if(isrobot(L) || isxeno(L))
				return
			else
				to_chat(L, span_warning(wetmessage))
