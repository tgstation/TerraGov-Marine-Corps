/obj/screen/human
	icon = 'icons/mob/screen_midnight.dmi'

/obj/screen/human/toggle
	name = "toggle"
	icon_state = "toggle"

/obj/screen/human/toggle/Click()

	var/mob/targetmob = usr

	if(isobserver(usr))
		if(ishuman(usr.client.eye) && (usr.client.eye != usr))
			var/mob/M = usr.client.eye
			targetmob = M

	if(usr.hud_used.inventory_shown && targetmob.hud_used)
		usr.hud_used.inventory_shown = FALSE
		usr.client.screen -= targetmob.hud_used.toggleable_inventory
	else
		usr.hud_used.inventory_shown = TRUE
		usr.client.screen += targetmob.hud_used.toggleable_inventory

	targetmob.hud_used.hidden_inventory_update(usr)

/obj/screen/human/equip
	name = "equip"
	icon_state = "act_equip"

/obj/screen/human/equip/Click()
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return 1
	var/mob/living/carbon/human/H = usr
	H.quick_equip()

/obj/screen/devil
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/devil/soul_counter
	icon = 'icons/mob/screen_gen.dmi'
	name = "souls owned"
	icon_state = "Devil-6"
	screen_loc = ui_devilsouldisplay

/obj/screen/devil/soul_counter/proc/update_counter(souls = 0)
	invisibility = 0
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#FF0000'>[souls]</font></div>"
	switch(souls)
		if(0,null)
			icon_state = "Devil-1"
		if(1,2)
			icon_state = "Devil-2"
		if(3 to 5)
			icon_state = "Devil-3"
		if(6 to 8)
			icon_state = "Devil-4"
		if(9 to INFINITY)
			icon_state = "Devil-5"
		else
			icon_state = "Devil-6"

/obj/screen/devil/soul_counter/proc/clear()
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/ling
	invisibility = INVISIBILITY_ABSTRACT

/obj/screen/ling/sting
	name = "current sting"
	screen_loc = ui_lingstingdisplay

/obj/screen/ling/sting/Click()
	if(isobserver(usr))
		return
	var/mob/living/carbon/U = usr
	U.unset_sting()

/obj/screen/ling/chems
	name = "chemical storage"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay

/datum/hud/human/New(mob/living/carbon/human/owner)

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


	reads = new /obj/screen/read
	reads.hud = src
	static_inventory += reads
	textr = new /obj/screen/readtext
	textr.hud = src
	static_inventory += textr
	reads.textright = textr
	textl = new /obj/screen/readtext
	textl.hud = src
	static_inventory += textl
	reads.textleft = textl

	scannies = new /obj/screen/scannies
	scannies.hud = src
	static_inventory += scannies
	if(owner.client?.prefs?.crt == TRUE)
		scannies.alpha = 70

	action_intent = new /obj/screen/act_intent/rogintent
	action_intent.hud = src
	action_intent.screen_loc = rogueui_intents
	static_inventory += action_intent

//	clock = new /obj/screen/time
//	clock.hud = src
//	clock.screen_loc = rogueui_clock
//	static_inventory += clock

	stressies = new /obj/screen/stress
	stressies.hud = src
	stressies.screen_loc = rogueui_stress
	static_inventory += stressies

	rmb_intent = new /obj/screen/rmbintent(owner.client)
	rmb_intent.hud = src
	rmb_intent.screen_loc = rogueui_rmbintents
	static_inventory += rmb_intent
	rmb_intent.update_icon()

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

	cmode_button = new /obj/screen/cmode
	cmode_button.hud = src
	static_inventory += cmode_button

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

	fov_blocker = new /obj/screen/fov_blocker()
	fov_blocker.hud = src
	static_inventory += fov_blocker

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


/*	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = rogueui_resist
	using.hud = src
	hotkeybuttons += using
*/
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

	using = new /obj/screen/advsetup
	using.screen_loc = rogueui_advsetup
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

	//OLD SLOTS ////////////////////////////////////
/*
	using = new/obj/screen/language_menu
	using.icon = ui_style
	using.screen_loc = UI_BOXLANG
	static_inventory += using

	using = new /obj/screen/area_creator
	using.icon = ui_style
	if(!widescreen_layout)
		using.screen_loc = UI_BOXAREA
	static_inventory += using

	action_intent = new /obj/screen/act_intent/segmented
	action_intent.icon_state = mymob.a_intent
	static_inventory += action_intent

	using = new /obj/screen/mov_intent
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	using.screen_loc = ui_movi
	static_inventory += using

	using = new /obj/screen/drop()
	using.icon = ui_style
	using.screen_loc = ui_drop_throw
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "i_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = SLOT_PANTS
	inv_box.icon_state = "uniform"
	inv_box.screen_loc = ui_iclothing
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "o_clothing"
	inv_box.icon = ui_style
	inv_box.slot_id = SLOT_ARMOR
	inv_box.icon_state = "suit"
	inv_box.screen_loc = ui_oclothing
	toggleable_inventory += inv_box

	build_hand_slots()

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand_position(owner,1)
	static_inventory += using

	using = new /obj/screen/swap_hand()
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "id"
	inv_box.icon = ui_style
	inv_box.icon_state = "id"
	inv_box.screen_loc = ui_id
	inv_box.slot_id = SLOT_RING
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mask"
	inv_box.icon = ui_style
	inv_box.icon_state = "mask"
	inv_box.screen_loc = ui_mask
	inv_box.slot_id = SLOT_WEAR_MASK
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "neck"
	inv_box.icon = ui_style
	inv_box.icon_state = "neck"
	inv_box.screen_loc = ui_neck
	inv_box.slot_id = SLOT_NECK
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "back"
	inv_box.icon = ui_style
	inv_box.icon_state = "back"
	inv_box.screen_loc = ui_back
	inv_box.slot_id = SLOT_BACK
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage1"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage1
	inv_box.slot_id = SLOT_L_STORE
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "storage2"
	inv_box.icon = ui_style
	inv_box.icon_state = "pocket"
	inv_box.screen_loc = ui_storage2
	inv_box.slot_id = SLOT_R_STORE
	static_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "suit storage"
	inv_box.icon = ui_style
	inv_box.icon_state = "suit_storage"
	inv_box.screen_loc = ui_sstore1
	inv_box.slot_id = SLOT_S_STORE
	static_inventory += inv_box

	using = new /obj/screen/resist()
	using.icon = ui_style
	using.screen_loc = ui_above_intent
	hotkeybuttons += using

	using = new /obj/screen/human/toggle()
	using.icon = ui_style
	using.screen_loc = ui_inventory
	static_inventory += using

	using = new /obj/screen/human/equip()
	using.icon = ui_style
	using.screen_loc = ui_equip_position(mymob)
	static_inventory += using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "gloves"
	inv_box.icon = ui_style
	inv_box.icon_state = "gloves"
	inv_box.screen_loc = ui_gloves
	inv_box.slot_id = SLOT_GLOVES
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "eyes"
	inv_box.icon = ui_style
	inv_box.icon_state = "glasses"
	inv_box.screen_loc = ui_glasses
	inv_box.slot_id = SLOT_GLASSES
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "ears"
	inv_box.icon = ui_style
	inv_box.icon_state = "ears"
	inv_box.screen_loc = ui_ears
	inv_box.slot_id = SLOT_HEAD
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "head"
	inv_box.icon = ui_style
	inv_box.icon_state = "head"
	inv_box.screen_loc = ui_head
	inv_box.slot_id = SLOT_HEAD
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "shoes"
	inv_box.icon = ui_style
	inv_box.icon_state = "shoes"
	inv_box.screen_loc = ui_shoes
	inv_box.slot_id = SLOT_SHOES
	toggleable_inventory += inv_box

	inv_box = new /obj/screen/inventory()
	inv_box.name = "belt"
	inv_box.icon = ui_style
	inv_box.icon_state = "belt"
//	inv_box.icon_full = "template_small"
	inv_box.screen_loc = ui_belt
	inv_box.slot_id = SLOT_BELT
	static_inventory += inv_box

	throw_icon = new /obj/screen/throw_catch()
	throw_icon.icon = ui_style
	throw_icon.screen_loc = ui_drop_throw
	hotkeybuttons += throw_icon

	rest_icon = new /obj/screen/rest()
	rest_icon.icon = ui_style
	rest_icon.screen_loc = ui_above_movement
	static_inventory += rest_icon

	internals = new /obj/screen/internals()
	infodisplay += internals

	healths = new /obj/screen/healths()
	infodisplay += healths

	healthdoll = new /obj/screen/healthdoll()
	infodisplay += healthdoll

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = ui_style
	pull_icon.update_icon(mymob)
	pull_icon.screen_loc = ui_above_intent
	static_inventory += pull_icon

	lingchemdisplay = new /obj/screen/ling/chems()
	infodisplay += lingchemdisplay

	lingstingdisplay = new /obj/screen/ling/sting()
	infodisplay += lingstingdisplay

	devilsouldisplay = new /obj/screen/devil/soul_counter
	infodisplay += devilsouldisplay

	zone_select =  new /obj/screen/zone_sel()
	zone_select.icon = ui_style
	zone_select.hud = src
	zone_select.update_icon()
	static_inventory += zone_select

	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv.hud = src
			inv_slots[inv.slot_id] = inv
			inv.update_icon()

	update_locked_slots()
*/

/datum/hud/human/update_locked_slots()
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob
	if(!istype(H) || !H.dna)
		return
	var/datum/species/S = H.dna.species
	if(!S)
		return
	for(var/obj/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			if(inv.slot_id in S.no_equip)
				inv.alpha = 128
			else
				inv.alpha = initial(inv.alpha)

/datum/hud/human/hidden_inventory_update(mob/viewer)
	if(!mymob)
		return
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used.inventory_shown && screenmob.hud_used.hud_shown)
		if(H.shoes)
			H.shoes.screen_loc = rogueui_shoes
			screenmob.client.screen += H.shoes
		if(H.gloves)
			H.gloves.screen_loc = rogueui_gloves
			screenmob.client.screen += H.gloves
		if(H.wear_mask)
			H.wear_mask.screen_loc = rogueui_mask
			screenmob.client.screen += H.wear_mask
		if(H.mouth)
			H.mouth.screen_loc = rogueui_mouth
			screenmob.client.screen += H.mouth
		if(H.wear_neck)
			H.wear_neck.screen_loc = rogueui_neck
			screenmob.client.screen += H.wear_neck
		if(H.cloak)
			H.cloak.screen_loc = rogueui_cloak
			screenmob.client.screen += H.cloak
		if(H.wear_armor)
			H.wear_armor.screen_loc = rogueui_armor
			screenmob.client.screen += H.wear_armor
		if(H.wear_pants)
			H.wear_pants.screen_loc = rogueui_pants
			screenmob.client.screen += H.wear_pants
		if(H.wear_shirt)
			H.wear_shirt.screen_loc = rogueui_shirt
			screenmob.client.screen += H.wear_shirt
		if(H.wear_ring)
			H.wear_ring.screen_loc = rogueui_ringr
			screenmob.client.screen += H.wear_ring
		if(H.wear_wrists)
			H.wear_wrists.screen_loc = rogueui_wrists
			screenmob.client.screen += H.wear_wrists
		if(H.backr)
			H.backr.screen_loc = rogueui_backr
			screenmob.client.screen += H.backr
		if(H.backl)
			H.backl.screen_loc = rogueui_backl
			screenmob.client.screen += H.backl
		if(H.beltr)
			H.beltr.screen_loc = rogueui_beltr
			screenmob.client.screen += H.beltr
		if(H.belt)
			H.belt.screen_loc = rogueui_belt
			screenmob.client.screen += H.belt
		if(H.beltl)
			H.beltl.screen_loc = rogueui_beltl
			screenmob.client.screen += H.beltl
		if(H.head)
			H.head.screen_loc = rogueui_head
			screenmob.client.screen += H.head
	else
		return



/datum/hud/human/persistent_inventory_update(mob/viewer)
	if(!mymob)
		return
	..()
	var/mob/living/carbon/human/H = mymob

	var/mob/screenmob = viewer || H

	if(screenmob.hud_used)
		if(screenmob.hud_used.hud_shown)
			if(H.wear_ring)
				H.wear_ring.screen_loc = ui_id
				screenmob.client.screen += H.wear_ring
			if(H.belt)
				H.belt.screen_loc = ui_belt
				screenmob.client.screen += H.belt
			if(H.back)
				H.back.screen_loc = ui_back
				screenmob.client.screen += H.back
		else
			if(H.wear_ring)
				screenmob.client.screen -= H.wear_ring
			if(H.belt)
				screenmob.client.screen -= H.belt
			if(H.back)
				screenmob.client.screen -= H.back
			if(H.l_store)
				screenmob.client.screen -= H.l_store
			if(H.r_store)
				screenmob.client.screen -= H.r_store

	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in H.held_items)
			I.screen_loc = ui_hand_position(H.get_held_index_of_item(I))
			screenmob.client.screen += I
	else
		for(var/obj/item/I in H.held_items)
			I.screen_loc = null
			screenmob.client.screen -= I


/mob/living/carbon/human/verb/toggle_hotkey_verbs()
	set category = "OOC"
	set name = "Toggle hotkey buttons"
	set desc = ""
	set hidden = 1
	if(hud_used.hotkey_ui_hidden)
		client.screen += hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = FALSE
	else
		client.screen -= hud_used.hotkeybuttons
		hud_used.hotkey_ui_hidden = TRUE
