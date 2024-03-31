//Used for normal mobs that have hands.
/datum/hud/dextrous/New(mob/living/owner)

	..()
	owner.overlay_fullscreen("see_through_darkness", /obj/screen/fullscreen/see_through_darkness)
/*
	var/widescreen_layout = FALSE
	if(owner.client?.prefs?.widescreenpref)
		widescreen_layout = FALSE
*/
	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	ui_style = ui_style

	//Rogue Slots /////////////////////////////////

	grain = new /obj/screen/grain
	grain.hud = src
	static_inventory += grain

	scannies = new /obj/screen/scannies
	scannies.hud = src
	static_inventory += scannies

	action_intent = new /obj/screen/act_intent/rogintent
	action_intent.hud = src
	action_intent.screen_loc = rogueui_intents
	static_inventory += action_intent

//	clock = new /obj/screen/time
//	clock.hud = src
//	clock.screen_loc = rogueui_clock
//	static_inventory += clock

	bloods = new /obj/screen/healths/blood
	bloods.hud = src
	bloods.screen_loc = rogueui_blood
	static_inventory += bloods

	quad_intents = new /obj/screen/quad_intents
	quad_intents.hud = src
	static_inventory += quad_intents

	def_intent = new /obj/screen/def_intent
	def_intent.hud = src
	static_inventory += def_intent

	give_intent = new /obj/screen/give_intent
	give_intent.hud = src
	static_inventory += give_intent

	backhudl =  new /obj/screen/backhudl()
	backhudl.hud = src
	static_inventory += backhudl

	hsover =  new /obj/screen/heatstamover()
	hsover.hud = src
	static_inventory += hsover

	fov = new /obj/screen/fov()
	fov.hud = src
	static_inventory += fov

	cdleft = new /obj/screen/action_bar/clickdelay/left()
	cdleft.hud = src
	cdleft.screen_loc = "WEST-3:-16,SOUTH+7"
	static_inventory += cdleft

	cdright = new /obj/screen/action_bar/clickdelay/right()
	cdright.hud = src
	cdright.screen_loc = "WEST-2:-16,SOUTH+7"
	static_inventory += cdright

	cdmid = new /obj/screen/action_bar/clickdelay()
	cdmid.hud = src
	cdmid.screen_loc = "WEST-3:0,SOUTH+7"
	static_inventory += cdmid

	build_hand_slots()

	inv_box = new /obj/screen/inventory()
	inv_box.name = "ring"
	inv_box.icon = ui_style
	inv_box.icon_state = "ring"
	inv_box.screen_loc = rogueui_ringr
	inv_box.slot_id = SLOT_RING
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "wrists"
	inv_box.icon = ui_style
	inv_box.icon_state = "wrist"
	inv_box.screen_loc = rogueui_wrists
	inv_box.slot_id = SLOT_WRISTS
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = rogueui_mask
	inv_box.slot_id = SLOT_WEAR_MASK
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "neck"
	inv_box.screen_loc = rogueui_neck
	inv_box.slot_id = SLOT_NECK
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "backl"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = rogueui_backl
	inv_box.slot_id = SLOT_BACK_L
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "backr"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = rogueui_backr
	inv_box.slot_id = SLOT_BACK_R
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = rogueui_gloves
	inv_box.slot_id = SLOT_GLOVES
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = rogueui_head
	inv_box.slot_id = SLOT_HEAD
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = rogueui_shoes
	inv_box.slot_id = SLOT_SHOES
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
	inv_box.screen_loc = rogueui_belt
	inv_box.slot_id = SLOT_BELT
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "hip r"
	inv_box.icon = ui_style
	inv_box.icon_state = "hip"
	inv_box.screen_loc = rogueui_beltr
	inv_box.slot_id = SLOT_BELT_R
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "hip l"
	inv_box.icon = ui_style
	inv_box.icon_state = "hip"
	inv_box.screen_loc = rogueui_beltl
	inv_box.slot_id = SLOT_BELT_L
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shirt"
	inv_box.icon = ui_style
	inv_box.icon_state = "shirt"
	inv_box.screen_loc = rogueui_shirt
	inv_box.slot_id = SLOT_SHIRT
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "trou"
	inv_box.icon = ui_style
	inv_box.icon_state = "pants"
	inv_box.screen_loc = rogueui_pants
	inv_box.slot_id = SLOT_PANTS
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "armor"
	inv_box.icon = ui_style
	inv_box.icon_state = "armor"
	inv_box.screen_loc = rogueui_armor
	inv_box.slot_id = SLOT_ARMOR
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "cloak"
	inv_box.icon = ui_style
	inv_box.icon_state = "cloak"
	inv_box.screen_loc = rogueui_cloak
	inv_box.slot_id = SLOT_CLOAK
	inv_box.hud = src
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mouth"
	inv_box.icon = ui_style
	inv_box.icon_state = "mouth"
	inv_box.screen_loc = rogueui_mouth
	inv_box.slot_id = SLOT_MOUTH
	inv_box.hud = src
	static_inventory += inv_box

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = rogueui_drop
	using.hud = src
	static_inventory += using

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = ui_style
	throw_icon.screen_loc = rogueui_throw
	throw_icon.hud = src
	hotkeybuttons += throw_icon

	using = new /obj/screen/restup()
	using.icon = ui_style
	using.screen_loc = rogueui_stance
	using.hud = src
	static_inventory += using

	using = new /obj/screen/restdown()
	using.icon = ui_style
	using.screen_loc = rogueui_stance
	using.hud = src
	static_inventory += using

	using = new/obj/screen/skills
	using.icon = ui_style
	using.screen_loc = rogueui_skills
	static_inventory += using

	using = new/obj/screen/craft
	using.icon = ui_style
	using.screen_loc = rogueui_craft
	static_inventory += using


//	using = new /obj/screen/resist()
//	using.icon = ui_style
//	using.screen_loc = rogueui_resist
//	using.hud = src
//	hotkeybuttons += using

//sneak button
	using = new /obj/screen/rogmove
	using.screen_loc = rogueui_moves
	using.hud = src
	static_inventory += using
	using.update_icon_state()
//sprint button
	using = new /obj/screen/rogmove/sprint
	using.screen_loc = rogueui_moves
	using.hud = src
	static_inventory += using
	using.update_icon_state()

	using = new /obj/screen/eye_intent
	using.icon = ui_style
	using.icon_state = "eye"
	using.screen_loc = rogueui_eye
	using.hud = src
	static_inventory += using
/*
	healthdoll = new /obj/screen/healthdoll()
	healthdoll.icon = ui_style
	healthdoll.hud = src
	infodisplay += healthdoll
*/
	zone_select =  new /obj/screen/zone_sel()
	zone_select.icon = 'icons/mob/roguehud64.dmi'
	zone_select.screen_loc = rogueui_targetdoll
	zone_select.update_icon()
	zone_select.hud = src
	static_inventory += zone_select

	zone_select.update_icon()

	fats = new /obj/screen/rogfat()
	infodisplay += fats

	stams = new /obj/screen/rogstam()
	infodisplay += stams

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

	update_locked_slots()
	mymob.update_a_intents()

/datum/hud/dextrous/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/D = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I


//Dextrous simple mobs can use hands!
/mob/living/simple_animal/create_mob_hud()
	if(dextrous)
		hud_type = dextrous_hud_type
	return ..()
