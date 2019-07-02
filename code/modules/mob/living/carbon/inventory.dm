//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed(obj/item/restraints/handcuffs/restraints)
	if(restraints)
		drop_all_held_items()
		stop_pulling()
		handcuffed = restraints
		handcuffed.RegisterSignal(src, COMSIG_LIVING_DO_RESIST, /obj/item/restraints/.proc/resisted_against)
	else if(handcuffed)
		handcuffed.UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
		handcuffed = null
	update_inv_handcuffed()

/mob/living/carbon/proc/update_legcuffed(obj/item/restraints/legcuffs/restraints)
	if(restraints)
		if(m_intent != MOVE_INTENT_WALK)
			m_intent = MOVE_INTENT_WALK
			if(hud_used?.move_intent)
				hud_used.move_intent.icon_state = "walking"
		legcuffed = restraints
		legcuffed.RegisterSignal(src, COMSIG_LIVING_DO_RESIST, /obj/item/restraints/.proc/resisted_against)
	else if (legcuffed)
		legcuffed.UnregisterSignal(src, COMSIG_LIVING_DO_RESIST)
		legcuffed = null
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
		update_handcuffed(null)
	else if(I == legcuffed)
		update_legcuffed(null)

/mob/living/carbon/proc/wear_mask_update(obj/item/I, equipping = FALSE)
	if(!equipping && internal)
		if(hud_used?.internals)
			hud_used.internals.icon_state = "internal0"
		internal = null
	update_tint()
	update_inv_wear_mask()
