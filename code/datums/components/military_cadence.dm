// This is a song meant to by sang in-turn by multiple people, so everything has to be static
/datum/component/military_cadence
	var/static/last_cadence_ckey = ""
	var/static/cadence_unlock_time = 0
	var/static/cadence_reset_time = 0
	var/static/curr_cadence_line_index = 1

	var/static/list/cadence_sounds = list('sound/music/edf/Line1.ogg',\
		'sound/music/edf/Line2.ogg',\
		'sound/music/edf/Line3.ogg',\
		'sound/music/edf/Line4.ogg')

	var/static/list/cadence_lyrics = list("To save our mother Earth from any alien attack!",\
		"From vicious giant insects who have once again come back!",\
		"We'll unleash all our forces, we won't cut them any slack!",\
		"The EDF deploys!")

/datum/component/military_cadence/Initialize(...)
	. = ..()
	if (!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE

/datum/component/military_cadence/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_KB_SING_MILITARY_CADENCE , .proc/sing_military_cadence)

/datum/component/military_cadence/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_KB_SING_MILITARY_CADENCE)

/datum/component/military_cadence/proc/sing_military_cadence(mob/living/source)
	if (able_to_sing(source))
		check_timeout()

		perform_singing(source)

		lock_cadence(source)

/datum/component/military_cadence/proc/able_to_sing(mob/living/source) {
	if (source.ckey == null)
		return FALSE

	if (!source.can_speak_vocal())
		return FALSE

	if (source.stat != CONSCIOUS)
		return FALSE

	if (REALTIMEOFDAY < cadence_unlock_time)
		return FALSE

	if (source.ckey == last_cadence_ckey)
		return FALSE

	return TRUE
}

// Reset song progress if too much time passed before singing the previous line
/datum/component/military_cadence/proc/check_timeout()
	if (REALTIMEOFDAY > cadence_reset_time)
		curr_cadence_line_index = 1

// Perform the singing by playing audio and speaking the lyrics
/datum/component/military_cadence/proc/perform_singing(mob/source)
	// Audio
	if (ISINRANGE(curr_cadence_line_index, 1, cadence_sounds.len))
		var/cadence_sound = cadence_sounds[curr_cadence_line_index]
		playsound(source, soundin = cadence_sound, vol = 30, sound_range = 15, falloff = 1)

	// Visual
	if (ISINRANGE(curr_cadence_line_index, 1, cadence_lyrics.len))
		var/cadence_lyric = cadence_lyrics[curr_cadence_line_index]
		source.say(cadence_lyric)

// Prepare restrictions to reduce spam
/datum/component/military_cadence/proc/lock_cadence(mob/source)
	curr_cadence_line_index = curr_cadence_line_index + 1 > cadence_sounds.len ? 1 : curr_cadence_line_index + 1
	cadence_unlock_time = REALTIMEOFDAY + 40
	cadence_reset_time = REALTIMEOFDAY + 90 // Five seconds of silence resets the song
	last_cadence_ckey = source.ckey
