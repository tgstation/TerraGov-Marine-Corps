/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A, has_proximity, modifiers)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return
	A.attack_animal(src)


/atom/proc/attack_animal(mob/user as mob)
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

	if(status_flags & INCORPOREAL || user.status_flags & INCORPOREAL) //We can't physically attack or be attacked by the incorporeal
		return FALSE

	if(buckle_flags & CAN_BUCKLE)
		switch(LAZYLEN(buckled_mobs))
			if(0)
				return
			if(1)
				if(user_unbuckle_mob(buckled_mobs[1], user))
					return TRUE
			else
				var/unbuckled = tgui_input_list(user, "Who do you wish to unbuckle?", "Unbuckle Who?", sortNames(buckled_mobs))
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

/**
 * This proc is called when a human user right clicks on an atom with an empty hand
 *
 * Arguments:
 * * user: The mob clicking on the atom
 */
/atom/proc/attack_hand_alternate(mob/living/user)
	. = FALSE
	if(QDELETED(src))
		stack_trace("attack_hand_alternate on a qdeleted atom")
		return TRUE
	add_fingerprint(user, "attack_hand_alternate")
	if(SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND_ALTERNATE, user) & COMPONENT_NO_ATTACK_HAND)
		return TRUE

/**
 * This proc is called when an atom gets attacked (clicked on) by a powerloader clamp
 *
 * Arguments:
 * * user: The mob doing the attacking
 * * attached_clamp: The clamp used by the mob for attacking
 */


/atom/proc/attack_powerloader(mob/living/user, obj/item/powerloader_clamp/attached_clamp)
	. = FALSE

	SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_POWERLOADER, user, attached_clamp)
	add_fingerprint(user, "attack_powerloader")

	if(!attached_clamp)
		stack_trace("attack_powerloader called on [src] without an attached_clamp.")
		return TRUE

	if(!user)
		stack_trace("[attached_clamp] called attack_powerloader on [src] without a user.")
		return TRUE

	if(!attached_clamp.linked_powerloader)
		stack_trace("[attached_clamp] called attack_powerloader on [src] without a linked_powerloader.")
		return TRUE

	if(!Adjacent(user))
		return TRUE

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/new_player/Click()
	return TRUE
