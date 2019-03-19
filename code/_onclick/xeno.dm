/mob/living/carbon/Xenomorph/UnarmedAttack(atom/A, proximity_flag)
	if(lying)
		return FALSE

	if(xeno_caste)
		var/datum/xeno_caste/X = xeno_caste
		changeNext_move(X.attack_delay)
	else
		changeNext_move(CLICK_CD_MELEE)

	var/atom/S = A.handle_barriers(src)
	S.attack_alien(src)


//The parent proc, will default to attack_paw behaviour unless overriden
/atom/proc/attack_alien(mob/user)
	return attack_paw(user)


/mob/living/carbon/Xenomorph/Larva/UnarmedAttack(atom/A, proximity_flag)
	if(lying)
		return FALSE

	A.attack_larva(src)


//Larva attack, will default to attack_alien behaviour unless overriden
/atom/proc/attack_larva(mob/living/carbon/Xenomorph/Larva/user)
	return attack_alien(user)


/mob/living/carbon/Xenomorph/Queen/CtrlMiddleClickOn(atom/A)
	. = ..()
	if(!ovipositor)
		return
	if(!isxeno(A) || A == src)
		return
	var/mob/living/carbon/Xenomorph/X = A
	if(X.stat == DEAD)
		return
	set_queen_overwatch(A)


/mob/living/carbon/Xenomorph/MiddleClickOn(atom/A)
	. = ..()
	if(!middle_mouse_toggle || !selected_ability)
		return
	selected_ability.use_ability(A)


/mob/living/carbon/Xenomorph/ShiftClickOn(atom/A)
	. = ..()
	if(!selected_ability || middle_mouse_toggle)
		return
	selected_ability.use_ability(A)



/mob/living/carbon/Xenomorph/Boiler/ClickOn(atom/A, params)
	. = ..()
	if(istype(A, /obj/screen) || !is_bombarding)
		return
	if(isturf(A))
		bomb_turf(A)
	else
		bomb_turf(get_turf(A))
	if(client)
		client.mouse_pointer_icon = initial(client.mouse_pointer_icon)


/mob/living/carbon/Xenomorph/Crusher/ClickOn(atom/A, params)
	. = ..()
	if(istype(A, /obj/screen))
		return
	if(!is_charging)
		return
	stop_momentum(charge_dir)