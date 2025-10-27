/// This element hooks a signal onto the loc the current object is on.
/// When the object moves, it will unhook the signal and rehook it to the new object.
/datum/element/connect_loc
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// An assoc list of signal -> procpath to register to the loc this object is on.
	var/list/connections

/datum/element/connect_loc/Attach(atom/movable/listener, list/connections, check_rotation = FALSE)
	. = ..()
	if (!istype(listener))
		return ELEMENT_INCOMPATIBLE

	src.connections = connections

	RegisterSignals(listener, list(COMSIG_MOVABLE_MOVED, COMSIG_MULTITILE_VEHICLE_ROTATED), PROC_REF(on_moved), override = TRUE)
	//check_rotation should ONLY be used for multitile props. See on_rotate()
	if(check_rotation)
		RegisterSignal(listener, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_rotate))
	update_signals(listener)

/datum/element/connect_loc/Detach(atom/movable/listener)
	. = ..()
	unregister_signals(listener, listener.loc, listener.locs)
	UnregisterSignal(listener, list(COMSIG_MOVABLE_MOVED, COMSIG_MULTITILE_VEHICLE_ROTATED))

/datum/element/connect_loc/proc/update_signals(atom/movable/listener)
	var/atom/listener_loc = listener.loc
	if(isnull(listener_loc))
		return

	for (var/signal in connections)
		//override=TRUE because more than one connect_loc element instance tracked object can be on the same loc
		if(length(listener.locs) < 2) //this is kinda funny but a multitile object could be inside something
			listener.RegisterSignal(listener_loc, signal, connections[signal], override=TRUE)
			continue
		for(var/turf/turf AS in listener.locs)
			listener.RegisterSignal(turf, signal, connections[signal], override=TRUE)


/datum/element/connect_loc/proc/unregister_signals(datum/listener, atom/old_loc, list/turf/old_locs)
	if(isnull(old_loc))
		return

	for (var/signal in connections)
		if(length(old_locs) < 2)
			listener.UnregisterSignal(old_loc, signal)
			continue
		for(var/turf/turf AS in old_locs)
			listener.UnregisterSignal(turf, signal)

/datum/element/connect_loc/proc/on_moved(atom/movable/listener, atom/old_loc, movement_dir, forced, list/turf/old_locs)
	SIGNAL_HANDLER
	unregister_signals(listener, old_loc, old_locs)
	update_signals(listener)

///Updates our connections on rotate if required
/datum/element/connect_loc/proc/on_rotate(atom/movable/listener, old_dir, new_dir)
	SIGNAL_HANDLER
	if(length(listener.locs) <= 1) //this only matters for multitile
		return
	if(old_dir == new_dir)
		return
	unregister_signals(listener, listener.loc, listener.locs)
	//This is kinda stinky  but since locs are handled internally by byond, we can't get the old locs and new locs at the same time, so we hook into the new locs next tick
	INVOKE_NEXT_TICK(src, PROC_REF(update_signals), listener)
