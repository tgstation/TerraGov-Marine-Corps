//Straight up copied from old Bay
//Abby

//Xeno Overlays Indexes//////////
#define X_HEAD_LAYER			1
#define X_SUIT_LAYER			2
#define X_L_HAND_LAYER			3
#define X_R_HAND_LAYER			4
#define TARGETED_LAYER			5
#define X_LEGCUFF_LAYER			6
#define X_FIRE_LAYER			7
#define X_TOTAL_LAYERS			7
/////////////////////////////////

/mob/living/carbon/Xenomorph
	var/list/overlays_lying[X_TOTAL_LAYERS]
	var/list/overlays_standing[X_TOTAL_LAYERS]

/mob/living/carbon/Xenomorph/update_icons()
	lying_prev = lying	//so we don't update overlays for lying/standing unless our stance changes again
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	var/is_lying = 0
	var/image/overlay_claws = null
	var/enh_claws = has_upgrade("eclaws")  //Rebuilding the image each time? Why not, ugh.
	if(stat == DEAD)
		icon_state = "[caste] Dead"
		is_lying = 1
		if(enh_claws) overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Knocked Down")
	else if(lying)
		if(resting)
			icon_state = "[caste] Sleeping"
			if(enh_claws) overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Sleeping")
		else
			icon_state = "[caste] Knocked Down"
			if(enh_claws) overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Knocked Down")
		is_lying = 1

	else
		if(m_intent == "run")
			if(istype(src,/mob/living/carbon/Xenomorph/Crusher))
				if(src:momentum > 2) //Let it build up a bit so we're not changing icons every single turf
					icon_state = "[caste] Charging"
				else
					icon_state = "[caste] Running"
			else
				icon_state = "[caste] Running"
			if(enh_claws) overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Running")
		else
			icon_state = "[caste] Walking"
			if(enh_claws) overlay_claws = image("icon" = src.icon, "icon_state" = "[caste] Claws Walking")
		is_lying = 0

	if(overlay_claws && enh_claws)
		overlays += overlay_claws

	if(is_lying)
		for(var/image/I in overlays_lying)
			overlays += I
	else
		for(var/image/I in overlays_standing)
			overlays += I

/mob/living/carbon/Xenomorph/regenerate_icons()
	..()
	if (monkeyizing)	return

//We don't need to do most of this stuff anymore, they don't even have the slots.
//	update_inv_head(0)
//	update_inv_wear_suit(0)
	update_inv_r_hand(0)
	update_inv_l_hand(0)
//	update_inv_pockets(0)
	//update_hud() //Icons already update hud
	update_icons()
	update_fire()


/mob/living/carbon/Xenomorph/update_hud()
	//TODO
	if (client)
//		if(other)	client.screen |= hud_used.other		//Not used
//		else		client.screen -= hud_used.other		//Not used
		client.screen |= contents

/mob/living/carbon/Xenomorph/update_inv_wear_suit(var/update_icons=1)
	if(wear_suit)
		var/t_state = wear_suit.item_state
		if(!t_state)	t_state = wear_suit.icon_state
		var/image/lying		= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]2")
		var/image/standing	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]")

		if(wear_suit.blood_DNA)
			var/t_suit = "suit"
			if( istype(wear_suit, /obj/item/clothing/suit/armor) )
				t_suit = "armor"
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[t_suit]blood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "[t_suit]blood")

		//TODO
		wear_suit.screen_loc = ui_alien_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			drop_from_inventory(handcuffed)
			drop_r_hand()
			drop_l_hand()

		overlays_lying[X_SUIT_LAYER]	= lying
		overlays_standing[X_SUIT_LAYER]	= standing
	else
		overlays_lying[X_SUIT_LAYER]	= null
		overlays_standing[X_SUIT_LAYER]	= null
	if(update_icons)	update_icons()


/mob/living/carbon/Xenomorph/update_inv_head(var/update_icons=1)
	if (head)
		var/t_state = head.item_state
		if(!t_state)	t_state = head.icon_state
		var/image/lying		= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]2")
		var/image/standing	= image("icon" = 'icons/mob/mob.dmi', "icon_state" = "[t_state]")
		if(head.blood_DNA)
			lying.overlays		+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood2")
			standing.overlays	+= image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood")
		head.screen_loc = ui_alien_head
		overlays_lying[X_HEAD_LAYER]	= lying
		overlays_standing[X_HEAD_LAYER]	= standing
	else
		overlays_lying[X_HEAD_LAYER]	= null
		overlays_standing[X_HEAD_LAYER]	= null
	if(update_icons)	update_icons()


/mob/living/carbon/Xenomorph/update_inv_pockets(var/update_icons=1)
	if(l_store)		l_store.screen_loc = ui_storage1
	if(r_store)		r_store.screen_loc = ui_storage2
	if(update_icons)	update_icons()


/mob/living/carbon/Xenomorph/update_inv_r_hand(var/update_icons=1)
	if(r_hand)
		var/t_state = r_hand.item_state
		if(!t_state)	t_state = r_hand.icon_state
		r_hand.screen_loc = ui_rhand
		overlays_standing[X_R_HAND_LAYER]	= image("icon" = r_hand.sprite_sheet_id?'icons/mob/items_righthand_0.dmi':'icons/mob/items_righthand_0.dmi', "icon_state" = t_state)
	else
		overlays_standing[X_R_HAND_LAYER]	= null
	if(update_icons)	update_icons()

/mob/living/carbon/Xenomorph/update_inv_l_hand(var/update_icons=1)
	if(l_hand)
		var/t_state = l_hand.item_state
		if(!t_state)	t_state = l_hand.icon_state
		l_hand.screen_loc = ui_lhand
		overlays_standing[X_L_HAND_LAYER]	= image("icon" = l_hand.sprite_sheet_id?'icons/mob/items_lefthand_1.dmi':'icons/mob/items_lefthand_0.dmi', "icon_state" = t_state)
	else
		overlays_standing[X_L_HAND_LAYER]	= null
	if(update_icons)	update_icons()

//Call when target overlay should be added/removed
/mob/living/carbon/Xenomorph/update_targeted(var/update_icons=1)
	if (targeted_by && target_locked)
		overlays_lying[TARGETED_LAYER]		= target_locked
		overlays_standing[TARGETED_LAYER]	= target_locked
	else if (!targeted_by && target_locked)
		del(target_locked)
	if (!targeted_by || src.stat == DEAD)
		overlays_lying[TARGETED_LAYER]		= null
		overlays_standing[TARGETED_LAYER]	= null
	if(update_icons)		update_icons()

/mob/living/carbon/Xenomorph/update_inv_legcuffed(var/update_icons=1)
	if(legcuffed)
		overlays_standing[X_LEGCUFF_LAYER]	= image("icon" = 'icons/Xeno/Effects.dmi', "icon_state" = "legcuff")
		if(src.m_intent != "walk")
			src.m_intent = "walk"
	else
		overlays_standing[X_LEGCUFF_LAYER]	= null
	if(update_icons)   update_icons()

/mob/living/carbon/Xenomorph/proc/create_shriekwave()
	overlays_standing[X_SUIT_LAYER] = image("icon" = src.icon, "icon_state" = "shriek_waves") //Ehh, suit layer's not being used.
	update_icons()
	spawn(30)
		overlays_standing[X_SUIT_LAYER] = null
		update_icons()

/mob/living/carbon/Xenomorph/update_fire(var/update_icons=1)
	if(on_fire)
		if(big_xeno)
			overlays_standing[X_FIRE_LAYER] = image("icon"='icons/Xeno/Effects.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)
		else
			overlays_standing[X_FIRE_LAYER] = image("icon"='icons/Xeno/2x2_Xenos.dmi', "icon_state"="alien_fire", "layer"=-X_FIRE_LAYER)

	else
		overlays_standing[X_FIRE_LAYER] = null

	if(update_icons) update_icons()


//Xeno Overlays Indexes//////////
#undef X_HEAD_LAYER
#undef X_SUIT_LAYER
#undef X_L_HAND_LAYER
#undef X_R_HAND_LAYER
#undef TARGETED_LAYER
#undef X_LEGCUFF_LAYER
#undef X_FIRE_LAYER
#undef X_TOTAL_LAYERS
