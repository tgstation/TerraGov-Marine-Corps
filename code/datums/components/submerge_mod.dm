//Allows an atom to contribute to the submerging effects of a turf
//Submerge height is additive, so best to avoid spamming multiple atoms on a turf with this component/very high values unless you want wack results.
/datum/component/submerge_modifier
	///Height in pixels a target is submerged by the parent of this component
	var/submerge_height

/datum/component/submerge_modifier/Initialize(_submerge_height = 10)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE
	submerge_height = _submerge_height

/datum/component/submerge_modifier/RegisterWithParent()
	var/atom/movable/owner = parent
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(move_submerge_element))
	for(var/atom/movable/AM AS in owner.loc) //we remove the submerge and reapply after owner is connect
		if(HAS_TRAIT(AM, TRAIT_NOSUBMERGE))
			continue
		AM.set_submerge_level(null, owner.loc, duration = 0.1)
	add_connections(owner.loc)
	for(var/atom/movable/AM AS in owner.loc)
		if(HAS_TRAIT(AM, TRAIT_NOSUBMERGE))
			continue
		AM.set_submerge_level(owner.loc, null, duration = 0.1)

/datum/component/submerge_modifier/UnregisterFromParent()
	var/atom/movable/owner = parent
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	for(var/atom/movable/AM AS in owner.loc) //we remove the submerge and reapply after owner is no longer connect
		if(HAS_TRAIT(AM, TRAIT_NOSUBMERGE))
			continue
		AM.set_submerge_level(null, owner.loc, duration = 0.1)
	remove_connections(owner.loc)
	for(var/atom/movable/AM AS in owner.loc)
		if(HAS_TRAIT(AM, TRAIT_NOSUBMERGE))
			continue
		AM.set_submerge_level(owner.loc, null, duration = 0.1)

///Adds the submerge element to a turf and registers for the submerge signal
/datum/component/submerge_modifier/proc/add_connections(turf/new_turf)
	if(!istype(new_turf))
		return
	new_turf.AddElement(/datum/element/submerge)
	RegisterSignal(new_turf, COMSIG_TURF_SUBMERGE_CHECK, PROC_REF(get_submerge_height_mod))

///Removes the submerge element from a turf if it can no longer submerge things
/datum/component/submerge_modifier/proc/remove_connections(turf/old_turf)
	if(!istype(old_turf))
		return
	UnregisterSignal(old_turf, COMSIG_TURF_SUBMERGE_CHECK)
	if(old_turf.get_submerge_height() || old_turf.get_submerge_depth())
		return
	old_turf.RemoveElement(/datum/element/submerge)

///Removes and adds connections on move
/datum/component/submerge_modifier/proc/move_submerge_element(atom/movable/source, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	remove_connections(old_loc)
	add_connections(source.loc)

///How high up an AM's is covered by an alpha mask when submerged. This amount is additive
/datum/component/submerge_modifier/proc/get_submerge_height_mod(turf/source, list/submerge_list)
	SIGNAL_HANDLER
	submerge_list += submerge_height
