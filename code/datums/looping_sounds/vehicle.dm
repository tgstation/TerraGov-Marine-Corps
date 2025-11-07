/datum/looping_sound/bike_idle
	mid_sounds = list(
		'sound/vehicles/bikeidle-1.ogg'=1,
		'sound/vehicles/bikeidle-2.ogg'=1,
		'sound/vehicles/bikeidle-3.ogg'=1,
		'sound/vehicles/bikeidle-4.ogg'=1,
		'sound/vehicles/bikeidle-5.ogg'=1,
		'sound/vehicles/bikeidle-6.ogg'=1,
	)
	mid_length = 1 SECONDS
	start_sound = 'sound/vehicles/bikestart.ogg'
	start_length = 1 SECONDS
	volume = 25

/datum/looping_sound/som_tank_drive/hover_bike
	mid_length = 10 //The freq change makes ugly gaps otherwise, but this still isn't perfect
	vary = TRUE
	volume = 30
	frequency = 49000
