
/*
	Hello, friends, this is Doohl from sexylands. You may be wondering what this
	monstrous code file is. Sit down, boys and girls, while I tell you the tale.


	The telecom machines were designed to be compatible with any radio
	signals, provided they use subspace transmission. Currently they are only used for
	headsets, but they can eventually be outfitted for real COMPUTER networks. This
	is just a skeleton, ladies and gentlemen.

	Look at radio.dm for the prequel to this code.
*/

GLOBAL_LIST_EMPTY(telecomms_list)
GLOBAL_LIST_EMPTY(telecomms_freq_listening_list)

/obj/machinery/telecomms
	icon = 'icons/obj/machines/telecomms.dmi'
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE|UNACIDABLE
	/// list of machines this machine is linked to
	var/list/links = list()
	/**
	 * associative lazylist list of the telecomms_type of linked telecomms machines and a list of said machines.
	 * eg list(telecomms_type1 = list(everything linked to us with that type), telecomms_type2 = list(everything linked to us with THAT type)...)
	 */
	var/list/links_by_telecomms_type
	/// value increases as traffic increases
	var/traffic = 0
	/// how much traffic to lose per second (50 gigabytes/second * netspeed)
	var/netspeed = 5
	/// list of text/number values to link with
	var/list/autolinkers = list()
	/// identification string
	var/id = "NULL"
	/// the relevant type path of this telecomms machine eg /obj/machinery/telecomms/server but not server/preset. used for links_by_telecomms_type
	var/telecomms_type = null
	/// the network of the machinery
	var/network = "NULL"

	// list of frequencies to tune into: if none, will listen to all
	var/list/freq_listening = list()

	var/on = TRUE
	/// Is it toggled on
	var/toggled = TRUE
	/// Can you link it across Z levels or on the otherside of the map? (Relay & Hub)
	var/long_range_link = FALSE
	/// Is it a hidden machine?
	var/hide = FALSE

/// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending
/obj/machinery/telecomms/proc/relay_information(datum/signal/subspace/signal, filter, copysig, amount = 20)
	// relay signal to all linked machinery that are of type [filter]. If signal has been sent [amount] times, stop sending
	if(!on)
		return


	if(!filter || !ispath(filter, /obj/machinery/telecomms))
		CRASH("null or non /obj/machinery/telecomms typepath given as the filter argument! given typepath: [filter]")

	var/send_count = 0

	// Apply some lag based on traffic rates
	var/netlag = round(traffic / 50)
	if(netlag > signal.data["slow"])
		signal.data["slow"] = netlag

	// Loop through all linked machines and send the signal or copy.
	for(var/obj/machinery/telecomms/filtered_machine in links_by_telecomms_type?[filter])
		if(!filtered_machine.on)
			continue
		if(amount && send_count >= amount)
			break
		if(z != filtered_machine.loc.z && !long_range_link && !filtered_machine.long_range_link)
			continue

		send_count++
		if(filtered_machine.is_freq_listening(signal))
			filtered_machine.traffic++

		if(copysig)
			filtered_machine.receive_information(signal.copy(), src)
		else
			filtered_machine.receive_information(signal, src)

	if(send_count > 0 && is_freq_listening(signal))
		traffic++

	return send_count


/obj/machinery/telecomms/proc/relay_direct_information(datum/signal/signal, obj/machinery/telecomms/machine)
	// send signal directly to a machine
	machine.receive_information(signal, src)

///receive information from linked machinery
/obj/machinery/telecomms/proc/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	return


/obj/machinery/telecomms/proc/is_freq_listening(datum/signal/signal)
	// return TRUE if found, FALSE if not found
	return signal && (!length(freq_listening) || (signal.frequency in freq_listening))


/obj/machinery/telecomms/Initialize(mapload)
	. = ..()
	GLOB.telecomms_list += src
	start_processing()
	if(mapload && length(autolinkers))
		return INITIALIZE_HINT_LATELOAD


/obj/machinery/telecomms/LateInitialize()
	. = ..()
	for(var/obj/machinery/telecomms/T in (long_range_link ? GLOB.telecomms_list : urange(20, src, 1)))
		add_automatic_link(T)
	if(!GLOB.telecomms_freq_listening_list)
		return
	LAZYADDASSOC(GLOB.telecomms_freq_listening_list, type, freq_listening)

/obj/machinery/telecomms/Destroy()
	GLOB.telecomms_list -= src
	stop_processing()
	for(var/obj/machinery/telecomms/comm in GLOB.telecomms_list)
		remove_link(comm)
	links = list()
	return ..()


/// Used in auto linking
/obj/machinery/telecomms/proc/add_automatic_link(obj/machinery/telecomms/T)
	var/turf/position = get_turf(src)
	var/turf/T_position = get_turf(T)
	if((position.z != T_position.z) && !(long_range_link && T.long_range_link))
		return
	if(src == T)
		return
	for(var/autolinker_id in autolinkers)
		if(autolinker_id in T.autolinkers)
			add_new_link(T)
			return


/obj/machinery/telecomms/update_icon()
	if(on)
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			icon_state = "[initial(icon_state)]_o"
		else
			icon_state = initial(icon_state)
	else
		if(CHECK_BITFIELD(machine_stat, PANEL_OPEN))
			icon_state = "[initial(icon_state)]_o_off"
		else
			icon_state = "[initial(icon_state)]_off"


/obj/machinery/telecomms/proc/update_power()
	if(toggled)
		if(machine_stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
			on = FALSE
		else
			on = TRUE
	else
		on = FALSE


/obj/machinery/telecomms/process()
	update_power()

	// Update the icon
	update_icon()

	if(traffic > 0)
		traffic -= netspeed

///adds new_connection to src's links list AND vice versa. also updates links_by_telecomms_type
/obj/machinery/telecomms/proc/add_new_link(obj/machinery/telecomms/new_connection, mob/user)
	if(!istype(new_connection) || new_connection == src)
		return FALSE

	if((new_connection in links) && (src in new_connection.links))
		return FALSE

	links |= new_connection
	new_connection.links |= src

	LAZYADDASSOCLIST(links_by_telecomms_type, new_connection.telecomms_type, new_connection)
	LAZYADDASSOCLIST(new_connection.links_by_telecomms_type, telecomms_type, src)

	if(user)
		log_game("[key_name(user)] linked [src] for [new_connection] at [AREACOORD(src)].")
	return TRUE

///removes old_connection from src's links list AND vice versa. also updates links_by_telecomms_type
/obj/machinery/telecomms/proc/remove_link(obj/machinery/telecomms/old_connection, mob/user)
	if(!istype(old_connection) || old_connection == src)
		return FALSE

	if(old_connection in links)
		links -= old_connection
		LAZYREMOVEASSOC(links_by_telecomms_type, old_connection.telecomms_type, old_connection)

	if(src in old_connection.links)
		old_connection.links -= src
		LAZYREMOVEASSOC(old_connection.links_by_telecomms_type, telecomms_type, src)

	if(user)
		log_game("[key_name(user)] unlinked [src] and [old_connection] at [AREACOORD(src)].")

	return TRUE
