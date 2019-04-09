/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = TRUE

	if(incapacitated() || lying || istype(usr.loc, /obj/mecha) || istype(usr.loc, /obj/vehicle/multitile/root/cm_armored))
		return

	var/obj/item/I = get_active_held_item()
	if(!I)
		if(next_move > world.time)
			return
		if(client?.prefs?.preferred_slot)
			if(draw_from_slot_if_possible(client.prefs.preferred_slot))
				next_move = world.time + 3
				return
		for(var/slot in SLOT_DRAW_ORDER)
			if(draw_from_slot_if_possible(slot))
				next_move = world.time + 3
				return
	else
		if(client?.prefs?.preferred_slot)
			if(equip_to_slot_if_possible(I, client.prefs.preferred_slot, FALSE, FALSE, FALSE))
				return
		if(!equip_to_appropriate_slot(I, FALSE))
			return
		if(hand)
			update_inv_l_hand(FALSE)
		else
			update_inv_r_hand(FALSE)


/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], 1, del_on_fail = 0))
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
		if(SLOT_LEGCUFFED)
			return has_limb(LEG_LEFT) && has_limb(LEG_RIGHT)
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
	if(!O || !O.is_usable())
		return FALSE
	. = ..()

/mob/living/carbon/human/put_in_r_hand(obj/item/W)
	var/datum/limb/O = get_limb("r_hand")
	if(!O || !O.is_usable())
		return FALSE
	. = ..()

/mob/living/carbon/human/doUnEquip(obj/item/I, atom/newloc, nomoveupdate, force)
	. = ..()
	if(!. || !I)
		return FALSE

	if(I == wear_suit)
		if(s_store)
			dropItemToGround(s_store)
		wear_suit = null
		if(I.flags_inv_hide & HIDESHOES)
			update_inv_shoes()
		if(I.flags_inv_hide & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
			update_hair()
		if(I.flags_inv_hide & HIDEJUMPSUIT)
			update_inv_w_uniform()
		update_inv_wear_suit()
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
		update_suit_sensors()
		update_inv_w_uniform()
	else if(I == head)
		var/updatename = 0
		if(head.flags_inv_hide & HIDEFACE)
			updatename = 1
		head = null
		if(updatename)
			name = get_visible_name()
		if(I.flags_inv_hide & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
			update_hair()	//rebuild hair
		if(I.flags_inv_hide & HIDEEARS)
			update_inv_ears()
		if(I.flags_inv_hide & HIDEMASK)
			update_inv_wear_mask()
		if(I.flags_inv_hide & HIDEEYES)
			update_inv_glasses()
		update_tint()
		update_inv_head()
	else if (I == gloves)
		gloves = null
		update_inv_gloves()
	else if (I == glasses)
		glasses = null
		var/obj/item/clothing/glasses/G = I
		if(G.vision_flags || G.darkness_view || G.see_invisible)
			update_sight()
		if(G.tint)
			update_tint()
		update_inv_glasses()
	else if (I == wear_ear)
		wear_ear = null
		update_inv_ears()
	else if (I == shoes)
		shoes = null
		update_inv_shoes()
	else if (I == belt)
		belt = null
		update_inv_belt()
	else if (I == wear_id)
		wear_id = null
		sec_hud_set_ID()
		hud_set_squad()
		update_inv_wear_id()
		name = get_visible_name()
	else if (I == r_store)
		r_store = null
		update_inv_pockets()
	else if (I == l_store)
		l_store = null
		update_inv_pockets()
	else if (I == s_store)
		s_store = null
		update_inv_s_store()



/mob/living/carbon/human/wear_mask_update(obj/item/I, equipping)
	name = get_visible_name() // doing this without a check, still cheaper than doing it every Life() tick -spookydonut
	if(I.flags_inv_hide & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
		update_hair()	//rebuild hair
	if(I.flags_inv_hide & HIDEEARS)
		update_inv_ears()
	if(I.flags_inv_hide & HIDEEYES)
		update_inv_glasses()
	return ..()


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot)
	if(!slot)
		return
	if(!istype(W))
		return
	if(!has_limb_for_slot(slot))
		return

	if(W == l_hand)
		l_hand = null
		update_inv_l_hand()
		//removes item's actions, may be readded once re-equipped to the new slot
		for(var/X in W.actions)
			var/datum/action/A = X
			A.remove_action(src)

	else if(W == r_hand)
		r_hand = null
		update_inv_r_hand()
		//removes item's actions, may be readded once re-equipped to the new slot
		for(var/X in W.actions)
			var/datum/action/A = X
			A.remove_action(src)

	W.screen_loc = null
	W.loc = src
	W.layer = ABOVE_HUD_LAYER

	switch(slot)
		if(SLOT_BACK)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		if(SLOT_WEAR_MASK)
			wear_mask = W
			W.equipped(src, slot)
			sec_hud_set_ID()
			wear_mask_update(W, TRUE)
		if(SLOT_HANDCUFFED)
			handcuffed = W
			handcuff_update()
		if(SLOT_LEGCUFFED)
			legcuffed = W
			W.equipped(src, slot)
			legcuff_update()
		if(SLOT_L_HAND)
			l_hand = W
			W.equipped(src, slot)
			update_inv_l_hand()
		if(SLOT_R_HAND)
			r_hand = W
			W.equipped(src, slot)
			update_inv_r_hand()
		if(SLOT_BELT)
			belt = W
			W.equipped(src, slot)
			update_inv_belt()
		if(SLOT_WEAR_ID)
			wear_id = W
			W.equipped(src, slot)
			sec_hud_set_ID()
			hud_set_squad()
			update_inv_wear_id()
			name = get_visible_name()
		if(SLOT_EARS)
			wear_ear = W
			W.equipped(src, slot)
			update_inv_ears()
		if(SLOT_GLASSES)
			glasses = W
			W.equipped(src, slot)
			var/obj/item/clothing/glasses/G = W
			if(G.vision_flags || G.darkness_view || G.see_invisible)
				update_sight()
			if(G.tint)
				update_tint()
			update_inv_glasses()
		if(SLOT_GLOVES)
			gloves = W
			W.equipped(src, slot)
			update_inv_gloves()
		if(SLOT_HEAD)
			head = W
			if(head.flags_inv_hide & HIDEFACE)
				name = get_visible_name()
			if(head.flags_inv_hide & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
				update_hair()	//rebuild hair
			if(head.flags_inv_hide & HIDEEARS)
				update_inv_ears()
			if(head.flags_inv_hide & HIDEMASK)
				update_inv_wear_mask()
			if(head.flags_inv_hide & HIDEEYES)
				update_inv_glasses()
			W.equipped(src, slot)
			update_tint()
			update_inv_head()
		if(SLOT_SHOES)
			shoes = W
			W.equipped(src, slot)
			update_inv_shoes()
		if(SLOT_WEAR_SUIT)
			wear_suit = W
			if(wear_suit.flags_inv_hide & HIDESHOES)
				update_inv_shoes()
			if(wear_suit.flags_inv_hide & HIDEJUMPSUIT)
				update_inv_w_uniform()
			if( wear_suit.flags_inv_hide & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
				update_hair()
			W.equipped(src, slot)
			update_inv_wear_suit()
		if(SLOT_W_UNIFORM)
			w_uniform = W
			W.equipped(src, slot)
			sec_hud_set_ID()
			update_inv_w_uniform()
		if(SLOT_L_STORE)
			l_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(SLOT_R_STORE)
			r_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(SLOT_ACCESSORY)
			var/obj/item/clothing/under/U = w_uniform
			if(U && !U.hastie)
				var/obj/item/clothing/tie/T = W
				T.on_attached(U, src)
				U.hastie = T
				update_inv_w_uniform()
		if(SLOT_S_STORE)
			s_store = W
			W.equipped(src, slot)
			update_inv_s_store()
		if(SLOT_IN_BOOT)
			var/obj/item/clothing/shoes/marine/B = shoes
			B.attackby(W, src)
		if(SLOT_IN_BACKPACK)
			var/obj/item/storage/S = back
			S.handle_item_insertion(W, TRUE, src)
		if(SLOT_IN_SUIT)
			var/obj/item/clothing/suit/storage/S = wear_suit
			var/obj/item/storage/internal/T = S.pockets
			T.handle_item_insertion(W, FALSE)
			T.close(src)
		if(SLOT_IN_BELT)
			var/obj/item/storage/belt/S = belt
			S.handle_item_insertion(W, FALSE, src)
		if(SLOT_IN_HEAD)
			var/obj/item/clothing/head/helmet/marine/S = head
			var/obj/item/storage/internal/T = S.pockets
			T.handle_item_insertion(W, FALSE)
			T.close(src)
		if(SLOT_IN_ACCESSORY)
			var/obj/item/clothing/under/U = w_uniform
			var/obj/item/clothing/tie/storage/T = U.hastie
			var/obj/item/storage/internal/S = T.hold
			S.handle_item_insertion(W, FALSE)
			S.close(src)
		if(SLOT_IN_HOLSTER)
			var/obj/item/storage/S = belt
			S.handle_item_insertion(W, FALSE, src)
		if(SLOT_IN_B_HOLSTER)
			var/obj/item/storage/S = back
			S.handle_item_insertion(W, FALSE, src)
		if(SLOT_IN_S_HOLSTER)
			var/obj/item/storage/S = s_store
			S.handle_item_insertion(W, FALSE, src)
		if(SLOT_IN_STORAGE)
			var/obj/item/storage/S = s_active
			S.handle_item_insertion(W, FALSE, src)
		if(SLOT_IN_L_POUCH)
			var/obj/item/storage/S = l_store
			S.handle_item_insertion(W, FALSE, src)
		if(SLOT_IN_R_POUCH)
			var/obj/item/storage/S = r_store
			S.handle_item_insertion(W, FALSE, src)
		else
			to_chat(src, "<span class='warning'>You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it...</span>")
			return
	return TRUE




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
		if(SLOT_LEGCUFFED)
			return legcuffed
		if(SLOT_IN_BOOT)
			return shoes
		if(SLOT_IN_B_HOLSTER)
			return back
		if(SLOT_IN_HOLSTER)
			return belt
		if(SLOT_IN_STORAGE)
			return wear_suit
		if(SLOT_IN_S_HOLSTER)
			return s_store
		if(SLOT_IN_ACCESSORY)
			return w_uniform


/mob/living/carbon/human/stripPanelUnequip(obj/item/I, mob/M, slot_to_process)
	if(I.flags_item & ITEM_ABSTRACT)
		return
	if(I.flags_item & NODROP)
		to_chat(src, "<span class='warning'>You can't remove \the [I.name], it appears to be stuck!</span>")
		return
	log_combat(src, M, "attempted to remove [key_name(I)] ([slot_to_process])")

	M.visible_message("<span class='danger'>[src] tries to remove [M]'s [I.name].</span>", \
					"<span class='userdanger'>[src] tries to remove [M]'s [I.name].</span>", null, 5)
	I.add_fingerprint(src)
	if(do_mob(src, M, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
		if(I && Adjacent(M) && I == M.get_item_by_slot(slot_to_process))
			M.dropItemToGround(I)
			if(isidcard(I))
				log_admin("[key_name(src)] took the [I] of [key_name(M)].")
				message_admins("[ADMIN_TPMONTY(src)] took the [I] of [ADMIN_TPMONTY(M)].")

	if(M)
		if(interactee == M && Adjacent(M))
			M.show_inv(src)


/mob/living/carbon/human/stripPanelEquip(obj/item/I, mob/M, slot_to_process)
	if(I && !(I.flags_item & ITEM_ABSTRACT))
		if(I.flags_item & NODROP)
			to_chat(src, "<span class='warning'>You can't put \the [I.name] on [M], it's stuck to your hand!</span>")
			return
		if(!I.mob_can_equip(M, slot_to_process, TRUE))
			to_chat(src, "<span class='warning'>You can't put \the [I.name] on [M]!</span>")
			return
		visible_message("<span class='notice'>[src] tries to put [I] on [M].</span>", null, 5)
		if(do_mob(src, M, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
			if(I == get_active_held_item() && !M.get_item_by_slot(slot_to_process) && Adjacent(M))
				if(I.mob_can_equip(M, slot_to_process, TRUE))//Placing an item on the mob
					dropItemToGround(I)
					if(I && !I.gc_destroyed) //Might be self-deleted?
						M.equip_to_slot_if_possible(I, slot_to_process, 1, 0, 1, 1)

	if(M)
		if(interactee == M && Adjacent(M))
			M.show_inv(src)


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