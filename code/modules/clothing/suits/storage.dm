/obj/item/clothing/suit/storage
	var/obj/item/storage/internal/pockets = /obj/item/storage/internal/suit


/obj/item/clothing/suit/storage/Initialize()
	. = ..()
	if(!pockets)
		return
	pockets = new pockets(src)


/obj/item/clothing/suit/storage/attack_hand(mob/living/user)
	if(!pockets || pockets.handle_attack_hand(user))
		return ..()


/obj/item/clothing/suit/storage/MouseDrop(obj/over_object)
	if(!pockets && (over_object.name == "r_hand" || over_object.name == "l_hand"))
		var/mob/user = usr
		if(time_to_unequip)
			INVOKE_ASYNC(src, .proc/handle_drop_delay, user, over_object.name)
		user.dropItemToGround(src)
		if(over_object.name == "r_hand")
			user.put_in_r_hand(src)
		if(over_object.name == "l_hand")
			user.put_in_l_hand(src)
		return
	if(pockets.handle_mousedrop(usr, over_object))
		return ..(over_object)

///Takes off src after a delay.
/obj/item/clothing/suit/storage/proc/handle_drop_delay(mob/user, slot)
	if(!do_after(user, time_to_unequip, TRUE, src, BUSY_ICON_FRIENDLY))
		to_chat(user, "You stop taking off \the [src]")
		return
	user.dropItemToGround(src)
	if(slot == "r_hand")
		user.put_in_r_hand(src)
	if(slot == "l_hand")
		user.put_in_l_hand(src)

/obj/item/clothing/suit/storage/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!pockets)
		return
	return pockets.attackby(I, user, params)


/obj/item/clothing/suit/storage/emp_act(severity)
	if(!pockets)
		return
	pockets.emp_act(severity)
	return ..()


/obj/item/storage/internal/suit
	storage_slots = 2	//two slots
	max_w_class = 2		//fit only small items
	max_storage_space = 4
