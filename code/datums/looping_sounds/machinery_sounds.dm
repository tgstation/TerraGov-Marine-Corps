/datum/looping_sound/generator
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 4
	mid_sounds = list('sound/machines/generator/generator_mid1.ogg'=1, 'sound/machines/generator/generator_mid2.ogg'=1, 'sound/machines/generator/generator_mid3.ogg'=1)
	mid_length = 4
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40

/datum/looping_sound/grill
	mid_sounds = list('sound/machines/grill/grillsizzle.ogg' = 1)
	mid_length = 18
	volume = 50

/datum/looping_sound/alarm_loop
	mid_sounds = list('sound/machines/sound_machines_FireAlarm2.ogg', 'sound/machines/sound_machines_FireAlarm4.ogg')
	mid_length = 18
	volume = 50
	range = 20

/datum/looping_sound/river_loop
	mid_sounds = list(
		'sound/ambience/river/stream_1.ogg' = 1,
		'sound/ambience/river/stream_2.ogg' = 1,
		'sound/ambience/river/stream_3.ogg' = 1,
	)
	mid_length = 2.5 SECONDS
	volume = 25
	range = 14
	falloff = 2
	ambient_sound = TRUE

/datum/looping_sound/water_res_loop
	mid_sounds = list('sound/effects/natural/wave1.ogg' = 1, 'sound/effects/natural/wave2.ogg' = 1, 'sound/effects/natural/wave3.ogg' = 1)
	mid_length = 4 SECONDS
	volume = 28
	range = 7

/datum/looping_sound/drip_loop
	mid_sounds = list('sound/effects/drip1.ogg' = 1, 'sound/effects/drip2.ogg' = 1, 'sound/effects/drip3.ogg' = 1, 'sound/effects/drip4.ogg' = 1, 'sound/effects/drip5.ogg' = 1)
	mid_length = 4
	volume = 25
	range = 7

/datum/looping_sound/radio
	mid_sounds = list('sound/effects/radio_chatter/radio1.ogg' = 1, 'sound/effects/radio_chatter/radio2.ogg' = 1, 'sound/effects/radio_chatter/radio3.ogg' = 1, 'sound/effects/radio_chatter/radio4.ogg' = 1, 'sound/effects/radio_chatter/radio5.ogg' = 1, 'sound/effects/radio_chatter/radio6.ogg' = 1, 'sound/effects/radio_chatter/radio7.ogg' = 1, 'sound/effects/radio_chatter/radio8.ogg' = 1)
	mid_length = 35 SECONDS
	volume = 24
	range = 8
	falloff = 1

/datum/looping_sound/flickeringambient
	mid_sounds = list('sound/effects/lightbuzzloop6.ogg' = 1)
	mid_length = 5 SECONDS
	volume = 50
	range = 6
	falloff = 2

/datum/looping_sound/geiger
	mid_sounds = list(
		list('sound/effects/geiger/low1.ogg'=1, 'sound/effects/geiger/low2.ogg'=1, 'sound/effects/geiger/low3.ogg'=1, 'sound/effects/geiger/low4.ogg'=1),
		list('sound/effects/geiger/med1.ogg'=1, 'sound/effects/geiger/med2.ogg'=1, 'sound/effects/geiger/med3.ogg'=1, 'sound/effects/geiger/med4.ogg'=1),
		list('sound/effects/geiger/high1.ogg'=1, 'sound/effects/geiger/high2.ogg'=1, 'sound/effects/geiger/high3.ogg'=1, 'sound/effects/geiger/high4.ogg'=1),
		list('sound/effects/geiger/ext1.ogg'=1, 'sound/effects/geiger/ext2.ogg'=1, 'sound/effects/geiger/ext3.ogg'=1, 'sound/effects/geiger/ext4.ogg'=1)
		)
	mid_length = 2
	volume = 20
	max_loops = 5
	direct = TRUE
	///how loud and angry the geiger counter will sound
	var/severity = 1

/datum/looping_sound/geiger/get_sound(starttime)
	return ..(starttime, mid_sounds[severity])

/datum/looping_sound/mech_overload
	start_sound = 'sound/mecha/overload_start.ogg'
	start_length = 9
	mid_sounds = list('sound/mecha/overload_loop.ogg'=1)
	mid_length = 6
	end_sound = 'sound/mecha/overload_stop.ogg'
	volume = 40

/datum/looping_sound/benchpress_creak
	mid_sounds = list('sound/machines/creak.ogg'=1)
	mid_length = 8
	volume = 60

/datum/looping_sound/scan_pulse
	mid_sounds = list('sound/items/scan_pulse.wav' = 1)
	mid_length = 5 SECONDS
	volume = 60
