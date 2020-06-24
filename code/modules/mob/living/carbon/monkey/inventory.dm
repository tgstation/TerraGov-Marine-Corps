

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/W as obj, slot)
	if(!slot) return
	if(!istype(W)) return

	if(W == r_hand)
		r_hand = null
		W.unequipped(src, SLOT_R_HAND)
		update_inv_r_hand()
	else if(W == l_hand)
		l_hand = null
		W.unequipped(src, SLOT_L_HAND)
		update_inv_l_hand()

	W.screen_loc = null

	W.loc = src
	switch(slot)
		if(SLOT_BACK)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		if(SLOT_WEAR_MASK)
			wear_mask = W
			W.equipped(src, slot)
			wear_mask_update(W, TRUE)
		if(SLOT_HANDCUFFED)
			update_handcuffed(W)
		if(SLOT_L_HAND)
			l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand()
		if(SLOT_R_HAND)
			r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand()
		if(SLOT_IN_BACKPACK)
			W.forceMove(back)
		else
			to_chat(usr, "<span class='warning'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return

	W.layer = ABOVE_HUD_LAYER
	W.plane = ABOVE_HUD_PLANE

	return 1




/mob/living/carbon/monkey/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_BACK)
			return back
		if(SLOT_WEAR_MASK)
			return wear_mask
		if(SLOT_L_HAND)
			return l_hand
		if(SLOT_R_HAND)
			return r_hand
		if(SLOT_HANDCUFFED)
			return handcuffed

