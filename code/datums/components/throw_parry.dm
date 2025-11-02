/datum/component/throw_parry
	///Whether you need to be facing the thrown thing
	var/directional
	///The source of the parry, may differ from parent
	var/atom/source_atom
	///Removal timer if duration is set
	var/removal_timer

/datum/component/throw_parry/Initialize(duration, _directional = FALSE, source)
	. = ..()
	if(!isatom(parent))
		return ELEMENT_INCOMPATIBLE

	if(duration)
		removal_timer = addtimer(CALLBACK(src, PROC_REF(remove_self), parent), duration, TIMER_STOPPABLE)
	directional = _directional
	source_atom = source ? source : parent

/datum/component/throw_parry/RemoveComponent()
	source_atom.UnregisterSignal(parent, COMSIG_ELEMENT_PARRY_TRIGGERED)
	source_atom = null
	deltimer(removal_timer)
	removal_timer = null
	return ..()

/datum/component/throw_parry/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PRE_MOVABLE_IMPACT, PROC_REF(parry_check))
	source_atom.RegisterSignal(parent, COMSIG_ELEMENT_PARRY_TRIGGERED, TYPE_PROC_REF(/atom, on_parry_throw))

/datum/component/throw_parry/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PRE_MOVABLE_IMPACT)

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
	SEND_SIGNAL(reflector, COMSIG_ELEMENT_PARRY_TRIGGERED, thrown)
	INVOKE_NEXT_TICK(thrown, TYPE_PROC_REF(/atom/movable, throw_at), thrown.throw_source, 6, max(thrown.thrown_speed * 0.5, 1), reflector, TRUE)
	return COMPONENT_PRE_MOVABLE_IMPACT_DODGED

///Removes self after duration is up
/datum/component/throw_parry/proc/remove_self(atom/reflector)
	qdel(src)

/**
 * Any special behavior when this atom parries something
 * src is what is responsible for the parry
 * reflector is what actually has the parry component, could be src
 * thrown is the thing being reflected
 */
/atom/proc/on_parry_throw(atom/reflector, atom/movable/thrown)
	SIGNAL_HANDLER
	reflector.visible_message(span_warning("[reflector] deflects [thrown]!"), span_notice("[isxeno(reflector) ? "We" : "You"] bounce [thrown] back towards its source!"))
