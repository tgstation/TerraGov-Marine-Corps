/obj/item/radio
	icon = 'icons/obj/items/radio.dmi'
	name = "station bounced radio"
	icon_state = "walkietalkie"
	item_state = "walkietalkie"

	flags_atom = CONDUCT
	flags_equip_slot = ITEM_SLOT_BELT
	throw_speed = 2
	throw_range = 9
	w_class = 2

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

	matter = list("glass" = 25,"metal" = 75)

	var/wires = WIRE_SIGNAL|WIRE_RECEIVE|WIRE_TRANSMIT
	var/const/WIRE_SIGNAL = 1 //sends a signal, like to set off a bomb or electrocute someone
	var/const/WIRE_RECEIVE = 2
	var/const/WIRE_TRANSMIT = 4
	var/const/TRANSMISSION_DELAY = 5 // only 2/second/radio
	var/const/FREQ_LISTENING = 1


	var/list/channels = list()  // Map from name (see communications.dm) to on/off. First entry is current department (:h).
	var/list/secure_radio_connections
	var/obj/item/encryptionkey/keyslot


/obj/item/radio/Initialize()
	secure_radio_connections = new
	. = ..()
	frequency = sanitize_frequency(frequency, freerange)
	set_frequency(frequency)

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])


/obj/item/radio/Destroy()
	remove_radio_all(src) //Just to be sure
	QDEL_NULL(keyslot)
	return ..()


/obj/item/radio/proc/set_frequency(new_frequency)
	SEND_SIGNAL(src, COMSIG_RADIO_NEW_FREQUENCY, args)
	remove_radio(src, frequency)
	frequency = add_radio(src, new_frequency)


/obj/item/radio/attack_self(mob/user as mob)
	user.set_interaction(src)
	interact(user)


/obj/item/radio/interact(mob/user as mob)
	if(!on)
		return

	var/dat

	if(!istype(src, /obj/item/radio/headset)) //Headsets dont get a mic button
		dat += "Microphone: [broadcasting ? "<A href='byond://?src=\ref[src];talk=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];talk=1'>Disengaged</A>"]<BR>"

	dat += {"
				Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
				Frequency: 	[format_frequency(frequency)] "}

	for(var/ch_name in channels)
		dat += text_sec_channel(ch_name, channels[ch_name])
	
	dat += {"[text_wires()]"}

	var/datum/browser/popup = new(user, "radio", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "radio")


/obj/item/radio/proc/text_wires()
	if(!unscrewed)
		return ""
	return {"
			<hr>
			Green Wire: <A href='byond://?src=\ref[src];wires=4'>[(wires & 4) ? "Cut" : "Mend"] Wire</A><BR>
			Red Wire:   <A href='byond://?src=\ref[src];wires=2'>[(wires & 2) ? "Cut" : "Mend"] Wire</A><BR>
			Blue Wire:  <A href='byond://?src=\ref[src];wires=1'>[(wires & 1) ? "Cut" : "Mend"] Wire</A><BR>
			"}


/obj/item/radio/proc/text_sec_channel(var/chan_name, var/chan_stat)
	var/list = !!(chan_stat&FREQ_LISTENING)!=0
	return {"
			<B>[chan_name]</B><br>
			Speaker: <A href='byond://?src=\ref[src];ch_name=[chan_name];listen=[!list]'>[list ? "Engaged" : "Disengaged"]</A><BR>
			"}

/obj/item/radio/Topic(href, href_list)
	//..()
	if (usr.stat || !on)
		return

	if (!(issilicon(usr) || (usr.contents.Find(src) || ( in_range(src, usr) && istype(loc, /turf) ))))
		usr << browse(null, "window=radio")
		return
	usr.set_interaction(src)
	if (href_list["track"])
		var/mob/target = locate(href_list["track"])
		var/mob/living/silicon/ai/A = locate(href_list["track2"])
		if(A && target)
			A.ai_actual_track(target)
		return

	else if (href_list["freq"])
		var/new_frequency = (frequency + text2num(href_list["freq"]))
		set_frequency(new_frequency)

	else if (href_list["talk"])
		broadcasting = text2num(href_list["talk"])
	else if (href_list["listen"])
		var/chan_name = href_list["ch_name"]
		if (!chan_name)
			listening = text2num(href_list["listen"])
		else
			if (channels[chan_name] & FREQ_LISTENING)
				channels[chan_name] &= ~FREQ_LISTENING
			else
				channels[chan_name] |= FREQ_LISTENING
	else if (href_list["wires"])
		var/t1 = text2num(href_list["wires"])
		if (!iswirecutter(usr.get_active_held_item()))
			return
		if (wires & t1)
			wires &= ~t1
		else
			wires |= t1
	if (!( master ))
		if (istype(loc, /mob))
			interact(loc)
		else
			updateDialog()
	else
		if (istype(master.loc, /mob))
			interact(master.loc)
		else
			updateDialog()
	add_fingerprint(usr)


/obj/item/radio/talk_into(atom/movable/M, message, channel, list/spans, datum/language/language)
	if(!spans)
		spans = M.get_spans()
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

	// All radios make an attempt to use the subspace system first
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
	user.set_interaction(src)
	if(isscrewdriver(I))
		unscrewed = !unscrewed
		if(unscrewed)
			to_chat(user, "<span class='notice'>The radio can now be attached and modified!</span>")
		else
			to_chat(user, "<span class='notice'>The radio can no longer be modified or attached!</span>")


///////////////////////////////
//////////Borg Radios//////////
///////////////////////////////
//Giving borgs their own radio to have some more room to work with -Sieve

/obj/item/radio/borg
	var/mob/living/silicon/robot/myborg = null // Cyborg which owns this radio. Used for power checks
	var/shut_up = 0
	icon = 'icons/obj/robot_component.dmi' // Cyborgs radio icons should look like the component.
	icon_state = "radio"
	canhear_range = 3

/obj/item/radio/borg/talk_into()
	..()
	if (iscyborg(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		var/datum/robot_component/C = R.components["radio"]
		R.cell_use_power(C.active_usage)

/obj/item/radio/borg/attackby(obj/item/W as obj, mob/user as mob)
//	..()
	user.set_interaction(src)
	if (!(isscrewdriver(W) || (istype(W, /obj/item/encryptionkey/ ))))
		return

	if(isscrewdriver(W))
		if(keyslot)


			for(var/ch_name in channels)
				SSradio.remove_object(src, GLOB.radiochannels[ch_name])
				secure_radio_connections[ch_name] = null


			if(keyslot)
				var/turf/T = get_turf(user)
				if(T)
					keyslot.loc = T
					keyslot = null

			recalculateChannels()
			to_chat(user, "You pop out the encryption key in the radio!")

		else
			to_chat(user, "This radio doesn't have any encryption keys!")

	if(istype(W, /obj/item/encryptionkey/))
		if(keyslot)
			to_chat(user, "The radio can't hold another key!")
			return

		if(!keyslot)
			if(user.drop_held_item())
				W.forceMove(src)
				keyslot = W

		recalculateChannels()


/obj/item/radio/proc/recalculateChannels()
	channels = list()

	if(keyslot)
		for(var/ch_name in keyslot.channels)
			if(!(ch_name in channels))
				channels[ch_name] = keyslot.channels[ch_name]

	for(var/ch_name in channels)
		secure_radio_connections[ch_name] = add_radio(src, GLOB.radiochannels[ch_name])


/obj/item/radio/borg/Topic(href, href_list)
	if(usr.stat || !on)
		return
	if (href_list["mode"])
		if(subspace_transmission != 1)
			subspace_transmission = 1
			to_chat(usr, "Subspace Transmission is disabled")
		else
			subspace_transmission = 0
			to_chat(usr, "Subspace Transmission is enabled")
		if(subspace_transmission == 1)//Simple as fuck, clears the channel list to prevent talking/listening over them if subspace transmission is disabled
			channels = list()
		else
			recalculateChannels()
	if (href_list["shutup"]) // Toggle loudspeaker mode, AKA everyone around you hearing your radio.
		shut_up = !shut_up
		if(shut_up)
			canhear_range = 0
		else
			canhear_range = 3

	..()

/obj/item/radio/borg/interact(mob/user as mob)
	if(!on)
		return

	var/dat = {"
				Speaker: [listening ? "<A href='byond://?src=\ref[src];listen=0'>Engaged</A>" : "<A href='byond://?src=\ref[src];listen=1'>Disengaged</A>"]<BR>
				Frequency:
				<A href='byond://?src=\ref[src];freq=-10'>-</A>
				<A href='byond://?src=\ref[src];freq=-2'>-</A>
				[format_frequency(frequency)]
				<A href='byond://?src=\ref[src];freq=2'>+</A>
				<A href='byond://?src=\ref[src];freq=10'>+</A><BR>
				<A href='byond://?src=\ref[src];mode=1'>Toggle Broadcast Mode</A><BR>
				<A href='byond://?src=\ref[src];shutup=1'>Toggle Loudspeaker</A><BR>
				"}

	if(!subspace_transmission)//Don't even bother if subspace isn't turned on
		for (var/ch_name in channels)
			dat+=text_sec_channel(ch_name, channels[ch_name])
	dat += {"[text_wires()]"}

	var/datum/browser/popup = new(user, "radio", "<div align='center'>[src]</div>")
	popup.set_content(dat)
	popup.open(FALSE)
	onclose(user, "radio")


/obj/item/radio/off
	listening = 0



//MARINE RADIO

/obj/item/radio/marine
	frequency = FREQ_COMMON
