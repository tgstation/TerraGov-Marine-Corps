/datum/element/newton/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOB_EXTINGUISHER_USE, .proc/exinguish)
	RegisterSignal(target, COMSIG_HUMAN_GUN_FIRED, .proc/fire_gun)

/datum/element/newton/Detach(datum/target, force)
	. = ..()
	UnregisterSignal(target, COMSIG_MOB_EXTINGUISHER_USE)
	UnregisterSignal(target, COMSIG_HUMAN_GUN_FIRED)

/datum/element/newton/proc/exinguish(datum/source, atom/target_atom, force)
	var/mob/M = source

	propel(M, get_dir(M, target_atom), force)

/datum/element/newton/proc/fire_gun(datum/source, atom/target, obj/item/weapon/gun/gun, mob/living/user)
	propel(user, get_dir(user, target), 2)

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
