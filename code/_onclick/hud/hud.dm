
/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_version = HUD_STYLE_STANDARD	//the hud version used (standard, reduced, none)
	var/hud_shown = TRUE			//Used for the HUD toggle (F12)
	var/inventory_shown = TRUE		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/obj/screen/alien_plasma_display
	var/obj/screen/locate_leader
	var/obj/screen/pred_power_icon

	var/obj/screen/module_store_icon

	var/obj/screen/nutrition_icon

	var/obj/screen/use_attachment
	var/obj/screen/toggle_raillight
	var/obj/screen/eject_mag
	var/obj/screen/toggle_burst
	var/obj/screen/unique_action

	var/obj/screen/zone_sel
	var/obj/screen/pull_icon
	var/obj/screen/throw_icon
	var/obj/screen/oxygen_icon
	var/obj/screen/pressure_icon
	var/obj/screen/toxin_icon
	var/obj/screen/internals
	var/obj/screen/healths
	var/obj/screen/fire_icon
	var/obj/screen/bodytemp_icon

	var/obj/screen/gun_setting_icon
	var/obj/screen/gun_item_use_icon
	var/obj/screen/gun_move_icon
	var/obj/screen/gun_run_icon

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/obj/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)

	var/obj/screen/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0


/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new

/datum/hud/Dispose()
	if(mymob.hud_used == src)
		mymob.hud_used = null
	if(static_inventory.len)
		for(var/thing in static_inventory)
			cdel(thing)
		static_inventory.Cut()
	if(toggleable_inventory.len)
		for(var/thing in toggleable_inventory)
			cdel(thing)
		toggleable_inventory.Cut()
	if(hotkeybuttons.len)
		for(var/thing in hotkeybuttons)
			cdel(thing)
		hotkeybuttons.Cut()
	if(infodisplay.len)
		for(var/thing in infodisplay)
			cdel(thing)
		infodisplay.Cut()

 	cdel(hide_actions_toggle)
	hide_actions_toggle = null

	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	alien_plasma_display = null
	locate_leader = null
	pred_power_icon = null

	module_store_icon = null

	nutrition_icon = null

	use_attachment = null
	toggle_raillight = null
	eject_mag = null
	toggle_burst = null
	unique_action = null

	zone_sel = null
	pull_icon = null
	throw_icon = null
	oxygen_icon = null
	pressure_icon = null
	toxin_icon = null
	internals = null
	healths = null
	fire_icon = null
	bodytemp_icon = null

	gun_setting_icon = null
	gun_item_use_icon = null
	gun_move_icon = null
	gun_run_icon = null

	. = ..()


/mob/proc/create_hud()
	return


//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	mymob.client.screen = list()
	mymob.client.apply_clickcatcher()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen += static_inventory
			if(toggleable_inventory.len && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			if(l_hand_hud_object)
				mymob.client.screen += l_hand_hud_object	//we want the hands to be visible
			if(r_hand_hud_object)
				mymob.client.screen += r_hand_hud_object	//we want the hands to be visible
			if(action_intent)
				mymob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistant_inventory_update()
	mymob.update_action_buttons(TRUE)
	mymob.reload_fullscreens()



/datum/hud/human/show_hud(version = 0)
	..()
	hidden_inventory_update()

/datum/hud/proc/hidden_inventory_update()
	return

/datum/hud/proc/persistant_inventory_update()
	return




//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud()
		usr << "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>"
	else
		usr << "<span class ='warning'>This mob type does not use a HUD.</span>"
