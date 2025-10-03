/datum/looping_sound/tank_idle
	mid_sounds = list(
		'sound/vehicles/looping/tank_eng_idle_1.ogg'=1,
		'sound/vehicles/looping/tank_eng_idle_2.ogg'=1,
		'sound/vehicles/looping/tank_eng_idle_3.ogg'=1,
		'sound/vehicles/looping/tank_eng_idle_4.ogg'=1,
	)
	mid_length = 20
	start_sound = 'sound/vehicles/looping/tank_eng_start.ogg'
	start_length = 12
	volume = 50

/datum/looping_sound/tank_idle_interior
	mid_sounds = list(
		'sound/vehicles/looping/tank_eng_interior_idle_1.ogg'=2,
		'sound/vehicles/looping/tank_eng_interior_idle_2.ogg'=1,
	)
	mid_length = 20
	start_sound = 'sound/vehicles/looping/tank_eng_interior_start.ogg'
	start_volume = 15
	start_length = 25
	direct = TRUE
	volume = 10

/datum/looping_sound/tank_drive_interior
	mid_sounds = list(
		'sound/vehicles/looping/tank_eng_interior_loop_1.ogg'=1,
		'sound/vehicles/looping/tank_eng_interior_loop_2.ogg'=1,
		'sound/vehicles/looping/tank_eng_interior_loop_3.ogg'=1,
	)
	mid_length = 20
	direct = TRUE
	volume = 15

/datum/looping_sound/tank_drive
	mid_sounds = list(
		'sound/vehicles/looping/engine_rev_1.ogg'=1,
		'sound/vehicles/looping/engine_rev_2.ogg'=1,
	)
	vary = TRUE
	mid_length = 20
	volume = 50


/datum/looping_sound/som_tank_idle
	mid_sounds = list(
		'sound/vehicles/hover_tank/idle_1.ogg'=1,
	)
	mid_length = 20
	volume = 50

/datum/looping_sound/som_tank_idle_interior
	mid_sounds = list(
		'sound/vehicles/hover_tank/idle_interior_1.ogg'=1,
		'sound/vehicles/hover_tank/idle_interior_2.ogg'=1,
	)
	mid_length = 20
	volume = 10

/datum/looping_sound/som_tank_drive
	mid_sounds = list(
		'sound/vehicles/hover_tank/hover_1.ogg'=1,
		'sound/vehicles/hover_tank/hover_2.ogg'=1,
		'sound/vehicles/hover_tank/hover_3.ogg'=1,
		'sound/vehicles/hover_tank/hover_4.ogg'=1,
	)
	mid_length = 12
	volume = 50

/datum/looping_sound/som_tank_drive_interior
	mid_sounds = list(
		'sound/vehicles/hover_tank/hover_interior_1.ogg'=1,
		'sound/vehicles/hover_tank/hover_interior_2.ogg'=1,
		'sound/vehicles/hover_tank/hover_interior_3.ogg'=1,
		'sound/vehicles/hover_tank/hover_interior_4.ogg'=1,
	)
	mid_length = 12
	volume = 20
