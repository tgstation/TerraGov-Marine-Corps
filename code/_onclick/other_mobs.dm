/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(var/atom/A)
	A.attack_animal(src)


/atom/proc/attack_animal(mob/user as mob)
	return



/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(var/atom/A)
	A.attack_paw(src)

/atom/proc/attack_paw(mob/user as mob)
	return


/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(var/atom/A)
	if(a_intent != INTENT_HARM || !ismob(A))
		return
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = ran_zone(pick("chest", "l_hand", "r_hand", "l_leg", "r_leg"))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		for(var/mob/O in viewers(ML, null))
			O.show_message("<span class='danger'>[name] has bit [ML]!</span>", 1)
	else
		for(var/mob/O in viewers(ML, null))
			O.show_message("<span class='danger'>[src] has attempted to bite [ML]!</span>", 1)


/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/Click()
	return TRUE