/*
	The server logs all traffic and signal data. Once it records the signal, it sends
	it to the subspace broadcaster.

	Store a maximum of 100 logs and then deletes them.
*/
/obj/machinery/telecomms/server
	name = "telecommunication server"
	icon_state = "comm_server"
	desc = "A machine used to store data and network statistics."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 15
	circuit = /obj/item/circuitboard/machine/telecomms/server
	var/list/log_entries = list()
	var/totaltraffic = 0 // gigabytes (if > 1024, divide by 1024 -> terrabytes)


/obj/machinery/telecomms/server/Initialize()
	. = ..()


/obj/machinery/telecomms/server/receive_information(datum/signal/subspace/vocal/signal, obj/machinery/telecomms/machine_from)
	// can't log non-vocal signals
	if(!istype(signal) || !signal.data["message"] || !is_freq_listening(signal))
		return

	if(traffic > 0)
		totaltraffic += traffic // add current traffic to total traffic

	// Delete particularly old logs
	if(length(log_entries) >= 400)
		log_entries.Cut(1, 2)

	var/datum/comm_log_entry/log = new
	log.parameters["mobtype"] = signal.virt.source.type
	log.parameters["name"] = signal.data["name"]
	log.parameters["job"] = signal.data["job"]
	log.parameters["message"] = signal.data["message"]
	log.parameters["language"] = signal.language

	// If the signal is still compressed, make the log entry gibberish
	var/compression = signal.data["compression"]
	if(compression > 0)
		log.input_type = "Corrupt File"
		log.parameters["name"] = Gibberish(signal.data["name"], compression + 50)
		log.parameters["job"] = Gibberish(signal.data["job"], compression + 50)
		log.parameters["message"] = Gibberish(signal.data["message"], compression + 50)

	// Give the log a name and store it
	var/identifier = num2text( rand(-1000,1000) + world.time )
	log.name = "data packet ([md5(identifier)])"
	log_entries.Add(log)

	var/can_send = relay_information(signal, /obj/machinery/telecomms/hub)
	if(!can_send)
		relay_information(signal, /obj/machinery/telecomms/broadcaster)


// Simple log entry datum
/datum/comm_log_entry
	var/input_type = "Speech File"
	var/name = "data packet (#)"
	var/parameters = list()  // copied from signal.data above


// Preset Servers
/obj/machinery/telecomms/server/presets
	network = "tcommsat"


/obj/machinery/telecomms/server/presets/Initialize()
	. = ..()
	name = id


/obj/machinery/telecomms/server/presets/medical
	id = "Medical Server"
	freq_listening = list(MED_FREQ)
	autolinkers = list("medical")


/obj/machinery/telecomms/server/presets/requisitions
	id = "Requisitions Server"
	freq_listening = list(SUP_FREQ)
	autolinkers = list("requisitions")


/obj/machinery/telecomms/server/presets/alpha
	id = "Alpha Server"
	freq_listening = list(ALPHA_FREQ)
	autolinkers = list("alpha")


/obj/machinery/telecomms/server/presets/bravo
	id = "Bravo Server"
	freq_listening = list(BRAVO_FREQ)
	autolinkers = list("bravo")


/obj/machinery/telecomms/server/presets/charlie
	id = "Charlie Server"
	freq_listening = list(CHARLIE_FREQ)
	autolinkers = list("charlie")


/obj/machinery/telecomms/server/presets/delta
	id = "Delta Server"
	freq_listening = list(DELTA_FREQ)
	autolinkers = list("delta")


/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	freq_listening = list(COMM_FREQ)
	autolinkers = list("command")


/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	freq_listening = list(ENG_FREQ)
	autolinkers = list("engineering")


/obj/machinery/telecomms/server/presets/security
	id = "Police Server"
	freq_listening = list(SEC_FREQ)
	autolinkers = list("police")


/obj/machinery/telecomms/server/presets/common
	id = "Common Server"
	freq_listening = list(PMC_FREQ, COL_FREQ, UPP_FREQ, DTH_FREQ, IMP_FREQ)
	autolinkers = list("common", "ert")


//Common and other radio frequencies for people to freely use
/obj/machinery/telecomms/server/presets/common/Initialize()
	. = ..()
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i
