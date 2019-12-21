/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A)
	A.attack_animal(src)


/atom/proc/attack_animal(mob/user as mob)
	return



/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A)
	A.attack_paw(src)

/atom/proc/attack_paw(mob/living/carbon/monkey/user)
	return


/atom/proc/attack_hand(mob/living/user)
	. = FALSE
	if(QDELETED(src))
		stack_trace("attack_hand on a qdeleted atom")
		return TRUE
	add_fingerprint(user, "attack_hand")
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE

/atom/movable/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(buckle_flags & CAN_BUCKLE)
		switch(LAZYLEN(buckled_mobs))
			if(0)
				return
			if(1)
				if(user_unbuckle_mob(buckled_mobs[1], user))
					return TRUE
			else
				var/unbuckled = input(user, "Who do you wish to unbuckle?", "Unbuckle Who?") as null|mob in sortNames(buckled_mobs)
				if(!unbuckled)
					return
				if(user_unbuckle_mob(unbuckled, user))
					return TRUE

/obj/structure/bed/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(buckled_bodybag)
		unbuckle_bodybag()
		return TRUE

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(a_intent != INTENT_HARM || !ismob(A))
		return
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = ran_zone(pick("chest", "l_hand", "r_hand", "l_leg", "r_leg"))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		visible_message("<span class='danger'>[name] has bit [ML]!</span>")
	else
		visible_message("<span class='danger'>[src] has attempted to bite [ML]!</span>")


/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/Click()
	return TRUE
