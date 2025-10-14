/datum/element/throw_parry/Attach(atom/movable/listener, duration)
	. = ..()
	if(!isatom(listener))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(listener, COMSIG_PRE_MOVABLE_IMPACT, PROC_REF(parry_check))
	if(duration)
		addtimer(CALLBACK(src, PROC_REF(remove_self), listener), duration)

/datum/element/throw_parry/Detach(atom/movable/listener)
	. = ..()
	UnregisterSignal(listener, COMSIG_PRE_MOVABLE_IMPACT)

/**
 * This is triggered by an object attempting to impact into something with the parry component attached and checks whether the current conditions are valid to trigger a parry success.
 * The mob has to be conscious aswell as not resting and the parry duration must not have timed out.
 * * Returns TRUE on successful parry and nothing if failed, which is then handled by throwing code.
**/
/datum/element/throw_parry/proc/parry_check(atom/source, atom/movable/thrown)
	SIGNAL_HANDLER
	var/mob/living/living_source
	if(isliving(source))
		living_source = source
		if(living_source.stat >= UNCONSCIOUS)
			return
		if(living_source.resting)
			return
		living_source.visible_message(span_warning("[living_source] deflects [thrown]!"), span_notice("[isxeno(living_source) ? "We" : "You"] bounce [thrown] back towards its source!"))
	thrown.set_throwing(FALSE)
	INVOKE_NEXT_TICK(thrown, TYPE_PROC_REF(/atom/movable, throw_at), thrown.throw_source, 6, max(thrown.thrown_speed * 0.5, 1), source, TRUE)

	return COMPONENT_PRE_MOVABLE_IMPACT_DODGED

///Removes self after duration is up
/datum/element/throw_parry/proc/remove_self(atom/reflector)
	reflector.RemoveElement(/datum/element/throw_parry)
