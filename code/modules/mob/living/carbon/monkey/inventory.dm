

//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/monkey/equip_to_slot(obj/item/W as obj, slot)
	if(!slot) return
	if(!istype(W)) return

	if(W == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(W == l_hand)
		l_hand = null
		update_inv_l_hand()

	W.screen_loc = null

	W.loc = src
	switch(slot)
		if(WEAR_BACK)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		if(WEAR_FACE)
			wear_mask = W
			W.equipped(src, slot)
			update_inv_wear_mask()
		if(WEAR_HANDCUFFS)
			handcuffed = W
			handcuff_update()
		if(WEAR_LEGCUFFS)
			legcuffed = W
			W.equipped(src, slot)
			legcuff_update()
		if(WEAR_L_HAND)
			l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand()
		if(WEAR_R_HAND)
			r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand()
		if(WEAR_IN_BACK)
			W.forceMove(back)
		else
			usr << "\red You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it..."
			return

	W.layer = ABOVE_HUD_LAYER

	return 1




/mob/living/carbon/monkey/get_item_by_slot(slot_id)
	switch(slot_id)
		if(WEAR_BACK)
			return back
		if(WEAR_FACE)
			return wear_mask
		if(WEAR_L_HAND)
			return l_hand
		if(WEAR_R_HAND)
			return r_hand
		if(WEAR_HANDCUFFS)
			return handcuffed
		if(WEAR_LEGCUFFS)
			return legcuffed

