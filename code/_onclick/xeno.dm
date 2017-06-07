
/*
	Xenomorph
*/

/mob/living/carbon/Xenomorph/UnarmedAttack(var/atom/A)
	A.attack_alien(src)
	next_move = world.time + (10 + attack_delay) //Adds some lag to the 'attack'

//The parent proc, will default to attack_paw behaviour unless overriden
/atom/proc/attack_alien(mob/user as mob)
	return attack_paw(user)



/mob/living/carbon/Xenomorph

	MiddleClickOn(atom/A)
		if(middle_mouse_toggle)
			Xeno_MiddleClick_Action(A)
			return
		..()

	ShiftClickOn(atom/A)
		if(shift_mouse_toggle)
			Xeno_ShiftClick_Action(A)
			return
		..()

/mob/living/carbon/Xenomorph/proc/Xeno_MiddleClick_Action(atom/A)
	return

/mob/living/carbon/Xenomorph/proc/Xeno_ShiftClick_Action(atom/A)
	Xeno_MiddleClick_Action(A) //defaults to the middleclick action



/mob/living/carbon/Xenomorph/Hunter

	Xeno_MiddleClick_Action(atom/A)
		Pounce(A)


/mob/living/carbon/Xenomorph/Sentinel

	Xeno_MiddleClick_Action(atom/A)
		neurotoxin(A)




/mob/living/carbon/Xenomorph/Runner

	Xeno_MiddleClick_Action(atom/A)
		Pounce(A)



/mob/living/carbon/Xenomorph/Spitter

	Xeno_MiddleClick_Action(atom/A)
		neurotoxin(A)



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

	Xeno_MiddleClick_Action(atom/A)
		if(A)
			face_atom(A)
			acid_spray(A)



/mob/living/carbon/Xenomorph/Carrier

	Xeno_MiddleClick_Action(atom/A)
		throw_hugger(A)



/mob/living/carbon/Xenomorph/Praetorian

	Xeno_MiddleClick_Action(atom/A)
		neurotoxin(A)

	Xeno_ShiftClick_Action(atom/A)
		resin_spit(A)



/mob/living/carbon/Xenomorph/Crusher

	ClickOn( var/atom/A, var/params )
		if(!istype(A,/obj/screen))
			if(momentum > 1)
				stop_momentum(charge_dir)
		..()



/mob/living/carbon/Xenomorph/Ravager

	Xeno_MiddleClick_Action(atom/A)
		charge(A)



/mob/living/carbon/Xenomorph/Ravager/ravenger

	Xeno_MiddleClick_Action(atom/A)
		breathe_fire(A)



/mob/living/carbon/Xenomorph/Xenoborg

	Xeno_MiddleClick_Action(atom/A)
		if(!gun_on)
			Pounce(A)
		else
			fire_cannon(A)




/mob/living/carbon/Xenomorph/Larva/UnarmedAttack(var/atom/A)
	A.attack_larva(src)
	next_move = world.time + (10 + attack_delay) //Adds some lag to the 'attack'

//Larva attack, will default to attack_alien behaviour unless overriden
/atom/proc/attack_larva(mob/living/carbon/Xenomorph/Larva/user)
	return attack_alien(user)