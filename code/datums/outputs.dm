GLOBAL_LIST_EMPTY(outputs)

/datum/outputs
	var/text = ""
	var/list/sounds = 'sound/items/bikehorn.ogg' //can be either a sound path or a WEIGHTED list, put multiple for random selection between sounds
	var/mutable_appearance/vfx = list('icons/sound_icon.dmi',"circle", HUD_LAYER) //syntax: icon, icon_state, layer


/datum/outputs/New()
	vfx = mutable_appearance(vfx[1],vfx[2],vfx[3])


/datum/outputs/proc/send_info(mob/receiver, turf/turf_source, vol as num, vary, frequency, falloff, channel = 0)
	var/sound/sound_output
	//Pick sound
	if(islist(sounds))
		if(sounds.len)
			var/soundin = pickweight(sounds)
			sound_output = sound(get_sfx(soundin))
	else
		sound_output = sound(get_sfx(sounds))
	//Process sound
	if(sound_output)
		sound_output.wait = 0 //No queue
		sound_output.channel = channel || open_sound_channel()
		sound_output.volume = vol

		if(vary)
			if(frequency)
				sound_output.frequency = frequency
			else
				sound_output.frequency = get_rand_frequency()

		if(isturf(turf_source))
			var/turf/T = get_turf(receiver)

			//sound volume falloff with distance
			var/distance = get_dist(T, turf_source)

			sound_output.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

			if(sound_output.volume <= 0)
				return //No sound

			var/dx = turf_source.x - T.x // Hearing from the right/left
			sound_output.x = dx
			var/dz = turf_source.y - T.y // Hearing from infront/behind
			sound_output.z = dz
			// The y value is for above your head, but there is no ceiling in 2d spessmens.
			sound_output.y = 1
			sound_output.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

	receiver.display_output(sound_output, vfx, text, turf_source, vol, vary, frequency, falloff, channel)


/datum/outputs/bikehorn
	text = "You hear a HONK."
	sounds = 'sound/items/bikehorn.ogg'


/datum/outputs/alarm
	text = "You hear a blaring alarm."
	sounds = 'sound/machines/alarm.ogg'


/datum/outputs/squeak
	text = "You hear a squeak."
	sounds = 'sound/effects/mousesqueek.ogg'


/datum/outputs/clownstep
	sounds = list('sound/effects/clownstep1.ogg' = 1,'sound/effects/clownstep2.ogg' = 1)


/datum/outputs/slash
	text = "You hear a slashing noise."
	sounds = 'sound/weapons/slash.ogg'