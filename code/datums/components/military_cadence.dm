// This is a song meant to by sang in-turn by multiple people, so everything has to be static
/datum/component/military_cadence
	var/static/list/cadence_ckeys_queue = list();	// Ckeys who are not allowed to sing until others have sung. Spam prevention.
	var/static/cadence_unlock_time = 0
	var/static/cadence_reset_time = 0
	var/static/curr_cadence_line_index = 1

	var/static/list/cadence_sounds = list('sound/music/edf/Line1.ogg',\
		'sound/music/edf/Line2.ogg',\
		'sound/music/edf/Line3.ogg',\
		'sound/music/edf/Line4.ogg',\
		'sound/music/edf/Line5.ogg',\
		'sound/music/edf/Line6.ogg',\
		'sound/music/edf/Line7.ogg',\
		'sound/music/edf/Line8.ogg',\
		'sound/music/edf/Line9.ogg',\
		'sound/music/edf/Line10.ogg',\
		'sound/music/edf/Line11.ogg',\
		'sound/music/edf/Line12.ogg',\
		'sound/music/edf/Line13.ogg',\
		'sound/music/edf/Line14.ogg',\
		'sound/music/edf/Line15.ogg',\
		'sound/music/edf/Line16.ogg',\
		'sound/music/edf/Line17.ogg',\
		'sound/music/edf/Line18.ogg',\
		'sound/music/edf/Line19.ogg',\
		'sound/music/edf/Line20.ogg',\
		'sound/music/edf/Line21.ogg',\
		'sound/music/edf/Line22.ogg',\
		'sound/music/edf/Line23.ogg',\
		'sound/music/edf/Line24.ogg',\
		'sound/music/edf/Line25.ogg',\
		'sound/music/edf/Line26.ogg',\
		'sound/music/edf/Line27.ogg',\
		'sound/music/edf/Line28.ogg',\
		'sound/music/edf/Line29.ogg',\
		'sound/music/edf/Line30.ogg',\
		'sound/music/edf/Line31.ogg',\
		'sound/music/edf/Line32.ogg')

	var/static/list/cadence_lyrics = list("To save our mother Earth from any alien attack!",\
		"From vicious giant insects who have once again come back!",\
		"We'll unleash all our forces, we won't cut them any slack!",\
		"The EDF deploys!",\
		"Our soldiers are prepared for any alien threats!",\
		"The navy launches ships, the air force sends their jets!",\
		"And nothing can withstand our fixed bayonets!",\
		"The EDF deploys!",\
		"Our forces have now dwindled and we pull back to regroup!",\
		"The enemy has multiplied and formed a massive group!",\
		"We better beat these bugs before we're all turned to soup!",\
		"The EDF deploys!",\
		"To take down giant insects who came from outer space!",\
		"We now head underground, for their path we must retrace!",\
		"And find their giant nest and crush the queen's carapace!",\
		"The EDF deploys!",\
		"The air force and the navy were destroyed or cast about!",\
		"Scouts, rangers, wing divers have almost been wiped out!",\
		"Despite all this, the infantry will stubbornly hold out!",\
		"The EDF deploys!",\
		"Our friends were all killed yesterday, as were our families!",\
		"Today we might not make it, facing these atrocities!",\
		"We'll never drop our banner despite our casualties!",\
		"The EDF deploys!",\
		"Two days ago my brother died, next day my lover fell!",\
		"Today most everyone was killed, on that we must not dwell!",\
		"But we will never leave the field, we'll never say farewell!",\
		"The EDF deploys!",\
		"A legendary hero soon will lead us to glory!",\
		"Eight years ago, he sunk the mothership says history!",\
		"Tomorrow, we will follow this brave soul to victory!",\
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
	if (source.ckey == null)	// Military cadences require soul to sing
		return FALSE

	if (!source.can_speak_vocal())	// No message if mute in case changeling stung or something sneaky like that
		return FALSE

	if (source.stat != CONSCIOUS)
		to_chat(source, "You must be conscious to do this!")
		return FALSE

	// Placing this condition second to last instead of last so players can see their turn order even while someone is singing
	var/source_queue_index = cadence_ckeys_queue.Find(source.ckey)
	if (source_queue_index > 0)
		var/queue_empty_positions = max(CADENCE_LOCKOUT_SIZE - cadence_ckeys_queue.len, 0)
		var/source_queue_position = source_queue_index + queue_empty_positions
		to_chat(source, "It's not yet your turn! Wait for [source_queue_position] more to sing.")
		return FALSE

	if (REALTIMEOFDAY < cadence_unlock_time)
		to_chat(source, "Someone is still singing!")
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
		playsound(source, soundin = cadence_sound, vol = 20, sound_range = 10, falloff = 1)

	// Visual
	if (ISINRANGE(curr_cadence_line_index, 1, cadence_lyrics.len))
		var/cadence_lyric = cadence_lyrics[curr_cadence_line_index]
		source.say(cadence_lyric)

// Prepare restrictions to reduce spam
/datum/component/military_cadence/proc/lock_cadence(mob/source)
	curr_cadence_line_index = curr_cadence_line_index >= cadence_sounds.len ? 1 : curr_cadence_line_index + 1
	cadence_unlock_time = REALTIMEOFDAY + CADENCE_DURATION
	cadence_reset_time = REALTIMEOFDAY + CADENCE_DURATION + CADENCE_RESET_TIME // X seconds of silence will reset the song progress to line 1

	// Add to queue so the source will not be able to sing again until they leave the queue
	cadence_ckeys_queue += source.ckey
	// Remove first index if queue is full
	if (cadence_ckeys_queue.len > CADENCE_LOCKOUT_SIZE)
		var/queue_surplus_count = cadence_ckeys_queue.len - CADENCE_LOCKOUT_SIZE // Just in case there's extra in the queue somehow
		var/cut_end_index = queue_surplus_count + 1
		cadence_ckeys_queue.Cut(1, cut_end_index)
