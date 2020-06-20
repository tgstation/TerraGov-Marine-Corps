//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed(obj/item/restraints/handcuffs/restraints)
	if(restraints)
		drop_all_held_items()
		stop_pulling()
		handcuffed = restraints
		restraints.equipped(src, SLOT_HANDCUFFED)
		handcuffed.RegisterSignal(src, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
	else if(handcuffed)
		handcuffed.UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
		handcuffed = null
		restraints.unequipped(src, SLOT_HANDCUFFED)
	update_inv_handcuffed()

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
		update_handcuffed(null)
		. = ITEM_UNEQUIP_UNEQUIPPED


/mob/living/carbon/proc/wear_mask_update(obj/item/I, equipping = FALSE)
	if(!equipping && internal)
		if(hud_used?.internals)
			hud_used.internals.icon_state = "internal0"
		internal = null
	update_inv_wear_mask()
