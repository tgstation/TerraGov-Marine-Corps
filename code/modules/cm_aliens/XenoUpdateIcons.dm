//Straight up copied from old Bay
//Abby

//Xeno Overlays Indexes//////////
#define X_HEAD_LAYER			7
#define X_SUIT_LAYER			6
#define X_L_HAND_LAYER			5
#define X_R_HAND_LAYER			4
#define X_TARGETED_LAYER		3
#define X_LEGCUFF_LAYER			2
#define X_FIRE_LAYER			1
#define X_TOTAL_LAYERS			7
/////////////////////////////////

/mob/living/carbon/Xenomorph
	var/list/overlays_standing[X_TOTAL_LAYERS]

/mob/living/carbon/Xenomorph/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/Xenomorph/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

/mob/living/carbon/Xenomorph/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	var/image/overlay_claws = null
	var/enh_claws = has_upgrade("eclaws")  //Rebuilding the image each time? Why not, ugh.
	if(stat == DEAD)
		icon_state = "[caste] Dead"
		if(enh_claws)
			overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Knocked Down")
	else if(lying)
		if(resting)
			icon_state = "[caste] Sleeping"
			if(enh_claws)
				overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Sleeping")
		else
			icon_state = "[caste] Knocked Down"
			if(enh_claws)
				overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Knocked Down")

	else
		if(m_intent == "run")
			if(isXenoCrusher(src))
				var/mob/living/carbon/Xenomorph/Crusher/crusher = src
				if(crusher.momentum > 2) //Let it build up a bit so we're not changing icons every single turf
					icon_state = "[caste] Charging"
				else
					icon_state = "[caste] Running"
			else
				icon_state = "[caste] Running"
			if(enh_claws)
				overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Running")
		else
			icon_state = "[caste] Walking"
			if(enh_claws)
				overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Walking")

	if(overlay_claws && enh_claws)
		overlays += overlay_claws

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/Xenomorph/regenerate_icons()
	..()
	if(monkeyizing)
		return

	update_inv_r_hand()
	update_inv_l_hand()
	update_icons()
	update_fire()

/mob/living/carbon/Xenomorph/update_hud()
	//TODO
	if(client)
		client.screen |= contents


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
		if(client)
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
		if(client)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand
		var/t_state = l_hand.item_state
		if(!t_state)
			t_state = l_hand.icon_state
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = l_hand.sprite_sheet_id?'icons/mob/items_lefthand_1.dmi':'icons/mob/items_lefthand_0.dmi', "icon_state" = t_state, "layer" =-X_L_HAND_LAYER)
		apply_overlay(X_L_HAND_LAYER)

//Call when target overlay should be added/removed
/mob/living/carbon/Xenomorph/update_targeted()
	remove_overlay(X_TARGETED_LAYER)
	if(targeted_by && target_locked)
		overlays_standing[X_TARGETED_LAYER]	= image("icon" = target_locked, "layer" =-X_TARGETED_LAYER)
	else if(!targeted_by && target_locked)
		cdel(target_locked)
	if(!targeted_by || src.stat == DEAD)
		overlays_standing[X_TARGETED_LAYER]	= null
	apply_overlay(X_TARGETED_LAYER)

/mob/living/carbon/Xenomorph/update_inv_legcuffed()
	remove_overlay(X_LEGCUFF_LAYER)
	if(legcuffed)
		overlays_standing[X_LEGCUFF_LAYER]	= image("icon" = 'icons/Xeno/Effects.dmi', "icon_state" = "legcuff", "layer" =-X_LEGCUFF_LAYER)
		apply_overlay(X_LEGCUFF_LAYER)

/mob/living/carbon/Xenomorph/proc/create_shriekwave()
	overlays_standing[X_SUIT_LAYER] = image("icon" = src.icon, "icon_state" = "shriek_waves") //Ehh, suit layer's not being used.
	apply_overlay(X_SUIT_LAYER)
	spawn(30)
		remove_overlay(X_SUIT_LAYER)

/mob/living/carbon/Xenomorph/update_fire()
	remove_overlay(X_FIRE_LAYER)
	if(on_fire)
		if(big_xeno)
			overlays_standing[X_FIRE_LAYER] = image("icon"='icons/Xeno/Effects.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)
		else
			overlays_standing[X_FIRE_LAYER] = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)

		apply_overlay(X_FIRE_LAYER)


//Xeno Overlays Indexes//////////
#undef X_HEAD_LAYER
#undef X_SUIT_LAYER
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef TARGETED_LAYER
#undef X_LEGCUFF_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
