#define MAXHUD_POSSIBLE 4
/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	///the hud version used (standard, reduced, none)
	var/hud_version = HUD_STYLE_STANDARD
	///Used for the HUD toggle (F12)
	var/hud_shown = TRUE
	///the inventory
	var/inventory_shown = TRUE
	var/show_intent_icons = 0
	///This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)
	var/hotkey_ui_hidden = FALSE

	var/atom/movable/screen/r_hand_hud_object
	var/atom/movable/screen/l_hand_hud_object
	var/atom/movable/screen/action_intent
	var/atom/movable/screen/move_intent
	var/atom/movable/screen/alien_plasma_display
	var/atom/movable/screen/locate_leader
	var/atom/movable/screen/SL_locator

	var/atom/movable/screen/module_store_icon

	var/atom/movable/screen/nutrition_icon

	var/atom/movable/screen/use_attachment
	var/atom/movable/screen/toggle_raillight
	var/atom/movable/screen/eject_mag
	var/atom/movable/screen/toggle_firemode
	var/atom/movable/screen/unique_action

	var/atom/movable/screen/zone_sel/zone_sel
	var/atom/movable/screen/pull_icon
	var/atom/movable/screen/throw_icon
	var/atom/movable/screen/rest_icon
	var/atom/movable/screen/healths
	var/atom/movable/screen/stamina_hud/staminas

	var/atom/movable/screen/gun_setting_icon
	var/atom/movable/screen/gun_item_use_icon
	var/atom/movable/screen/gun_move_icon
	var/atom/movable/screen/gun_run_icon

	var/list/atom/movable/screen/ammo_hud_list = list()

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/atom/movable/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)

	var/atom/movable/screen/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	/// Assoc list of key => "plane master groups"
	/// This is normally just the main window, but it'll occasionally contain things like spyglasses windows
	var/list/datum/plane_master_group/master_groups = list()
	/// see "appearance_flags" in the ref, assoc list of "[plane]" = object
	var/list/atom/movable/screen/plane_master/plane_masters = list()

	// List of weakrefs to objects that we add to our screen that we don't expect to DO anything
	// They typically use * in their render target. They exist solely so we can reuse them,
	// and avoid needing to make changes to all idk 300 consumers if we want to change the appearance
	var/list/asset_refs_for_reuse = list()

/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new

	for(var/mytype in subtypesof(/atom/movable/screen/plane_master) - /atom/movable/screen/plane_master/rendering_plate)
		var/atom/movable/screen/plane_master/instance = new mytype()
		plane_masters["[instance.plane]"] = instance
		instance.backdrop(mymob)

	var/datum/plane_master_group/main/main_group = new(PLANE_GROUP_MAIN)
	main_group.attach_to(src)

/datum/hud/proc/should_use_scale()
	return should_sight_scale(mymob.sight)

/datum/hud/proc/should_sight_scale(sight_flags)
	return (sight_flags & (SEE_TURFS | SEE_OBJS)) != SEE_TURFS

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null
	if(length(static_inventory))
		for(var/thing in static_inventory)
			qdel(thing)
		static_inventory.Cut()
	if(length(toggleable_inventory))
		for(var/thing in toggleable_inventory)
			qdel(thing)
		toggleable_inventory.Cut()
	if(length(hotkeybuttons))
		for(var/thing in hotkeybuttons)
			qdel(thing)
		hotkeybuttons.Cut()
	if(length(infodisplay))
		for(var/thing in infodisplay)
			qdel(thing)
		infodisplay.Cut()

	qdel(hide_actions_toggle)
	hide_actions_toggle = null

	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	alien_plasma_display = null
	locate_leader = null

	module_store_icon = null

	nutrition_icon = null

	use_attachment = null
	toggle_raillight = null
	eject_mag = null
	toggle_firemode = null
	unique_action = null

	zone_sel = null
	pull_icon = null
	throw_icon = null
	healths = null
	staminas = null

	gun_setting_icon = null
	gun_item_use_icon = null
	gun_move_icon = null
	gun_run_icon = null

	QDEL_LIST_ASSOC_VAL(plane_masters)

	QDEL_LIST(ammo_hud_list)

	mymob = null

	return ..()

/// Creates the required plane masters to fill out new z layers (because each "level" of multiz gets its own plane master set)
/datum/hud/proc/build_plane_groups(starting_offset, ending_offset)
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_plane_masters(starting_offset, ending_offset)

/// Returns the plane master that matches the input plane from the passed in group
/datum/hud/proc/get_plane_master(plane, group_key = PLANE_GROUP_MAIN)
	var/plane_key = "[plane]"
	var/datum/plane_master_group/group = master_groups[group_key]
	return group.plane_masters[plane_key]

/// Returns a list of all plane masters that match the input true plane, drawn from the passed in group (ignores z layer offsets)
/datum/hud/proc/get_true_plane_masters(true_plane, group_key = PLANE_GROUP_MAIN)
	var/list/atom/movable/screen/plane_master/masters = list()
	for(var/plane in TRUE_PLANE_TO_OFFSETS(true_plane))
		masters += get_plane_master(plane, group_key)
	return masters

/mob/proc/create_mob_hud()
	if(!client || hud_used)
		return
	var/ui_style = ui_style2icon(client.prefs.ui_style)
	var/ui_color = client.prefs.ui_style_color
	var/ui_alpha = client.prefs.ui_style_alpha
	hud_used = new hud_type(src, ui_style, ui_color, ui_alpha)
	update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)

/mob/living/carbon/xenomorph/create_mob_hud()
	. = ..()
	//Some parts require hud_used to already be set
	med_hud_set_health()
	hud_set_plasma()

//Version denotes which style should be displayed. blank or 0 means "next version"
/datum/hud/proc/show_hud(version = 0, mob/viewmob)
	if(!ismob(mymob))
		return FALSE

	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return FALSE

	screenmob.client.screen = list()
	screenmob.client.apply_clickcatcher()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = 1	//Governs behavior of other procs
			if(length(static_inventory))
				screenmob.client.screen += static_inventory
			if(length(toggleable_inventory) && inventory_shown)
				screenmob.client.screen += toggleable_inventory
			if(length(hotkeybuttons) && !hotkey_ui_hidden)
				screenmob.client.screen += hotkeybuttons
			if(length(infodisplay))
				screenmob.client.screen += infodisplay
			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = 0	//Governs behavior of other procs
			if(length(static_inventory))
				screenmob.client.screen -= static_inventory
			if(length(toggleable_inventory))
				screenmob.client.screen -= toggleable_inventory
			if(length(hotkeybuttons))
				screenmob.client.screen -= hotkeybuttons
			if(length(infodisplay))
				screenmob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			if(l_hand_hud_object)
				screenmob.client.screen += l_hand_hud_object	//we want the hands to be visible
			if(r_hand_hud_object)
				screenmob.client.screen += r_hand_hud_object	//we want the hands to be visible
			if(action_intent)
				screenmob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = 0	//Governs behavior of other procs
			if(length(static_inventory))
				screenmob.client.screen -= static_inventory
			if(length(toggleable_inventory))
				screenmob.client.screen -= toggleable_inventory
			if(length(hotkeybuttons))
				screenmob.client.screen -= hotkeybuttons
			if(length(infodisplay))
				screenmob.client.screen -= infodisplay

	hud_version = display_hud_version
	persistent_inventory_update(screenmob)
	mymob.update_action_buttons(TRUE)
	reorganize_alerts(screenmob)
	update_interactive_emotes()
	mymob.reload_fullscreens()
	update_parallax_pref(screenmob)

	// ensure observers get an accurate and up-to-date view
	if(!viewmob)
		plane_masters_update()
		for(var/M in mymob.observers)
			show_hud(hud_version, M)
	else if(viewmob.hud_used)
		viewmob.hud_used.plane_masters_update()

	return TRUE

/datum/hud/proc/plane_masters_update()
	// Plane masters are always shown to OUR mob, never to observers
	for(var/thing in plane_masters)
		var/atom/movable/screen/plane_master/PM = plane_masters[thing]
		PM.backdrop(mymob)
		mymob.client.screen += PM

/datum/hud/human/show_hud(version = 0, mob/viewmob)
	. = ..()
	if(!.)
		return
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return FALSE
	hidden_inventory_update(screenmob)


/datum/hud/proc/hidden_inventory_update(mob/viewer)
	return

/datum/hud/proc/persistent_inventory_update(mob/viewer)
	return

///Add an ammo hud to the user informing of the ammo count of ammo_owner
/datum/hud/proc/add_ammo_hud(datum/ammo_owner, list/ammo_type, ammo_count)
	if(length(ammo_hud_list) >= MAXHUD_POSSIBLE)
		return
	if(ammo_hud_list[ammo_owner])
		return
	var/atom/movable/screen/ammo/ammo_hud = new
	ammo_hud_list[ammo_owner] = ammo_hud
	ammo_hud.screen_loc = ammo_hud.ammo_screen_loc_list[length(ammo_hud_list)]
	ammo_hud.add_hud(mymob, ammo_owner)
	ammo_hud.update_hud(mymob, ammo_type, ammo_count)

///Remove the ammo hud related to the gun G from the user
/datum/hud/proc/remove_ammo_hud(datum/ammo_owner)
	var/atom/movable/screen/ammo/ammo_hud = ammo_hud_list[ammo_owner]
	if(isnull(ammo_hud))
		return
	ammo_hud.remove_hud(mymob, ammo_owner)
	qdel(ammo_hud)
	ammo_hud_list -= ammo_owner
	var/i = 1
	for(var/key in ammo_hud_list)
		ammo_hud = ammo_hud_list[key]
		ammo_hud.screen_loc = ammo_hud.ammo_screen_loc_list[i]
		i++

///Update the ammo hud related to the gun G
/datum/hud/proc/update_ammo_hud(datum/ammo_owner, list/ammo_type, ammo_count)
	var/atom/movable/screen/ammo/ammo_hud = ammo_hud_list[ammo_owner]
	ammo_hud?.update_hud(mymob, ammo_type, ammo_count)

/atom/movable/screen/action_button/MouseEntered(location, control, params)
	if (!usr.client?.prefs?.tooltips)
		return
	openToolTip(usr, src, params, title = name, content = desc)


/atom/movable/screen/action_button/MouseExited()
	if (!usr.client?.prefs?.tooltips)
		return
	closeToolTip(usr)

/datum/hud/proc/register_reuse(atom/movable/screen/reuse)
	asset_refs_for_reuse += WEAKREF(reuse)
	mymob?.client?.screen += reuse

/datum/hud/proc/unregister_reuse(atom/movable/screen/reuse)
	asset_refs_for_reuse -= WEAKREF(reuse)
	mymob?.client?.screen -= reuse

/datum/hud/proc/update_reuse(mob/show_to)
	for(var/datum/weakref/screen_ref as anything in asset_refs_for_reuse)
		var/atom/movable/screen/reuse = screen_ref.resolve()
		if(isnull(reuse))
			asset_refs_for_reuse -= screen_ref
			continue
		show_to.client?.screen += reuse

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = 1

	if(hud_used && client)
		hud_used.show_hud()
		to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")
