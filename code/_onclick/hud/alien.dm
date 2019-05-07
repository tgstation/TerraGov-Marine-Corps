/obj/screen/alien
	icon = 'icons/mob/screen/alien.dmi'

/obj/screen/alien/Click()
	if(!isxeno(usr))
		return TRUE

/obj/screen/alien/nightvision
	name = "toggle night vision"
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision

/obj/screen/alien/nightvision/Click()
	. = ..()
	if(.)
		return
	var/mob/living/carbon/Xenomorph/X = usr
	X.toggle_nightvision()
	icon_state == (X.see_invisible = SEE_INVISIBLE_LEVEL_TWO) ? "nightvision0" : "nightvision1"

/obj/screen/alien/queen_locator
	icon_state = "trackoff"
	name = "queen locator (click for hive status)"
	screen_loc = ui_queen_locator

/obj/screen/alien/queen_locator/Click()
	. = ..()
	if(.)
		return
	var/mob/living/carbon/Xenomorph/X = usr
	X.hive_status()

/obj/screen/alien/plasmadisplay
	name = "plasma stored"
	icon_state = "power_display2"
	screen_loc = ui_alienplasmadisplay

/datum/hud/alien/New(mob/living/carbon/Xenomorph/owner)
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent/corner()
	using.icon = 'icons/mob/screen/alien.dmi'
	using.icon_state = "intent_"+owner.a_intent
	static_inventory += using
	action_intent = using


	using = new /obj/screen/mov_intent()
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = 'icons/mob/screen/alien.dmi'
	static_inventory += using

	inv_box = new /obj/screen/inventory/hand/right()
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		using.add_overlay("hand_active")
	inv_box.slot_id = SLOT_R_HAND
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.icon = 'icons/mob/screen/alien.dmi'
	if(owner && owner.hand)	//This being 1 means the left hand is in use
		inv_box.add_overlay("hand_active")
	inv_box.slot_id = SLOT_L_HAND
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.icon = 'icons/mob/screen/alien.dmi'
	static_inventory += using

	using = new /obj/screen/swap_hand/right()
	using.icon = 'icons/mob/screen/alien.dmi'
	static_inventory += using

	using = new /obj/screen/resist()
	using.icon = 'icons/mob/screen/alien.dmi'
	hotkeybuttons += using

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = 'icons/mob/screen/alien.dmi'
	hotkeybuttons += throw_icon

	healths = new /obj/screen/healths/alien()
	infodisplay += healths

	using = new /obj/screen/alien/nightvision()
	infodisplay += using

	alien_plasma_display = new /obj/screen/alien/plasmadisplay()
	infodisplay += alien_plasma_display

	locate_leader = new /obj/screen/alien/queen_locator()
	infodisplay += locate_leader

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen/alien.dmi'
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