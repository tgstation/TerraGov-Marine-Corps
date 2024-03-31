#define RAD_GEIGER_LOW 100							// Geiger counter sound thresholds
#define RAD_GEIGER_MEDIUM 500
#define RAD_GEIGER_HIGH 1000

/datum/looping_sound/geiger
	mid_sounds = list(
		list('sound/blank.ogg'=1),
		list('sound/blank.ogg'=1),
		list('sound/blank.ogg'=1),
		list('sound/blank.ogg'=1)
		)
	mid_length = 2
	volume = 25
	var/last_radiation

/datum/looping_sound/geiger/get_sound(starttime)
	var/danger
	switch(last_radiation)
		if(RAD_BACKGROUND_RADIATION to RAD_GEIGER_LOW)
			danger = 1
		if(RAD_GEIGER_LOW to RAD_GEIGER_MEDIUM)
			danger = 2
		if(RAD_GEIGER_MEDIUM to RAD_GEIGER_HIGH)
			danger = 3
		if(RAD_GEIGER_HIGH to INFINITY)
			danger = 4
		else
			return null
	return ..(starttime, mid_sounds[danger])

/datum/looping_sound/geiger/stop()
	. = ..()
	last_radiation = 0

#undef RAD_GEIGER_LOW
#undef RAD_GEIGER_MEDIUM
#undef RAD_GEIGER_HIGH

/datum/looping_sound/reverse_bear_trap
	mid_sounds = list('sound/blank.ogg')
	mid_length = 3.5
	volume = 25


/datum/looping_sound/reverse_bear_trap_beep
	mid_sounds = list('sound/blank.ogg')
	mid_length = 60
	volume = 10

/datum/looping_sound/torchloop
	mid_sounds = list('sound/items/torchloop.ogg')
	mid_length = 75
	volume = 100
	extra_range = -1
	vary = TRUE

/datum/looping_sound/boneloop
	mid_sounds = list('sound/vo/mobs/ghost/skullpile_loop.ogg')
	mid_length = 65
	volume = 100
	extra_range = -1

/datum/looping_sound/fireloop
	mid_sounds = list('sound/misc/fire_place.ogg')
	mid_length = 35
	volume = 100
	extra_range = -2
	vary = TRUE

/datum/looping_sound/streetlamp1
	mid_sounds = list('sound/misc/loops/StLight1.ogg')
	mid_length = 60
	volume = 40
	extra_range = 0
	vary = TRUE
	ignore_wallz = FALSE

/datum/looping_sound/streetlamp2
	mid_sounds = list('sound/misc/loops/StLight2.ogg')
	mid_length = 40
	volume = 40
	extra_range = 0
	vary = TRUE
	ignore_wallz = FALSE

/datum/looping_sound/streetlamp3
	mid_sounds = list('sound/misc/loops/StLight3.ogg')
	mid_length = 50
	volume = 40
	extra_range = 0
	vary = TRUE
	ignore_wallz = FALSE

/datum/looping_sound/clockloop
	mid_sounds = list('sound/misc/clockloop.ogg')
	mid_length = 20
	volume = 10
	extra_range = -3
	ignore_wallz = FALSE

/datum/looping_sound/boatloop
	mid_sounds = list('sound/ambience/boat (1).ogg','sound/ambience/boat (2).ogg')
	mid_length = 60
	volume = 100
	extra_range = -1
