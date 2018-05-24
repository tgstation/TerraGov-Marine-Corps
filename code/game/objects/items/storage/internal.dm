//A storage item intended to be used by other items to provide storage functionality.
//Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
/obj/item/storage/internal
	var/obj/item/master_item

/obj/item/storage/internal/New(obj/item/MI)
	master_item = MI
	loc = master_item
	name = master_item.name
	verbs -= /obj/item/verb/verb_pickup	//make sure this is never picked up.
	..()

/obj/item/storage/internal/attack_hand()
	return		//make sure this is never picked up

/obj/item/storage/internal/mob_can_equip()
	return 0	//make sure this is never picked up

//Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
//These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
//However they are helpful for allowing the master item to pretend it is a storage item itself.
//If you are using these you will probably want to override attackby() as well.
//See /obj/item/clothing/suit/storage for an example.

//Items that use internal storage have the option of calling this to emulate default storage MouseDrop behaviour.
//Returns 1 if the master item's parent's MouseDrop() should be called, 0 otherwise. It's strange, but no other way of
//Doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_mousedrop(mob/user as mob, obj/over_object as obj)
	if(ishuman(user) || ismonkey(user)) //so monkeys can take off their backpacks -- Urist

		if(user.lying) //Can't use your inventory when lying
			return

		if(istype(user.loc, /obj/mecha)) //Stops inventory actions in a mech
			return 0

		if(over_object == user && Adjacent(user)) //This must come before the screen objects only block
			open(user)
			return 0

		if(master_item.flags_item & NODROP) return

		if(!istype(over_object, /obj/screen))
			return 1

		//Makes sure master_item is equipped before putting it in hand, so that we can't drag it into our hand from miles away.
		//There's got to be a better way of doing this...
		if(master_item.loc != user || (master_item.loc && master_item.loc.loc == user))
			return 0

		if(!user.is_mob_restrained() && !user.stat)
			switch(over_object.name)
				if("r_hand")
					if(master_item.time_to_unequip)
						spawn(0)
							if(!do_after(user, master_item.time_to_unequip, TRUE, 5, BUSY_ICON_GENERIC))
								user << "You stop taking off \the [master_item]"
							else
								user.drop_inv_item_on_ground(master_item)
								user.put_in_r_hand(master_item)
							return 0
					else
						user.drop_inv_item_on_ground(master_item)
						user.put_in_r_hand(master_item)
				if("l_hand")
					if(master_item.time_to_unequip)
						spawn(0)
							if(!do_after(user, master_item.time_to_unequip, TRUE, 5, BUSY_ICON_GENERIC))
								user << "You stop taking off \the [master_item]"
							else
								user.drop_inv_item_on_ground(master_item)
								user.put_in_l_hand(master_item)
							return 0
					else
						user.drop_inv_item_on_ground(master_item)
						user.put_in_l_hand(master_item)
			master_item.add_fingerprint(user)
			return 0
	return 0

//Items that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
//Returns 1 if the master item's parent's attack_hand() should be called, 0 otherwise.
//It's strange, but no other way of doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_attack_hand(mob/user as mob)

	if(user.lying)
		return 0

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == master_item && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			H.put_in_hands(master_item)
			H.l_store = null
			return 0
		if(H.r_store == master_item && !H.get_active_hand())
			H.put_in_hands(master_item)
			H.r_store = null
			return 0

	src.add_fingerprint(user)
	if(master_item.loc == user)
		src.open(user)
		return 0

	for(var/mob/M in range(1, master_item.loc))
		if(M.s_active == src)
			src.close(M)
	return 1

/obj/item/storage/internal/Adjacent(var/atom/neighbor)
	return master_item.Adjacent(neighbor)


/obj/item/storage/internal/handle_item_insertion(obj/item/W as obj, prevent_warning = 0)
	. = ..()
	master_item.on_pocket_insertion()


/obj/item/storage/internal/remove_from_storage(obj/item/W as obj, atom/new_location)
	. = ..()
	master_item.on_pocket_removal()


//things to do when an item is inserted in the obj's internal pocket
/obj/item/proc/on_pocket_insertion()
	return

//things to do when an item is removed in the obj's internal pocket
/obj/item/proc/on_pocket_removal()
	return