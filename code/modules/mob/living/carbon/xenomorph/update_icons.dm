//Straight up copied from old Bay
//Abby

//Xeno Overlays Indexes//////////
#define X_LASER_LAYER			9
#define X_WOUND_LAYER			8
#define X_HEAD_LAYER			7
#define X_SUIT_LAYER			6
#define X_L_HAND_LAYER			5
#define X_R_HAND_LAYER			4
#define X_TARGETED_LAYER		3
#define X_LEGCUFF_LAYER			2
#define X_FIRE_LAYER			1
#define X_TOTAL_LAYERS			9
/////////////////////////////////

/mob/living/carbon/Xenomorph/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/Xenomorph/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

/mob/living/carbon/Xenomorph/proc/handle_special_state()
	return FALSE

/mob/living/carbon/Xenomorph/update_icons()
	if(stat == DEAD)
		icon_state = "[xeno_caste.caste_name] Dead"
	else if(lying)
		if((resting || sleeping) && (!knocked_down && !knocked_out && health > 0))
			icon_state = "[xeno_caste.caste_name] Sleeping"
		else
			icon_state = "[xeno_caste.caste_name] Knocked Down"
	else if(!handle_special_state())
		if(m_intent == MOVE_INTENT_RUN)
			icon_state = "[xeno_caste.caste_name] Running"
		else
			icon_state = "[xeno_caste.caste_name] Walking"
	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()
	
	hud_set_plasma()
	med_hud_set_health()

/mob/living/carbon/Xenomorph/regenerate_icons()
	..()
	if(monkeyizing)
		return

	update_inv_r_hand()
	update_inv_l_hand()
	update_icons()


/mob/living/carbon/Xenomorph/update_inv_pockets()
	if(l_store)
		if(client && hud_used && hud_used.hud_shown)
			l_store.screen_loc = ui_storage1
			client.screen += l_store
	if(r_store)
		if(client && hud_used && hud_used.hud_shown)
			r_store.screen_loc = ui_storage2
			client.screen += r_store

/mob/living/carbon/Xenomorph/update_inv_r_hand()
	remove_overlay(X_R_HAND_LAYER)
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand
		var/t_state = r_hand.item_state
		if(!t_state)
			t_state = r_hand.icon_state
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = r_hand.sprite_sheet_id?'icons/mob/items_righthand_0.dmi':'icons/mob/items_righthand_0.dmi', "icon_state" = t_state, "layer" =-X_R_HAND_LAYER)
		apply_overlay(X_R_HAND_LAYER)

/mob/living/carbon/Xenomorph/update_inv_l_hand()
	remove_overlay(X_L_HAND_LAYER)
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		var/spritesheet_used = "icons/mob/items_lefthand_[l_hand.sprite_sheet_id]"
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = spritesheet_used, "icon_state" = t_state, "layer" =-X_L_HAND_LAYER)
		apply_overlay(X_L_HAND_LAYER)

//Call when target overlay should be added/removed
/mob/living/carbon/Xenomorph/update_targeted()
	remove_overlay(X_TARGETED_LAYER)
	if(targeted_by && target_locked)
		overlays_standing[X_TARGETED_LAYER]	= image("icon" = target_locked, "layer" =-X_TARGETED_LAYER)
	else if(!targeted_by && target_locked)
		qdel(target_locked)
		target_locked = null
	if(!targeted_by || src.stat == DEAD)
		overlays_standing[X_TARGETED_LAYER]	= null
	apply_overlay(X_TARGETED_LAYER)

/mob/living/carbon/Xenomorph/update_inv_legcuffed()
	remove_overlay(X_LEGCUFF_LAYER)
	if(legcuffed)
		overlays_standing[X_LEGCUFF_LAYER]	= image("icon" = 'icons/Xeno/Effects.dmi', "icon_state" = "legcuff", "layer" =-X_LEGCUFF_LAYER)
		apply_overlay(X_LEGCUFF_LAYER)

/mob/living/carbon/Xenomorph/proc/create_shriekwave()
	overlays_standing[X_SUIT_LAYER] = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state" = "shriek_waves") //Ehh, suit layer's not being used.
	apply_temp_overlay(X_SUIT_LAYER, 3 SECONDS)

/mob/living/carbon/Xenomorph/proc/create_stomp()
	overlays_standing[X_SUIT_LAYER] = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state" = "stomp") //Ehh, suit layer's not being used.
	apply_temp_overlay(X_SUIT_LAYER, 1.2 SECONDS)

/mob/living/carbon/Xenomorph/update_fire()
	remove_overlay(X_FIRE_LAYER)
	if(on_fire)
		var/image/I
		if(mob_size == MOB_SIZE_BIG)
			if((!initial(pixel_y) || lying) && !resting && !sleeping)
				I = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)
			else
				I = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state"="alien_fire_lying", "layer"=-X_FIRE_LAYER)
		else
			I = image("icon"='icons/Xeno/Effects.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)

		overlays_standing[X_FIRE_LAYER] = I
		apply_overlay(X_FIRE_LAYER)

/mob/living/carbon/Xenomorph/proc/apply_alpha_channel(var/image/I)
	return I

/mob/living/carbon/Xenomorph/proc/update_wounds()
	remove_overlay(X_WOUND_LAYER)
	if(health < maxHealth * 0.5) //Injuries appear at less than 50% health
		var/image/I
		if(resting)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="[xeno_caste.wound_type]_wounded_resting", "layer"=-X_WOUND_LAYER)
		else if(sleeping || stat == DEAD)
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="[xeno_caste.wound_type]_wounded_sleeping", "layer"=-X_WOUND_LAYER)
		else
			I = image("icon"='icons/Xeno/wound_overlays.dmi', "icon_state"="[xeno_caste.wound_type]_wounded", "layer"=-X_WOUND_LAYER)
		I = apply_alpha_channel(I)
		overlays_standing[X_WOUND_LAYER] = I
		apply_overlay(X_WOUND_LAYER)

/mob/living/carbon/Xenomorph/update_transform()
	..()
	return update_icons()
