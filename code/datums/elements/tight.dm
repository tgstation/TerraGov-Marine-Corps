/// Not entierly sure how to go about this
/datum/element/wall_speedup
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

/datum/element/wall_speedup/Attach(datum/target)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/wall_speed)

/datum/element/wall_speedup/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source)

/datum/element/wall_speedup/proc/wall_speed(datum/source, atom/oldloc)
	SIGNAL_HANDLER
	var/mob/living/fast = source
	var/static/list/dirs_to_check = list(NORTH, EAST, SOUTH, WEST, SOUTHEAST, NORTHWEST, SOUTHWEST, NORTHEAST)
	for(var/direction in dirs_to_check)
		if(!isclosedturf(get_step(fast, direction)))
			continue
		if(!isclosedturf(get_step(fast, REVERSE_DIR(direction))))
			continue
		fast.next_move_slowdown -= WIDOW_SPEED_BONUS // dunno how to approach this, maybe fast.movespeed or somet
		break
