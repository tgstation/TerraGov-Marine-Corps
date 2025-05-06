/*
	*Submerge element for turfs that apply submerge effects
	*Element is required for a turf if the turf OR its contents (i.e. tallgrass) apply submerge.
	*This means any new turfs that add submerge must add and remove this element on init/destroy
	*Similarly, any atom that modifies submerge like tall grass, must appropriately set and unset the element on it's turf, and connect_loc to maintain the right connection
**/
/datum/element/submerge/Attach(datum/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	//override true as we don't look up if the turf already has the element
	RegisterSignals(target, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), PROC_REF(atom_entered), TRUE)
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(atom_exited), TRUE)

/datum/element/submerge/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON, COMSIG_ATOM_EXITED))
	for(var/atom/movable/AM AS in source)
		if(HAS_TRAIT(AM, TRAIT_NOSUBMERGE))
			continue
		AM.set_submerge_level(null, source, duration = 0.1)

///Applies or modifies submerge effects on entering AMs
/datum/element/submerge/proc/atom_entered(turf/source, atom/movable/mover, atom/old_loc, list/old_locs)
	SIGNAL_HANDLER
	if(HAS_TRAIT(mover, TRAIT_NOSUBMERGE))
		return
	if(!source.get_submerge_height() && !source.get_submerge_depth())
		return
	mover.set_submerge_level(mover.loc, old_loc)

///Removes submerge effects if the new loc does not submerge the AM
/datum/element/submerge/proc/atom_exited(turf/source, atom/movable/mover, direction)
	SIGNAL_HANDLER
	if(HAS_TRAIT(mover, TRAIT_NOSUBMERGE))
		return
	//this is slightly stinky since the submerge effects are not tied to the element itself, and because we can't check if the turf actually has the element or not,
	//we have to hope that no one has shitcoded and forgot to give something the element when it's supposed to have it.
	var/turf/new_loc = mover.loc
	if(isturf(mover.loc) && (new_loc.get_submerge_height() || new_loc.get_submerge_depth()))
		return //If the new loc submerges, we let it handle that on enter
	mover.set_submerge_level(mover.loc, source)
