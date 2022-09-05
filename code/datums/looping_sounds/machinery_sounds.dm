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

/datum/looping_sound/radio
	mid_sounds = list('sound/effects/radio_chatter/radio1.ogg' = 1, 'sound/effects/radio_chatter/radio2.ogg' = 1, 'sound/effects/radio_chatter/radio3.ogg' = 1, 'sound/effects/radio_chatter/radio4.ogg' = 1, 'sound/effects/radio_chatter/radio5.ogg' = 1, 'sound/effects/radio_chatter/radio6.ogg' = 1, 'sound/effects/radio_chatter/radio7.ogg' = 1, 'sound/effects/radio_chatter/radio8.ogg' = 1)
	mid_length = 35 SECONDS
	volume = 24
	range = 8
	falloff = 1
