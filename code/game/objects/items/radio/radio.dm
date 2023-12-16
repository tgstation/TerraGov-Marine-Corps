/obj/item/radio
	icon = 'icons/obj/items/radio.dmi'
	name = "station bounced radio"
	icon_state = "walkietalkie"
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/equipment/tools_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/equipment/tools_right.dmi',
	)
	item_state = "radio"

	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = WEIGHT_CLASS_SMALL

	///if FALSE, broadcasting and listening dont matter and this radio shouldnt do anything
	var/on = TRUE
	///the "default" radio frequency this radio is set to, listens and transmits to this frequency by default. wont work if the channel is encrypted
	var/frequency = FREQ_COMMON

	/// Whether the radio will transmit dialogue it hears nearby into its radio channel.
	var/broadcasting = FALSE
	/// Whether the radio is currently receiving radio messages from its radio frequencies.
	var/listening = TRUE

	//the below three vars are used to track listening and broadcasting should they be forced off for whatever reason but "supposed" to be active
	//eg player sets the radio to listening, but an emp or whatever turns it off, its still supposed to be activated but was forced off,
	//when it wears off it sets listening to should_be_listening

	///used for tracking what broadcasting should be in the absence of things forcing it off, eg its set to broadcast but gets emp'd temporarily
	var/should_be_broadcasting = FALSE
	///used for tracking what listening should be in the absence of things forcing it off, eg its set to listen but gets emp'd temporarily
	var/should_be_listening = TRUE

	/// Both the range around the radio in which mobs can hear what it receives and the range the radio can hear
	var/canhear_range = 3
	/// Tracks the number of EMPs currently stacked.
	var/emped = 0

	/// Whether wires are accessible. Toggleable by screwdrivering.
	var/unscrewed = FALSE
	/// If true, the radio has access to the full spectrum.
	var/freerange = FALSE
	/// If true, the radio transmits and receives on subspace exclusively.
	var/subspace_transmission = FALSE
	/// If true, subspace_transmission can be toggled at will.
	var/subspace_switchable = FALSE
	/// Frequency lock to stop the user from untuning specialist radios.
	var/freqlock = FALSE
	/// If true, broadcasts will be large and BOLD.
	var/use_command = FALSE
	/// If true, use_command can be toggled at will.
	var/command = FALSE
	/// If true, can say/hear over non common channels without working tcomms equipment (for ERTs mostly).
	var/independent = FALSE

	/// associative list of the encrypted radio channels this radio is currently set to listen/broadcast to, of the form: list(channel name = TRUE or FALSE)
	var/list/channels = list()
	/// associative list of the encrypted radio channels this radio can listen/broadcast to, of the form: list(channel name = channel frequency)
	var/list/secure_radio_connections
	var/obj/item/encryptionkey/keyslot

	var/const/FREQ_LISTENING = 1

/obj/item/radio/Initialize(mapload)
	wires = new /datum/wires/radio(src)
	secure_radio_connections = list()
	. = ..()

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])

	set_listening(listening)
	set_broadcasting(broadcasting)
	set_frequency(sanitize_frequency(frequency, freerange))
	set_on(on)

/obj/item/radio/Destroy()
	remove_radio_all(src) //Just to be sure
	QDEL_NULL(wires)
	QDEL_NULL(keyslot)
	return ..()

/obj/item/radio/proc/set_frequency(new_frequency)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, args)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)

///simple getter for the on variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/is_on()
	return on

///simple getter for the frequency variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/get_frequency()
	return frequency

///simple getter for the broadcasting variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/get_broadcasting()
	return broadcasting

///simple getter for the listening variable. necessary due to VAR_PROTECTED
/obj/item/radio/proc/get_listening()
	return listening

/obj/item/radio/interact(mob/user)
	. = ..()
	if(.)
		return

	if(unscrewed)
		return wires.interact(user)

	var/dat


	dat += "Microphone: [broadcasting ? "<A href='byond://?src=[text_ref(src)];talk=0'>Engaged</A>" : "<A href='byond://?src=[text_ref(src)];talk=1'>Disengaged</A>"]<BR>"
	dat += "Speaker: [listening ? "<A href='byond://?src=[text_ref(src)];listen=0'>Engaged</A>" : "<A href='byond://?src=[text_ref(src)];listen=1'>Disengaged</A>"]<BR>"
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
			Speaker: <A href='byond://?src=[text_ref(src)];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>
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
		set_broadcasting(text2num(href_list["talk"]))

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

/**
 * setter for the listener var, adds or removes this radio from the global radio list if we are also on
 *
 * * new_listening - the new value we want to set listening to
 * * actual_setting - whether or not the radio is supposed to be listening, sets should_be_listening to the new listening value if true, otherwise just changes listening
 */
/obj/item/radio/proc/set_listening(new_listening, actual_setting = TRUE)

	listening = new_listening
	if(actual_setting)
		should_be_listening = listening

	if(listening && on)
		recalculateChannels()
		add_radio(src, frequency)
	else if(!listening)
		remove_radio_all(src)

/**
 * setter for broadcasting that makes us not hearing sensitive if not broadcasting and hearing sensitive if broadcasting
 * hearing sensitive in this case only matters for the purposes of listening for words said in nearby tiles, talking into us directly bypasses hearing
 *
 * * new_broadcasting- the new value we want to set broadcasting to
 * * actual_setting - whether or not the radio is supposed to be broadcasting, sets should_be_broadcasting to the new value if true, otherwise just changes broadcasting
 */
/obj/item/radio/proc/set_broadcasting(new_broadcasting, actual_setting = TRUE)

	broadcasting = new_broadcasting
	if(actual_setting)
		should_be_broadcasting = broadcasting

	if(broadcasting && on) //we dont need hearing sensitivity if we arent broadcasting, because talk_into doesnt care about hearing
		become_hearing_sensitive(INNATE_TRAIT)
	else if(!broadcasting)
		lose_hearing_sensitivity(INNATE_TRAIT)

///setter for the on var that sets both broadcasting and listening to off or whatever they were supposed to be
/obj/item/radio/proc/set_on(new_on)

	on = new_on

	if(on)
		set_broadcasting(should_be_broadcasting)//set them to whatever theyre supposed to be
		set_listening(should_be_listening)
	else
		set_broadcasting(FALSE, actual_setting = FALSE)//fake set them to off
		set_listening(FALSE, actual_setting = FALSE)

/obj/item/radio/talk_into(atom/movable/talking_movable, message, channel, list/spans, datum/language/language, list/message_mods)
	if(!spans)
		spans = list(talking_movable.speech_span)
	if(!language)
		language = talking_movable.get_default_language()
	INVOKE_ASYNC(src, PROC_REF(talk_into_impl), talking_movable, message, channel, spans.Copy(), language, message_mods)
	return ITALICS | REDUCE_RANGE


/obj/item/radio/proc/talk_into_impl(atom/movable/talking_movable, message, channel, list/spans, datum/language/language, list/message_mods)
	if(!on)
		return // the device has to be on

	if(!talking_movable || !message)
		return

	if(!talking_movable.IsVocal())
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
	var/atom/movable/virtualspeaker/speaker = new(null, talking_movable, src)

	// Construct the signal
	var/datum/signal/subspace/vocal/signal = new(src, freq, speaker, language, message, spans)

	if (independent && freq >= MIN_ERT_FREQ && freq <= MAX_ERT_FREQ)
		signal.data["compression"] = 0
		signal.transmission_method = TRANSMISSION_SUPERSPACE
		signal.levels = list(0)
		signal.broadcast()
		return

	var/area/A = get_area(src)
	var/radio_disruption = CAVE_NO_INTERFERENCE
	if(!isnull(A) && (A.ceiling >= CEILING_UNDERGROUND) && !(A.flags_area & ALWAYS_RADIO))
		radio_disruption = CAVE_MINOR_INTERFERENCE
		if(A.ceiling >= CEILING_DEEP_UNDERGROUND)
			radio_disruption = CAVE_FULL_INTERFERENCE

	var/list/inplace_interference = list(radio_disruption)
	SEND_SIGNAL(talking_movable, COMSIG_CAVE_INTERFERENCE_CHECK, inplace_interference)
	radio_disruption = inplace_interference[1]

	switch(radio_disruption)
		if(CAVE_MINOR_INTERFERENCE)
			signal.data["compression"] += rand(20, 40)
		if(CAVE_FULL_INTERFERENCE)
			return

	// All non-independent radios make an attempt to use the subspace system first
	signal.send_to_receivers()

	// If the radio is subspace-only, that's all it can do
	if(subspace_transmission)
		return

	// Non-subspace radios will check in a couple of seconds, and if the signal
	// was never received, send a mundane broadcast (no headsets).
	addtimer(CALLBACK(src, PROC_REF(backup_transmission), signal), 20)


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
		return FALSE

	if(message_mode == MODE_WHISPER || message_mode == MODE_WHISPER_CRIT)
		// radios don't pick up whispers very well
		raw_message = stars(raw_message)
	else if(ismob(speaker) && loc == speaker)
		var/mob/M = speaker
		if(M.l_hand == src && message_mode != MODE_L_HAND)
			return FALSE
		else if(M.r_hand == src && message_mode != MODE_R_HAND)
			return FALSE

	talk_into(speaker, raw_message, , spans, language = message_language)


/// Checks if this radio can receive on the given frequency.
/obj/item/radio/proc/can_receive(input_frequency, list/levels)
	if(!(RADIO_NO_Z_LEVEL_RESTRICTION in levels))
		var/turf/position = get_turf(src)
		if(!position || !(position.z in levels))
			return FALSE
		var/radio_disruption = CAVE_NO_INTERFERENCE
		var/area/A = get_area(src)
		if(A?.ceiling >= CEILING_UNDERGROUND && !(A.flags_area & ALWAYS_RADIO))
			radio_disruption = CAVE_MINOR_INTERFERENCE //Unused for this case but may aswell create parity on what the value of the var is.
			if(A.ceiling >= CEILING_DEEP_UNDERGROUND)
				radio_disruption = CAVE_FULL_INTERFERENCE
		var/list/potential_owners = get_nested_locs(src) //Sometimes not equipped, sometimes not even equippable, sometimes in storage, this feels like it's an okay way to do it.
		var/mob/living/found_owner
		for(var/mob/living/candidate in potential_owners)
			found_owner = candidate
			break

		if(found_owner)
			var/inplace_interference = list(radio_disruption)
			SEND_SIGNAL(found_owner, COMSIG_CAVE_INTERFERENCE_CHECK, inplace_interference)
			radio_disruption = inplace_interference[1]
		if(radio_disruption == CAVE_FULL_INTERFERENCE)
			return FALSE

	// allow checks: are we listening on that frequency?
	if(input_frequency == frequency)
		return TRUE
	for(var/ch_name in channels)
		if(channels[ch_name] & FREQ_LISTENING)
			//the GLOB.GLOB.radiochannels list is located in communications.dm
			if(GLOB.radiochannels[ch_name] == text2num(input_frequency))
				return TRUE
	return FALSE


/obj/item/radio/examine(mob/user)
	. = ..()
	if(frequency && in_range(src, user))
		. += span_notice("It is set to broadcast over the [frequency / 10] frequency.")
	if(unscrewed)
		. += span_notice("It can be attached and modified.")
	else
		. += span_notice("It cannot be modified or attached.")


/obj/item/radio/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(isscrewdriver(I) && !subspace_transmission)
		unscrewed = !unscrewed
		if(unscrewed)
			to_chat(user, span_notice("The radio can now be attached and modified!"))
		else
			to_chat(user, span_notice("The radio can no longer be modified or attached!"))

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


/obj/item/radio/off/Initialize(mapload)
	. = ..()
	set_listening(FALSE)

/obj/item/radio/survivor
	freqlock = TRUE
	frequency = FREQ_CIV_GENERAL
