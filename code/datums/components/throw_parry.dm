/datum/component/throw_parry
	dupe_mode = COMPONENT_DUPE_SOURCES
	///Whether you need to be facing the thrown thing
	var/directional
	///The source of the parry, may differ from parent
	var/atom/source_atom

/datum/component/throw_parry/Initialize(_directional = FALSE, source)
	. = ..()
	if(!isatom(parent))
		return ELEMENT_INCOMPATIBLE

	directional = _directional
	source_atom = source ? source : parent

/datum/component/throw_parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PRE_MOVABLE_IMPACT, PROC_REF(parry_check))

/datum/component/throw_parry/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PRE_MOVABLE_IMPACT)
	source_atom = null

///reflects the thrown thing if checks are satisfied
/datum/component/throw_parry/proc/parry_check(atom/reflector, atom/movable/thrown)
	SIGNAL_HANDLER
	if(isliving(reflector))
		var/mob/living/living_reflector = reflector
		if(living_reflector.stat)
			return
		if(living_reflector.resting)
			return
	if(directional && !(reflector.dir & REVERSE_DIR(get_dir(thrown.throw_source, reflector))))
		return

	thrown.set_throwing(FALSE)
	source_atom.on_parry_throw(reflector, thrown)
	INVOKE_NEXT_TICK(thrown, TYPE_PROC_REF(/atom/movable, throw_at), thrown.throw_source, 6, max(thrown.thrown_speed * 0.5, 1), reflector, TRUE)
	return COMPONENT_PRE_MOVABLE_IMPACT_DODGED

/**
 * Any special behavior when this atom parries something
 * src is what is responsible for the parry
 * reflector is what actually has the parry component, could be src
 * thrown is the thing being reflected
 */
/atom/proc/on_parry_throw(atom/reflector, atom/movable/thrown)
	SIGNAL_HANDLER
	reflector.visible_message(span_warning("[reflector] deflects [thrown]!"), span_notice("[isxeno(reflector) ? "We" : "You"] bounce [thrown] back towards its source!"))
