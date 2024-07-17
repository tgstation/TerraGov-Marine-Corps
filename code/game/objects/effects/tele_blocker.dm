//blocks teleporters
/obj/effect/abstract/tele_blocker
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE

/obj/effect/abstract/tele_blocker/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_TURF_TELEPORT_CHECK = PROC_REF(tele_check),
	)
	AddElement(/datum/element/connect_loc, connections)

///Tells the turf that nothing can teleport there
/obj/effect/abstract/tele_blocker/proc/tele_check(datum/source)
	SIGNAL_HANDLER
	return TRUE
