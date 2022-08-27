
/mob/living/carbon/xenomorph/apply_overlay(cache_index)
	var/image/I = overlays_standing[cache_index]
	if(I)
		overlays += I

/mob/living/carbon/xenomorph/remove_overlay(cache_index)
	if(overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

/mob/living/carbon/xenomorph/proc/handle_special_state()
	return FALSE

/mob/living/carbon/xenomorph/proc/handle_special_wound_states()
	return FALSE

/mob/living/carbon/xenomorph/update_icons()
	if(HAS_TRAIT(src, TRAIT_MOB_ICON_UPDATE_BLOCKED))
		return
	if(stat == DEAD)
		icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Dead"
	else if(lying_angle)
		if((resting || IsSleeping()) && (!IsParalyzed() && !IsUnconscious() && health > 0))
			icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Sleeping"
		else
			icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Knocked Down"
	else if(burrowed)
		icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Burrowed"
	else if(!handle_special_state())
		if(m_intent == MOVE_INTENT_RUN)
			icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Running"
		else
			icon_state = "[xeno_caste.caste_name][is_a_rouny ? " rouny" : ""] Walking"
	update_fire() //the fire overlay depends on the xeno's stance, so we must update it.
	update_wounds()

	hud_set_plasma()
	med_hud_set_health()
	hud_set_sunder()
	hud_set_firestacks()

/mob/living/carbon/xenomorph/regenerate_icons()
	..()

	update_inv_r_hand()
	update_inv_l_hand()
	update_icons()


/mob/living/carbon/xenomorph/update_inv_pockets()
	if(l_store)
		if(client && hud_used && hud_used.hud_shown)
			l_store.screen_loc = ui_storage1
			client.screen += l_store
	if(r_store)
		if(client && hud_used && hud_used.hud_shown)
			r_store.screen_loc = ui_storage2
			client.screen += r_store

/mob/living/carbon/xenomorph/update_inv_r_hand()
	remove_overlay(X_R_HAND_LAYER)
	if(r_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			r_hand.screen_loc = ui_rhand
			client.screen += r_hand

		overlays_standing[X_R_HAND_LAYER] = r_hand.make_worn_icon(inhands = TRUE, slot_name = slot_r_hand_str, default_icon = 'icons/mob/items_righthand_0.dmi', default_layer = X_R_HAND_LAYER)
		apply_overlay(X_R_HAND_LAYER)

/mob/living/carbon/xenomorph/update_inv_l_hand()
	remove_overlay(X_L_HAND_LAYER)
	if(l_hand)
		if(client && hud_used && hud_used.hud_version != HUD_STYLE_NOHUD)
			l_hand.screen_loc = ui_lhand
			client.screen += l_hand

		overlays_standing[X_L_HAND_LAYER] = l_hand.make_worn_icon(inhands = TRUE, slot_name = slot_l_hand_str, default_icon = 'icons/mob/items_lefthand_0.dmi', default_layer = X_L_HAND_LAYER)
		apply_overlay(X_L_HAND_LAYER)

/mob/living/carbon/xenomorph/proc/create_shriekwave()
	overlays_standing[X_SUIT_LAYER] = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state" = "shriek_waves") //Ehh, suit layer's not being used.
	apply_temp_overlay(X_SUIT_LAYER, 3 SECONDS)

/mob/living/carbon/xenomorph/proc/create_stomp()
	overlays_standing[X_SUIT_LAYER] = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state" = "stomp") //Ehh, suit layer's not being used.
	apply_temp_overlay(X_SUIT_LAYER, 1.2 SECONDS)

/mob/living/carbon/xenomorph/update_fire()
	remove_overlay(X_FIRE_LAYER)
	if(on_fire)
		var/image/I
		if(mob_size == MOB_SIZE_BIG)
			if((!initial(pixel_y) || lying_angle) && !resting && !IsSleeping())
				I = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)
			else
				I = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state"="alien_fire_lying", "layer"=-X_FIRE_LAYER)
		else
			I = image("icon"='icons/Xeno/Effects.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)

		overlays_standing[X_FIRE_LAYER] = I
		apply_overlay(X_FIRE_LAYER)

/mob/living/carbon/xenomorph/proc/apply_alpha_channel(image/I)
	return I

/mob/living/carbon/xenomorph/proc/update_wounds()
	if(QDELETED(src))
		return
	var/health_thresholds
	wound_overlay.layer = layer + 0.3
	if(health > health_threshold_crit)
		health_thresholds = CEILING((health * 4) / (maxHealth), 1) //From 1 to 4, in 25% chunks
		if(health_thresholds > 3)
			wound_overlay.icon_state = "none"
			return //Injuries appear at less than 75% health
	else if(health_threshold_dead)
		switch(CEILING((health * 3) / health_threshold_dead, 1)) //Negative health divided by a negative threshold, positive result.
			if(0 to 1)
				health_thresholds = 1
			if(2)
				health_thresholds = 2
			if(3 to INFINITY)
				health_thresholds = 3
	if(lying_angle)
		if((resting || IsSleeping()) && (!IsParalyzed() && !IsUnconscious() && health > 0))
			wound_overlay.icon_state = "[xeno_caste.wound_type]_wounded_resting_[health_thresholds]"
		else
			wound_overlay.icon_state = "[xeno_caste.wound_type]_wounded_stunned_[health_thresholds]"
	else if(!handle_special_state())
		wound_overlay.icon_state = "[xeno_caste.wound_type]_wounded_[health_thresholds]"
	else
		wound_overlay.icon_state = handle_special_wound_states(health_thresholds)

/mob/living/carbon/xenomorph/update_transform()
	..()
	return update_icons()

///Used to display the xeno wounds without rapidly switching overlays
/atom/movable/vis_obj/xeno_wounds
	icon = 'icons/Xeno/wound_overlays.dmi'
	var/mob/living/carbon/xenomorph/wound_owner

/atom/movable/vis_obj/xeno_wounds/Initialize(mapload, mob/living/carbon/xenomorph/owner)
	. = ..()
	if(owner)
		wound_owner = owner
		RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_change)

/atom/movable/vis_obj/xeno_wounds/Destroy()
	if(wound_owner)
		wound_owner = null
	return ..()

/atom/movable/vis_obj/xeno_wounds/proc/on_dir_change(mob/living/carbon/xenomorph/source, olddir, newdir)
	SIGNAL_HANDLER
	if(newdir != dir)
		dir = newdir
