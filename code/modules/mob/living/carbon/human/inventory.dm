///async signal wrapper for do_quick_equip
/mob/living/carbon/human/proc/async_do_quick_equip(atom/source, datum/keybinding/human/quick_equip/equip_slot)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_quick_equip), initial(equip_slot.quick_equip_slot))
	return COMSIG_KB_ACTIVATED //The return value must be a flag compatible with the signals triggering this.

/// runs equip, quick_equip_used is the # in INVOKE_ASYNC
/mob/living/carbon/human/proc/do_quick_equip(quick_equip_slot = NONE)
	if(incapacitated() || lying_angle)
		return

	var/slot_requested = client?.prefs?.quick_equip[quick_equip_slot] || VALID_EQUIP_SLOTS[quick_equip_slot]
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
		return

	if(s_active?.on_attackby(s_active, I, src)) //stored in currently open storage
		return TRUE
	if(equip_to_appropriate_slot(I, FALSE, FALSE)) //we try to put it in an appropriate slot first
		return
	if(slot_requested)
		if(equip_to_slot_if_possible(I, slot_requested, FALSE, FALSE, FALSE)) // then we try to put it in the requested slot
			return
	if(equip_to_appropriate_slot(I, FALSE, TRUE)) // then we just go through draw_order storage
		return
	if(hand)
		update_inv_l_hand()
	else
		update_inv_r_hand()


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(W, slot, ignore_delay = TRUE, warning = FALSE))
			return slot
	if(del_on_fail)
		qdel(W)
	return null


/mob/living/carbon/human/proc/has_limb(org_name)
	for(var/X in limbs)
		var/datum/limb/E = X
		if(E.body_part == org_name)
			return !(E.limb_status & LIMB_DESTROYED)

/// Does src have the appropriate limbs to equip to the provided slot?
/mob/living/carbon/human/proc/has_limb_for_slot(slot)
	switch(slot)
		if(ITEM_SLOT_BACK)
			return has_limb(CHEST)
		if(ITEM_SLOT_MASK)
			return has_limb(HEAD)
		if(ITEM_SLOT_HANDCUFF)
			return has_limb(HAND_LEFT) && has_limb(HAND_RIGHT)
		if(ITEM_SLOT_L_HAND)
			return has_limb(HAND_LEFT)
		if(ITEM_SLOT_R_HAND)
			return has_limb(HAND_RIGHT)
		if(ITEM_SLOT_BELT)
			return has_limb(CHEST)
		if(ITEM_SLOT_ID)
			return TRUE
		if(ITEM_SLOT_EARS)
			return has_limb(HEAD)
		if(ITEM_SLOT_EYES)
			return has_limb(HEAD)
		if(ITEM_SLOT_GLOVES)
			return has_limb(HAND_LEFT) && has_limb(HAND_RIGHT)
		if(ITEM_SLOT_HEAD)
			return has_limb(HEAD)
		if(ITEM_SLOT_FEET)
			return has_limb(FOOT_RIGHT) && has_limb(FOOT_LEFT)
		if(ITEM_SLOT_OCLOTHING)
			return has_limb(CHEST)
		if(ITEM_SLOT_ICLOTHING)
			return has_limb(CHEST)
		if(ITEM_SLOT_L_POCKET)
			return has_limb(CHEST)
		if(ITEM_SLOT_R_POCKET)
			return has_limb(CHEST)
		if(ITEM_SLOT_SUITSTORE)
			return has_limb(CHEST)

/mob/living/carbon/human/put_in_l_hand(obj/item/W)
	var/datum/limb/O = get_limb(BODY_ZONE_PRECISE_L_HAND)
	if(!O?.is_usable())
		return FALSE
	. = ..()

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	var/datum/limb/O = get_limb(BODY_ZONE_PRECISE_R_HAND)
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
		I.unequipped(src, ITEM_SLOT_OCLOTHING)
		if(I.inv_hide_flags & HIDESHOES)
			update_inv_shoes()
		if(I.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
			update_hair()
		if(I.inv_hide_flags & HIDEJUMPSUIT)
			update_inv_w_uniform()
		update_inv_wear_suit()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == w_uniform)
		if(r_pocket)
			dropItemToGround(r_pocket)
		if(l_pocket)
			dropItemToGround(l_pocket)
		if(belt)
			dropItemToGround(belt)
		if(wear_suit && istype(wear_suit, /obj/item/clothing/suit))
			dropItemToGround(wear_suit)
		w_uniform = null
		I.unequipped(src, ITEM_SLOT_ICLOTHING)
		update_suit_sensors()
		update_inv_w_uniform()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == head)
		var/updatename = 0
		if(head.inv_hide_flags & HIDEFACE)
			updatename = 1
		head = null
		I.unequipped(src, ITEM_SLOT_HEAD)
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
		I.unequipped(src, ITEM_SLOT_GLOVES)
		update_inv_gloves()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == glasses)
		glasses = null
		I.unequipped(src, ITEM_SLOT_EYES)
		var/obj/item/clothing/glasses/G = I
		if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
			update_sight()
		if(!QDELETED(src))
			update_inv_glasses()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == wear_ear)
		wear_ear = null
		I.unequipped(src, ITEM_SLOT_EARS)
		update_inv_ears()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == shoes)
		shoes = null
		I.unequipped(src, ITEM_SLOT_FEET)
		update_inv_shoes()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == belt)
		belt = null
		I.unequipped(src, ITEM_SLOT_BELT)
		update_inv_belt()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == wear_id)
		wear_id = null
		I.unequipped(src, ITEM_SLOT_ID)
		update_inv_wear_id()
		name = get_visible_name()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == r_pocket)
		r_pocket = null
		I.unequipped(src, ITEM_SLOT_R_POCKET)
		update_inv_pockets()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == l_pocket)
		l_pocket = null
		I.unequipped(src, ITEM_SLOT_L_POCKET)
		update_inv_pockets()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == s_store)
		s_store = null
		I.unequipped(src, ITEM_SLOT_SUITSTORE)
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
/mob/living/carbon/human/equip_to_slot(obj/item/item_to_equip, slot, into_storage)
	. = ..()
	if(bitslot)
		var/oldslot = slot
		slot = slotbit2slotdefine(oldslot)
	if(!has_limb_for_slot(slot))
		return

	if(into_storage)
		var/obj/item/selected_storage_target
		switch(slot)
			if(ITEM_SLOT_BACK)
				selected_storage_target = back
			if(ITEM_SLOT_SUITSTORE)
				selected_storage_target = s_store
			if(ITEM_SLOT_BELT)
				selected_storage_target = belt
			if(ITEM_SLOT_ACTIVE_STORAGE)
				selected_storage_target = s_active
			if(ITEM_SLOT_L_POCKET)
				selected_storage_target = l_pocket
			if(ITEM_SLOT_R_POCKET)
				selected_storage_target = r_pocket
			if(ITEM_SLOT_ICLOTHING)
				if(isclothing(w_uniform))
					for(var/key AS in w_uniform.attachments_by_slot)
						var/atom/attachment = w_uniform.attachments_by_slot[key]
						if(!attachment?.storage_datum)
							continue
						selected_storage_target = attachment
						break
			if(ITEM_SLOT_OCLOTHING)
				if(isclothing(wear_suit))
					for(var/key AS in wear_suit.attachments_by_slot)
						var/atom/attachment = wear_suit.attachments_by_slot[key]
						if(!attachment?.storage_datum)
							continue
						selected_storage_target = attachment
						break
			if(ITEM_SLOT_HEAD)
				if(isclothing(head))
					for(var/key AS in head.attachments_by_slot)
						var/atom/attachment = head.attachments_by_slot[key]
						if(!attachment?.storage_datum)
							continue
						selected_storage_target = attachment
						break
			if(ITEM_SLOT_FEET)
				if(isclothing(shoes))
					for(var/key AS in shoes.attachments_by_slot)
						var/atom/attachment = shoes.attachments_by_slot[key]
						if(!attachment?.storage_datum)
							continue
						selected_storage_target = attachment
						break

		var/datum/storage/selected_storage = selected_storage_target.storage_datum
		if(!isdatumstorage(selected_storage)) //probably means can_equip failed its job
			to_chat(src, span_warning("Equipping to slot failed, yell at coders."))
			CRASH("Failed to get a valid storage datum from slot [slot] while equipping into container in equip_to_slot!")
		return selected_storage.handle_item_insertion(item_to_equip, FALSE, src)

	switch(slot)
		if(ITEM_SLOT_BACK)
			back = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_back()
		if(ITEM_SLOT_MASK)
			wear_mask = item_to_equip
			item_to_equip.equipped(src, slot)
			wear_mask_update(item_to_equip, TRUE)
		if(ITEM_SLOT_HANDCUFF)
			update_handcuffed(item_to_equip)
		if(ITEM_SLOT_L_HAND)
			l_hand = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_l_hand()
		if(ITEM_SLOT_R_HAND)
			r_hand = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_r_hand()
		if(ITEM_SLOT_BELT)
			belt = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_belt()
		if(ITEM_SLOT_ID)
			wear_id = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_wear_id()
			name = get_visible_name()
		if(ITEM_SLOT_EARS)
			wear_ear = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_ears()
		if(ITEM_SLOT_EYES)
			glasses = item_to_equip
			item_to_equip.equipped(src, slot)
			var/obj/item/clothing/glasses/G = item_to_equip
			if(G.vision_flags || G.darkness_view || G.invis_override || G.invis_view || !isnull(G.lighting_alpha))
				update_sight()
			update_inv_glasses()
		if(ITEM_SLOT_GLOVES)
			gloves = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_gloves()
		if(ITEM_SLOT_HEAD)
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
		if(ITEM_SLOT_FEET)
			shoes = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_shoes()
		if(ITEM_SLOT_OCLOTHING)
			wear_suit = item_to_equip
			if(wear_suit.inv_hide_flags & HIDESHOES)
				update_inv_shoes()
			if(wear_suit.inv_hide_flags & HIDEJUMPSUIT)
				update_inv_w_uniform()
			if(wear_suit.inv_hide_flags & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
				update_hair()
			item_to_equip.equipped(src, slot)
			update_inv_wear_suit()
		if(ITEM_SLOT_ICLOTHING)
			w_uniform = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_w_uniform()
		if(ITEM_SLOT_L_POCKET)
			l_pocket = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_pockets()
		if(ITEM_SLOT_R_POCKET)
			r_pocket = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_pockets()
		if(ITEM_SLOT_SUITSTORE)
			s_store = item_to_equip
			item_to_equip.equipped(src, slot)
			update_inv_s_store()

/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
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
			return r_pocket
		if(ITEM_SLOT_L_POCKET)
			return l_pocket
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
		. = ITEM_SLOT_OCLOTHING
	else if(equipped_item == w_uniform)
		. = ITEM_SLOT_ICLOTHING
	else if(equipped_item == shoes)
		. = ITEM_SLOT_FEET
	else if(equipped_item == belt)
		. = ITEM_SLOT_BELT
	else if(equipped_item == gloves)
		. = ITEM_SLOT_GLOVES
	else if(equipped_item == glasses)
		. = ITEM_SLOT_EYES
	else if(equipped_item == head)
		. = ITEM_SLOT_HEAD
	else if(equipped_item == wear_ear)
		. = ITEM_SLOT_EARS
	else if(equipped_item == wear_id)
		. = ITEM_SLOT_ID
	else if(equipped_item == r_pocket)
		. = ITEM_SLOT_R_POCKET
	else if(equipped_item == l_pocket)
		. = ITEM_SLOT_L_POCKET
	else if(equipped_item == s_store)
		. = ITEM_SLOT_SUITSTORE

/mob/living/carbon/human/stripPanelUnequip(obj/item/I, mob/M, slot_to_process) //todo deal with this
	if(!I.canStrip(M))
		return
	log_combat(src, M, "attempted to remove [key_name(I)] ([slot_to_process])")

	M.visible_message(span_danger("[src] tries to remove [M]'s [I.name]."), \
					span_userdanger("[src] tries to remove [M]'s [I.name]."), null, 5)
	if(do_after(src, HUMAN_STRIP_DELAY, NONE, M, BUSY_ICON_HOSTILE))
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
	for(var/slot in SLOT_ALL)
		if(get_item_by_slot(slot) == item_searched)
			return TRUE
	return FALSE

/**
 * Return the first item found in SLOT_ALL of the type searched
 * type searched the type you are looking for
 */
/mob/living/carbon/human/proc/get_type_in_slots(type_searched)
	for(var/slot in SLOT_ALL)
		if(istype(get_item_by_slot(slot),type_searched))
			return get_item_by_slot(slot)


/**
 * Return [TRUE]|[FALSE] if item_searched is in the hands of the human
 * item_searched the item you want to check
 */
/mob/living/carbon/human/proc/is_item_in_hands(obj/item/item_searched)
	if(get_item_by_slot(ITEM_SLOT_R_HAND) == item_searched)
		return TRUE
	if(get_item_by_slot(ITEM_SLOT_L_HAND) == item_searched)
		return TRUE
	return FALSE
