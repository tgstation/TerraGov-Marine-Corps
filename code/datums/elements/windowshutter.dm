/datum/element/windowshutter/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/structure/window))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED, PROC_REF(spawn_shutter))
	RegisterSignal(target, COMSIG_OBJ_DECONSTRUCT, PROC_REF(spawn_shutter_first))

/datum/element/windowshutter/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, list(COMSIG_OBJ_DECONSTRUCT, COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED))

/datum/element/windowshutter/proc/spawn_shutter_first(datum/source)
	SIGNAL_HANDLER
	playsound(source, 'sound/machines/hiss.ogg', 50, 1)
	spawn_shutter(source)

/datum/element/windowshutter/proc/spawn_shutter(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED)
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/window/W in get_step(source,direction) )
			SEND_SIGNAL(W, COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED)
	var/obj/machinery/door/poddoor/shutters/mainship/pressure/P = new(get_turf(source))
	P.density = TRUE
	var/obj/structure/window/attachee = source
	if(attachee.smoothing_junction & (NORTH_JUNCTION|SOUTH_JUNCTION))
		P.setDir(EAST)
	else
		P.setDir(SOUTH)
	addtimer(CALLBACK(P, TYPE_PROC_REF(/obj/machinery/door, close)), 16)
	Detach(source)

/datum/element/windowshutter/cokpitshutters/spawn_shutter(datum/source)
	UnregisterSignal(source, COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED)
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/window/W in get_step(source,direction))
			SEND_SIGNAL(W, COMSIG_ELEMENT_CLOSE_SHUTTER_LINKED)
	var/obj/machinery/door/poddoor/shutters/tadpole_cockpit/P = new(get_turf(source))
	P.density = TRUE
	var/obj/structure/window/attachee = source
	switch(attachee.junction)
		if(4,5,8,9,12)
			P.setDir(SOUTH)
		else
			P.setDir(EAST)
	addtimer(CALLBACK(P, TYPE_PROC_REF(/obj/machinery/door, close)), 16)
	Detach(source)
