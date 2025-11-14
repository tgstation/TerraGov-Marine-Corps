/*!
 * This element allows the mob its attached to the ability to click an adjacent mob by clicking a distant atom
 * that is in the general direction relative to the parent.
 */
/datum/element/directional_attack/Attach(datum/target)
	. = ..()
	if(!ismob(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/element/directional_attack/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_MOB_ATTACK_RANGED)

/**
 * This proc handles clicks on tiles that aren't adjacent to the source mob
 * In addition to clicking the distant tile, it checks the tile in the direction and clicks the mob in the tile if there is one
 * Arguments:
 * * source - The mob clicking
 * * clicked_atom - The atom being clicked (should be a distant one)
 * * click_params - Miscellaneous click parameters, passed from Click itself
 */
/datum/element/directional_attack/proc/on_ranged_attack(mob/source, atom/clicked_atom, click_params)
	SIGNAL_HANDLER

	if(!(source?.client?.prefs?.toggles_gameplay & DIRECTIONAL_ATTACKS))
		return

	if(QDELETED(clicked_atom))
		return

	var/turf/turf_to_check = get_step(source, angle_to_dir(Get_Angle(source, clicked_atom)))
	if(!turf_to_check || !source.Adjacent(turf_to_check))
		return

	var/mob/living/target_mob = locate() in turf_to_check
	if(!target_mob || source.faction == target_mob.faction || target_mob.stat == DEAD)
		return

	//This is here to undo the +1 the click on the distant turf adds so we can click the mob near us
	source.next_click = world.time - 1
	INVOKE_ASYNC(source, TYPE_PROC_REF(/mob, ClickOn), target_mob, turf_to_check, click_params)
