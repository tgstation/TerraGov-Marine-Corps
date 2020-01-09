/obj/screen/alien
	icon = 'icons/mob/screen/alien.dmi'

/obj/screen/alien/Click()
	if(!isxeno(usr))
		return FALSE
	return TRUE

/obj/screen/alien/nightvision
	name = "toggle night vision"
	icon_state = "nightvision2"
	screen_loc = ui_alien_nightvision

/obj/screen/alien/nightvision/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = usr
	X.toggle_nightvision()
	switch(X.lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_INVISIBLE)
			icon_state = "nightvision3"
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			icon_state = "nightvision2"
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			icon_state = "nightvision1"
		else
			icon_state = "nightvision0"


/obj/screen/alien/queen_locator
	icon_state = "trackoff"
	name = "queen locator (click for hive status)"
	screen_loc = ui_queen_locator

/obj/screen/alien/queen_locator/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = usr
	X.hive_status()

/obj/screen/alien/plasmadisplay
	name = "plasma stored"
	icon_state = "power_display2"
	screen_loc = ui_alienplasmadisplay

/datum/hud/alien/New(mob/living/carbon/xenomorph/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent/corner()
	using.alpha = ui_alpha
	using.icon_state = owner.a_intent
	static_inventory += using
	action_intent = using


	using = new /obj/screen/mov_intent/alien()
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /obj/screen/inventory/hand/right()
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		using.add_overlay("hand_active")
	inv_box.slot_id = SLOT_R_HAND
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	if(owner?.hand)	//This being 1 means the left hand is in use
		inv_box.add_overlay("hand_active")
	inv_box.slot_id = SLOT_L_HAND
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /obj/screen/swap_hand/right()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /obj/screen/resist()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.screen_loc = ui_above_intent
	using.alpha = ui_alpha
	hotkeybuttons += using

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen/alien.dmi'
	pull_icon.screen_loc = ui_above_intent
	pull_icon.alpha = ui_alpha
	pull_icon.update_icon(owner)
	hotkeybuttons += pull_icon

	stand_icon = new /obj/screen/stand()
	stand_icon.icon = 'icons/mob/screen/alien.dmi'
	stand_icon.screen_loc = ui_above_movement
	stand_icon.alpha = ui_alpha
	stand_icon.update_icon(owner)
	hotkeybuttons += stand_icon

	crawl_icon = new /obj/screen/crawl()
	crawl_icon.icon = 'icons/mob/screen/alien.dmi'
	crawl_icon.screen_loc = ui_above_movement
	crawl_icon.alpha = ui_alpha
	crawl_icon.update_icon(owner)
	hotkeybuttons += crawl_icon

	rest_icon = new /obj/screen/rest()
	rest_icon.icon = 'icons/mob/screen/alien.dmi'
	rest_icon.screen_loc = ui_above_movement
	rest_icon.alpha = ui_alpha
	rest_icon.update_icon(owner)
	hotkeybuttons += rest_icon

	toggle_resting_icon = new /obj/screen/toggle_resting()
	toggle_resting_icon.alpha = ui_alpha
	toggle_resting_icon.update_icon(owner)
	hotkeybuttons += toggle_resting_icon

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = 'icons/mob/screen/alien.dmi'
	throw_icon.alpha = ui_alpha
	hotkeybuttons += throw_icon

	healths = new /obj/screen/healths/alien()
	healths.alpha = ui_alpha
	infodisplay += healths

	using = new /obj/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	alien_plasma_display = new /obj/screen/alien/plasmadisplay()
	alien_plasma_display.alpha = ui_alpha
	infodisplay += alien_plasma_display

	locate_leader = new /obj/screen/alien/queen_locator()
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader

	zone_sel = new /obj/screen/zone_sel/alien()
	zone_sel.update_icon(owner)
	static_inventory += zone_sel

/datum/hud/alien/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/xenomorph/H = mymob
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
