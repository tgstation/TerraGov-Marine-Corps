/datum/looping_sound/active_ashstorm
	mid_sounds = list(
		'sound/weather/ashstorm/outside/active_mid1.ogg'=1,
		'sound/weather/ashstorm/outside/active_mid2.ogg'=1,
		'sound/weather/ashstorm/outside/active_mid3.ogg'=1,
		'sound/weather/ashstorm/inside/active_mid1.ogg'=1,
		'sound/weather/ashstorm/inside/active_mid2.ogg'=1,
		'sound/weather/ashstorm/inside/active_mid3.ogg'=1,
	)
	mid_length = 80
	start_sound ='sound/weather/ashstorm/outside/active_start.ogg'
	start_length = 130
	end_sound = 'sound/weather/ashstorm/outside/active_end.ogg'
	volume = 65

/datum/looping_sound/weak_ashstorm
	mid_sounds = list(
		'sound/weather/ashstorm/outside/weak_mid1.ogg'=1,
		'sound/weather/ashstorm/outside/weak_mid2.ogg'=1,
		'sound/weather/ashstorm/outside/weak_mid3.ogg'=1,
		'sound/weather/ashstorm/inside/weak_mid1.ogg'=1,
		'sound/weather/ashstorm/inside/weak_mid2.ogg'=1,
		'sound/weather/ashstorm/inside/weak_mid3.ogg'=1,
	)
	mid_length = 80
	start_sound = 'sound/weather/ashstorm/outside/weak_start.ogg'
	start_length = 130
	end_sound = 'sound/weather/ashstorm/outside/weak_end.ogg'
	volume = 40

/datum/looping_sound/acidrain
	start_sound = 'sound/weather/acidrain/acidrain_start.ogg'
	start_length = 130
	mid_sounds = list(
		'sound/weather/acidrain/acidrain_mid.ogg'=1,
	)
	end_sound = 'sound/weather/acidrain/acidrain_end.ogg'
	mid_length = 80
	volume = 40
