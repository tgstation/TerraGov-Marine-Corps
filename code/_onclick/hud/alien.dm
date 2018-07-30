/datum/hud/alien/New(mob/living/carbon/Xenomorph/owner)
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent/corner()
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "intent_"+owner.a_intent
	static_inventory += using
	action_intent = using


	using = new /obj/screen/mov_intent()
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = 'icons/mob/screen1_alien.dmi'
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.icon = 'icons/mob/screen1_alien.dmi'
	inv_box.dir = 1 //north is sprite for right hand, south is left hand.
	inv_box.icon_state = "hand_inactive"
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		using.icon_state = "hand_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = HUD_LAYER
	inv_box.slot_id = WEAR_R_HAND
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.icon = 'icons/mob/screen1_alien.dmi'
	inv_box.icon_state = "hand_inactive"
	if(owner && owner.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_lhand
	inv_box.layer = HUD_LAYER
	inv_box.slot_id = WEAR_L_HAND
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_LAYER
	static_inventory += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_LAYER
	static_inventory += using


	using = new /obj/screen/resist/alien()
	hotkeybuttons += using

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = 'icons/mob/screen1_alien.dmi'
	hotkeybuttons += throw_icon

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	using = new /obj/screen/xenonightvision()
	infodisplay += using

	alien_plasma_display = new /obj/screen()
	alien_plasma_display.icon = 'icons/mob/screen1_alien.dmi'
	alien_plasma_display.icon_state = "power_display2"
	alien_plasma_display.name = "plasma stored"
	alien_plasma_display.screen_loc = ui_alienplasmadisplay
	infodisplay += alien_plasma_display

	locate_leader = new /obj/screen/queen_locator()
	infodisplay += locate_leader

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen1_alien.dmi'
	pull_icon.screen_loc = ui_pull_resist
	pull_icon.update_icon(owner)
	hotkeybuttons += pull_icon

	zone_sel = new /obj/screen/zone_sel/alien()
	zone_sel.update_icon(owner)
	static_inventory += zone_sel



/datum/hud/alien/persistant_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/Xenomorph/H = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		if(H.r_hand)
			H.r_hand.screen_loc = ui_rhand
			H.client.screen += H.r_hand
		if(H.l_hand)
			H.l_hand.screen_loc = ui_lhand
			H.client.screen += H.l_hand
	else
		if(H.r_hand)
			H.r_hand.screen_loc = null
		if(H.l_hand)
			H.l_hand.screen_loc = null


/mob/living/carbon/Xenomorph/create_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/alien(src)