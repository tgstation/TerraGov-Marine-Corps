/*
	The HUB idles until it receives information. It then passes on that information
	depending on where it came from.

	This is the heart of the Telecommunications Network, sending information where it
	is needed. It mainly receives information from long-distance Relays and then sends
	that information to be processed. Afterwards it gets the uncompressed information
	from Servers/Buses and sends that back to the relay, to then be broadcasted.
*/
/obj/machinery/telecomms/hub
	name = "telecommunication hub"
	icon_state = "hub"
	desc = "A mighty piece of hardware used to send/receive massive amounts of data."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 80
	long_range_link = TRUE
	netspeed = 40
	circuit = /obj/item/circuitboard/machine/telecomms/hub


/obj/machinery/telecomms/hub/receive_information(datum/signal/signal, obj/machinery/telecomms/machine_from)
	if(!is_freq_listening(signal))
		return

	if(istype(machine_from, /obj/machinery/telecomms/receiver))
		// It's probably compressed so send it to the bus.
		relay_information(signal, /obj/machinery/telecomms/bus, TRUE)
	else
		// Send it to each relay so their levels get added...
		relay_information(signal, /obj/machinery/telecomms/relay)
		// Then broadcast that signal to
		relay_information(signal, /obj/machinery/telecomms/broadcaster)


//Preset HUB
/obj/machinery/telecomms/hub/preset
	id = "Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "s_relay", "command", "medical", "ert",
	"requisitions", "alpha","firesupport", "bravo", "charlie", "delta", "common", "engineering",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")

//proper cicbackup machine
/obj/machinery/telecomms/hub/preset/cicbackup
	on = 0
	id = "Backup Hub"
	network = "tcommsat"
	autolinkers = list("hub", "relay", "s_relay", "command", "medical", "ert",
	"requisitions", "alpha","firesupport", "bravo", "charlie", "delta", "common", "engineering",
	"receiverA", "receiverB", "broadcasterA", "broadcasterB")


/obj/machinery/telecomms/hub/preset/rebel
	id = "Hub rebel"
	autolinkers = list("hub_rebel", "relay", "s_relay", "command_rebel", "medical_rebel", "ert",
	"requisitions_rebel", "alpha_rebel","firesupport_rebel", "bravo_rebel", "charlie_rebel", "delta_rebel", "common_rebel", "engineering_rebel",
	"receiverA_rebel", "receiverB_rebel", "broadcasterA_rebel")

/obj/machinery/telecomms/hub/preset/som
	id = "Hub som"
	autolinkers = list("hub_som", "relay", "s_relay", "command_som", "medical_som", "ert",
	"zulu", "yankee", "xray", "whiskey", "common_som", "engineering_som",
	"receiverA_som", "receiverB_som", "broadcasterA_som")
