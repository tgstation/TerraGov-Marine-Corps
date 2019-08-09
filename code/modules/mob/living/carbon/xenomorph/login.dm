/mob/living/carbon/xenomorph/Login()
	. = ..()
	if(afk_timer_id)
		deltimer(afk_timer_id)
		afk_timer_id = null

	if(lighting_alpha == LIGHTING_PLANE_ALPHA_NV_TRAIT)
		ENABLE_BITFIELD(sight, SEE_MOBS)
		ENABLE_BITFIELD(sight, SEE_OBJS)
		ENABLE_BITFIELD(sight, SEE_TURFS)
		update_sight()

	if(!isdistress(SSticker.mode))
		return 

	var/datum/game_mode/distress/D = SSticker.mode
	D.xenomorphs |= mind

	mind.assigned_role = ROLE_XENOMORPH


/mob/living/carbon/xenomorph/queen/Login()
	. = ..()

	mind.assigned_role = ROLE_XENO_QUEEN


/mob/living/carbon/xenomorph/shrike/Login()
	. = ..()

	mind.assigned_role = ROLE_XENO_QUEEN	
