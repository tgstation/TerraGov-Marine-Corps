/mob/living/carbon/doUnEquip(obj/item/I)
	. = ..()
	if(.)
		return
	if(I == back)
		back = null
		I.unequipped(src, SLOT_BACK)
		update_inv_back()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == wear_mask)
		wear_mask = null
		I.unequipped(src, SLOT_WEAR_MASK)
		wear_mask_update(I)
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == handcuffed)
		handcuffed = null
		update_handcuffed(null)
		. = ITEM_UNEQUIP_UNEQUIPPED

/mob/living/carbon/equip_to_slot(obj/item/item_to_equip, slot, into_storage)
	. = ..()

	if(!slot)
		return

	if(!istype(item_to_equip))
		return

	if(item_to_equip == l_hand)
		l_hand = null
		item_to_equip.unequipped(src, ITEM_SLOT_L_HAND)
		update_inv_l_hand()

	else if(item_to_equip == r_hand)
		r_hand = null
		item_to_equip.unequipped(src, ITEM_SLOT_R_HAND)
		update_inv_r_hand()

	for(var/datum/action/A AS in item_to_equip.actions)
		A.remove_action(src)

	item_to_equip.screen_loc = null
	item_to_equip.loc = src
	item_to_equip.layer = ABOVE_HUD_LAYER
	item_to_equip.plane = ABOVE_HUD_PLANE
	item_to_equip.forceMove(src)

/mob/living/carbon/get_equipped_slot(obj/equipped_item)
	if(..())
		return

	if(equipped_item == handcuffed)
		. = ITEM_SLOT_HANDCUFF
	else if(equipped_item == back)
		. = ITEM_SLOT_BACK

///called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed(obj/item/restraints/handcuffs/restraints)
	if(restraints)
		drop_all_held_items()
		stop_pulling()
		handcuffed = restraints
		restraints.equipped(src, SLOT_HANDCUFFED)
		handcuffed.RegisterSignal(src, COMSIG_LIVING_DO_RESIST, TYPE_PROC_REF(/atom/movable, resisted_against))
	else if(handcuffed)
		handcuffed.UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
		handcuffed.unequipped(src, SLOT_HANDCUFFED)
	update_inv_handcuffed()

///Updates the mask slot icon
/mob/living/carbon/proc/wear_mask_update(obj/item/I, equipping = FALSE)
	update_inv_wear_mask()
