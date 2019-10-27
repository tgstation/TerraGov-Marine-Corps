/datum/element/newton/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOB_EXTINGUISHER_USE, .proc/exinguish)

/datum/element/newton/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, COMSIG_MOB_EXTINGUISHER_USE)

/datum/element/newton/proc/exinguish(datum/target, atom/target_atom, force)
	var/mob/M = target

	propel(target, get_dir(M, target_atom), force)

/datum/element/newton/proc/propel(mob/M, direction, force)
	if(!M.buckled || !isobj(M.buckled) || M.buckled.anchored)
		Detach(M)

	var/rep = CLAMP((4-force)*2, 0, 8)

	move_chair(M.buckled, reverse_direction(direction), rep)

/datum/element/newton/proc/move_chair(obj/B, movementdirection, repetition=0)
	step(B, movementdirection)

	var/timer_seconds
	switch(repetition)
		if(0 to 2)
			timer_seconds = 1
		if(3 to 4)
			timer_seconds = 2
		if(5 to 8)
			timer_seconds = 3
		else
			return

	repetition++
	addtimer(CALLBACK(src, .proc/move_chair, B, movementdirection, repetition), timer_seconds)
