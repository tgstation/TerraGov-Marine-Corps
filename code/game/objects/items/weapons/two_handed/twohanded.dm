/obj/item/weapon/twohanded
	icon = 'icons/obj/items/weapons/twohanded.dmi'
	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/weapons/twohanded_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/weapons/twohanded_right.dmi',
	)
	w_class = WEIGHT_CLASS_BULKY
	var/wieldsound
	var/unwieldsound
	item_flags = TWOHANDED

/obj/item/weapon/twohanded/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	unwield(user)
	return ..()

/obj/item/weapon/twohanded/dropped(mob/user)
	. = ..()
	unwield(user)

/obj/item/weapon/twohanded/pickup(mob/user)
	unwield(user)

/obj/item/proc/wield(mob/user)
	if(!(item_flags & TWOHANDED) || item_flags & WIELDED)
		return FALSE

	var/obj/item/offhand = user.get_inactive_held_item()
	if(offhand)
		if(offhand == user.r_hand)
			user.drop_r_hand()
		else if(offhand == user.l_hand)
			user.drop_l_hand()
		if(user.get_inactive_held_item()) //Failsafe; if there's somehow still something in the off-hand (undroppable), bail.
			to_chat(user, span_warning("You need your other hand to be empty!"))
			return FALSE

	if(ishuman(user))
		var/check_hand = user.r_hand == src ? "l_hand" : "r_hand"
		var/mob/living/carbon/human/wielder = user
		var/datum/limb/hand = wielder.get_limb(check_hand)
		if(!istype(hand) || !hand.is_usable())
			to_chat(user, span_warning("Your other hand can't hold [src]!"))
			return FALSE

	if(!place_offhand(user))
		to_chat(user, span_warning("You cannot wield [src] right now."))
		return FALSE

	toggle_wielded(user, TRUE)
	SEND_SIGNAL(src, COMSIG_ITEM_WIELD, user)
	name = "[name] (Wielded)"
	update_item_state()
	user.update_inv_l_hand()
	user.update_inv_r_hand()
	return TRUE

/obj/item/proc/unwield(mob/user)
	if(!CHECK_MULTIPLE_BITFIELDS(item_flags, TWOHANDED|WIELDED))
		return FALSE

	toggle_wielded(user, FALSE)
	SEND_SIGNAL(src, COMSIG_ITEM_UNWIELD, user)
	var/sf = findtext(name, " (Wielded)", -10) // 10 == length(" (Wielded)")
	if(sf)
		name = copytext(name, 1, sf)
	else
		name = "[initial(name)]"
	update_item_state()
	remove_offhand(user)
	return TRUE

/obj/item/proc/place_offhand(mob/user)
	var/obj/item/weapon/twohanded/offhand/offhand = new /obj/item/weapon/twohanded/offhand(user)
	if(!user.put_in_inactive_hand(offhand))
		qdel(offhand)
		return FALSE
	to_chat(user, span_notice("You grab [src] with both hands."))
	offhand.name = "[name] - offhand"
	offhand.desc = "Your second grip on [src]."
	return TRUE

/obj/item/proc/remove_offhand(mob/user)
	to_chat(user, span_notice("You are now carrying [src] with one hand."))
	var/obj/item/weapon/twohanded/offhand/offhand = user.get_inactive_held_item()
	if(istype(offhand) && !QDELETED(offhand))
		qdel(offhand)
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/proc/toggle_wielded(user, wielded)
	if(wielded)
		item_flags |= WIELDED
	else
		item_flags &= ~WIELDED

/obj/item/weapon/twohanded/wield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(TRUE)

	if(wieldsound)
		playsound(user, wieldsound, 15, 1)

	force = force_activated

/obj/item/weapon/twohanded/unwield(mob/user)
	. = ..()
	if(!.)
		return
	toggle_active(FALSE)

	if(unwieldsound)
		playsound(user, unwieldsound, 15, 1)

	force = initial(force)

// TODO port tg wielding component
/obj/item/weapon/twohanded/attack_self(mob/user)
	. = ..()

	if(item_flags & WIELDED)
		unwield(user)
	else
		wield(user)

///////////OFFHAND///////////////
/obj/item/weapon/twohanded/offhand
	w_class = WEIGHT_CLASS_HUGE
	icon_state = "offhand"
	name = "offhand"
	item_flags = DELONDROP|TWOHANDED|WIELDED
	resistance_flags = RESIST_ALL
	layer = BELOW_OBJ_LAYER

/obj/item/weapon/twohanded/offhand/Destroy()
	if(ismob(loc))
		var/mob/user = loc
		var/obj/item/main_hand = user.get_active_held_item()
		if(main_hand)
			main_hand.unwield(user)
	return ..()

/obj/item/weapon/twohanded/offhand/unwield(mob/user)
	return

/obj/item/weapon/twohanded/offhand/dropped(mob/user)
	. = ..()
	return

/obj/item/weapon/twohanded/offhand/forceMove(atom/destination)
	if(!ismob(destination))
		qdel(src)
	return ..()
