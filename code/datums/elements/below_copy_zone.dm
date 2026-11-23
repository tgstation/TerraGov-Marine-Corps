
///Element for turfs that are close enough to open-space so that any living mobs stepping on them get a copy of themselves shown on a z-level below them.
/datum/element/below_copy_zone

/datum/element/below_copy_zone/Attach(datum/target)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignals(target, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON), PROC_REF(on_entered))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/element/below_copy_zone/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_INITIALIZED_ON, COMSIG_ATOM_EXITED))
	for(var/mob/living/standing_mob in source)
		QDEL_NULL(standing_mob.below_copy)

///Update the copy of living mobs that step on this turf
/datum/element/below_copy_zone/proc/on_entered(turf/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isliving(arrived))
		update_copy(arrived)

/// Removes the copy of living mobs below if they step off this turf
/datum/element/below_copy_zone/proc/on_exited(turf/source, atom/movable/gone, direction)
	SIGNAL_HANDLER
	if(!isliving(gone))
		return
	var/mob/living/living_gone = gone
	if(!living_gone.below_copy)
		return
	if(LAZYACCESS(attach_sources, living_gone.loc))
		return
	QDEL_NULL(living_gone.below_copy)

///Updates (or hides) the copy of a mob standing on this turf
/datum/element/below_copy_zone/proc/update_copy(mob/living/owner)
	var/turf/below_spot = QDELETED(owner) ? null : get_step_multiz(owner.loc, DOWN)
	if(!below_spot)
		QDEL_NULL(owner.below_copy)
		return
	var/atom/movable/below_copy/below_copy = owner.below_copy
	var/can_look_down = !!owner.get_looking_turf(DOWN, TRUE)
	if(!below_copy)
		owner.below_copy = new(below_spot, owner, can_look_down)
		return
	if(below_copy.loc == below_spot && below_copy.shown == can_look_down)
		return
	var/stepped = below_copy.loc != below_spot
	if(stepped)
		below_copy.set_glide_size(owner.glide_size)
		below_copy.abstract_move(below_spot)
	// ensure that we don't hide the gliding and you don't just pop in
	if(stepped && below_copy.shown && !can_look_down && !below_copy.hide_timer)
		below_copy.hide_after(GLIDE_SIZE_TO_DELAY(owner.glide_size))
		below_copy.update_copy()
		return
	below_copy.set_shown(can_look_down)
