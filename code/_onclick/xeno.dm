/mob/living/carbon/xenomorph/UnarmedAttack(atom/A, proximity_flag)
	if(lying)
		return FALSE

	if(xeno_caste)
		changeNext_move(xeno_caste.attack_delay)
	else
		changeNext_move(CLICK_CD_MELEE)

	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src)


/atom/proc/attack_alien(mob/living/carbon/xenomorph/X)
	return


/mob/living/carbon/xenomorph/larva/UnarmedAttack(atom/A, proximity_flag)
	if(lying)
		return FALSE

	A.attack_larva(src)


/atom/proc/attack_larva(mob/living/carbon/xenomorph/larva/L)
	return


/mob/living/carbon/xenomorph/MiddleClickOn(atom/A)
	. = ..()
	if(!middle_mouse_toggle || !selected_ability)
		return
	if(selected_ability.can_use_ability(A))
		selected_ability.use_ability(A)


/mob/living/carbon/xenomorph/ShiftClickOn(atom/A)
	. = ..()
	if(!selected_ability || middle_mouse_toggle)
		return
	if(selected_ability.can_use_ability(A))
		selected_ability.use_ability(A)
