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


/mob/living/carbon/xenomorph/wraith/Move(NewLoc, Dir = 0)

	if(status_flags & INCORPOREAL)

		if(!check_passable(NewLoc) )
			return FALSE

		face_atom(NewLoc) //Face the loc so we don't look like an ass.
		forceMove(NewLoc)
		return TRUE

	..()

/mob/living/carbon/xenomorph/wraith/proc/check_passable(turf/T)
	SHOULD_BE_PURE(TRUE)
	. = TRUE
	if(locate(WRAITH_PHASE_SHIFT_BLOCKERS) in T) //Cannot go through plasma gas or fire
		return FALSE

	for(var/atom/A in T) //Cannot go through dense objects that are indestructible for balance/design reasons, etc
		if(QDESTROYING(A))
			continue
		if(A.resistance_flags == RESIST_ALL && A.density && !(A.flags_atom & ON_BORDER))
			return FALSE

	return TRUE
