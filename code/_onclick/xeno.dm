
/*
	Xenomorph
*/

/mob/living/carbon/Xenomorph/UnarmedAttack(var/atom/A)
	A.attack_alien(src)
	next_move = world.time + (10 + attack_delay) //Adds some lag to the 'attack'

//The parent proc, will default to attack_paw behaviour unless overriden
/atom/proc/attack_alien(mob/user as mob)
	return attack_paw(user)



/mob/living/carbon/Xenomorph/MiddleClickOn(atom/A)
	if(selected_ability && middle_mouse_toggle)
		selected_ability.use_ability(A)
		return
	..()

/mob/living/carbon/Xenomorph/ShiftClickOn(atom/A)
	if(selected_ability && !middle_mouse_toggle)
		selected_ability.use_ability(A)
		return
	..()

/mob/living/carbon/Xenomorph/Boiler

	ClickOn(var/atom/A, params)
		if(!istype(A,/obj/screen))
			if(is_zoomed && !is_bombarding)
				zoom_out()

			if(is_bombarding)
				if(isturf(A))
					bomb_turf(A)
				else if(isturf(get_turf(A)))
					bomb_turf(get_turf(A))
				if(client)
					client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
				return
		..()


/mob/living/carbon/Xenomorph/Crusher

	ClickOn( var/atom/A, var/params)
		if(!istype(A,/obj/screen))
			if(momentum > 1)
				stop_momentum(charge_dir)
		..()





/mob/living/carbon/Xenomorph/Larva/UnarmedAttack(var/atom/A)
	A.attack_larva(src)
	next_move = world.time + (10 + attack_delay) //Adds some lag to the 'attack'

//Larva attack, will default to attack_alien behaviour unless overriden
/atom/proc/attack_larva(mob/living/carbon/Xenomorph/Larva/user)
	return attack_alien(user)



/mob/living/carbon/Xenomorph/Queen/DblClickOn(var/atom/A, var/params)
	if(ovipositor)
		if(isXeno(A) && A != src)
			if(observed_xeno)
				set_queen_overwatch(observed_xeno, TRUE)
			set_queen_overwatch(A)
			return
	ClickOn(A,params)

