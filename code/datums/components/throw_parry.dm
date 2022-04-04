/**
 * This component allows a mob/living to parry thrown objects back towards its source provided certain conditions are met.
 * COMSIG_PARRY_TRIGGER together with a duration enables parrying for this time frame, durations do not stack and only the current latest ending one is used.
 * A thrown item being parried will prevent the throw from ending and returns said thrown object back towards its source with half its speed.
**/
/datum/component/throw_parry
	///The mob/living this component interacts with, namely reacting to attempted throw impacts on it.
	var/mob/living/living_parent
	///Until which world.time the parry is active. Parries can only trigger if this is larger than the current world.time.
	var/parry_until = 0


/datum/component/throw_parry/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	living_parent = parent

/datum/component/throw_parry/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_THROW_PARRY_CHECK, .proc/parry_check)
	RegisterSignal(parent, COMSIG_PARRY_TRIGGER, .proc/enable_parry)

/datum/component/throw_parry/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_THROW_PARRY_CHECK,
		COMSIG_PARRY_TRIGGER
	))

/**
 * This is triggered by an object attempting to impact into something with the parry component attached and checks whether the current conditions are valid to trigger a parry success.
 * The mob has to be conscious aswell as not resting and the parry duration must not have timed out.
 * * Returns TRUE on successful parry and nothing if failed, which is then handled by throwing code.
**/
/datum/component/throw_parry/proc/parry_check(parry_target, atom/movable/to_parry)
	SIGNAL_HANDLER
	if(living_parent.stat >= UNCONSCIOUS)
		return
	if(living_parent.resting)
		return
	if(parry_until < world.time)
		return
	living_parent.visible_message(span_warning("[living_parent] deflects [to_parry]!"), span_notice("[isxeno(living_parent) ? "We" : "You"] bounce [to_parry] back towards its source!"))
	return TRUE

/**
 * Enables parrying for the passed duration. Multiple sources of enabling will not be directly summed up, instead using the latest ending one.
**/
/datum/component/throw_parry/proc/enable_parry(parry_triggerer, duration)
	SIGNAL_HANDLER
	parry_until = max(parry_until, world.time + duration)

