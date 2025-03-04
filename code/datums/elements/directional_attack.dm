/*!
 * This element allows the mob its attached to the ability to click an adjacent mob by clicking a distant atom
 * that is in the general direction relative to the parent.
 */
/datum/element/directional_attack/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))
	RegisterSignal(target, COMSIG_MOB_ATTACK_UNARMED, PROC_REF(on_unarmed_attack))

/datum/element/directional_attack/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_MOB_ATTACK_RANGED, COMSIG_MOB_ATTACK_UNARMED))

/**
 * This proc handles clicks on tiles that are NOT adjacent to the source mob.
 * In addition to clicking the distant tile, it checks the tile in the direction and clicks the mob in the tile if there an eligible one.
 *
 * Arguments:
 * * source - The mob clicking
 * * clicked_atom - The atom being clicked (should be a distant one)
 * * click_params - Miscellaneous click parameters, passed from Click itself
 */
/datum/element/directional_attack/proc/on_ranged_attack(mob/source, atom/clicked_atom, click_params)
	SIGNAL_HANDLER
	if(!can_attack(source, clicked_atom))
		return
	var/turf/turf_to_check = get_step(source, angle_to_dir(Get_Angle(source, clicked_atom)))
	if(!turf_to_check || !source.Adjacent(turf_to_check))
		return
	var/mob/target_mob = locate() in turf_to_check
	if(!target_mob || source.faction == target_mob.faction)
		return
	source.next_click = world.time - 1 //This is here to undo the +1 the click on the distant turf adds so we can click the mob near us.
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, ClickOn), target_mob, turf_to_check, click_params)

/// Inversely to the above proc, this one handles clicks on tiles that are adjacent to the source mob. If there is an eligible mob in the tile, it will attack them.
/datum/element/directional_attack/proc/on_unarmed_attack(mob/source, atom/clicked_atom, click_params)
	SIGNAL_HANDLER
	if(!can_attack(source, clicked_atom))
		return
	if(ismob(clicked_atom))
		return
	var/mob/target_mob = locate() in get_turf(clicked_atom)
	if(!target_mob || source.faction == target_mob.faction)
		return
	source.next_click = world.time - 1
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, UnarmedAttack), target_mob, TRUE, click_params)

/// Checks if an attack is possible on a given atom.
/datum/element/directional_attack/proc/can_attack(mob/source, atom/clicked_atom)
	if(!(source?.client?.prefs?.toggles_gameplay & DIRECTIONAL_ATTACKS))
		return FALSE
	if(QDELETED(clicked_atom))
		return FALSE
	return TRUE
