

/mob/living/carbon/proc/handcuff_update()
	if(handcuffed)
		drop_held_items()
		stop_pulling()
	update_inv_handcuffed()

/mob/living/carbon/proc/legcuff_update()
	if(legcuffed)
		if(m_intent != MOVE_INTENT_WALK)
			m_intent = MOVE_INTENT_WALK
			if(hud_used && hud_used.move_intent)
				hud_used.move_intent.icon_state = "walking"
	update_inv_legcuffed()


/mob/living/carbon/u_equip(obj/item/I, atom/newloc, nomoveupdate, force)
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
		handcuff_update()
	else if(I == legcuffed)
		legcuffed = null
		legcuff_update()


/mob/living/carbon/proc/wear_mask_update(obj/item/I)
	update_inv_wear_mask()
