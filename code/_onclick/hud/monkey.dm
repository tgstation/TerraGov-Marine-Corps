/datum/hud/monkey/New(mob/living/carbon/monkey/owner, ui_style='icons/mob/screen/White.dmi', ui_color = "#ffffff", ui_alpha = 230)
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent()
	using.icon = ui_style
	using.alpha = ui_alpha
	using.icon_state = owner.a_intent
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /obj/screen/inventory/hand/right()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		inv_box.add_overlay("hand_active")
	inv_box.slot_id = SLOT_R_HAND
	inv_box.layer = HUD_LAYER
	r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory/hand()
	inv_box.icon = ui_style
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	if(owner?.hand)	//This being 1 means the left hand is in use
		inv_box.add_overlay("hand_active")
	inv_box.slot_id = SLOT_L_HAND
	inv_box.layer = HUD_LAYER
	l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /obj/screen/swap_hand()
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	using = new /obj/screen/swap_hand/right()
	using.color = ui_color
	using.alpha = ui_alpha
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = SLOT_WEAR_MASK
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.color = ui_color
	inv_box.alpha = ui_alpha
	inv_box.screen_loc = ui_back
	inv_box.slot_id = SLOT_BACK
	static_inventory += inv_box


	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = ui_style
	throw_icon.color = ui_color
	throw_icon.alpha = ui_alpha
	hotkeybuttons += throw_icon

	oxygen_icon = new /obj/screen/oxygen()
	infodisplay += oxygen_icon

	pressure_icon = new /obj/screen()
	pressure_icon.icon_state = "pressure0"
	pressure_icon.name = "pressure"
	pressure_icon.screen_loc = ui_pressure
	infodisplay += pressure_icon

	toxin_icon = new /obj/screen()
	toxin_icon.icon_state = "tox0"
	toxin_icon.name = "toxin"
	toxin_icon.screen_loc = ui_toxin
	infodisplay += toxin_icon

	internals = new /obj/screen/internals()
	infodisplay += internals

	fire_icon = new /obj/screen/fire()
	infodisplay += fire_icon

	bodytemp_icon = new /obj/screen/bodytemp()
	infodisplay += bodytemp_icon

	healths = new /obj/screen/healths()
	infodisplay += healths

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.color = ui_color
	pull_icon.alpha = ui_alpha
	pull_icon.update_icon(owner)
	hotkeybuttons += pull_icon

	rest_icon = new /obj/screen/rest()
	rest_icon.icon = ui_style
	rest_icon.color = ui_color
	rest_icon.alpha = ui_alpha
	rest_icon.update_icon(owner)
	static_inventory += rest_icon

	zone_sel = new /obj/screen/zone_sel()
	zone_sel.icon = ui_style
	zone_sel.color = ui_color
	zone_sel.alpha = ui_alpha
	zone_sel.update_icon(owner)
	static_inventory += zone_sel

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.color = ui_color
	using.alpha = ui_alpha
	hotkeybuttons += using






/datum/hud/monkey/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/carbon/monkey/M = mymob

	if(hud_shown)
		if(M.back)
			M.back.screen_loc = ui_back
			M.client.screen += M.back
		if(M.wear_mask)
			M.wear_mask.screen_loc = ui_monkey_mask
			M.client.screen += M.wear_mask
	else
		if(M.back)
			M.back.screen_loc = null
		if(M.wear_mask)
			M.wear_mask.screen_loc = null


	if(hud_version != HUD_STYLE_NOHUD)
		if(M.r_hand)
			M.r_hand.screen_loc = ui_rhand
			M.client.screen += M.r_hand
		if(M.l_hand)
			M.l_hand.screen_loc = ui_lhand
			M.client.screen += M.l_hand
	else
		if(M.r_hand)
			M.r_hand.screen_loc = null
		if(M.l_hand)
			M.l_hand.screen_loc = null