//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
		drop_all_held_items()
		stop_pulling()
		RegisterSignal(src, COMSIG_LIVING_DO_RESIST, .proc/resist_handcuffs)
	else
		UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
	update_inv_handcuffed()

/mob/living/carbon/proc/update_legcuffed()
	if(legcuffed)
		if(m_intent != MOVE_INTENT_WALK)
			m_intent = MOVE_INTENT_WALK
			if(hud_used?.move_intent)
				hud_used.move_intent.icon_state = "walking"
		RegisterSignal(src, COMSIG_LIVING_DO_RESIST, .proc/resist_legcuffs)
	else
		UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
	update_inv_legcuffed()


/mob/living/carbon/doUnEquip(obj/item/I, atom/newloc, nomoveupdate, force)
	. = ..()
	if(!. || !I)
		return FALSE

	if(I == back)
		back = null
		update_inv_back()
	else if (I == wear_mask)
		wear_mask = null
		wear_mask_update(I)
		sec_hud_set_ID()
	else if(I == handcuffed)
		handcuffed = null
		update_handcuffed()
	else if(I == legcuffed)
		legcuffed = null
		update_legcuffed()

/mob/living/carbon/proc/wear_mask_update(obj/item/I, equipping = FALSE)
	if(!equipping && internal)
		if(hud_used?.internals)
			hud_used.internals.icon_state = "internal0"
		internal = null
	update_tint()
	update_inv_wear_mask()
