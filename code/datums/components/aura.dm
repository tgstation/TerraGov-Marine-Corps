/**
Applys status effects to mobs within range
*/
/datum/component/aura
	/// if the component is active
	var/active = TRUE

	/// How far should this aura emit to (default to world view)
	var/range = WORLD_VIEW_NUM

	/// How long does the aura last for (default -1 // infinite)
	var/duration = -1

	/// How strong of an aura do we emit, stronger auras do not replace weaker auras (default 1)
	var/strength = 1

	/// Which status effect to apply
	var/datum/status_effect/aura/current_aura = /datum/status_effect/aura/frenzy


/datum/component/aura/Initialize(datum/status_effect/aura/aura_path, set_range, set_duration, set_strength)
	. = ..()
	if(ispath(aura_path))
		current_aura = aura_path
	if(isnum(set_range))
		range = set_range
	if(isnum(set_duration))
		duration = set_duration
	if(isnum(set_strength))
		strength = set_strength

	START_PROCESSING(SSprocessing, src)

/datum/component/aura/proc/toggle_active(set_active = TRUE)
	active = set_active
	if(active)
		START_PROCESSING(SSprocessing, src)
	else
		STOP_PROCESSING(SSprocessing, src)

/datum/component/aura/proc/set_aura(datum/status_effect/aura/new_aura)
	if(!ispath(new_aura))
		return
	current_aura = new_aura

/datum/component/aura/process()
	emit_burst()

/// Emit a single instance of the aura
/datum/component/aura/proc/emit_burst()
	if(!ispath(current_aura))
		stack_trace("Invalid aura given to component")
		qdel(src)
		return
	var/mob/living/carbon/xenomorph/xeno = parent
	xeno.apply_status_effect(current_aura, duration, strength)
	for(var/x in xeno.hive.get_all_xenos())
		if(get_dist(parent, x) > range)
			continue
		var/mob/living/carbon/xenomorph/nearby_xeno = x
		nearby_xeno.apply_status_effect(current_aura, duration, strength)
