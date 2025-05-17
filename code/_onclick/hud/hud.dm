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

	/// Displays a HUD element that indicates the current combo, as well as what has been inputted so far.
	var/atom/movable/screen/combo/combo_display

	var/list/atom/movable/screen/ammo_hud_list = list()

	var/list/static_inventory = list() //the screen objects which are static
	var/list/toggleable_inventory = list() //the screen objects which can be hidden
	var/list/atom/movable/screen/hotkeybuttons = list() //the buttons that can be used via hotkeys
	var/list/infodisplay = list() //the screen objects that display mob info (health, alien plasma, etc...)
	/// Screen objects that never exit view.
	var/list/always_visible_inventory = list()

	var/atom/movable/screen/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = 0

	/// Assoc list of key => "plane master groups"
	/// This is normally just the main window, but it'll occasionally contain things like spyglasses windows
	var/list/datum/plane_master_group/master_groups = list()
	///Assoc list of controller groups, associated with key string group name with value of the plane master controller ref
	var/list/atom/movable/plane_master_controller/plane_master_controllers = list()

	/// Think of multiz as a stack of z levels. Each index in that stack has its own group of plane masters
	/// This variable is the plane offset our mob/client is currently "on"
	/// We use it to track what we should show/not show
	/// Goes from 0 to the max (z level stack size - 1)
	var/current_plane_offset = 0

	// List of weakrefs to objects that we add to our screen that we don't expect to DO anything
	// They typically use * in their render target. They exist solely so we can reuse them,
	// and avoid needing to make changes to all idk 300 consumers if we want to change the appearance
	var/list/asset_refs_for_reuse = list()


/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new

	var/datum/plane_master_group/main/main_group = new(PLANE_GROUP_MAIN)
	main_group.attach_to(src)

	for(var/mytype in subtypesof(/atom/movable/plane_master_controller))
		var/atom/movable/plane_master_controller/controller_instance = new mytype(null,src)
		plane_master_controllers[controller_instance.name] = controller_instance

	owner.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/see_through_darkness)

	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_plane_increase))
	RegisterSignal(mymob, COMSIG_MOB_LOGIN, PROC_REF(client_refresh))
	RegisterSignal(mymob, COMSIG_MOB_LOGOUT, PROC_REF(clear_client))
	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(update_sightflags))
	update_sightflags(mymob, mymob.sight, NONE)

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

	QDEL_NULL(combo_display)

	QDEL_LIST_ASSOC_VAL(master_groups)
	QDEL_LIST_ASSOC_VAL(plane_master_controllers)

	QDEL_LIST(ammo_hud_list)
	QDEL_LIST(always_visible_inventory)

	mymob = null
	return ..()

/datum/hud/proc/client_refresh(datum/source)
	SIGNAL_HANDLER
	var/client/client = mymob.canon_client
	RegisterSignal(client, COMSIG_CLIENT_SET_EYE, PROC_REF(on_eye_change))
	on_eye_change(null, null, client.eye)

/datum/hud/proc/clear_client(datum/source)
	SIGNAL_HANDLER
	if(mymob.canon_client)
		UnregisterSignal(mymob.canon_client, COMSIG_CLIENT_SET_EYE)

/datum/hud/proc/on_eye_change(datum/source, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER
	SEND_SIGNAL(src, COMSIG_HUD_EYE_CHANGED, old_eye, new_eye)

	if(old_eye)
		UnregisterSignal(old_eye, COMSIG_MOVABLE_Z_CHANGED)
	if(new_eye)
		// By the time logout runs, the client's eye has already changed
		// There's just no log of the old eye, so we need to override
		// :sadkirby:
		RegisterSignal(new_eye, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(eye_z_changed), override = TRUE)
	eye_z_changed(new_eye)

/datum/hud/proc/update_sightflags(datum/source, new_sight, old_sight)
	SIGNAL_HANDLER
	// If neither the old and new flags can see turfs but not objects, don't transform the turfs
	// This is to ensure parallax works when you can't see holder objects
	if(should_sight_scale(new_sight) == should_sight_scale(old_sight))
		return

	for(var/group_key as anything in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_planes_offset(src, current_plane_offset)

/datum/hud/proc/on_plane_increase(datum/source, old_max_offset, new_max_offset)
	SIGNAL_HANDLER
	//for(var/i in old_max_offset + 1 to new_max_offset)
	//	register_reuse(GLOB.starlight_objects[i + 1])
	build_plane_groups(old_max_offset + 1, new_max_offset)

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

/// Returns all the planes belonging to the passed in group key
/datum/hud/proc/get_planes_from(group_key)
	var/datum/plane_master_group/group = master_groups[group_key]
	return group.plane_masters

/// Returns the corresponding plane group datum if one exists
/datum/hud/proc/get_plane_group(key)
	return master_groups[key]

/datum/hud/proc/eye_z_changed(atom/eye)
	SIGNAL_HANDLER
	update_parallax_pref(mymob) // If your eye changes z level, so should your parallax prefs
	var/turf/eye_turf = get_turf(eye)
	if(!eye_turf)
		return
	SEND_SIGNAL(src, COMSIG_HUD_Z_CHANGED, eye_turf.z)
	var/new_offset = GET_TURF_PLANE_OFFSET(eye_turf)
	if(current_plane_offset == new_offset)
		return
	var/old_offset = current_plane_offset
	current_plane_offset = new_offset

	SEND_SIGNAL(src, COMSIG_HUD_OFFSET_CHANGED, old_offset, new_offset)
	for(var/group_key as anything in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_planes_offset(src, new_offset)

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
			if(length(always_visible_inventory))
				screenmob.client.screen += always_visible_inventory

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
			if(length(always_visible_inventory))
				screenmob.client.screen += always_visible_inventory

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
			if(length(always_visible_inventory))
				screenmob.client.screen += always_visible_inventory

	hud_version = display_hud_version
	persistent_inventory_update(screenmob)
	mymob.update_action_buttons(TRUE)
	reorganize_alerts(screenmob)
	update_interactive_emotes()
	mymob.reload_fullscreens()
	update_parallax_pref(screenmob)
	update_reuse(screenmob)

	// ensure observers get an accurate and up-to-date view
	if(!viewmob)
		plane_masters_update()
		for(var/M in mymob.observers)
			show_hud(hud_version, M)
	else if(viewmob.hud_used)
		viewmob.hud_used.plane_masters_update()

	SEND_SIGNAL(screenmob, COMSIG_MOB_HUD_REFRESHED, src)
	return TRUE

/datum/hud/proc/plane_masters_update()
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		// Plane masters are always shown to OUR mob, never to observers
		group.refresh_hud()

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
