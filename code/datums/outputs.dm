//NOTE: When adding new sounds here, check to make sure they haven't been added already via CTRL + F.

/datum/outputs
    var/text = "You hear something."
    var/list/sounds = 'sound/misc/bangindonk.ogg' //can be either a sound path or a WEIGHTED list, put multiple for random selection between sounds
    var/mutable_appearance/vfx = list('icons/mob/talk.dmi',"scream", HUD_LAYER) //syntax: icon, icon_state, layer
    var/cooldown =  0.1 SECONDS // ms

/datum/outputs/New()
    vfx = mutable_appearance(vfx[1],vfx[2],vfx[3])

/datum/outputs/proc/send_info(mob/receiver, turf/turf_source, vol as num, vary, frequency, falloff, channel = 0, pressure_affected = TRUE, last_played_time)
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
        sound_output.channel = channel || 0 // TODO: open_sound_channel()
        sound_output.volume = vol

        if(vary)
            if(frequency)
                sound_output.frequency = frequency
            else
                sound_output.frequency = GET_RANDOM_FREQ

        if(isturf(turf_source))
            var/turf/T = get_turf(receiver)

            //sound volume falloff with distance
            var/distance = get_dist(T, turf_source)

            sound_output.volume -= max(distance - world.view, 0) * 2 //multiplicative falloff to add on top of natural audio falloff.

            if(pressure_affected)
                //Atmosphere affects sound
                var/pressure_factor = 1
                var/hearer_pressure = T.return_pressure()
                var/source_pressure = turf_source.return_pressure()

                if(hearer_pressure && source_pressure)
                    var/pressure = min(hearer_pressure, source_pressure)
                    if(pressure < ONE_ATMOSPHERE)
                        pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
                else //space
                    pressure_factor = 0

                if(distance <= 1)
                    pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

                sound_output.volume *= pressure_factor
                //End Atmosphere affecting sound

            if(sound_output.volume <= 0)
                return //No sound

            var/dx = turf_source.x - T.x // Hearing from the right/left
            sound_output.x = dx
            var/dz = turf_source.y - T.y // Hearing from infront/behind
            sound_output.z = dz
            // The y value is for above your head, but there is no ceiling in 2d spessmens.
            sound_output.y = 1
            sound_output.falloff = (falloff ? falloff : FALLOFF_SOUNDS)

    if(world.time >= last_played_time + cooldown)
        receiver.display_output(sound_output, vfx, text, turf_source, vol, vary, frequency, falloff, channel, pressure_affected)
        . = TRUE //start cooling down text
    else
        receiver.display_output(sound_output, vfx, , turf_source, vol, vary, frequency, falloff, channel, pressure_affected) //changing the text takes more cpu time than a single if check

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
    text = ""
    sounds = list('sound/effects/clownstep1.ogg' = 1,'sound/effects/clownstep2.ogg' = 1)

/datum/outputs/bite
    text = "You hear ravenous biting."
    sounds = 'sound/weapons/bite.ogg'

/datum/outputs/slash
    text = "You hear a slashing noise."
    sounds = 'sound/weapons/slash.ogg'

/datum/outputs/squelch
    text = "You hear a horrendous squelching sound."
    sounds = 'sound/effects/blobattack.ogg'