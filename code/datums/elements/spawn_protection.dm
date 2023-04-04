/datum/element/turf_restrictor

/datum/element/turf_restrictor/Attach(datum/target, _result)
	. = ..()
	RegisterSignal(target, COMSIG_ATOM_ENTERED_RESTRICTED, PROC_REF(on_bump_protected_turf))

/datum/element/turf_restrictor/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_ENTERED_RESTRICTED)

/datum/element/turf_restrictor/proc/on_bump_protected_turf(object, oldloc)
	SIGNAL_HANDLER
	return TRUE

/obj/effect/turf_restrictor
	icon_state = "blocker"
	invisibility = INVISIBILITY_MAXIMUM

/obj/effect/turf_restrictor/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(SEND_SIGNAL(mover, COMSIG_ATOM_ENTERED_RESTRICTED, target))
		return FALSE

/obj/effect/landmark/spawn_turf_restrictor/Initialize()
	GLOB.turf_restrictor += loc
	. = ..()
	return INITIALIZE_HINT_QDEL
