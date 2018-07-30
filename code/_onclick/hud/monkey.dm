/datum/hud/monkey/New(mob/living/carbon/monkey/owner, ui_style='icons/mob/screen1_old.dmi')
	..()
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen/act_intent()
	using.icon = ui_style
	using.icon_state = "intent_"+owner.a_intent
	static_inventory += using
	action_intent = using

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (owner.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	static_inventory += using
	move_intent = using

	using = new /obj/screen/drop()
	using.icon = ui_style
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "r_hand"
	inv_box.dir = WEST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(owner && !owner.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_rhand
	inv_box.slot_id = WEAR_R_HAND
	inv_box.layer = HUD_LAYER
	src.r_hand_hud_object = inv_box
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.dir = EAST
	inv_box.icon = ui_style
	inv_box.icon_state = "hand_inactive"
	if(owner && owner.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_active"
	inv_box.screen_loc = ui_lhand
	inv_box.slot_id = WEAR_L_HAND
	inv_box.layer = HUD_LAYER
	src.l_hand_hud_object = inv_box
	static_inventory += inv_box

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand1"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_LAYER
	static_inventory += using

	using = new /obj/screen/inventory()
	using.name = "hand"
	using.dir = SOUTH
	using.icon = ui_style
	using.icon_state = "hand2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_LAYER
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.dir = NORTH
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_monkey_mask
	inv_box.slot_id = WEAR_FACE
	inv_box.layer = HUD_LAYER
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.dir = NORTHEAST
	inv_box.icon = ui_style
	inv_box.icon_state = "equip"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = WEAR_BACK
	inv_box.layer = HUD_LAYER
	static_inventory += inv_box


	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = ui_style
	hotkeybuttons += throw_icon

	oxygen_icon = new /obj/screen/oxygen()
	oxygen_icon.icon = ui_style
	infodisplay += oxygen_icon

	pressure_icon = new /obj/screen()
	pressure_icon.icon = ui_style
	pressure_icon.icon_state = "pressure0"
	pressure_icon.name = "pressure"
	pressure_icon.screen_loc = ui_pressure
	infodisplay += pressure_icon

	toxin_icon = new /obj/screen()
	toxin_icon.icon = ui_style
	toxin_icon.icon_state = "tox0"
	toxin_icon.name = "toxin"
	toxin_icon.screen_loc = ui_toxin
	infodisplay += toxin_icon

	internals = new /obj/screen/internals()
	internals.icon = ui_style
	infodisplay += internals

	fire_icon = new /obj/screen/fire()
	fire_icon.icon = ui_style
	infodisplay += fire_icon

	bodytemp_icon = new /obj/screen/bodytemp()
	bodytemp_icon.icon = ui_style
	infodisplay += bodytemp_icon

	healths = new /obj/screen/healths()
	healths.icon = ui_style
	infodisplay += healths

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(owner)
	hotkeybuttons += pull_icon

	zone_sel = new /obj/screen/zone_sel()
	zone_sel.icon = ui_style
	zone_sel.update_icon(owner)
	static_inventory += zone_sel

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_pull_resist
	hotkeybuttons += using

	//Handle the gun settings buttons
	gun_setting_icon = new /obj/screen/gun/mode()
	gun_setting_icon.update_icon(owner)
	static_inventory += gun_setting_icon

	gun_item_use_icon = new /obj/screen/gun/item()
	gun_item_use_icon.update_icon(owner)
	static_inventory += gun_item_use_icon

	gun_move_icon = new /obj/screen/gun/move()
	gun_move_icon.update_icon(owner)
	static_inventory +=	gun_move_icon

	gun_run_icon = new /obj/screen/gun/run()
	gun_run_icon.update_icon(owner)
	static_inventory +=	gun_run_icon






/datum/hud/monkey/persistant_inventory_update()
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



/mob/living/carbon/monkey/create_hud()
	if(client && !hud_used)
		hud_used = new /datum/hud/monkey(src, ui_style2icon(client.prefs.UI_style))