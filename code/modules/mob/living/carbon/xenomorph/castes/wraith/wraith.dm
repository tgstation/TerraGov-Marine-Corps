///Global list of things the wraith can't pass while ethereal
GLOBAL_LIST_INIT(wraith_no_incorporeal_pass_atoms, typecacheof(list(
	/obj/flamer_fire,
	/obj/effect/particle_effect/smoke/plasmaloss,
	/turf/open/space)))

GLOBAL_LIST_INIT(wraith_no_incorporeal_pass_areas, typecacheof(list(
	/area/shuttle/drop1/lz1,
	/area/shuttle/drop2/lz2,
	/area/outpost/lz1,
	/area/outpost/lz2)))

//Don't even think of going in here
GLOBAL_LIST_INIT(wraith_strictly_forbidden_areas, typecacheof(list(
	/area/space)))

GLOBAL_LIST_INIT(wraith_no_incorporeal_pass_shutters, typecacheof(list(
	/obj/machinery/door/poddoor/timed_late/containment,
	/obj/machinery/door/poddoor/shutters/mainship/selfdestruct)))

/mob/living/carbon/xenomorph/wraith
	caste_base_type = /mob/living/carbon/xenomorph/wraith
	name = "Wraith"
	desc = "A strange tendriled alien. The air around it warps and shimmers like a heat mirage."
	icon = 'icons/Xeno/2x2_Xenos.dmi'
	icon_state = "Wraith Walking"
	health = 150
	maxHealth = 150
	plasma_stored = 150
	pixel_x = -16
	old_x = -16
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	inherent_verbs = list(
		/mob/living/carbon/xenomorph/proc/vent_crawl,
	)

/// Returns true or false to allow src to move through the blocker, mover has final say
/mob/living/carbon/xenomorph/wraith/CanPassThrough(atom/blocker, turf/target, blocker_opinion)
	if(!(status_flags & INCORPOREAL)) //If we're not incorporeal don't bother with special checks
		return ..()
	if(is_type_in_typecache(blocker, GLOB.wraith_no_incorporeal_pass_atoms)) //If we're incorporeal via Phase Shift and we encounter something on the no-go list, it's time to stop
		return FALSE
	if(is_type_in_typecache(blocker, GLOB.wraith_no_incorporeal_pass_shutters) && blocker.density) //If we're incorporeal via Phase Shift and we encounter no-go shutters that are closed, it's time to stop
		return FALSE
	var/area/target_area = get_area(target) //Have to set this as vars or is_type_in freaks out
	var/area/current_area = get_area(src)
	if(is_type_in_typecache(target_area, GLOB.wraith_strictly_forbidden_areas)) //We can't enter these period.
		return FALSE
	if(is_type_in_typecache(target_area, GLOB.wraith_no_incorporeal_pass_areas) && !is_type_in_typecache(current_area, GLOB.wraith_no_incorporeal_pass_areas)) //If we're incorporeal via Phase Shift and we enter an off-limits area while not in one, it's time to stop
		return FALSE
	return TRUE
