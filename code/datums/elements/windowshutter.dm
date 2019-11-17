/datum/element/windowshutter/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/structure/window))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, ELEMENT_CLOSE_SHUTTER_LINKED, .proc/spawn_shutter)
	RegisterSignal(target, COMSIG_OBJ_DECONSTRUCT, .proc/spawn_shutter_first)

/datum/element/windowshutter/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, list(COMSIG_OBJ_DECONSTRUCT, ELEMENT_CLOSE_SHUTTER_LINKED))

/datum/element/windowshutter/proc/spawn_shutter_first(datum/source)
	playsound(source, 'sound/machines/hiss.ogg', 50, 1)
	spawn_shutter(source)

/datum/element/windowshutter/proc/spawn_shutter(datum/source)
	UnregisterSignal(source, ELEMENT_CLOSE_SHUTTER_LINKED)
	for(var/direction in GLOB.cardinals)
		for(var/obj/structure/window/W in get_step(source,direction) )
			SEND_SIGNAL(W, ELEMENT_CLOSE_SHUTTER_LINKED)
	var/obj/machinery/door/poddoor/shutters/mainship/pressure/P = new(get_turf(source))
	P.density = TRUE
	var/obj/structure/window/attachee = source
	switch(attachee.junction)
		if(4,5,8,9,12)
			P.setDir(SOUTH)
		else
			P.setDir(EAST)
	addtimer(CALLBACK(P, /obj/machinery/door.proc/close), 16)
	Detach(source)
