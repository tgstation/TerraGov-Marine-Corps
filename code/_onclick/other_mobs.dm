
/*
	Carbon
*/

/mob/living/carbon/click(var/atom/A, var/list/mods)
	if (mods["shift"] && mods["middle"])
		point_to(A)
		return 1

	if (mods["middle"])
		swap_hand()
		return 1

	return ..()


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
	if(a_intent != "harm" || !ismob(A)) return
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = ran_zone(pick("chest", "l_hand", "r_hand", "l_leg", "r_leg"))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[name] has bit [ML]!</B>", 1)
		if(armor >= 2) return
		if(ismonkey(ML))
			for(var/datum/disease/D in viruses)
				if(istype(D, /datum/disease/jungle_fever))
					ML.contract_disease(D,1,0)
	else
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[src] has attempted to bite [ML]!</B>", 1)

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/click()
	return 1



/*
	Hell Hound
*/

/mob/living/carbon/hellhound/click(atom/A)
	..()

	if(stat > 0)
		return 1 //Can't click on shit buster!

	if(attack_timer)
		return 1

	if(get_dist(src,A) > 1)
		return 1

	if(istype(A,/mob/living/carbon/human))
		bite_human(A)
	else if(istype(A,/mob/living/carbon/Xenomorph))
		bite_xeno(A)
	else if(istype(A,/mob/living))
		bite_animal(A)
	else
		A.attack_animal(src)

	attack_timer = 1
	spawn(12)
		attack_timer = 0

	return 1