/atom/movable/screen/alien
	icon = 'icons/mob/screen/alien.dmi'

/atom/movable/screen/alien/Click()
	if(!isxeno(usr))
		return FALSE
	return TRUE

/atom/movable/screen/alien/MouseEntered(location, control, params)
	if(!usr.client?.prefs?.tooltips)
		return
	openToolTip(usr, src, params, title = name, content = desc)

/atom/movable/screen/alien/MouseExited()
	if(!usr.client?.prefs?.tooltips)
		return
	closeToolTip(usr)

/atom/movable/screen/alien/nightvision
	name = "Toggle Night Vision"
	icon_state = "nightvision2"
	screen_loc = ui_alien_nightvision

/atom/movable/screen/alien/nightvision/Click()
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


/atom/movable/screen/alien/queen_locator
	icon_state = "trackoff"
	name = "Queen Locator"
	desc = "Click for hive status."
	screen_loc = ui_queen_locator

/atom/movable/screen/alien/queen_locator/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = usr
	X.hive_status()

/atom/movable/screen/alien/plasmadisplay
	name = "Plasma Stored"
	icon = 'icons/mob/screen/alien_better.dmi'
	icon_state = "power_display2"
	screen_loc = ui_alienplasmadisplay

/datum/hud/alien/New(mob/living/carbon/xenomorph/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/act_intent/corner()
	using.alpha = ui_alpha
	using.icon_state = owner.a_intent
	static_inventory += using
	action_intent = using


	using = new /atom/movable/screen/mov_intent/alien()
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/drop()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory/hand/right()
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		using.add_overlay("hand_active")
	inv_box.slot_id = SLOT_R_HAND
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand()
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	if(owner?.hand)	//This being 1 means the left hand is in use
		inv_box.add_overlay("hand_active")
	inv_box.slot_id = SLOT_L_HAND
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /atom/movable/screen/swap_hand()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/swap_hand/right()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/resist()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.screen_loc = ui_above_movement
	using.alpha = ui_alpha
	hotkeybuttons += using

	throw_icon = new /atom/movable/screen/throw_catch()
	throw_icon.icon = 'icons/mob/screen/alien.dmi'
	throw_icon.alpha = ui_alpha
	hotkeybuttons += throw_icon

	healths = new /atom/movable/screen/healths/alien()
	healths.alpha = ui_alpha
	infodisplay += healths

	using = new /atom/movable/screen/alien/nightvision()
	using.alpha = ui_alpha
	infodisplay += using

	alien_plasma_display = new /atom/movable/screen/alien/plasmadisplay()
	alien_plasma_display.alpha = ui_alpha
	infodisplay += alien_plasma_display

	locate_leader = new /atom/movable/screen/alien/queen_locator()
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = 'icons/mob/screen/alien.dmi'
	pull_icon.screen_loc = ui_above_movement
	pull_icon.alpha = ui_alpha
	pull_icon.update_icon(owner)
	hotkeybuttons += pull_icon

	zone_sel = new /atom/movable/screen/zone_sel/alien()
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
