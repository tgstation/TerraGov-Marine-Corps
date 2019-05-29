//These procs handle putting s tuff in your hand. It's probably best to use these rather than setting l_hand = ...etc
//as they handle all relevant stuff like adding it to the player's screen and updating their overlays.

//Returns the thing in our active hand
/mob/proc/get_active_held_item()
	if(hand)
		return l_hand
	return r_hand

//Returns the thing in our inactive hand
/mob/proc/get_inactive_held_item()
	if(hand)
		return r_hand
	return l_hand

//Puts the item into your l_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_l_hand(obj/item/W)
	if(lying)
		return FALSE
	if(!istype(W))
		return FALSE
	if(!l_hand)
		W.forceMove(src)
		l_hand = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.equipped(src,SLOT_L_HAND)
		update_inv_l_hand()
		return TRUE
	return FALSE

//Puts the item into your r_hand if possible and calls all necessary triggers/updates. returns 1 on success.
/mob/proc/put_in_r_hand(obj/item/W)
	if(lying)
		return FALSE
	if(!istype(W))
		return FALSE
	if(!r_hand)
		W.forceMove(src)
		r_hand = W
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		W.equipped(src,SLOT_R_HAND)
		update_inv_r_hand()
		return TRUE
	return FALSE

//Puts the item into our active hand if possible. returns 1 on success.
/mob/proc/put_in_active_hand(obj/item/W)
	if(hand)
		return put_in_l_hand(W)
	return put_in_r_hand(W)

//Puts the item into our inactive hand if possible. returns 1 on success.
/mob/proc/put_in_inactive_hand(obj/item/W)
	if(hand)
		return put_in_r_hand(W)
	return put_in_l_hand(W)

//Puts the item our active hand if possible. Failing that it tries our inactive hand. Returns 1 on success.
//If both fail it drops it on the floor and returns 0.
//This is probably the main one you need to know :)
/mob/proc/put_in_hands(obj/item/W)
	if(!W)
		return FALSE
	if(put_in_active_hand(W))
		return TRUE
	if(put_in_inactive_hand(W))
		return TRUE
	else
		W.forceMove(get_turf(src))
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)
		W.dropped(src)
		return FALSE


/mob/proc/drop_item_v()		//this is dumb.
	if(stat == CONSCIOUS && isturf(loc))
		return drop_held_item()
	return FALSE


//Drops the item in our left hand
/mob/proc/drop_l_hand()
	if(l_hand)
		return dropItemToGround(l_hand)
	return FALSE

//Drops the item in our right hand
/mob/proc/drop_r_hand()
	if(r_hand)
		return dropItemToGround(r_hand)
	return FALSE

//Drops the item in our active hand.
/mob/proc/drop_held_item()
	if(hand)
		return drop_l_hand()
	return drop_r_hand()

//Drops the items in our hands.
/mob/proc/drop_all_held_items()
	drop_r_hand()
	drop_l_hand()

//drop the inventory item on a specific location
/mob/proc/transferItemToLoc(obj/item/I, atom/newloc, nomoveupdate, force)
	return doUnEquip(I, newloc, nomoveupdate, force)

//drop the inventory item on the ground
/mob/proc/dropItemToGround(obj/item/I, nomoveupdate, force)
	return doUnEquip(I, loc, nomoveupdate, force)

//Never use this proc directly. nomoveupdate is used when we don't want the item to react to
// its new loc (e.g.triggering mousetraps)
/mob/proc/doUnEquip(obj/item/I, atom/newloc, nomoveupdate, force)

	if(!I)
		return TRUE

	if((I.flags_item & NODROP) && !force)
		return FALSE //doUnEquip() only fails if item has NODROP

	if (I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if (I == l_hand)
		l_hand = null
		update_inv_l_hand()

	if (client)
		client.screen -= I
	I.layer = initial(I.layer)
	I.plane = initial(I.plane)
	if(newloc)
		if(!nomoveupdate)
			I.forceMove(newloc)
		else
			I.loc = newloc
	I.dropped(src)

	return TRUE

//Remove an item on a mob's inventory.  It does not change the item's loc, just unequips it from the mob.
//Used just before you want to delete the item, or moving it afterwards.
/mob/proc/temporarilyRemoveItemFromInventory(obj/item/I, force)
	return doUnEquip(I, null, force)


//Outdated but still in use apparently. This should at least be a human proc.
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
	if (hand)
		return l_hand
	else
		return r_hand
	return

/mob/living/carbon/human/proc/equip_if_possible(obj/item/W, slot, del_on_fail = 1) // since byond doesn't seem to have pointers, this seems like the best way to do this :/
	//warning: icky code
	var/equipped = 0
	switch(slot)
		if(SLOT_BACK)
			if(!src.back)
				src.back = W
				equipped = 1
		if(SLOT_WEAR_MASK)
			if(!src.wear_mask)
				src.wear_mask = W
				equipped = 1
		if(SLOT_HANDCUFFED)
			if(!src.handcuffed)
				src.handcuffed = W
				equipped = 1
		if(SLOT_L_HAND)
			if(!src.l_hand)
				src.l_hand = W
				equipped = 1
		if(SLOT_R_HAND)
			if(!src.r_hand)
				src.r_hand = W
				equipped = 1
		if(SLOT_BELT)
			if(!src.belt && src.w_uniform)
				src.belt = W
				equipped = 1
		if(SLOT_WEAR_ID)
			if(!src.wear_id /* && src.w_uniform */)
				src.wear_id = W
				equipped = 1
		if(SLOT_EARS)
			if(!wear_ear)
				wear_ear = W
				equipped = 1
		if(SLOT_GLASSES)
			if(!src.glasses)
				src.glasses = W
				equipped = 1
		if(SLOT_GLOVES)
			if(!src.gloves)
				src.gloves = W
				equipped = 1
		if(SLOT_HEAD)
			if(!src.head)
				src.head = W
				equipped = 1
		if(SLOT_SHOES)
			if(!src.shoes)
				src.shoes = W
				equipped = 1
		if(SLOT_WEAR_SUIT)
			if(!src.wear_suit)
				src.wear_suit = W
				equipped = 1
		if(SLOT_W_UNIFORM)
			if(!src.w_uniform)
				src.w_uniform = W
				equipped = 1
		if(SLOT_L_STORE)
			if(!src.l_store && src.w_uniform)
				src.l_store = W
				equipped = 1
		if(SLOT_R_STORE)
			if(!src.r_store && src.w_uniform)
				src.r_store = W
				equipped = 1
		if(SLOT_S_STORE)
			if(!src.s_store && src.wear_suit)
				src.s_store = W
				equipped = 1
		if(SLOT_IN_BACKPACK)
			if (src.back && istype(src.back, /obj/item/storage/backpack))
				var/obj/item/storage/backpack/B = src.back
				if(B.contents.len < B.storage_slots && W.w_class <= B.max_w_class)
					W.loc = B
					equipped = 1

	if(equipped)
		W.layer = ABOVE_HUD_LAYER
		W.plane = ABOVE_HUD_PLANE
		if(src.back && W.loc != src.back)
			W.loc = src
	else
		if (del_on_fail)
			qdel(W)
	return equipped





// The mob is trying to strip an item from someone
/mob/proc/stripPanelUnequip(obj/item/I, mob/M)
	return

// The mob is trying to place an item on someone
/mob/proc/stripPanelEquip(obj/item/I, mob/M)
	return

//returns the item in a given slot
/mob/proc/get_item_by_slot(slot_id)
	return
