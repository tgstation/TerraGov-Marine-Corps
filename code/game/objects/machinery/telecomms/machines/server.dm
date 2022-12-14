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
	var/identifier = num2text(rand(-1000, 1000) + world.time)
	log.name = "data packet ([md5(identifier)])"
	LAZYADD(log_entries, log)

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
	freq_listening = list(FREQ_MEDICAL)
	autolinkers = list("medical")


/obj/machinery/telecomms/server/presets/requisitions
	id = "Requisitions Server"
	freq_listening = list(FREQ_REQUISITIONS)
	autolinkers = list("requisitions")


/obj/machinery/telecomms/server/presets/alpha
	id = "Alpha Server"
	freq_listening = list(FREQ_ALPHA)
	autolinkers = list("alpha")


/obj/machinery/telecomms/server/presets/bravo
	id = "Bravo Server"
	freq_listening = list(FREQ_BRAVO)
	autolinkers = list("bravo")


/obj/machinery/telecomms/server/presets/charlie
	id = "Charlie Server"
	freq_listening = list(FREQ_CHARLIE)
	autolinkers = list("charlie")


/obj/machinery/telecomms/server/presets/delta
	id = "Delta Server"
	freq_listening = list(FREQ_DELTA)
	autolinkers = list("delta")


/obj/machinery/telecomms/server/presets/command
	id = "Command Server"
	freq_listening = list(FREQ_COMMAND)
	autolinkers = list("command")


/obj/machinery/telecomms/server/presets/engineering
	id = "Engineering Server"
	freq_listening = list(FREQ_ENGINEERING)
	autolinkers = list("engineering")


/obj/machinery/telecomms/server/presets/cas
	id = "Fire Support Server"
	freq_listening = list(FREQ_CAS)
	autolinkers = list("firesupport")

/obj/machinery/telecomms/server/presets/medical/rebel
	id = "Medical Server rebel"
	freq_listening = list(FREQ_MEDICAL_REBEL)
	autolinkers = list("medical_rebel")


/obj/machinery/telecomms/server/presets/requisitions/rebel
	id = "Requisitions Server rebel"
	freq_listening = list(FREQ_REQUISITIONS_REBEL)
	autolinkers = list("requisitions_rebel")


/obj/machinery/telecomms/server/presets/alpha/rebel
	id = "Alpha Server rebel"
	freq_listening = list(FREQ_ALPHA_REBEL)
	autolinkers = list("alpha_rebel")


/obj/machinery/telecomms/server/presets/bravo/rebel
	id = "Bravo Server rebel"
	freq_listening = list(FREQ_BRAVO_REBEL)
	autolinkers = list("bravo_rebel")


/obj/machinery/telecomms/server/presets/charlie/rebel
	id = "Charlie Server rebel"
	freq_listening = list(FREQ_CHARLIE_REBEL)
	autolinkers = list("charlie_rebel")


/obj/machinery/telecomms/server/presets/delta/rebel
	id = "Delta Server rebel"
	freq_listening = list(FREQ_DELTA_REBEL)
	autolinkers = list("delta_rebel")


/obj/machinery/telecomms/server/presets/command/rebel
	id = "Command Server rebel"
	freq_listening = list(FREQ_COMMAND_REBEL)
	autolinkers = list("command_rebel")


/obj/machinery/telecomms/server/presets/engineering/rebel
	id = "Engineering Server rebel"
	freq_listening = list(FREQ_ENGINEERING_REBEL)
	autolinkers = list("engineering_rebel")


/obj/machinery/telecomms/server/presets/cas/rebel
	id = "Fire Support Server rebel"
	freq_listening = list(FREQ_CAS_REBEL)
	autolinkers = list("firesupport_rebel")

//SOM
/obj/machinery/telecomms/server/presets/medical/som
	id = "Medical Server som"
	freq_listening = list(FREQ_MEDICAL_SOM)
	autolinkers = list("medical_som")

/obj/machinery/telecomms/server/presets/zulu
	id = "Zulu"
	freq_listening = list(FREQ_ZULU)
	autolinkers = list("zulu")


/obj/machinery/telecomms/server/presets/yankee
	id = "Yankee"
	freq_listening = list(FREQ_YANKEE)
	autolinkers = list("yankee")


/obj/machinery/telecomms/server/presets/xray
	id = "Xray"
	freq_listening = list(FREQ_XRAY)
	autolinkers = list("xray")


/obj/machinery/telecomms/server/presets/whiskey
	id = "Whiskey"
	freq_listening = list(FREQ_WHISKEY)
	autolinkers = list("whiskey")


/obj/machinery/telecomms/server/presets/command/som
	id = "Command Server som"
	freq_listening = list(FREQ_COMMAND_SOM)
	autolinkers = list("command_som")


/obj/machinery/telecomms/server/presets/engineering/som
	id = "Engineering Server som"
	freq_listening = list(FREQ_ENGINEERING_SOM)
	autolinkers = list("engineering_som")


/obj/machinery/telecomms/server/presets/common
	id = "Common Server"
	freq_listening = list(FREQ_COMMON, FREQ_PMC, FREQ_COLONIST, FREQ_USL, FREQ_DEATHSQUAD, FREQ_IMPERIAL, FREQ_SOM, FREQ_SECTOID, FREQ_ECHO)
	autolinkers = list("common", "ert")

//adds a proper emergency server in CIC instead of an unlinked one.
/obj/machinery/telecomms/server/presets/common/cicbackup
	on = 0
	id = "Backup Common Server"
	freq_listening = list(FREQ_COMMON, FREQ_PMC, FREQ_COLONIST, FREQ_USL, FREQ_DEATHSQUAD, FREQ_IMPERIAL, FREQ_SOM, FREQ_SECTOID, FREQ_ECHO)
	autolinkers = list("common", "ert")

/obj/machinery/telecomms/server/presets/common/rebel
	id = "Common Server rebel"
	freq_listening = list(FREQ_COMMON_REBEL, FREQ_PMC, FREQ_COLONIST, FREQ_USL, FREQ_DEATHSQUAD, FREQ_IMPERIAL, FREQ_SOM, FREQ_SECTOID, FREQ_ECHO)
	autolinkers = list("common_rebel", "ert")

/obj/machinery/telecomms/server/presets/common/som
	id = "Common Server som"
	freq_listening = list(FREQ_SOM)
	autolinkers = list("common_som")

//Common and other radio frequencies for people to freely use
/obj/machinery/telecomms/server/presets/common/Initialize()
	. = ..()
	for(var/i = MIN_FREQ, i <= MAX_FREQ, i += 2)
		freq_listening |= i
