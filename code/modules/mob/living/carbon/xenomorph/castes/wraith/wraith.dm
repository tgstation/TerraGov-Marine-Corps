///Global list of things the wraith can't pass while ethereal
GLOBAL_LIST_INIT(wraith_no_ethereal_pass, typecacheof(list(
/obj/flamer_fire,
/obj/effect/particle_effect/smoke/plasmaloss,
/turf/open/space,
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
/mob/living/carbon/xenomorph/wraith/IncorporealCanPassThrough(atom/blocker, turf/target)
	if(is_type_in_typecache(blocker, GLOB.wraith_no_ethereal_pass)) //If we're incorporeal via Phase Shift and we encounter something on the no-go list, it's time to stop
		return FALSE

	return ..()
