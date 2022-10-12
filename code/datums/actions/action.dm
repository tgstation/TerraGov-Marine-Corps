/*
ACTION TYPES
-ACTION_CLICK (no visuals)
-ACTION_TOGGLE (adds an active frame on activation)
-ACTION_SELECT (adds a selection frame whenever clicked)

KEYBINDINGS
-KEYBINDING_NORMAL (calls keybind_activation)
-KEYBINDING_ALTERNATE (calls alternate_ability_activation)
*/
/datum/action
	var/name = "Generic Action"
	var/desc
	var/datum/target = null
	var/obj/screen/action_button/button = null
	var/mob/owner
	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "default"
	var/background_icon = 'icons/mob/actions.dmi'
	var/background_icon_state = "template"
	/// holds a set of misc visual references to use with the overlay API
	var/list/visual_references = list()
	/// Used for keybindings , use KEYBINDING_NORMAL or KEYBINDING_ALTERNATE for keybinding_activation or alternate_ability_activate
	var/list/keybinding_signals = list()
	/// Holds offsets for said keybinds, 0 0 is bottom-left corner.
	var/list/maptext_offsets = list(
		KEYBINDING_NORMAL = list(0,0),
		KEYBINDING_ALTERNATE = list(0,22)
	)
	/// Defines what visual references will be initialized at round-start
	var/action_type = ACTION_CLICK
	/// Used for keeping track of the addition of the selected/active frames
	var/toggled = FALSE

/datum/action/New(Target)
	target = Target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/clean_action)
	button = new
	button.icon = icon(background_icon, background_icon_state)
	button.source_action = src
	button.name = name
	if(desc)
		button.desc = desc
	if(length(keybinding_signals) == 1)
		var/mutable_appearance/maptext_appearance = mutable_appearance()
		maptext_appearance.layer = ABOVE_HUD_LAYER // above selected/empowered frame
		visual_references[VREF_MUTABLE_MAPTEXT] = maptext_appearance
	else
		var/list/maptext_list = list()
		for(var/keybind_type in keybinding_signals)
			var/mutable_appearance/maptext_appearance = mutable_appearance()
			maptext_appearance.layer = ABOVE_HUD_LAYER // above selected/empowered frame
			maptext_appearance.pixel_x = maptext_offsets[keybind_type][1]
			maptext_appearance.pixel_y = maptext_offsets[keybind_type][2]
			maptext_list[keybinding_signals[keybind_type]] = maptext_appearance
		visual_references[VREF_MUTABLE_MAPTEXT] = maptext_list
	switch(action_type)
		if(ACTION_TOGGLE)
			var/mutable_appearance/active_appearance = mutable_appearance('icons/Marine/marine-weapons.dmi', "active")
			active_appearance.layer = HUD_LAYER
			active_appearance.plane = HUD_PLANE
			visual_references[VREF_MUTABLE_ACTIVE_FRAME] = active_appearance
		if(ACTION_SELECT)
			var/mutable_appearance/selected_appeareance = mutable_appearance('icons/mob/actions.dmi', "selected_frame")
			selected_appeareance.layer = HUD_LAYER + 0.1
			selected_appeareance.plane = HUD_PLANE
			visual_references[VREF_MUTABLE_SELECTED_FRAME] = selected_appeareance
	var/mutable_appearance/action_appearence =	mutable_appearance(action_icon, action_icon_state)
	action_appearence.layer = HUD_LAYER
	action_appearence.plane = HUD_PLANE
	visual_references[VREF_MUTABLE_ACTION_STATE] = action_appearence
	button.add_overlay(visual_references[VREF_MUTABLE_ACTION_STATE])

/datum/action/Destroy()
	if(owner)
		remove_action(owner)
	QDEL_NULL(button)
	target = null
	return ..()

/datum/action/proc/clean_action()
	SIGNAL_HANDLER
	qdel(src)

/datum/action/proc/should_show()
	return TRUE

/// Depending on the action type , toggles the selected/active frame to show without allowing stacking multiple overlays
/datum/action/proc/set_toggle(value)
	if(value == toggled)
		return
	if(value)
		switch(action_type)
			if(ACTION_SELECT)
				button.add_overlay(visual_references[VREF_MUTABLE_SELECTED_FRAME])
			if(ACTION_TOGGLE)
				button.add_overlay(visual_references[VREF_MUTABLE_ACTIVE_FRAME])
		toggled = TRUE
		return
	switch(action_type)
		if(ACTION_SELECT)
			button.cut_overlay(visual_references[VREF_MUTABLE_SELECTED_FRAME])
		if(ACTION_TOGGLE)
			button.cut_overlay(visual_references[VREF_MUTABLE_ACTIVE_FRAME])
	toggled = FALSE

/// A handler used to update the maptext and show the change immediately.
/datum/action/proc/update_map_text(key_string, key_signal)
	// The cutting needs to be done /BEFORE/ the string maptext gets changed
	// Since byond internally recognizes it as a different image, and doesn't cut it properly
	var/mutable_appearance/reference = null
	if(length(keybinding_signals) == 1)
		reference = visual_references[VREF_MUTABLE_ACTION_STATE]
		button.cut_overlay(reference)
		reference.maptext = MAPTEXT(key_string)
		visual_references[VREF_MUTABLE_MAPTEXT] = reference
		button.add_overlay(reference)
	else
		reference = visual_references[VREF_MUTABLE_MAPTEXT][key_signal]
		button.cut_overlay(reference)
		reference.maptext = MAPTEXT(key_string)
		visual_references[VREF_MUTABLE_MAPTEXT][key_signal] = reference
		button.add_overlay(reference)

/datum/action/proc/update_button_icon()
	if(!button)
		return
	button.name = name
	button.desc = desc
	if(action_icon && action_icon_state)
		var/mutable_appearance/action_appearence = visual_references[VREF_MUTABLE_ACTION_STATE]
		if(action_appearence.icon != action_icon || action_appearence.icon_state != action_icon_state)
			button.cut_overlay(action_appearence)
			action_appearence.icon = action_icon
			// We need to update the reference since it becomes a new appearance for byond internally
			action_appearence.icon_state = action_icon_state
			visual_references[VREF_MUTABLE_ACTION_STATE] = action_appearence
			button.add_overlay(visual_references[VREF_MUTABLE_ACTION_STATE])
	if(background_icon_state != button.icon_state)
		button.icon_state = background_icon_state
	handle_button_status_visuals()
	return TRUE

/// A proc called on update button action for  additional visuals beyond the very base
/datum/action/proc/handle_button_status_visuals()
	if(can_use_action())
		button.color = rgb(255, 255, 255, 255)
	else
		button.color = rgb(128, 0, 0, 128)

/datum/action/proc/action_activate()
	if(SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER) & COMPONENT_ACTION_BLOCK_TRIGGER)
		return FALSE
	return TRUE

///Signal Handler for main action
/datum/action/proc/keybind_activation()
	SIGNAL_HANDLER
	if(can_use_action())
		INVOKE_ASYNC(src, .proc/action_activate)
	return COMSIG_KB_ACTIVATED

///Signal Handler for alternate actions
/datum/action/proc/alternate_action_activate()
	SIGNAL_HANDLER
	return

/// Handler for what action to trigger, inherit from this and call parent before for extra actions
/datum/action/proc/keybind_trigger(mob/source, datum/keybinding/kb_type)
	SIGNAL_HANDLER
	if(kb_type.keybind_signal == keybinding_signals[KEYBINDING_NORMAL])
		return keybind_activation()
	if(kb_type.keybind_signal == keybinding_signals[KEYBINDING_ALTERNATE])
		return alternate_action_activate()

/datum/action/proc/fail_activate()
	return

/datum/action/proc/can_use_action()
	if(!QDELETED(owner))
		return TRUE

/datum/action/proc/give_action(mob/M)
	if(owner)
		if(owner == M)
			return
		remove_action(owner)
	owner = M
	owner.actions += src
	if(owner.client)
		owner.client.screen += button
	owner.update_action_buttons()
	owner.actions_by_path[type] = src
	if(keybinding_signals.len)
		for(var/type in keybinding_signals)
			var/signal = keybinding_signals[type]
			if(signal)
				RegisterSignal(owner, signal, .proc/keybind_trigger)
				var/datum/keybinding/our_kb = GLOB.keybindings_by_signal[signal]
				if(M.client && our_kb)
					update_map_text(our_kb.get_keys_formatted(M.client), signal)

	SEND_SIGNAL(M, ACTION_GIVEN)

/datum/action/proc/remove_action(mob/M)
	if(keybinding_signals.len)
		for(var/type in keybinding_signals)
			var/signal = keybinding_signals[type]
			if(owner)
				UnregisterSignal(owner, signal)
	if(M.client)
		M.client.screen -= button
	M.actions_by_path[type] = null
	M.actions -= src
	M.update_action_buttons()
	owner = null
	SEND_SIGNAL(M, ACTION_REMOVED)

//Should a AI element occasionally see if this ability should be used?
/datum/action/proc/ai_should_start_consider()
	return FALSE

//When called, see if based on the surroundings should the AI use this ability
/datum/action/proc/ai_should_use(target)
	return FALSE

//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_version == HUD_STYLE_NOHUD)
		return

	var/button_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/A in actions)
			A.button.screen_loc = null
			if(reload_screen)
				client.screen += A.button
	else
		for(var/datum/action/A in actions)
			if(A.should_show())
				A.update_button_icon()
				button_number++
				var/obj/screen/action_button/B = A.button
				B.screen_loc = B.get_button_screen_loc(button_number)
				if(reload_screen)
					client.screen += B
			else
				A.button.screen_loc = null
				if(reload_screen)
					client.screen += A.button

		if(!button_number)
			hud_used.hide_actions_toggle.screen_loc = null
			if(reload_screen)
				client.screen += hud_used.hide_actions_toggle
			return

	hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.get_button_screen_loc(button_number+1)

	if(reload_screen)
		client.screen += hud_used.hide_actions_toggle
