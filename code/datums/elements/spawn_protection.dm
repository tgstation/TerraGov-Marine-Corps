/datum/element/spawn_protecting

/datum/element/spawn_protecting/Attach(datum/target, _result)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_ENTERED_RESTRICTED, PROC_REF(on_bump_protected_turf))

/datum/element/scalping/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED_RESTRICTED)

/datum/element/spawn_protecting/proc/on_bump_protected_turf(object, oldloc)
	SIGNAL_HANDLER
	return TRUE

/obj/effect/spawn_protection

/obj/effect/spawn_protection/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(SEND_SIGNAL(mover, COMSIG_ATOM_ENTERED_RESTRICTED, target))
		return FALSE
