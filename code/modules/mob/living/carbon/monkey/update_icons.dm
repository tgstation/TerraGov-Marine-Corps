//Monkey Overlays Indexes////////
#define M_MASK_LAYER			8
#define M_BACK_LAYER			7
#define M_HANDCUFF_LAYER		6
#define M_L_HAND_LAYER			5
#define M_R_HAND_LAYER			4
#define TARGETED_LAYER			3
#define M_FIRE_LAYER			2
#define M_BURST_LAYER			1
#define M_TOTAL_LAYERS			8
/////////////////////////////////

/mob/living/carbon/monkey
	var/list/overlays_standing[M_TOTAL_LAYERS]

/mob/living/carbon/monkey/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/monkey/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

/mob/living/carbon/monkey/regenerate_icons()
	update_inv_wear_mask()
	update_inv_back()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_fire()
	update_burst()
	update_transform()


/mob/living/carbon/monkey/update_transform()
	if(lying != lying_prev )
		lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again

		if(lying)
			var/matrix/M = matrix()
			M.Turn(90)
			M.Translate(1,-6)
			src.transform = M
		else
			var/matrix/M = matrix()
			src.transform = M


////////
/mob/living/carbon/monkey/update_inv_wear_mask()
	remove_overlay(M_MASK_LAYER)
	if(wear_mask)
		if(client && hud_used && hud_used.hud_shown && hud_used.inventory_shown)
			wear_mask.screen_loc = ui_monkey_mask
			client.screen += wear_mask
		overlays_standing[M_MASK_LAYER]	= image("icon" = 'icons/mob/monkey.dmi', "icon_state" = "[wear_mask.icon_state]", "layer" =-M_MASK_LAYER)
		apply_overlay(M_MASK_LAYER)


/mob/living/carbon/monkey/update_inv_r_hand()
	remove_overlay(M_R_HAND_LAYER)
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			client.screen += r_hand
			r_hand.screen_loc = ui_rhand
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		overlays_standing[M_R_HAND_LAYER]	= image("icon" = r_hand.sprite_sheet_id?'icons/mob/items_righthand_1.dmi':'icons/mob/items_righthand_0.dmi', "icon_state" = t_state, "layer" =-M_R_HAND_LAYER)
		apply_overlay(M_MASK_LAYER)


/mob/living/carbon/monkey/update_inv_l_hand()
	remove_overlay(M_L_HAND_LAYER)
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			client.screen += l_hand
			l_hand.screen_loc = ui_lhand
		var/t_state = l_hand.item_state
		if(!t_state)	 t_state = l_hand.icon_state
		overlays_standing[M_L_HAND_LAYER]	= image("icon" = l_hand.sprite_sheet_id?'icons/mob/items_lefthand_1.dmi':'icons/mob/items_lefthand_0.dmi', "icon_state" = t_state, "layer" =-M_L_HAND_LAYER)
		remove_overlay(M_L_HAND_LAYER)


/mob/living/carbon/monkey/update_inv_back()
	remove_overlay(M_BACK_LAYER)
	if(back)
		if(client && hud_used && hud_used.hud_shown)
			back.screen_loc = ui_monkey_back
			client.screen += back
		overlays_standing[M_BACK_LAYER]	= image("icon" = 'icons/mob/back.dmi', "icon_state" = "[back.icon_state]", "layer" =-M_BACK_LAYER)
		apply_overlay(M_BACK_LAYER)


/mob/living/carbon/monkey/update_inv_handcuffed()
	remove_overlay(M_HANDCUFF_LAYER)
	if(handcuffed)
		overlays_standing[M_HANDCUFF_LAYER]	= image("icon" = 'icons/mob/monkey.dmi', "icon_state" = "handcuff1", "layer" =-M_HANDCUFF_LAYER)

		apply_overlay(M_HANDCUFF_LAYER)


/mob/living/carbon/monkey/update_fire()
	remove_overlay(M_FIRE_LAYER)
	if(on_fire)
		switch(fire_stacks)
			if(1 to 14)	overlays_standing[M_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="monkey_weak", "layer"=-M_FIRE_LAYER)
			if(15 to 20) overlays_standing[M_FIRE_LAYER] = image("icon"='icons/mob/OnFire.dmi', "icon_state"="monkey_medium", "layer"=-M_FIRE_LAYER)

		apply_overlay(M_FIRE_LAYER)


//Call when target overlay should be added/removed
/mob/living/carbon/monkey/update_targeted()
	remove_overlay(TARGETED_LAYER)
	if (targeted_by && target_locked)
		overlays_standing[TARGETED_LAYER]	= image("icon"=target_locked, "layer" =-TARGETED_LAYER)
	else if (!targeted_by && target_locked)
		cdel(target_locked)
		target_locked = null
	apply_overlay(TARGETED_LAYER)

/mob/living/carbon/monkey/update_burst()
	remove_overlay(M_BURST_LAYER)
	var/image/standing = null

	if(chestburst == 1)
		standing = image("icon" = 'icons/Xeno/Effects.dmi',"icon_state" = "burst_stand", "layer" =-M_BURST_LAYER)
	else if(chestburst == 2)
		standing = image("icon" = 'icons/Xeno/Effects.dmi',"icon_state" = "bursted_stand", "layer" =-M_BURST_LAYER)

	overlays_standing[M_BURST_LAYER]	= standing
	apply_overlay(M_BURST_LAYER)



//Monkey Overlays Indexes////////
#undef M_MASK_LAYER
#undef M_BACK_LAYER
#undef M_HANDCUFF_LAYER
#undef M_L_HAND_LAYER
#undef M_R_HAND_LAYER
#undef TARGETED_LAYER
#undef M_FIRE_LAYER
#undef M_BURST_LAYER
#undef M_TOTAL_LAYERS

