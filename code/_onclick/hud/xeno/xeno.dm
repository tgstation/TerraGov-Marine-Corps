/atom/movable/screen/alien
	icon = 'icons/mob/screen/alien.dmi'

/atom/movable/screen/alien/Click()
	if(!isxeno(usr))
		return FALSE
	return TRUE

/atom/movable/screen/alien/nightvision
	name = "toggle night vision"
	icon_state = "nightvision2"
	screen_loc = ui_alien_nightvision
	mouse_over_pointer = MOUSE_HAND_POINTER


/atom/movable/screen/alien/nightvision/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = usr
	X.toggle_nightvision()
	switch(X.lighting_cutoff)
		if(LIGHTING_CUTOFF_FULLBRIGHT)
			icon_state = "nightvision3"
		if(LIGHTING_CUTOFF_HIGH)
			icon_state = "nightvision2"
		if(LIGHTING_CUTOFF_MEDIUM)
			icon_state = "nightvision1"
		else
			icon_state = "nightvision0"


/atom/movable/screen/alien/queen_locator
	icon_state = "trackoff"
	name = "queen locator (click for hive status)"
	screen_loc = ui_queen_locator
	mouse_over_pointer = MOUSE_HAND_POINTER


/atom/movable/screen/alien/queen_locator/Click()
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/xenomorph/X = usr
	X.hive_status()

/atom/movable/screen/alien/plasmadisplay
	name = "plasma stored"
	icon_state = "power_display2"
	screen_loc = ui_alienplasmadisplay

/datum/hud/alien/New(mob/living/carbon/xenomorph/owner, ui_style, ui_color, ui_alpha = 230)
	..()
	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/act_intent/corner(null, src)
	using.alpha = ui_alpha
	using.icon_state = owner.a_intent
	static_inventory += using
	action_intent = using


	using = new /atom/movable/screen/mov_intent/alien(null, src)
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /atom/movable/screen/drop(null, src)
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /atom/movable/screen/inventory/hand/right(null, src)
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	inv_box.slot_id = SLOT_R_HAND
	inv_box.update_icon()
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /atom/movable/screen/inventory/hand/left(null, src)
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	inv_box.slot_id = SLOT_L_HAND
	inv_box.update_icon()
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /atom/movable/screen/swap_hand(null, src)
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/swap_hand/right(null, src)
	using.icon = 'icons/mob/screen/alien.dmi'
	using.alpha = ui_alpha
	static_inventory += using

	using = new /atom/movable/screen/resist(null, src)
	using.icon = 'icons/mob/screen/alien.dmi'
	using.screen_loc = ui_above_movement
	using.alpha = ui_alpha
	hotkeybuttons += using

	throw_icon = new /atom/movable/screen/throw_catch(null, src)
	throw_icon.icon = 'icons/mob/screen/alien.dmi'
	throw_icon.alpha = ui_alpha
	hotkeybuttons += throw_icon

	healths = new /atom/movable/screen/healths/alien(null, src)
	healths.alpha = ui_alpha
	infodisplay += healths

	using = new /atom/movable/screen/alien/nightvision(null, src)
	using.alpha = ui_alpha
	infodisplay += using

	alien_plasma_display = new /atom/movable/screen/alien/plasmadisplay(null, src)
	alien_plasma_display.alpha = ui_alpha
	infodisplay += alien_plasma_display

	locate_leader = new /atom/movable/screen/alien/queen_locator(null, src)
	locate_leader.alpha = ui_alpha
	infodisplay += locate_leader

	pull_icon = new /atom/movable/screen/pull(null, src)
	pull_icon.icon = 'icons/mob/screen/alien.dmi'
	pull_icon.screen_loc = ui_above_movement
	pull_icon.alpha = ui_alpha
	pull_icon.update_icon()
	hotkeybuttons += pull_icon

	zone_sel = new /atom/movable/screen/zone_sel/alien(null, src)
	zone_sel.update_icon()
	static_inventory += zone_sel

	combo_display = new /atom/movable/screen/combo(null, src)
	infodisplay += combo_display

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
