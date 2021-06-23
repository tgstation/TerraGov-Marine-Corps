/obj/item/radio
	icon = 'icons/obj/items/radio.dmi'
	name = "station bounced radio"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"

	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL

	var/on = TRUE
	var/frequency = FREQ_COMMON //common chat
	var/canhear_range = 3 // the range which mobs can hear this radio from

	var/unscrewed = FALSE  // Whether wires are accessible. Toggleable by screwdrivering.
	var/broadcasting = FALSE  // Whether the radio will transmit dialogue it hears nearby.
	var/listening = TRUE  // Whether the radio is currently receiving.
	var/freerange = FALSE  // If true, the radio has access to the full spectrum.
	var/subspace_transmission = FALSE  // If true, the radio transmits and receives on subspace exclusively.
	var/subspace_switchable = FALSE  // If true, subspace_transmission can be toggled at will.
	var/freqlock = FALSE  // Frequency lock to stop the user from untuning specialist radios.
	var/use_command = FALSE  // If true, broadcasts will be large and BOLD.
	var/command = FALSE  // If true, use_command can be toggled at will.
	var/independent = FALSE  // If true, can say/hear over non common channels without working tcomms equipment (for ERTs mostly).

	materials = list(/datum/material/metal = 25, /datum/material/glass = 25)

	var/list/channels = list()  // Map from name (see communications.dm) to on/off. First entry is current department (:h).
	var/list/secure_radio_connections
	var/obj/item/encryptionkey/keyslot

	var/const/FREQ_LISTENING = 1


/obj/item/radio/Initialize()
	secure_radio_connections = new
	. = ..()
	frequency = sanitize_frequency(frequency, freerange)
	set_frequency(frequency)

	wires = new /datum/wires/radio(src)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])


/obj/item/radio/Destroy()
	remove_radio_all(src) //Just to be sure
	if(keyslot)
		QDEL_NULL(keyslot)
	if(wires)
		QDEL_NULL(wires)
	return ..()


/obj/item/radio/proc/set_frequency(new_frequency)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, args)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)


/obj/item/radio/interact(mob/user)
	. = ..()
	if(.)
		return

	if(unscrewed)
		return wires.interact(user)

	var/dat


	dat += "Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>"
	dat += "Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>"
	dat += "Frequency: [format_frequency(frequency)]"

	for(var/ch_name in channels)
		dat += text_sec_channel(ch_name, channels[ch_name])

	var/datum/browser/popup = new(user, "radio", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open()


/obj/item/radio/proc/text_sec_channel(chan_name, chan_stat)
	var/list = !!(chan_stat & FREQ_LISTENING) != 0
	return {"
			<B>[chan_name]</B><br>
			Speaker: <A href='byond://?src=\ref[src];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>
			"}


/obj/item/radio/can_interact(mob/user)
	. = ..()
	if(!.)
		return FALSE

	if(!on)
		return FALSE

	return TRUE


/obj/item/radio/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["track"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)
			A.ai_actual_track(target)
		return

	else if(href_list["freq"])
		if(freqlock)
			return
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		set_frequency(new_frequency)

	else if(href_list["talk"])
		broadcasting = text2num(href_list["talk"])

	else if(href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if(!chan_name)
			listening = text2num(href_list["listen"])
		else
			if(channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
	else if(href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if(!iswirecutter(usr.get_active_held_item()))
			return
		if(wires & t1)
			wires &= ~t1
		else
			wires |= t1

	updateUsrDialog()


/obj/item/radio/talk_into(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!spans)
		spans = list(M.speech_span)
	if(!language)
		language = M.get_default_language()
	INVOKE_ASYNC(src, .proc/talk_into_impl, M, message, channel, spans.Copy(), language)
	return ITALICS | REDUCE_RANGE


/obj/item/radio/proc/talk_into_impl(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!on)
		return // the device has to be on

	if(!M || !message)
		return

	if(!M.IsVocal())
		return

	if(use_command)
		spans |= SPAN_COMMAND

	/*
	Roughly speaking, radios attempt to make a subspace transmission (which
	is received, processed, and rebroadcast by the telecomms satellite) and
	if that fails, they send a mundane radio transmission.

	Headsets cannot send/receive mundane transmissions, only subspace.
	Syndicate radios can hear transmissions on all well-known frequencies.
	CentCom radios can hear the CentCom frequency no matter what.
	*/

	// From the channel, determine the frequency and get a reference to it.
	var/freq
	if(channel && length(channels))
		if(channel == MODE_DEPARTMENT)
			channel = channels[1]
		freq = secure_radio_connections[channel]
		if(!channels[channel]) // if the channel is turned off, don't broadcast
			return
	else
		freq = frequency
		channel = null

	// Determine the identity information which will be attached to the signal.
	var/atom/movable/virtualspeaker/speaker = new(null, M, src)

	// Construct the signal
	var/datum/signal/subspace/vocal/signal = new(src, freq, speaker, language, message, spans)

	if (independent && freq >= MIN_ERT_FREQ && freq <= MAX_ERT_FREQ)
		signal.data["compression"] = 0
		signal.transmission_method = TRANSMISSION_SUPERSPACE
		signal.levels = list(0)  // reaches all Z-levels
		signal.broadcast()
		return

	// All non-independent radios make an attempt to use the subspace system first
	signal.send_to_receivers()

	// If the radio is subspace-only, that's all it can do
	if(subspace_transmission)
		return

	// Non-subspace radios will check in a couple of seconds, and if the signal
	// was never received, send a mundane broadcast (no headsets).
	addtimer(CALLBACK(src, .proc/backup_transmission, signal), 20)


/obj/item/radio/proc/backup_transmission(datum/signal/subspace/vocal/signal)
	var/turf/T = get_turf(src)
	if(signal.data["done"] && (T.z in signal.levels))
		return

	// Okay, the signal was never processed, send a mundane broadcast.
	signal.data["compression"] = 0
	signal.transmission_method = TRANSMISSION_RADIO
	signal.levels = list(T.z)
	signal.broadcast()


/obj/item/radio/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	. = ..()
	if(radio_freq || !broadcasting || get_dist(src, speaker) > canhear_range)
		return

	if(message_mode == MODE_WHISPER || message_mode == MODE_WHISPER_CRIT)
		// radios don't pick up whispers very well
		raw_message = stars(raw_message)
	else if(ismob(speaker) && loc == speaker)
		var/mob/M = speaker
		if(M.l_hand == src && message_mode != MODE_L_HAND)
			return
		else if(M.r_hand == src && message_mode != MODE_R_HAND)
			return

	talk_into(speaker, raw_message, , spans, language = message_language)


// Checks if this radio can receive on the given frequency.
/obj/item/radio/proc/can_receive(freq, level)
	// deny checks
	if(!on || !listening)
		return FALSE

	if(!(0 in level))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in level))
			return FALSE

	// allow checks: are we listening on that frequency?
	if(freq == frequency)
		return TRUE
	for(var/ch_name in channels)
		if(channels[ch_name] & FREQ_LISTENING)
			//the GLOB.GLOB.radiochannels list is located in communications.dm
			if(GLOB.radiochannels[ch_name] == text2num(freq))
				return TRUE
	return FALSE


/obj/item/radio/examine(mob/user)
	. = ..()
	if(frequency && in_range(src, user))
		to_chat(user, "<span class='notice'>It is set to broadcast over the [frequency / 10] frequency.</span>")
	if(unscrewed)
		to_chat(user, "<span class='notice'>It can be attached and modified.</span>")
	else
		to_chat(user, "<span class='notice'>It cannot be modified or attached.</span>")


/obj/item/radio/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(isscrewdriver(I) && !subspace_transmission)
		unscrewed = !unscrewed
		if(unscrewed)
			to_chat(user, "<span class='notice'>The radio can now be attached and modified!</span>")
		else
			to_chat(user, "<span class='notice'>The radio can no longer be modified or attached!</span>")

/obj/item/radio/proc/recalculateChannels()
	channels = list()
	independent = FALSE

	if(keyslot)
		for(var/ch_name in keyslot.channels)
			if(!(ch_name in channels))
				channels[ch_name] = keyslot.channels[ch_name]

		if(keyslot.independent)
			independent = TRUE

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])


/obj/item/radio/off
	listening = FALSE


/obj/item/radio/survivor
	freqlock = TRUE
	frequency = FREQ_CIV_GENERAL
