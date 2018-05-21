/mob/living/carbon/human/verb/quick_equip()
	set name = "quick-equip"
	set hidden = 1

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		var/obj/item/I = H.get_active_hand()
		if(!I)
			H << "<span class='notice'>You are not holding anything to equip.</span>"
			return
		if(H.equip_to_appropriate_slot(I, 0))
			if(hand)
				update_inv_l_hand(0)
			else
				update_inv_r_hand(0)
		else
			H << "\red You are unable to equip that."

/mob/living/carbon/human/proc/equip_in_one_of_slots(obj/item/W, list/slots, del_on_fail = 1)
	for (var/slot in slots)
		if (equip_to_slot_if_possible(W, slots[slot], 1, del_on_fail = 0))
			return slot
	if (del_on_fail)
		cdel(W)
	return null


/mob/living/carbon/human/proc/has_limb(org_name)
	for(var/X in limbs)
		var/datum/limb/E = X
		if(E.name == org_name)
			return !(E.status & LIMB_DESTROYED)

/mob/living/carbon/human/proc/has_limb_for_slot(slot)
	switch(slot)
		if(WEAR_BACK)
			return has_limb("chest")
		if(WEAR_FACE)
			return has_limb("head")
		if(WEAR_HANDCUFFS)
			return has_limb("l_hand") && has_limb("r_hand")
		if(WEAR_LEGCUFFS)
			return has_limb("l_leg") && has_limb("r_leg")
		if(WEAR_L_HAND)
			return has_limb("l_hand")
		if(WEAR_R_HAND)
			return has_limb("r_hand")
		if(WEAR_WAIST)
			return has_limb("chest")
		if(WEAR_ID)
			return 1
		if(WEAR_EAR)
			return has_limb("head")
		if(WEAR_EYES)
			return has_limb("head")
		if(WEAR_HANDS)
			return has_limb("l_hand") && has_limb("r_hand")
		if(WEAR_HEAD)
			return has_limb("head")
		if(WEAR_FEET)
			return has_limb("r_foot") && has_limb("l_foot")
		if(WEAR_JACKET)
			return has_limb("chest")
		if(WEAR_BODY)
			return has_limb("chest")
		if(WEAR_L_STORE)
			return has_limb("chest")
		if(WEAR_R_STORE)
			return has_limb("chest")
		if(WEAR_J_STORE)
			return has_limb("chest")
		if(WEAR_ACCESSORY)
			return has_limb("chest")
		if(WEAR_IN_BACK)
			return 1
		if(WEAR_IN_JACKET)
			return 1
		if(WEAR_IN_ACCESSORY)
			return 1

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

/mob/living/carbon/human/u_equip(obj/item/I, atom/newloc, nomoveupdate, force)
	. = ..()
	if(!. || !I)
		return FALSE

	if(I == wear_suit)
		if(s_store)
			drop_inv_item_on_ground(s_store)
		wear_suit = null
		if(I.flags_inventory & HIDESHOES)
			update_inv_shoes()
		if(I.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
			update_hair()
		update_inv_wear_suit()
	else if(I == w_uniform)
		if(r_store)
			drop_inv_item_on_ground(r_store)
		if(l_store)
			drop_inv_item_on_ground(l_store)
		if(belt)
			drop_inv_item_on_ground(belt)
		if(wear_suit) //We estimate all armors with uniform restrictions aren't okay with removing the uniform altogether
			var/obj/item/clothing/suit/S = wear_suit
			if(S.uniform_restricted)
				drop_inv_item_on_ground(wear_suit)
		w_uniform = null
		update_suit_sensors()
		update_inv_w_uniform()
	else if(I == head)
		head = null
		if(I.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
			update_hair()	//rebuild hair
		if(I.flags_inventory & HIDEEARS)
			update_inv_ears()
		if(I.flags_inventory & HIDEMASK)
			update_inv_wear_mask()
		update_inv_head()
	else if (I == gloves)
		gloves = null
		update_inv_gloves()
	else if (I == glasses)
		glasses = null
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
	else if (I == r_store)
		r_store = null
		update_inv_pockets()
	else if (I == l_store)
		l_store = null
		update_inv_pockets()
	else if (I == s_store)
		s_store = null
		update_inv_s_store()




/mob/living/carbon/human/wear_mask_update(obj/item/I)
	if(istype(I,/obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/F = I
		if(F.stat != DEAD && !F.sterile && !(status_flags & XENO_HOST)) //Huggered but not impregnated, deal damage.
			visible_message("<span class='danger'>[F] frantically claws at [src]'s face!</span>","<span class='danger'>[F] frantically claws at your face! Auugh!</span>")
			adjustBruteLossByPart(25,"head")
	if(I.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
		update_hair()	//rebuild hair
	if(I.flags_inventory & HIDEEARS)
		update_inv_ears()
	if(internal)
		if(hud_used && hud_used.internals)
			hud_used.internals.icon_state = "internal0"
		internal = null
	update_inv_wear_mask()


//This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible() or advanced_equip_to_slot_if_possible()
//set redraw_mob to 0 if you don't wish the hud to be updated - if you're doing it manually in your own proc.
/mob/living/carbon/human/equip_to_slot(obj/item/W as obj, slot)
	if(!slot) return
	if(!istype(W)) return
	if(!has_limb_for_slot(slot)) return

	if(W == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(W == r_hand)
		r_hand = null
		update_inv_r_hand()

	W.screen_loc = null
	W.loc = src
	W.layer = ABOVE_HUD_LAYER

	switch(slot)
		if(WEAR_BACK)
			back = W
			W.equipped(src, slot)
			update_inv_back()
		if(WEAR_FACE)
			wear_mask = W
			if( wear_mask.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
				update_hair()	//rebuild hair
				update_inv_ears()
			W.equipped(src, slot)
			sec_hud_set_ID()
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
		if(WEAR_WAIST)
			belt = W
			W.equipped(src, slot)
			update_inv_belt()
		if(WEAR_ID)
			wear_id = W
			W.equipped(src, slot)
			sec_hud_set_ID()
			hud_set_squad()
			update_inv_wear_id()
		if(WEAR_EAR)
			wear_ear = W
			W.equipped(src, slot)
			update_inv_ears()
		if(WEAR_EYES)
			glasses = W
			W.equipped(src, slot)
			update_inv_glasses()
		if(WEAR_HANDS)
			gloves = W
			W.equipped(src, slot)
			update_inv_gloves()
		if(WEAR_HEAD)
			head = W
			if(head.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR))
				update_hair()	//rebuild hair
			if(head.flags_inventory & HIDEEARS)
				update_inv_ears()
			if(head.flags_inventory & HIDEMASK)
				update_inv_wear_mask()
			W.equipped(src, slot)
			update_inv_head()
		if(WEAR_FEET)
			shoes = W
			W.equipped(src, slot)
			update_inv_shoes()
		if(WEAR_JACKET)
			wear_suit = W
			if(wear_suit.flags_inventory & HIDESHOES)
				update_inv_shoes()
			if( wear_suit.flags_inventory & (HIDEALLHAIR|HIDETOPHAIR|HIDELOWHAIR) )
				update_hair()
			W.equipped(src, slot)
			update_inv_wear_suit()
		if(WEAR_BODY)
			w_uniform = W
			W.equipped(src, slot)
			sec_hud_set_ID()
			update_inv_w_uniform()
		if(WEAR_L_STORE)
			l_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(WEAR_R_STORE)
			r_store = W
			W.equipped(src, slot)
			update_inv_pockets()
		if(WEAR_ACCESSORY)
			var/obj/item/clothing/under/U = w_uniform
			if(U && !U.hastie)
				var/obj/item/clothing/tie/T = W
				T.on_attached(U, src)
				U.hastie = T
				update_inv_w_uniform()
		if(WEAR_J_STORE)
			s_store = W
			W.equipped(src, slot)
			update_inv_s_store()
		if(WEAR_IN_BACK)
			if(get_active_hand() == W)
				temp_drop_inv_item(W)
			W.forceMove(back)
		if(WEAR_IN_JACKET)
			var/obj/item/clothing/suit/storage/S = wear_suit
			if(istype(S) && S.pockets.storage_slots) W.loc = S.pockets//Has to have some slots available.

		if(WEAR_IN_ACCESSORY)
			var/obj/item/clothing/under/U = w_uniform
			if(U && U.hastie)
				var/obj/item/clothing/tie/storage/T = U.hastie
				if(istype(T) && T.hold.storage_slots) W.loc = T.hold

		else
			src << "\red You are trying to eqip this item to an unsupported inventory slot. How the heck did you manage that? Stop it..."
			return

	return 1




/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(WEAR_BACK)
			return back
		if(WEAR_FACE)
			return wear_mask
		if(WEAR_WAIST)
			return belt
		if(WEAR_ID)
			return wear_id
		if(WEAR_EAR)
			return wear_ear
		if(WEAR_EYES)
			return glasses
		if(WEAR_HANDS)
			return gloves
		if(WEAR_L_HAND)
			return l_hand
		if(WEAR_R_HAND)
			return r_hand
		if(WEAR_HEAD)
			return head
		if(WEAR_FEET)
			return shoes
		if(WEAR_JACKET)
			return wear_suit
		if(WEAR_BODY)
			return w_uniform
		if(WEAR_L_STORE)
			return l_store
		if(WEAR_R_STORE)
			return r_store
		if(WEAR_J_STORE)
			return s_store
		if(WEAR_HANDCUFFS)
			return handcuffed
		if(WEAR_LEGCUFFS)
			return legcuffed





/mob/living/carbon/human/stripPanelUnequip(obj/item/I, mob/M, slot_to_process)
	if(I.abstract)
		return
	if((I.flags_atom & NODROP) || !I.canremove)
		src << "<span class='warning'>You can't remove \the [I.name], it appears to be stuck!</span>"
		return
	if(I.flags_inventory & CANTSTRIP)
		src << "<span class='warning'>You're having difficulty removing that item.</span>"
		return
	M.attack_log += "\[[time_stamp()]\] <font color='orange'>Has had their [I.name] ([slot_to_process]) attempted to be removed by [name] ([ckey])</font>"
	attack_log += "\[[time_stamp()]\] <font color='red'>Attempted to remove [M.name]'s ([M.ckey]) [I.name] ([slot_to_process])</font>"

	M.visible_message("<span class='danger'>[src] tries to remove [M]'s [I.name].</span>", \
					"<span class='userdanger'>[src] tries to remove [M]'s [I.name].</span>", null, 5)
	I.add_fingerprint(src)
	if(do_mob(src, M, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
		if(I && Adjacent(M) && I == M.get_item_by_slot(slot_to_process))
			M.drop_inv_item_on_ground(I)

	if(M)
		if(interactee == M && Adjacent(M))
			M.show_inv(src)


/mob/living/carbon/human/stripPanelEquip(obj/item/I, mob/M, slot_to_process)
	if(I && !I.abstract)
		if((I.flags_atom & NODROP) || !I.canremove)
			src << "<span class='warning'>You can't put \the [I.name] on [M], it's stuck to your hand!</span>"
			return
		if(!I.mob_can_equip(M, slot_to_process, TRUE))
			src << "<span class='warning'>You can't put \the [I.name] on [M]!</span>"
			return
		visible_message("<span class='notice'>[src] tries to put [I] on [M].</span>", null, 5)
		if(do_mob(src, M, HUMAN_STRIP_DELAY, BUSY_ICON_GENERIC, BUSY_ICON_GENERIC))
			if(I == get_active_hand() && !M.get_item_by_slot(slot_to_process) && Adjacent(M))
				if(I.mob_can_equip(M, slot_to_process, TRUE))//Placing an item on the mob
					drop_inv_item_on_ground(I)
					if(I && !I.disposed) //Might be self-deleted?
						M.equip_to_slot_if_possible(I, slot_to_process, 1, 0, 1, 1)

	if(M)
		if(interactee == M && Adjacent(M))
			M.show_inv(src)
