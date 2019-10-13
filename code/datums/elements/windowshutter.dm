/datum/element/windowshutter/Attach(datum/target)
	. = ..()
	if(!istype(target, /obj/structure/window))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_OBJ_DECONSTRUCT, .proc/spawn_shutter)

/datum/element/windowshutter/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, COMSIG_OBJ_DECONSTRUCT)

/datum/element/windowshutter/proc/spawn_shutter(datum/source, from_dir=0)
	if(!from_dir) //air escaping sound effect for original window
		playsound(src, 'sound/machines/hiss.ogg', 50, 1)
	for(var/direction in GLOB.cardinals)
		if(direction == from_dir)
			continue //doesn't check backwards
		for(var/obj/structure/window/framed/prison/reinforced/hull/W in get_step(source,direction) )
			spawn_shutter(W, turn(direction,180))
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
