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
 * returns TRUEif found FALSE if not
 * Args:
 * * typepath: typepath to check for
 */
/mob/proc/is_holding_item_of_type(typepath)
	if(istype(get_active_held_item(), typepath))
		return TRUE
	if(istype(get_inactive_held_item(), typepath))
		return TRUE
	return FALSE

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

	Returns TURE if it was able to put the thing into one of our hands.
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

	if((I.flags_item & NODROP) && !force)
		return FALSE //UnEquip() only fails if item has NODROP

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


//Outdated but still in use apparently. This should at least be a human proc.
//this is still in use please fix this mess
/mob/proc/get_equipped_items()
	var/list/items = new/list()

	if(hasvar(src,"back")) if(src:back) items += src:back
	if(hasvar(src,"belt")) if(src:belt) items += src:belt
	if(hasvar(src,"wear_ear")) if(src:wear_ear) items += src:wear_ear
	if(hasvar(src,"glasses")) if(src:glasses) items += src:glasses
	if(hasvar(src,"gloves")) if(src:gloves) items += src:gloves
	if(hasvar(src,"head")) if(src:head) items += src:head
	if(hasvar(src,"shoes")) if(src:shoes) items += src:shoes
	if(hasvar(src,"wear_id")) if(src:wear_id) items += src:wear_id
	if(hasvar(src,"wear_mask")) if(src:wear_mask) items += src:wear_mask
	if(hasvar(src,"wear_suit")) if(src:wear_suit) items += src:wear_suit
//	if(hasvar(src,"w_radio")) if(src:w_radio) items += src:w_radio  commenting this out since headsets go on your ears now PLEASE DON'T BE MAD KEELIN
	if(hasvar(src,"w_uniform")) if(src:w_uniform) items += src:w_uniform

	//if(hasvar(src,"l_hand")) if(src:l_hand) items += src:l_hand
	//if(hasvar(src,"r_hand")) if(src:r_hand) items += src:r_hand

	return items

/mob/living/proc/unequip_everything()
	var/list/items = list()
	items |= get_equipped_items(TRUE)
	for(var/I in items)
		dropItemToGround(I)
	drop_all_held_items()


/mob/living/carbon/proc/check_obscured_slots()
	var/list/obscured = list()
	var/hidden_slots = NONE

	for(var/obj/item/I in get_equipped_items())
		hidden_slots |= I.flags_inv_hide

	if(hidden_slots & HIDEMASK)
		obscured |= SLOT_WEAR_MASK
	if(hidden_slots & HIDEEYES)
		obscured |= SLOT_GLASSES
	if(hidden_slots & HIDEEARS)
		obscured |= SLOT_EARS
	if(hidden_slots & HIDEGLOVES)
		obscured |= SLOT_GLOVES
	if(hidden_slots & HIDEJUMPSUIT)
		obscured |= SLOT_WEAR_SUIT
	if(hidden_slots & HIDESHOES)
		obscured |= SLOT_SHOES
	if(hidden_slots & HIDESUITSTORAGE)
		obscured |= SLOT_S_STORE

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

// The mob is trying to place an item on someone
/mob/proc/stripPanelEquip(obj/item/I, mob/M)
	return

//returns the item in a given slot
/mob/proc/get_item_by_slot(slot_id)
	return

//placeholder until tg inventory system
/mob/proc/is_holding(obj/item/I)
	return ((I == l_hand) || (I == r_hand))
