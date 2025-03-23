///async signal wrapper for do_quick_equip
/mob/living/carbon/human/proc/async_do_quick_equip(atom/source, datum/keybinding/human/quick_equip/equip_slot)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_quick_equip), initial(equip_slot.quick_equip_slot))
	return COMSIG_KB_ACTIVATED //The return value must be a flag compatible with the signals triggering this.

/// runs equip, quick_equip_used is the # in INVOKE_ASYNC
/mob/living/carbon/human/proc/do_quick_equip(quick_equip_slot = 0)
	if(incapacitated() || lying_angle)
		return

	var/slot_requested = client?.prefs?.quick_equip[quick_equip_slot] || VALID_EQUIP_SLOTS
	var/obj/item/I = get_active_held_item()
	if(!I) //draw item
		if(next_move > world.time)
			return

		if(slot_requested) //Equips from quick_equip 1-5
			if(draw_from_slot_if_possible(slot_requested))
				next_move = world.time + 1
				return

		var/list/slot_to_draw = client?.prefs?.slot_draw_order_pref || SLOT_DRAW_ORDER //Equips from draw order in prefs
		for(var/slot in slot_to_draw)
			if(draw_from_slot_if_possible(slot))
				next_move = world.time + 1
				return

	else //store item
		if(I.last_equipped_slot)
			if(equip_to_slot_if_possible(I, I.last_equipped_slot, FALSE, FALSE, FALSE))
				return
		if(s_active?.on_attackby(s_active, I, src)) //stored in currently open storage
			return TRUE
		if(slot_requested)
			if(equip_to_slot_if_possible(I, slot_requested, FALSE, FALSE, FALSE))
				return
		if(!equip_to_appropriate_slot(I, FALSE))
			return
		if(hand)
			update_inv_l_hand(FALSE)
		else
			update_inv_r_hand(FALSE)


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slot, ignore_delay = TRUE, warning = FALSE))
			return slot
	if (del_on_fail)
		qdel(W)
	return null


/mob/living/carbon/human/proc/has_limb(org_name)
	for(var/X in limbs)
		var/datum/limb/E = X
		if(E.body_part == org_name)
			return !(E.limb_status & LIMB_DESTROYED)

/mob/living/carbon/human/proc/has_limb_for_slot(slot)
	switch(slot)
		if(SLOT_BACK)
			return has_limb(CHEST)
		if(SLOT_WEAR_MASK)
			return has_limb(HEAD)
		if(SLOT_HANDCUFFED)
			return has_limb(HAND_LEFT) && has_limb(HAND_RIGHT)
		if(SLOT_L_HAND)
			return has_limb(HAND_LEFT)
		if(SLOT_R_HAND)
			return has_limb(HAND_RIGHT)
		if(SLOT_BELT)
			return has_limb(CHEST)
		if(SLOT_WEAR_ID)
			return TRUE
		if(SLOT_EARS)
			return has_limb(HEAD)
		if(SLOT_GLASSES)
			return has_limb(HEAD)
		if(SLOT_GLOVES)
			return has_limb(HAND_LEFT) && has_limb(HAND_RIGHT)
		if(SLOT_HEAD)
			return has_limb(HEAD)
		if(SLOT_SHOES)
			return has_limb(FOOT_RIGHT) && has_limb(FOOT_LEFT)
		if(SLOT_WEAR_SUIT)
			return has_limb(CHEST)
		if(SLOT_W_UNIFORM)
			return has_limb(CHEST)
		if(SLOT_L_STORE)
			return has_limb(CHEST)
		if(SLOT_R_STORE)
			return has_limb(CHEST)
		if(SLOT_S_STORE)
			return has_limb(CHEST)
		if(SLOT_ACCESSORY)
			return has_limb(CHEST)
		if(SLOT_IN_BOOT)
			return has_limb(FOOT_RIGHT) && has_limb(FOOT_LEFT)
		if(SLOT_IN_BACKPACK)
			return has_limb(CHEST)
		if(SLOT_IN_SUIT)
			return has_limb(CHEST)
		if(SLOT_IN_BELT)
			return has_limb(CHEST)
		if(SLOT_IN_HEAD)
			return has_limb(HEAD)
		if(SLOT_IN_ACCESSORY)
			return has_limb(CHEST)
		if(SLOT_IN_HOLSTER)
			return has_limb(CHEST)
		if(SLOT_IN_S_HOLSTER)
			return has_limb(CHEST)
		if(SLOT_IN_B_HOLSTER)
			return has_limb(CHEST)
		if(SLOT_IN_STORAGE)
			return TRUE
		if(SLOT_IN_L_POUCH)
			return has_limb(CHEST)
		if(SLOT_IN_R_POUCH)
			return has_limb(CHEST)

/mob/living/carbon/human/put_in_l_hand(obj/item/W)
	var/datum/limb/O = get_limb("l_hand")
	if(!O?.is_usable())
		return FALSE
	. = ..()

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	var/datum/limb/O = get_limb("r_hand")
	if(!O?.is_usable())
		return FALSE
	. = ..()

/mob/living/carbon/human/doUnEquip(obj/item/I)
	. = ..()
	switch(.)
		if(ITEM_UNEQUIP_DROPPED)
			return
		if(ITEM_UNEQUIP_UNEQUIPPED)
			return
	if(I == wear_suit)
		wear_suit = null
		if(s_store)
			dropItemToGround(s_store)
		I.unequipped(src, SLOT_WEAR_SUIT)
		if(I.inv_hide_flags & HIDESHOES)
			update_inv_shoes()
		if(I.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
			update_hair()
		if(I.inv_hide_flags & HIDEJUMPSUIT)
			update_inv_w_uniform()
		update_inv_wear_suit()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == w_uniform)
		if(r_store)
			dropItemToGround(r_store)
		if(l_store)
			dropItemToGround(l_store)
		if(belt)
			dropItemToGround(belt)
		if(wear_suit && istype(wear_suit, /obj/item/clothing/suit))
			dropItemToGround(wear_suit)
		w_uniform = null
		I.unequipped(src, SLOT_W_UNIFORM)
		update_suit_sensors()
		update_inv_w_uniform()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == head)
		var/updatename = 0
		if(head.inv_hide_flags & HIDEFACE)
			updatename = 1
		head = null
		I.unequipped(src, SLOT_HEAD)
		if(updatename)
			name = get_visible_name()
		if(I.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR|HIDE_EXCESS_HAIR))
			update_hair()	//rebuild hair
		if(I.inv_hide_flags & HIDEEARS)
			update_inv_ears()
		if(I.inv_hide_flags & HIDEMASK)
			update_inv_wear_mask()
		if(I.inv_hide_flags & HIDEEYES)
			update_inv_glasses()
		update_inv_head()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == gloves)
		gloves = null
		I.unequipped(src, SLOT_GLOVES)
		update_inv_gloves()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == glasses)
		glasses = null
		I.unequipped(src, SLOT_GLASSES)
		var/obj/item/clothing/glasses/G = I
		if(G.vision_flags || G.invis_override || G.invis_view || !isnull(G.lighting_cutoff))
			update_sight()
		if(!QDELETED(src))
			update_inv_glasses()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == wear_ear)
		wear_ear = null
		I.unequipped(src, SLOT_EARS)
		update_inv_ears()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == shoes)
		shoes = null
		I.unequipped(src, SLOT_SHOES)
		update_inv_shoes()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == belt)
		belt = null
		I.unequipped(src, SLOT_BELT)
		update_inv_belt()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == wear_id)
		wear_id = null
		I.unequipped(src, SLOT_WEAR_ID)
		update_inv_wear_id()
		name = get_visible_name()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == r_store)
		r_store = null
		I.unequipped(src, SLOT_R_STORE)
		update_inv_pockets()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == l_store)
		l_store = null
		I.unequipped(src, SLOT_L_STORE)
		update_inv_pockets()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == s_store)
		s_store = null
		I.unequipped(src, SLOT_S_STORE)
		update_inv_s_store()
		. = ITEM_UNEQUIP_UNEQUIPPED


/mob/living/carbon/human/wear_mask_update(obj/item/I, equipping)
	name = get_visible_name() // doing this without a check, still cheaper than doing it every Life() tick -spookydonut
	if(I.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
		update_hair()	//rebuild hair
	if(I.inv_hide_flags & HIDEEARS)
		update_inv_ears()
	if(I.inv_hide_flags & HIDEEYES)
		update_inv_glasses()
	return ..()


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/item_to_equip, slot, bitslot = FALSE)
	. = ..()
	if(bitslot)
		var/oldslot = slot
		slot = slotbit2slotdefine(oldslot)
	if(!has_limb_for_slot(slot))
		return

	var/obj/item/selected_slot //the item in the specific slot we're trying to insert into, if applicable

	switch(slot)
		if(SLOT_BACK)
			back = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_back()
		if(SLOT_WEAR_MASK)
			wear_mask = item_to_equip
			item_to_equip.equipped(src, slot)
			wear_mask_update(item_to_equip, TRUE)
		if(SLOT_HANDCUFFED)
			update_handcuffed(item_to_equip)
		if(SLOT_L_HAND)
			l_hand = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_l_hand()
		if(SLOT_R_HAND)
			r_hand = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_r_hand()
		if(SLOT_BELT)
			belt = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_belt()
		if(SLOT_WEAR_ID)
			wear_id = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_wear_id()
			name = get_visible_name()
		if(SLOT_EARS)
			wear_ear = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_ears()
		if(SLOT_GLASSES)
			glasses = item_to_equip
			item_to_equip.equipped(src, slot)
			var/obj/item/clothing/glasses/G = item_to_equip
			if(G.vision_flags || G.invis_override || G.invis_view || !isnull(G.lighting_cutoff))
				update_sight()
			update_inv_glasses()
		if(SLOT_GLOVES)
			gloves = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_gloves()
		if(SLOT_HEAD)
			head = item_to_equip
			if(head.inv_hide_flags & HIDEFACE)
				name = get_visible_name()
			if(head.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR|HIDE_EXCESS_HAIR))
				update_hair()	//rebuild hair
			if(head.inv_hide_flags & HIDEEARS)
				update_inv_ears()
			if(head.inv_hide_flags & HIDEMASK)
				update_inv_wear_mask()
			if(head.inv_hide_flags & HIDEEYES)
				update_inv_glasses()
			item_to_equip.equipped(src, slot)
			update_inv_head()
		if(SLOT_SHOES)
			shoes = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_shoes()
		if(SLOT_WEAR_SUIT)
			wear_suit = item_to_equip
			if(wear_suit.inv_hide_flags & HIDESHOES)
				update_inv_shoes()
			if(wear_suit.inv_hide_flags & HIDEJUMPSUIT)
				update_inv_w_uniform()
			if( wear_suit.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
				update_hair()
			item_to_equip.equipped(src, slot)
			update_inv_wear_suit()
		if(SLOT_W_UNIFORM)
			w_uniform = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_w_uniform()
		if(SLOT_L_STORE)
			l_store = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_pockets()
		if(SLOT_R_STORE)
			r_store = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_pockets()
		if(SLOT_S_STORE)
			s_store = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_s_store()
		if(SLOT_IN_BOOT)
			selected_slot = shoes
		if(SLOT_IN_BACKPACK)
			selected_slot = back
		if(SLOT_IN_SUIT)
			selected_slot = wear_suit
		if(SLOT_IN_BELT)
			selected_slot = belt
		if(SLOT_IN_HEAD)
			selected_slot = head
		if(SLOT_IN_HOLSTER)
			selected_slot = belt
		if(SLOT_IN_B_HOLSTER)
			selected_slot = back
		if(SLOT_IN_S_HOLSTER)
			selected_slot = s_store
		if(SLOT_IN_STORAGE)
			selected_slot = s_active
		if(SLOT_IN_L_POUCH)
			selected_slot = l_store
		if(SLOT_IN_R_POUCH)
			selected_slot = r_store
		if(SLOT_IN_ACCESSORY)
			selected_slot = w_uniform
		else
			CRASH("[src] tried to equip [item_to_equip] to [slot] in equip_to_slot().")

	if(!selected_slot)
		return FALSE

	var/datum/storage/selected_storage
	if(isdatumstorage(selected_slot))
		selected_storage = selected_slot
	else if(selected_slot.storage_datum)
		selected_storage = selected_slot.storage_datum
	else if(isclothing(selected_slot))
		var/obj/item/clothing/selected_clothing = selected_slot
		for(var/key AS in selected_clothing.attachments_by_slot)
			var/atom/attachment = selected_clothing.attachments_by_slot[key]
			if(!attachment?.storage_datum)
				continue
			selected_storage = attachment.storage_datum
			break

	if(!selected_storage)
		return FALSE

	return selected_storage.handle_item_insertion(item_to_equip, FALSE, src)

/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_BACK)
			return back
		if(SLOT_WEAR_MASK)
			return wear_mask
		if(SLOT_BELT)
			return belt
		if(SLOT_WEAR_ID)
			return wear_id
		if(SLOT_EARS)
			return wear_ear
		if(SLOT_GLASSES)
			return glasses
		if(SLOT_GLOVES)
			return gloves
		if(SLOT_L_HAND)
			return l_hand
		if(SLOT_R_HAND)
			return r_hand
		if(SLOT_HEAD)
			return head
		if(SLOT_SHOES)
			return shoes
		if(SLOT_WEAR_SUIT)
			return wear_suit
		if(SLOT_W_UNIFORM)
			return w_uniform
		if(SLOT_L_STORE)
			return l_store
		if(SLOT_R_STORE)
			return r_store
		if(SLOT_S_STORE)
			return s_store
		if(SLOT_HANDCUFFED)
			return handcuffed
		if(SLOT_IN_BOOT)
			return shoes
		if(SLOT_IN_B_HOLSTER)
			return back
		if(SLOT_IN_BELT)
			return belt
		if(SLOT_IN_HOLSTER)
			return belt
		if(SLOT_IN_STORAGE)
			return wear_suit
		if(SLOT_IN_S_HOLSTER)
			return s_store
		if(SLOT_IN_ACCESSORY)
			return w_uniform
		if(SLOT_IN_L_POUCH)
			return l_store
		if(SLOT_IN_R_POUCH)
			return r_store
		if(SLOT_IN_HEAD)
			return head

/mob/living/carbon/human/get_item_by_slot_bit(slot_bit)
	switch(slot_bit)
		if(ITEM_SLOT_OCLOTHING)
			return wear_suit
		if(ITEM_SLOT_ICLOTHING)
			return w_uniform
		if(ITEM_SLOT_GLOVES)
			return gloves
		if(ITEM_SLOT_EYES)
			return glasses
		if(ITEM_SLOT_EARS)
			return wear_ear
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_FEET)
			return shoes
		if(ITEM_SLOT_ID)
			return wear_id
		if(ITEM_SLOT_BELT)
			return belt
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_R_POCKET)
			return r_store
		if(ITEM_SLOT_L_POCKET)
			return l_store
		if(ITEM_SLOT_SUITSTORE)
			return s_store
		if(ITEM_SLOT_HANDCUFF)
			return handcuffed
		if(ITEM_SLOT_L_HAND)
			return l_hand
		if(ITEM_SLOT_R_HAND)
			return r_hand

/mob/living/carbon/human/get_equipped_slot(obj/equipped_item)
	if(..())
		return

	if(equipped_item == wear_suit)
		. = SLOT_WEAR_SUIT
	else if(equipped_item == w_uniform)
		. = SLOT_W_UNIFORM
	else if(equipped_item == shoes)
		. = SLOT_SHOES
	else if(equipped_item == belt)
		. = SLOT_BELT
	else if(equipped_item == gloves)
		. = SLOT_GLOVES
	else if(equipped_item == glasses)
		. = SLOT_GLASSES
	else if(equipped_item == head)
		. = SLOT_HEAD
	else if(equipped_item == wear_ear)
		. = SLOT_EARS
	else if(equipped_item == wear_id)
		. = SLOT_WEAR_ID
	else if(equipped_item == r_store)
		. = SLOT_R_STORE
	else if(equipped_item == l_store)
		. = SLOT_L_STORE
	else if(equipped_item == s_store)
		. = SLOT_S_STORE

/mob/living/carbon/human/stripPanelUnequip(obj/item/I, mob/M, slot_to_process)
	if(!I.canStrip(M))
		return
	log_combat(src, M, "attempted to remove [key_name(I)] ([slot_to_process])")

	M.visible_message(span_danger("[src] tries to remove [M]'s [I.name]."), \
					span_userdanger("[src] tries to remove [M]'s [I.name]."), null, 5)
	if(do_after(src, I.getstripdelay(), NONE, M, BUSY_ICON_HOSTILE))
		if(Adjacent(M) && I && I == M.get_item_by_slot(slot_to_process))
			M.dropItemToGround(I)
			log_combat(src, M, "removed [key_name(I)] ([slot_to_process])")
			if(isidcard(I))
				message_admins("[ADMIN_TPMONTY(src)] took the [I] of [ADMIN_TPMONTY(M)].")


/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return FALSE
	if(!O)
		return FALSE

	return O.equip(src, visualsOnly)


/mob/living/carbon/human/proc/delete_equipment(save_id = FALSE)
	for(var/i in contents)
		if(save_id && istype(i, /obj/item/card/id))
			continue
		qdel(i)
/**
 * Return [TRUE]|[FALSE] if item_searched is equipped or in the hands of the human
 * item_searched the item you want to check
 */
/mob/living/carbon/human/proc/is_item_in_slots(item_searched)
	for (var/slot in SLOT_ALL)
		if (get_item_by_slot(slot) == item_searched)
			return TRUE
	return FALSE

/**
 * Return the first item found in SLOT_ALL of the type searched
 * type searched the type you are looking for
 */
/mob/living/carbon/human/proc/get_type_in_slots(type_searched)
	for (var/slot in SLOT_ALL)
		if (istype(get_item_by_slot(slot),type_searched))
			return get_item_by_slot(slot)


/**
 * Return [TRUE]|[FALSE] if item_searched is in the hands of the human
 * item_searched the item you want to check
 */
/mob/living/carbon/human/proc/is_item_in_hands(obj/item/item_searched)
	if (get_item_by_slot(SLOT_R_HAND) == item_searched)
		return TRUE
	if (get_item_by_slot(SLOT_L_HAND) == item_searched)
		return TRUE
	return FALSE
