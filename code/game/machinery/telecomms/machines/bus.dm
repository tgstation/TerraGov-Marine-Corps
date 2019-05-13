/*
	The bus mainframe idles and waits for hubs to relay them signals. They act
	as junctions for the network.

	They transfer uncompressed subspace packets to processor units, and then take
	the processed packet to a server for logging.

	Link to a subspace hub if it can't send to a server.
*/
/obj/machinery/telecomms/bus
	name = "bus mainframe"
	icon_state = "bus"
	desc = "A mighty piece of hardware used to send massive amounts of data quickly."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	netspeed = 40
	circuit = /obj/item/circuitboard/machine/telecomms/bus
	var/change_frequency = 0


/obj/machinery/telecomms/bus/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	if(!istype(signal) || !is_freq_listening(signal))
		return

	if(change_frequency)
		signal.frequency = change_frequency

	if(!istype(machine_from, /obj/machinery/telecomms/processor) && machine_from != src) // Signal must be ready (stupid assuming machine), let's send it
		// send to one linked processor unit
		if(relay_information(signal, /obj/machinery/telecomms/processor))
			return

		// failed to send to a processor, relay information anyway
		signal.data["slow"] += rand(1, 5) // slow the signal down only slightly

	// Try sending it!
	var/list/try_send = list(signal.server_type, /obj/machinery/telecomms/hub, /obj/machinery/telecomms/broadcaster)

	var/i = 0
	for(var/send in try_send)
		if(i)
			signal.data["slow"] += rand(0, 1) // slow the signal down only slightly
		i++
		if(relay_information(signal, send))
			break


//Preset Buses
/obj/machinery/telecomms/bus/preset_one
	id = "Bus 1"
	network = "tcommsat"
	freq_listening = list(FREQ_COMMAND, FREQ_POLICE, FREQ_MEDICAL, FREQ_ENGINEERING, FREQ_REQUISITIONS)
	autolinkers = list("processor1", "command", "police", "medical", "engineering", "requisitions")


/obj/machinery/telecomms/bus/preset_two
	id = "Bus 2"
	network = "tcommsat"
	freq_listening = list(FREQ_PMC, FREQ_COLONIST, FREQ_UPP, FREQ_DEATHSQUAD, FREQ_IMPERIAL)
	autolinkers = list("processor2", "ert")


/obj/machinery/telecomms/bus/preset_three
	id = "Bus 3"
	network = "tcommsat"
	freq_listening = list(FREQ_ALPHA, FREQ_BRAVO, FREQ_CHARLIE, FREQ_DELTA)
	autolinkers = list("processor3", "alpha", "bravo", "charlie", "delta")


/obj/machinery/telecomms/bus/preset_four
	id = "Bus 4"
	network = "tcommsat"
	freq_listening = list()
	autolinkers = list("processor4", "common")


/obj/machinery/telecomms/bus/preset_four/Initialize()
	. = ..()
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i