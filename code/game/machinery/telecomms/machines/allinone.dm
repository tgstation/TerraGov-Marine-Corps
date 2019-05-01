/*
	Basically just an empty shell for receiving and broadcasting radio messages. Not
	very flexible, but it gets the job done.
*/
/obj/machinery/telecomms/allinone
	name = "telecommunications mainframe"
	icon_state = "comm_server"
	desc = "A compact machine used for portable subspace telecommunications processing."
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0


/obj/machinery/telecomms/allinone/receive_signal(datum/signal/subspace/signal)
	if(!istype(signal) || signal.transmission_method != TRANSMISSION_SUBSPACE)  // receives on subspace only
		return

	if(!on || !is_freq_listening(signal))  // has to be on to receive messages
		return

	if(!(z in signal.levels) && !(0 in signal.levels))
		return

	signal.data["compression"] = 0
	signal.mark_done()
	if(signal.data["slow"] > 0)
		sleep(signal.data["slow"]) // simulate the network lag if necessary
	signal.broadcast()


/obj/machinery/telecomms/allinone/attackby(obj/item/P, mob/user, params)
	if(ismultitool(P))
		return attack_hand(user)