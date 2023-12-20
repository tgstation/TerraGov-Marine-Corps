//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

/**
	returns the thing in our currently active hand
*/
/mob/proc/get_active_held_item()
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return
	if(hand)
		return l_hand
	return r_hand

/**
	returns the thing in our currently inactive hand
*/
/mob/proc/get_inactive_held_item()
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return
	if(hand)
		return r_hand
	return l_hand

/**
 * Checks if this mob is holding a certain type of item in hands
 * returns the item if found
 * Args:
 * * typepath: typepath to check for
 */
/mob/proc/is_holding_item_of_type(typepath)
	var/obj/held_item = get_active_held_item()
	if(istype(held_item, typepath))
		return held_item
	held_item = get_inactive_held_item()
	if(istype(held_item, typepath))
		return held_item
	return

/**
	Puts the item into your l_hand if possible and calls all necessary triggers/updates.

	Arguments
	* obj/item/W is the item you are trying to equip

	Returns TRUE on success.
*/
/mob/proc/put_in_l_hand(obj/item/W)
	W.do_pickup_animation(src)
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(lying_angle)
		return FALSE
	if(!istype(W))
		return FALSE
	if(!l_hand)
		W.forceMove(src)
		l_hand = W
		W.equipped(src,SLOT_L_HAND)
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		update_inv_l_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return TRUE
	return FALSE

/**
	Puts the item into your r_hand if possible and calls all necessary triggers/updates.

	Arguments
	* obj/item/W is the item you are trying to equip

	Returns TRUE on success.
*/
/mob/proc/put_in_r_hand(obj/item/W)
	W.do_pickup_animation(src)
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(lying_angle)
		return FALSE
	if(!istype(W))
		return FALSE
	if(!r_hand)
		W.forceMove(src)
		r_hand = W
		W.equipped(src,SLOT_R_HAND)
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		update_inv_r_hand()
		W.pixel_x = initial(W.pixel_x)
		W.pixel_y = initial(W.pixel_y)
		return TRUE
	return FALSE

/**
	Puts the item into our active hand if possible.

	Arguments
	* obj/item/W is the item you are trying to equip

	Returns TRUE on success.
*/
/mob/proc/put_in_active_hand(obj/item/W)
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(hand)
		return put_in_l_hand(W)
	return put_in_r_hand(W)

/**
	Puts the item into our inactive hand if possible.

	Arguments
	* obj/item/W is the item you are trying to equip
	Returns TRUE on success.
*/
/mob/proc/put_in_inactive_hand(obj/item/W)
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(hand)
		return put_in_r_hand(W)
	return put_in_l_hand(W)

/**
	Puts the item our active hand if possible. Failing that it tries our inactive hand.
	If both hands fail the item falls to the floor.

	Arguments
	* obj/item/W is the item you are trying to equip
	* del_on_fail if true will delete the item instead of dropping it to the floor

	Returns TRUE if it was able to put the thing into one of our hands.
*/
/mob/proc/put_in_hands(obj/item/W, del_on_fail = FALSE)
	W.do_pickup_animation(src)
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(!W)
		return FALSE
	if(put_in_active_hand(W))
		return TRUE
	if(put_in_inactive_hand(W))
		return TRUE
	if(del_on_fail)
		qdel(W)
		return FALSE
	W.forceMove(get_turf(src))
	W.layer = initial(W.layer)
	W.plane = initial(W.plane)
	W.dropped(src)
	return FALSE

/// Returns if we're able to put something in a hand of a mob
/mob/proc/can_put_in_hand(I, hand_index)
	if(!put_in_hand_check(I))
		return FALSE
	if(!index_to_hand(hand_index))
		return FALSE
	return !get_item_for_held_index(hand_index)

///Puts an item in a specific hand index (so left or right)
/mob/proc/put_in_hand(obj/item/I, hand_index, del_on_fail)
	if(!hand_index)
		return put_in_hands(I, del_on_fail)
	switch(hand_index)
		if(1)
			return put_in_l_hand(I)
		else
			return put_in_r_hand(I)

///Proc that checks if we can put something into someone's hands
/mob/proc/put_in_hand_check(obj/item/I, hand_index)
	return FALSE					//nonliving mobs don't have hands

/mob/living/put_in_hand_check(obj/item/I, hand_index)
	if((I.flags_item & ITEM_ABSTRACT))
		return FALSE
	return TRUE

///returns the hand based on index (1 for left hand, 2 for right)
/mob/proc/index_to_hand(hand_index)
	return

///gets an item by hand index
/mob/proc/get_item_for_held_index(hand_index)
	if(!hand_index)
		return
	switch(hand_index)
		if(1)
			return l_hand
		else
			return r_hand

/**
	Helper proc used by the drop_item verb and on screen button.

	Returns TURE if it was successful.
*/
/mob/proc/drop_item_v()
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(stat == CONSCIOUS && isturf(loc))
		return drop_held_item()
	return FALSE

/**
	Drops the item in our left hand.

	Returns TURE if it was successful.
*/
/mob/proc/drop_l_hand()
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(l_hand)
		return dropItemToGround(l_hand)
	return FALSE

/**
	Drops the item in our right hand.

	Returns TURE if it was successful.
*/
/mob/proc/drop_r_hand()
	if(status_flags & INCORPOREAL) //  things don't have hands
		return FALSE
	if(r_hand)
		return dropItemToGround(r_hand)
	return FALSE

/**
	Drops the item in our active hand.

	Returns TURE if it was successful.
*/
/mob/proc/drop_held_item()
	if(status_flags & INCORPOREAL) // INCORPOREAL things don't have hands
		return FALSE
	if(hand)
		return drop_l_hand()
	return drop_r_hand()

/**
	Drops the items in our hands.

	Returns TURE if it was successful.
*/
/mob/proc/drop_all_held_items()
	if(status_flags & INCORPOREAL)
		return
	drop_r_hand()
	drop_l_hand()

/**
 * Used to drop an item (if it exists) to the ground.
 * * Will return TRUE is successfully dropped.
 * * Will return FALSE if the item can not be dropped due to TRAIT_NODROP via doUnEquip().
 * * Will return null if there is no item.
 * If the item can be dropped, it will be forceMove()'d to the ground and the turf's Entered() will be called.
*/
/mob/proc/dropItemToGround(obj/item/I, force = FALSE)
	. = UnEquip(I, force, drop_location())
	if(.)
		I.pixel_x = initial(I.pixel_x) + rand(-6,6)
		I.pixel_y = initial(I.pixel_y) + rand(-6,6)

/**
 * For when the item will be immediately placed in a loc other than the ground.
*/
/mob/proc/transferItemToLoc(obj/item/I, atom/newloc, force = FALSE)
	I.do_drop_animation(src)
	return UnEquip(I, force, newloc)

/**
 *Removes an item on a mob's inventory.
 * * It does not change the item's loc, just unequips it from the mob.
 * * Used just before you want to delete the item, or moving it afterwards.
*/
/mob/proc/temporarilyRemoveItemFromInventory(obj/item/I, force = FALSE)
	return UnEquip(I, force)

/**
 * DO NOT CALL THIS PROC
 * * Use one of the above 3 helper procs.
 * * You may override it, but do not modify the args.
*/
/mob/proc/UnEquip(obj/item/I, force, atom/newloc)
	if(!I)
		return

	if(HAS_TRAIT(I, TRAIT_NODROP) && !force)
		return FALSE //UnEquip() only fails if item has TRAIT_NODROP

	doUnEquip(I)

	if (client)
		client.screen -= I
	I.layer = initial(I.layer)
	I.plane = initial(I.plane)
	if(newloc)
		I.forceMove(newloc)
		I.removed_from_inventory(src)
	I.dropped(src)

	return TRUE


/mob/proc/doUnEquip(obj/item/I)
	if(I == r_hand)
		r_hand = null
		I.unequipped(src, SLOT_R_HAND)
		update_inv_r_hand()
		return ITEM_UNEQUIP_DROPPED
	else if (I == l_hand)
		l_hand = null
		I.unequipped(src, SLOT_L_HAND)
		update_inv_l_hand()
		return ITEM_UNEQUIP_DROPPED
	return ITEM_UNEQUIP_FAIL

/**
 * Used to return a list of equipped items on a mob; does not include held items (use get_all_gear)
 *
 * Argument(s):
 * * Optional - include_pockets (TRUE/FALSE), whether or not to include the pockets and suit storage in the returned list
 * * Optional - include_accessories (TRUE/FALSE), whether or not to include the accessories in the returned list
 */

/mob/living/proc/get_equipped_items(include_pockets = FALSE, include_accessories = FALSE)
	var/list/items = list()
	for(var/obj/item/item_contents in contents)
		if(item_contents.flags_item & IN_INVENTORY)
			items += item_contents
	items -= get_active_held_item()
	items -= get_inactive_held_item()
	return items

/**
 * Used to return a list of equipped items on a human mob; does not include held items (use get_all_gear)
 *
 * Argument(s):
 * * Optional - include_pockets (TRUE/FALSE), whether or not to include the pockets and suit storage in the returned list
 */

/mob/living/carbon/human/get_equipped_items(include_pockets = FALSE)
	var/list/items = ..()
	if(!include_pockets)
		items -= list(l_store, r_store)
	return items

///Find the slot an item is equipped to and returns its slot define
/mob/proc/get_equipped_slot(obj/equipped_item)
	if(equipped_item == l_hand)
		. = SLOT_L_HAND
	else if(equipped_item == r_hand)
		. = SLOT_R_HAND
	else if(equipped_item == wear_mask)
		. = SLOT_WEAR_MASK

/mob/living/proc/unequip_everything()
	var/list/items = list()
	items |= get_equipped_items(TRUE)
	for(var/I in items)
		dropItemToGround(I)
	drop_all_held_items()


/mob/living/carbon/proc/check_obscured_slots()
	var/obscured = NONE
	var/hidden_slots = NONE

	for(var/obj/item/I in get_equipped_items())
		hidden_slots |= I.flags_inv_hide

	if(hidden_slots & HIDEMASK)
		obscured |= ITEM_SLOT_MASK
	if(hidden_slots & HIDEEYES)
		obscured |= ITEM_SLOT_EYES
	if(hidden_slots & HIDEEARS)
		obscured |= ITEM_SLOT_EARS
	if(hidden_slots & HIDEGLOVES)
		obscured |= ITEM_SLOT_GLOVES
	if(hidden_slots & HIDEJUMPSUIT)
		obscured |= ITEM_SLOT_ICLOTHING
	if(hidden_slots & HIDESHOES)
		obscured |= ITEM_SLOT_FEET
	if(hidden_slots & HIDESUITSTORAGE)
		obscured |= ITEM_SLOT_SUITSTORE

	return obscured

//proc to get the item in the active hand.
/mob/proc/get_held_item()
	if(status_flags & INCORPOREAL)
		return
	if (hand)
		return l_hand
	else
		return r_hand


//Checks if we're holding a tool that has given quality
//Returns the tool that has the best version of this quality
/mob/proc/is_holding_tool_quality(quality)
	var/obj/item/best_item
	var/best_quality = INFINITY

	for(var/obj/item/I in list(l_hand, r_hand))
		if(I.tool_behaviour == quality && I.toolspeed < best_quality)
			best_item = I
			best_quality = I.toolspeed

	return best_item


// The mob is trying to strip an item from someone
/mob/proc/stripPanelUnequip(obj/item/I, mob/M)
	return

//returns the item in a given slot
/mob/proc/get_item_by_slot(slot_id)
	return

//returns the item in a given bit slot
/mob/proc/get_item_by_slot_bit(slot_bit)
	return

//placeholder until tg inventory system
/mob/proc/is_holding(obj/item/I)
	return ((I == l_hand) || (I == r_hand))
