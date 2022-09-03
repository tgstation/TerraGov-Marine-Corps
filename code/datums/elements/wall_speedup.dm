/// This element makes you move faster when opposite adjacent turfs are closed, you get a flat movement speed bonus
/datum/element/wall_speedup
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///The amount of speed gained by being inbetween walls
	var/wall_speed_amount = 1

/datum/element/wall_speedup/Attach(datum/target, wall_speed_amount)
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/wall_speed)
	src.wall_speed_amount = wall_speed_amount

/datum/element/wall_speedup/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/// Here we check to see if polar opposite directions are closed turfs, if they are then we move faster
/datum/element/wall_speedup/proc/wall_speed(datum/source, atom/oldloc)
	SIGNAL_HANDLER
	var/mob/living/fast = source
	for(var/direction in GLOB.halfdirs)
		if(!isclosedturf(get_step(fast, direction)))
			continue
		if(!isclosedturf(get_step(fast, REVERSE_DIR(direction))))
			continue
		fast.next_move_slowdown -= wall_speed_amount
		break
