//blocks teleporters
/obj/effect/abstract/tele_blocker
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	///Previously received code
	var/received_code

/obj/effect/abstract/tele_blocker/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_TURF_TELEPORT_CHECK = PROC_REF(tele_check),
	)
	AddElement(/datum/element/connect_loc, connections)
	RegisterSignal(SSdcs, COMSIG_GLOB_CAMPAIGN_NT_OVERRIDE_CODE, PROC_REF(override_code_received))

///Tells the turf that nothing can teleport there
/obj/effect/abstract/tele_blocker/proc/tele_check(datum/source)
	SIGNAL_HANDLER
	return TRUE

///Recieves override codes, qdeling when both are received
/obj/effect/abstract/tele_blocker/proc/override_code_received(datum/source, color)
	SIGNAL_HANDLER
	if(received_code == color)
		return
	if(!received_code)
		received_code = color
		return
	qdel(src)
