//A storage item intended to be used by other items to provide storage functionality.
//Types that use this should consider overriding emp_act() and hear_talk(), unless they shield their contents somehow.
/obj/item/storage/internal
	allow_drawing_method = FALSE /// Unable to set draw_mode ourselves
	var/obj/master_item

/obj/item/storage/internal/Initialize(mapload)
	. = ..()
	master_item = loc
	if(!istype(master_item))
		master_item = null
		return INITIALIZE_HINT_QDEL
	name = master_item.name
	forceMove(master_item)
	verbs -= /obj/item/verb/verb_pickup	//make sure this is never picked up.

/obj/item/storage/internal/Destroy()
	for(var/i in contents)
		var/obj/item/content_item = i
		qdel(content_item)
	master_item = null
	return ..()

/obj/item/storage/internal/attack_hand(mob/living/user)
	return TRUE

/obj/item/storage/internal/mob_can_equip(mob/user, slot, warning = TRUE, override_nodrop = FALSE, bitslot = FALSE)
	return 0	//make sure this is never picked up

//Helper procs to cleanly implement internal storages - storage items that provide inventory slots for other items.
//These procs are completely optional, it is up to the master item to decide when it's storage get's opened by calling open()
//However they are helpful for allowing the master item to pretend it is a storage item itself.
//If you are using these you will probably want to override attackby() as well.
//See /obj/item/clothing/suit/storage for an example.

//Items that use internal storage have the option of calling this to emulate default storage MouseDrop behaviour.
//Returns 1 if the master item's parent's MouseDrop() should be called, 0 otherwise. It's strange, but no other way of
//Doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_mousedrop(mob/user, obj/over_object)
	if(!ishuman(user))
		return FALSE

	if(user.lying_angle || user.incapacitated()) //Can't use your inventory when lying
		return FALSE

	if(istype(user.loc, /obj/vehicle/multitile/root/cm_armored)) //Stops inventory actions in a mech/tank
		return FALSE

	if(over_object == user && Adjacent(user)) //This must come before the screen objects only block
		open(user)
		return FALSE

	if(!isitem(master_item))
		return FALSE

	var/obj/item/owner = master_item

	if(HAS_TRAIT(owner, TRAIT_NODROP))
		return FALSE

	if(!istype(over_object, /atom/movable/screen))
		return TRUE

	//Makes sure owner is equipped before putting it in hand, so that we can't drag it into our hand from miles away.
	//There's got to be a better way of doing this...
	if(owner.loc != user || (owner.loc?.loc == user))
		return FALSE

	if(over_object.name == "r_hand" || over_object.name == "l_hand")
		if(owner.unequip_delay_self)
			INVOKE_ASYNC(src, PROC_REF(unequip_item), user, over_object.name)
		else if(over_object.name == "r_hand")
			user.dropItemToGround(owner)
			user.put_in_r_hand(owner)
		else if(over_object.name == "l_hand")
			user.dropItemToGround(owner)
			user.put_in_l_hand(owner)
	return FALSE

///unequips items that require a do_after because they have an unequip time
/obj/item/storage/internal/proc/unequip_item(mob/living/carbon/user, hand_to_put_in)
	var/obj/item/owner = master_item
	if(!do_after(user, owner.unequip_delay_self, NONE, owner, BUSY_ICON_FRIENDLY))
		to_chat(user, "You stop taking off \the [owner]")
		return
	if(hand_to_put_in == "r_hand")
		user.dropItemToGround(owner)
		user.put_in_r_hand(owner)
	else
		user.dropItemToGround(owner)
		user.put_in_l_hand(owner)

//Items that use internal storage have the option of calling this to emulate default storage attack_hand behaviour.
//Returns 1 if the master item's parent's attack_hand() should be called, 0 otherwise.
//It's strange, but no other way of doing it without the ability to call another proc's parent, really.
/obj/item/storage/internal/proc/handle_attack_hand(mob/user)

	if(user.lying_angle)
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == master_item && !H.get_active_held_item())	//Prevents opening if it's in a pocket.
			H.put_in_hands(master_item)
			H.l_store = null
			return FALSE
		if(H.r_store == master_item && !H.get_active_held_item())
			H.put_in_hands(master_item)
			H.r_store = null
			return FALSE

	if(master_item.loc == user)
		if(draw_mode && ishuman(user) && length(contents))
			var/obj/item/I = contents[length(contents)]
			I.attack_hand(user)
		else
			open(user)
		return FALSE

	for(var/mob/M in range(1, master_item.loc))
		if(M.s_active == src)
			close(M)
	return TRUE

/obj/item/storage/internal/Adjacent(atom/neighbor)
	return master_item.Adjacent(neighbor)


/obj/item/storage/internal/handle_item_insertion(obj/item/W, prevent_warning = FALSE)
	. = ..()
	master_item?.on_pocket_insertion()


/obj/item/storage/internal/remove_from_storage(obj/item/W, atom/new_location, mob/user)
	. = ..()
	master_item?.on_pocket_removal()


///things to do when an item is inserted in the obj's internal pocket
/obj/proc/on_pocket_insertion()
	return

///things to do when an item is removed in the obj's internal pocket
/obj/proc/on_pocket_removal()
	return
