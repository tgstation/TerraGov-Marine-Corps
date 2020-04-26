//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed(obj/item/restraints/handcuffs/restraints)
	if(restraints)
		drop_all_held_items()
		stop_pulling()
		handcuffed = restraints
		handcuffed.RegisterSignal(src, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
	else if(handcuffed)
		handcuffed.UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
		handcuffed = null
	update_inv_handcuffed()

/mob/living/carbon/proc/update_legcuffed(obj/item/restraints/legcuffs/restraints)
	if(restraints)
		if(m_intent != MOVE_INTENT_WALK)
			toggle_move_intent(MOVE_INTENT_WALK)
			if(hud_used?.move_intent)
				hud_used.move_intent.icon_state = "walking"
		legcuffed = restraints
		legcuffed.RegisterSignal(src, COMSIG_LIVING_DO_RESIST, /atom/movable.proc/resisted_against)
		SEND_SIGNAL(src, COMSIG_LIVING_LEGCUFFED, restraints)
	else if (legcuffed)
		legcuffed.UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
		legcuffed = null
	update_inv_legcuffed()


/mob/living/carbon/doUnEquip(obj/item/I)
	. = ..()
	if(.)
		return
	if(I == back)
		back = null
		update_inv_back()
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if (I == wear_mask)
		wear_mask = null
		wear_mask_update(I)
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == handcuffed)
		update_handcuffed(null)
		. = ITEM_UNEQUIP_UNEQUIPPED
	else if(I == legcuffed)
		update_legcuffed(null)
		. = ITEM_UNEQUIP_UNEQUIPPED
	if(. == ITEM_UNEQUIP_UNEQUIPPED)
		if(I.slowdown)
			remove_movespeed_modifier(I.type)
		if(isclothing(I))
			var/obj/item/clothing/unequipped_clothing = I
			if(unequipped_clothing.accuracy_mod)
				adjust_mob_accuracy(-unequipped_clothing.accuracy_mod)


/mob/living/carbon/proc/wear_mask_update(obj/item/I, equipping = FALSE)
	if(!equipping && internal)
		if(hud_used?.internals)
			hud_used.internals.icon_state = "internal0"
		internal = null
	update_inv_wear_mask()
