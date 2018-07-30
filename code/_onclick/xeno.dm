
/*
	Xenomorph
*/

/mob/living/carbon/Xenomorph/UnarmedAttack(var/atom/A)

	if(lying) //No attacks while laying down
		return 0

	A.attack_alien(src)
	next_move = world.time + (10 + attack_delay) //Adds some lag to the 'attack'

//The parent proc, will default to attack_paw behaviour unless overriden
/atom/proc/attack_alien(mob/user as mob)
	return attack_paw(user)

/mob/living/carbon/Xenomorph/click(var/atom/A, var/list/mods)

	if(mods["middle"] && !mods["shift"])
		if(selected_ability && middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	if(mods["shift"])
		if(selected_ability && !middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	return ..()

/mob/living/carbon/Xenomorph/Boiler/click(var/atom/A, var/list/mods)
	if(!istype(A,/obj/screen))
		if(is_zoomed && !is_bombarding)
			zoom_out()
			return 1

		if(is_bombarding)
			if(isturf(A))
				bomb_turf(A)
			else if(isturf(get_turf(A)))
				bomb_turf(get_turf(A))
			if(client)
				client.mouse_pointer_icon = initial(client.mouse_pointer_icon)
			return 1

	if(mods["middle"] && !mods["shift"])
		if (selected_ability && middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	if(mods["shift"])
		if (selected_ability && !middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	return ..()

/mob/living/carbon/Xenomorph/Crusher/click(var/atom/A, var/list/mods)
	if(!istype(A, /obj/screen))
		if(is_charging)
			stop_momentum(charge_dir)

	if(mods["middle"] && !mods["shift"])
		if(selected_ability && middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	if(mods["shift"])
		if(selected_ability && !middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	return ..()

/mob/living/carbon/Xenomorph/Larva/UnarmedAttack(var/atom/A, var/list/mods)

	if(lying) //No attacks while laying down
		return 0

	A.attack_larva(src)
	next_move = world.time + (10 + attack_delay) //Adds some lag to the 'attack'

//Larva attack, will default to attack_alien behaviour unless overriden
/atom/proc/attack_larva(mob/living/carbon/Xenomorph/Larva/user)
	return attack_alien(user)

/mob/living/carbon/Xenomorph/Queen/click(var/atom/A, var/list/mods)

	if(mods["ctrl"] && mods["middle"])
		if(ovipositor)
			if(isXeno(A) && A != src)
				var/mob/living/carbon/Xenomorph/X = A
				if(X.stat != DEAD)
					set_queen_overwatch(A)
					return 1

	if(mods["middle"] && !mods["shift"])
		if (selected_ability && middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1

	if(mods["shift"])
		if(selected_ability && !middle_mouse_toggle)
			selected_ability.use_ability(A)
			return 1
