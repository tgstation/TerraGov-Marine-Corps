/mob/living/carbon/xenomorph/UnarmedAttack(atom/A, proximity_flag)
	if(lying)
		return FALSE

	if(xeno_caste)
		changeNext_move(xeno_caste.attack_delay)
	else
		changeNext_move(CLICK_CD_MELEE)

	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src)


//The parent proc, will default to attack_paw behaviour unless overriden
/atom/proc/attack_alien(mob/user)
	return attack_paw(user)


/mob/living/carbon/xenomorph/larva/UnarmedAttack(atom/A, proximity_flag)
	if(lying)
		return FALSE

	A.attack_larva(src)


//Larva attack, will default to attack_alien behaviour unless overriden
/atom/proc/attack_larva(mob/living/carbon/xenomorph/larva/user)
	return attack_alien(user)


/mob/living/carbon/xenomorph/queen/CtrlMiddleClickOn(atom/A)
	. = ..()
	if(!ovipositor)
		return
	if(!isxeno(A) || A == src)
		return
	var/mob/living/carbon/xenomorph/X = A
	if(X.stat == DEAD)
		return
	set_queen_overwatch(A)


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

/mob/living/carbon/xenomorph/crusher/ClickOn(atom/A, params)
	. = ..()
	if(!is_charging)
		return
	stop_momentum(charge_dir)